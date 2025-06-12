import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import type {
  WebsocketMessage,
  AskQuestionRequest,
  TaskFinishRequest,
  AskQuestionResponse,
  TaskFinishResponse,
  OnlineUser,
  ChatMessage as ProtoChatMessage
} from '../proto/agentassist_pb';
import {
  AskQuestionResponseSchema,
  TaskFinishResponseSchema,
  McpResultContentSchema,
  TextContentSchema,
  ChatMessageSchema
} from '../proto/agentassist_pb';
import { create } from '@bufbuild/protobuf';
import type { WebSocketServiceConfig } from '../services/websocket';
import { WebSocketService } from '../services/websocket';
import { WebSocketCommands } from '../types/websocket';
import { NotificationService } from '../services/notification';

export interface ChatMessage {
  id: string;
  type: 'question' | 'task' | 'reply' | 'notification';
  timestamp: Date;
  content: string;
  projectDirectory: string | undefined;
  isFromAgent: boolean;
  isAnswered?: boolean;
  isCancelled?: boolean;
  originalRequest?: AskQuestionRequest | TaskFinishRequest;
  response?: AskQuestionResponse | TaskFinishResponse;
  timeout: number | undefined;
  replyText?: string;
  repliedAt?: Date;
  repliedByCurrentUser?: boolean;
  repliedByNickname?: string;
}

