import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import type {
  WebsocketMessage,
  AskQuestionRequest,
  TaskFinishRequest,
  AskQuestionResponse,
  TaskFinishResponse
} from '../proto/agentassist_pb';
import {
  AskQuestionResponseSchema,
  TaskFinishResponseSchema,
  McpResultContentSchema,
  TextContentSchema
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
  originalRequest?: AskQuestionRequest | TaskFinishRequest;
  response?: AskQuestionResponse | TaskFinishResponse;
  timeout: number | undefined;
}

export const useChatStore = defineStore('chat', () => {
  // State
  const messages = ref<ChatMessage[]>([]);
  const isConnected = ref(false);
  const isConnecting = ref(false);
  const connectionError = ref<string | null>(null);
  const userToken = ref<string>('');
  const wsService = ref<WebSocketService | null>(null);
  const isManuallyDisconnected = ref(false);

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

    const config: WebSocketServiceConfig = {
      url: serverUrl,
      token: token,
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
    if (requestId) {
      const existingMessage = messages.value.find(msg => msg.id === requestId);
      if (existingMessage) {
        existingMessage.isAnswered = true;
      }
    }

    // Add notification message
    const notificationMessage: ChatMessage = {
      id: `notification-${Date.now()}`,
      type: 'notification',
      timestamp: new Date(),
      content: message.StrParam || 'Question has been answered by another user',
      isFromAgent: false,
      projectDirectory: undefined,
      timeout: undefined
    };

    messages.value.push(notificationMessage);
  }

  function handleTaskFinishReplyNotification(message: WebsocketMessage) {
    const requestId = message.TaskFinishRequest?.ID;
    if (requestId) {
      const existingMessage = messages.value.find(msg => msg.id === requestId);
      if (existingMessage) {
        existingMessage.isAnswered = true;
      }
    }

    // Add notification message
    const notificationMessage: ChatMessage = {
      id: `notification-${Date.now()}`,
      type: 'notification',
      timestamp: new Date(),
      content: message.StrParam || 'Task has been completed by another user',
      isFromAgent: false,
      projectDirectory: undefined,
      timeout: undefined
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

    // Mark question as answered and add reply message
    questionMessage.isAnswered = true;
    questionMessage.response = response;

    const replyMessage: ChatMessage = {
      id: `reply-${Date.now()}`,
      type: 'reply',
      timestamp: new Date(),
      content: replyText,
      isFromAgent: false,
      projectDirectory: undefined,
      timeout: undefined
    };

    messages.value.push(replyMessage);
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

    // Mark task as answered and add confirmation message
    taskMessage.isAnswered = true;
    taskMessage.response = response;

    const confirmMessage: ChatMessage = {
      id: `reply-${Date.now()}`,
      type: 'reply',
      timestamp: new Date(),
      content: confirmationText,
      isFromAgent: false,
      projectDirectory: undefined,
      timeout: undefined
    };

    messages.value.push(confirmMessage);
    NotificationService.confirmationSent();
  }

  function clearMessages() {
    messages.value = [];
  }

  function setConnectionError(error: string | null) {
    connectionError.value = error;
  }

  return {
    // State
    messages: sortedMessages,
    isConnected,
    isConnecting,
    connectionError,
    userToken,

    // Computed
    pendingQuestions,
    pendingTasks,

    // Actions
    initializeWebSocket,
    disconnect,
    replyToQuestion,
    confirmTask,
    clearMessages,
    setConnectionError
  };
});