export const useChatStore = defineStore('chat', () => {
  // State
  const messages = ref<ChatMessage[]>([]);
  const isConnected = ref(false);
  const isConnecting = ref(false);
  const connectionError = ref<string | null>(null);
  const userToken = ref<string>('');
  const userNickname = ref<string>('');
  const wsService = ref<WebSocketService | null>(null);
  const isManuallyDisconnected = ref(false);
  const onlineUsers = ref<OnlineUser[]>([]);
  const protoChatMessages = ref<Map<string, ProtoChatMessage[]>>(new Map());
  const activeChatUser = ref<string | null>(null);
  const currentClientId = ref<string | null>(null);

  // Computed
  const sortedMessages = computed(() => {
    return [...messages.value].sort((a, b) => a.timestamp.getTime() - b.timestamp.getTime());
  });

  const pendingQuestions = computed(() => {
    return messages.value.filter(msg =>
      msg.type === 'question' &&
      msg.isFromAgent &&
      !msg.isAnswered
    );
  });

  const pendingTasks = computed(() => {
    return messages.value.filter(msg =>
      msg.type === 'task' &&
      msg.isFromAgent &&
      !msg.isAnswered
    );
  });

  // Actions
  function initializeWebSocket(token: string, serverUrl: string) {
    userToken.value = token;

    // Load nickname if not already loaded
    if (!userNickname.value) {
      loadNickname();
    }

    const config: WebSocketServiceConfig = {
      url: serverUrl,
      token: token,
      nickname: userNickname.value,
      onMessage: handleWebSocketMessage,
      onConnect: () => {
        isConnected.value = true;
        isConnecting.value = false;
        connectionError.value = null;
        console.log('Connected to Agent Assistant server');
        NotificationService.connectionSuccess();
      },
      onDisconnect: () => {
        isConnected.value = false;
        isConnecting.value = false;
        console.log('Disconnected from Agent Assistant server');
        if (!isManuallyDisconnected.value) {
          NotificationService.connectionLost();
        }
      },
      onError: (error) => {
        connectionError.value = 'Connection error occurred';
        isConnecting.value = false;
        console.error('WebSocket error:', error);
        NotificationService.connectionError();
      }
    };

    wsService.value = new WebSocketService(config);
    isConnecting.value = true;

    return wsService.value.connect();
  }

  function disconnect() {
    isManuallyDisconnected.value = true;
    if (wsService.value) {
      wsService.value.disconnect();
      wsService.value = null;
    }
    isConnected.value = false;
    isConnecting.value = false;
  }

  function handleWebSocketMessage(message: WebsocketMessage) {
    console.log('Received WebSocket message:', message.Cmd);

    switch (message.Cmd) {
      case WebSocketCommands.ASK_QUESTION:
        handleAskQuestion(message.AskQuestionRequest!);
        break;
      case WebSocketCommands.TASK_FINISH:
        handleTaskFinish(message.TaskFinishRequest!);
        break;
      case WebSocketCommands.ASK_QUESTION_REPLY_NOTIFICATION:
        handleAskQuestionReplyNotification(message);
        break;
      case WebSocketCommands.TASK_FINISH_REPLY_NOTIFICATION:
        handleTaskFinishReplyNotification(message);
        break;
      case WebSocketCommands.REQUEST_CANCELLED:
        handleRequestCancelled(message);
        break;
      case WebSocketCommands.GET_ONLINE_USERS:
        handleGetOnlineUsersResponse(message);
        break;
      case WebSocketCommands.CHAT_MESSAGE_NOTIFICATION:
        handleChatMessageNotification(message);
        break;
      case WebSocketCommands.USER_LOGIN:
        handleUserLoginResponse(message);
        break;
      case WebSocketCommands.USER_CONNECTION_STATUS_NOTIFICATION:
        handleUserConnectionStatusNotification(message);
        break;
      default:
        console.log('Unknown message command:', message.Cmd);
    }
  }

  function handleAskQuestion(request: AskQuestionRequest) {
    const chatMessage: ChatMessage = {
      id: request.ID,
      type: 'question',
      timestamp: new Date(),
      content: request.Request?.Question || '',
      projectDirectory: request.Request?.ProjectDirectory,
      isFromAgent: true,
      isAnswered: false,
      originalRequest: request,
      timeout: request.Request?.Timeout
    };

    messages.value.push(chatMessage);
    NotificationService.questionReceived();
  }

  function handleTaskFinish(request: TaskFinishRequest) {
    const chatMessage: ChatMessage = {
      id: request.ID,
      type: 'task',
      timestamp: new Date(),
      content: request.Request?.Summary || '',
      projectDirectory: request.Request?.ProjectDirectory,
      isFromAgent: true,
      isAnswered: false,
      originalRequest: request,
      timeout: request.Request?.Timeout
    };

    messages.value.push(chatMessage);
    NotificationService.taskReceived();
  }

  function handleAskQuestionReplyNotification(message: WebsocketMessage) {
    const requestId = message.AskQuestionRequest?.ID;
    if (!requestId) {
      console.warn('AskQuestionReplyNotification missing request ID');
      return;
    }

    // Extract reply content from the response
    let replyText = '';
    if (message.AskQuestionResponse?.contents && message.AskQuestionResponse.contents.length > 0) {
      const firstContent = message.AskQuestionResponse.contents[0];
      if (firstContent && firstContent.text?.text) {
        replyText = firstContent.text.text;
      }
    }

    // Find and update the existing message
    const existingMessage = messages.value.find(msg => msg.id === requestId);
    if (existingMessage && !existingMessage.isAnswered) {
      existingMessage.isAnswered = true;
      existingMessage.replyText = replyText || '已回复';
      existingMessage.repliedAt = new Date();
      existingMessage.repliedByCurrentUser = false;
      existingMessage.repliedByNickname = message.Nickname || '其他用户';
      if (message.AskQuestionResponse) {
        existingMessage.response = message.AskQuestionResponse;
      }

      console.log(`Updated question ${requestId} with reply from ${existingMessage.repliedByNickname}: ${replyText}`);
    } else if (!existingMessage) {
      console.warn(`Message with request ID ${requestId} not found for reply notification`);
    }
  }

  function handleTaskFinishReplyNotification(message: WebsocketMessage) {
    const requestId = message.TaskFinishRequest?.ID;
    if (!requestId) {
      console.warn('TaskFinishReplyNotification missing request ID');
      return;
    }

    // Extract reply content from the response
    let replyText = '';
    if (message.TaskFinishResponse?.contents && message.TaskFinishResponse.contents.length > 0) {
      const firstContent = message.TaskFinishResponse.contents[0];
      if (firstContent && firstContent.text?.text) {
        replyText = firstContent.text.text;
      }
    }

    // Find and update the existing message
    const existingMessage = messages.value.find(msg => msg.id === requestId);
    if (existingMessage && !existingMessage.isAnswered) {
      existingMessage.isAnswered = true;
      existingMessage.replyText = replyText || '已确认';
      existingMessage.repliedAt = new Date();
      existingMessage.repliedByCurrentUser = false;
      existingMessage.repliedByNickname = message.Nickname || '其他用户';
      if (message.TaskFinishResponse) {
        existingMessage.response = message.TaskFinishResponse;
      }

      console.log(`Updated task ${requestId} with confirmation from ${existingMessage.repliedByNickname}: ${replyText}`);
    } else if (!existingMessage) {
      console.warn(`Message with request ID ${requestId} not found for task finish notification`);
    }
  }

  function handleRequestCancelled(message: WebsocketMessage) {
    const cancelNotification = message.RequestCancelledNotification;
    if (!cancelNotification) {
      console.error('Received RequestCancelled message without notification data');
      return;
    }

    const requestId = cancelNotification.requestId;
    const reason = cancelNotification.reason;
    const messageType = cancelNotification.messageType;

    console.log(`Request ${requestId} was cancelled: ${reason}`);

    // Find and update the existing message
    const existingMessage = messages.value.find(msg => msg.id === requestId);
    if (existingMessage) {
      existingMessage.isAnswered = true;
      existingMessage.isCancelled = true;
    }

    // Add cancellation notification message
    const notificationMessage: ChatMessage = {
      id: `cancellation-${Date.now()}`,
      type: 'notification',
      timestamp: new Date(),
      content: `${messageType} request was cancelled: ${reason}`,
      isFromAgent: false,
      projectDirectory: undefined,
      timeout: undefined,
      isCancelled: true
    };

    messages.value.push(notificationMessage);
  }

  function replyToQuestion(questionId: string, replyText: string) {
    const questionMessage = messages.value.find(msg => msg.id === questionId);
    if (!questionMessage || !questionMessage.originalRequest) {
      console.error('Question not found or missing original request');
      return;
    }

    const originalRequest = questionMessage.originalRequest as AskQuestionRequest;

    // Create response with text content
    const textContent = create(TextContentSchema, {
      type: 'text',
      text: replyText
    });

    const mcpContent = create(McpResultContentSchema, {
      type: 1, // text type
      text: textContent
    });

    const response = create(AskQuestionResponseSchema, {
      ID: questionId,
      IsError: false,
      Meta: {},
      contents: [mcpContent]
    });

    // Send reply via WebSocket
    if (wsService.value) {
      wsService.value.sendAskQuestionReply(originalRequest, response);
    }

    // Mark question as answered and store reply info
    questionMessage.isAnswered = true;
    questionMessage.response = response;
    questionMessage.replyText = replyText;
    questionMessage.repliedAt = new Date();
    questionMessage.repliedByCurrentUser = true;
    NotificationService.replySent();
  }

  function confirmTask(taskId: string, confirmationText: string = 'Task confirmed') {
    const taskMessage = messages.value.find(msg => msg.id === taskId);
    if (!taskMessage || !taskMessage.originalRequest) {
      console.error('Task not found or missing original request');
      return;
    }

    const originalRequest = taskMessage.originalRequest as TaskFinishRequest;

    // Create response with text content
    const textContent = create(TextContentSchema, {
      type: 'text',
      text: confirmationText
    });

    const mcpContent = create(McpResultContentSchema, {
      type: 1, // text type
      text: textContent
    });

    const response = create(TaskFinishResponseSchema, {
      ID: taskId,
      IsError: false,
      Meta: {},
      contents: [mcpContent]
    });

    // Send reply via WebSocket
    if (wsService.value) {
      wsService.value.sendTaskFinishReply(originalRequest, response);
    }

    // Mark task as answered and store confirmation info
    taskMessage.isAnswered = true;
    taskMessage.response = response;
    taskMessage.replyText = confirmationText;
    taskMessage.repliedAt = new Date();
    taskMessage.repliedByCurrentUser = true;
    NotificationService.confirmationSent();
  }

  function clearMessages() {
    messages.value = [];
  }

  function setConnectionError(error: string | null) {
    connectionError.value = error;
  }

  function setNickname(nickname: string) {
    userNickname.value = nickname;
    localStorage.setItem('user-nickname', nickname);

    // If connected, update nickname on server immediately
    if (wsService.value && isConnected.value) {
      wsService.value.updateNickname(nickname);
    }
  }

  function loadNickname() {
    const saved = localStorage.getItem('user-nickname');
    if (saved) {
      userNickname.value = saved;
    } else {
      // Generate default nickname
      const defaultNickname = generateDefaultNickname();
      setNickname(defaultNickname);
    }
  }

  function generateDefaultNickname(): string {
    const adjectives = ['聪明的', '勤奋的', '友善的', '活跃的', '创新的', '专业的'];
    const nouns = ['开发者', '用户', '助手', '伙伴', '同事', '朋友'];

    const adjective = adjectives[Math.floor(Math.random() * adjectives.length)];
    const noun = nouns[Math.floor(Math.random() * nouns.length)];
    const number = Math.floor(Math.random() * 1000);

    return `${adjective}${noun}${number}`;
  }

  function handleUserLoginResponse(message: WebsocketMessage) {
    if (message.UserLoginResponse) {
      const response = message.UserLoginResponse;
      if (response.success) {
        currentClientId.value = response.clientId;
        wsService.value?.setClientId(response.clientId);
        console.log('User login successful, client ID:', response.clientId);
        // Request online users after successful login
        requestOnlineUsers();
      } else {
        console.error('User login failed:', response.errorMessage);
      }
    }
  }

  function handleGetOnlineUsersResponse(message: WebsocketMessage) {
    if (message.GetOnlineUsersResponse) {
      const allUsers = message.GetOnlineUsersResponse.onlineUsers || [];
      // Filter out current user
      onlineUsers.value = allUsers.filter(user => user.clientId !== currentClientId.value);
      console.log('Updated online users:', onlineUsers.value.length);
    }
  }

  function handleChatMessageNotification(message: WebsocketMessage) {
    if (message.ChatMessageNotification?.chatMessage) {
      const chatMsg = message.ChatMessageNotification.chatMessage;
      const chatUserId = chatMsg.senderClientId;

      // Store in protobuf chat messages
      if (!protoChatMessages.value.has(chatUserId)) {
        protoChatMessages.value.set(chatUserId, []);
      }

      const userProtoChatMessages = protoChatMessages.value.get(chatUserId)!;
      userProtoChatMessages.push(chatMsg);

      console.log(`Received chat message from ${chatMsg.senderNickname}: ${chatMsg.content}`);
      NotificationService.questionReceived(); // Reuse notification for chat messages
    }
  }

  function requestOnlineUsers() {
    if (wsService.value) {
      wsService.value.getOnlineUsers();
    }
  }

  function sendChatMessage(receiverClientId: string, content: string) {
    if (wsService.value && currentClientId.value) {
      wsService.value.sendChatMessage(receiverClientId, content);

      // Add message to local protobuf chat history
      if (!protoChatMessages.value.has(receiverClientId)) {
        protoChatMessages.value.set(receiverClientId, []);
      }

      const userProtoChatMessages = protoChatMessages.value.get(receiverClientId)!;
      const localMessage = create(ChatMessageSchema, {
        messageId: `local-${Date.now()}`,
        senderClientId: currentClientId.value,
        senderNickname: userNickname.value || 'Me',
        receiverClientId: receiverClientId,
        receiverNickname: '',
        content: content,
        sentAt: BigInt(Math.floor(Date.now() / 1000))
      });
      userProtoChatMessages.push(localMessage);
    }
  }

  function setActiveChatUser(clientId: string | null) {
    activeChatUser.value = clientId;
  }

  function getChatMessages(clientId: string): ProtoChatMessage[] {
    return protoChatMessages.value.get(clientId) || [];
  }

  function handleUserConnectionStatusNotification(message: WebsocketMessage) {
    if (message.UserConnectionStatusNotification) {
      const notification = message.UserConnectionStatusNotification;
      const user = notification.user;
      const status = notification.status;

      if (status === 'connected') {
        // Add user to online users list if not already present
        const existingUserIndex = onlineUsers.value.findIndex(u => u.clientId === user?.clientId);
        if (existingUserIndex === -1 && user && user.clientId !== currentClientId.value) {
          onlineUsers.value.push(user);
          console.log(`User ${user.nickname} (${user.clientId}) connected`);
        }
      } else if (status === 'disconnected') {
        // Remove user from online users list
        const userIndex = onlineUsers.value.findIndex(u => u.clientId === user?.clientId);
        if (userIndex !== -1) {
          const disconnectedUser = onlineUsers.value[userIndex];
          onlineUsers.value.splice(userIndex, 1);
          console.log(`User ${disconnectedUser?.nickname} (${disconnectedUser?.clientId}) disconnected`);

          // Close chat dialog if it's open for this user
          if (activeChatUser.value === user?.clientId) {
            setActiveChatUser(null);
          }
        }
      }
    }
  }

  return {
    // State
    messages: sortedMessages,
    isConnected,
    isConnecting,
    connectionError,
    userToken,
    userNickname,
    onlineUsers,
    activeChatUser,
    currentClientId,

    // Computed
    pendingQuestions,
    pendingTasks,

    // Actions
    initializeWebSocket,
    disconnect,
    replyToQuestion,
    confirmTask,
    clearMessages,
    setConnectionError,
    setNickname,
    loadNickname,
    requestOnlineUsers,
    sendChatMessage,
    setActiveChatUser,
    getChatMessages
  };
});
