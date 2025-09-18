import type { WebsocketMessage, AskQuestionRequest, WorkReportRequest, AskQuestionResponse, WorkReportResponse } from '../proto/agentassist_pb';
import { WebsocketMessageSchema } from '../proto/agentassist_pb';
import { create,fromBinary, toBinary } from '@bufbuild/protobuf';
import { WebSocketCommands } from '../types/websocket';
import { APP_CONFIG } from '../config/app';

export type WebSocketMessageHandler = (message: WebsocketMessage) => void;

export interface WebSocketServiceConfig {
  url: string;
  token: string;
  nickname?: string;
  onMessage?: WebSocketMessageHandler;
  onConnect?: () => void;
  onDisconnect?: () => void;
  onError?: (error: Event) => void;
}

export class WebSocketService {
  private ws: WebSocket | null = null;
  private config: WebSocketServiceConfig;
  private clientId: string | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = APP_CONFIG.websocket.reconnectAttempts;
  private reconnectDelay = APP_CONFIG.websocket.reconnectDelay;
  private isConnecting = false;
  private isManuallyDisconnected = false;

  constructor(config: WebSocketServiceConfig) {
    this.config = config;
  }

  connect(): Promise<void> {
    return new Promise((resolve, reject) => {
      if (this.isConnecting || (this.ws && this.ws.readyState === WebSocket.OPEN)) {
        resolve();
        return;
      }

      this.isConnecting = true;
      this.isManuallyDisconnected = false;

      try {
        this.ws = new WebSocket(this.config.url);
        this.ws.binaryType = 'arraybuffer';

        this.ws.onopen = () => {
          console.log('WebSocket connected');
          this.isConnecting = false;
          this.reconnectAttempts = 0;

          // Send user login message
          this.sendUserLogin();

          if (this.config.onConnect) {
            this.config.onConnect();
          }
          resolve();
        };

        this.ws.onmessage = (event) => {
          try {
            let data: Uint8Array;
            if (event.data instanceof ArrayBuffer) {
              data = new Uint8Array(event.data);
            } else if (typeof event.data === 'string') {
              // Handle text messages (fallback)
              const textData = JSON.parse(event.data);
              const message = create(WebsocketMessageSchema, textData);
              if (this.config.onMessage) {
                this.config.onMessage(message);
              }

              return;
            } else {
              console.error('Unexpected message data type:', typeof event.data);
              return;
            }


            const message = fromBinary(WebsocketMessageSchema, data);
            if (this.config.onMessage) {
              this.config.onMessage(message);
            }
          } catch (error) {
            console.error('Error parsing WebSocket message:', error);
          }
        };

        this.ws.onclose = (event) => {
          console.log('WebSocket disconnected:', event.code, event.reason);
          this.isConnecting = false;
          this.ws = null;

          if (this.config.onDisconnect) {
            this.config.onDisconnect();
          }

          // Auto-reconnect if not manually disconnected
          if (!this.isManuallyDisconnected && this.reconnectAttempts < this.maxReconnectAttempts) {
            this.scheduleReconnect();
          }
        };

        this.ws.onerror = (error) => {
          console.error('WebSocket error:', error);
          this.isConnecting = false;

          if (this.config.onError) {
            this.config.onError(error);
          }
          reject(new Error(`WebSocket error: ${JSON.stringify(error)}`));
        };

      } catch (error) {
        this.isConnecting = false;
        reject(error instanceof Error ? error : new Error(JSON.stringify(error)));
      }
    });
  }

  disconnect(): void {
    this.isManuallyDisconnected = true;
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
  }

  private scheduleReconnect(): void {
    this.reconnectAttempts++;
    const delay = this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1);

    console.log(`Scheduling reconnect attempt ${this.reconnectAttempts} in ${delay}ms`);

    setTimeout(() => {
      if (!this.isManuallyDisconnected) {
        this.connect().catch(error => {
          console.error('Reconnect failed:', error);
        });
      }
    }, delay);
  }

  private sendMessage(message: WebsocketMessage): void {
    if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
      console.error('WebSocket is not connected');
      return;
    }

    try {
      const data = toBinary(WebsocketMessageSchema,message);
      this.ws.send(data);
    } catch (error) {
      console.error('Error sending WebSocket message:', error);
    }
  }

  sendUserLogin(): void {
    const message = create(WebsocketMessageSchema, {
      Cmd: WebSocketCommands.USER_LOGIN,
      StrParam: this.config.token,
      Nickname: this.config.nickname || ''
    });
    this.sendMessage(message);
  }

  updateNickname(nickname: string): void {
    this.config.nickname = nickname;
    // Send updated login message to server
    this.sendUserLogin();
  }

  sendAskQuestionReply(originalRequest: AskQuestionRequest, response: AskQuestionResponse): void {
    const message = create(WebsocketMessageSchema, {
      Cmd: WebSocketCommands.ASK_QUESTION_REPLY,
      AskQuestionRequest: originalRequest,
      AskQuestionResponse: response
    });
    this.sendMessage(message);
  }

  sendWorkReportReply(originalRequest: WorkReportRequest, response: WorkReportResponse): void {
    const message = create(WebsocketMessageSchema, {
      Cmd: WebSocketCommands.WORK_REPORT_REPLY,
      WorkReportRequest: originalRequest,
      WorkReportResponse: response
    });
    this.sendMessage(message);
  }

  getOnlineUsers(): void {
    const message = create(WebsocketMessageSchema, {
      Cmd: WebSocketCommands.GET_ONLINE_USERS,
      GetOnlineUsersRequest: {
        userToken: this.config.token
      }
    });
    this.sendMessage(message);
  }

  sendChatMessage(receiverClientId: string, content: string): void {
    const message = create(WebsocketMessageSchema, {
      Cmd: WebSocketCommands.SEND_CHAT_MESSAGE,
      SendChatMessageRequest: {
        receiverClientId: receiverClientId,
        content: content
      }
    });
    this.sendMessage(message);
  }

  isConnected(): boolean {
    return this.ws !== null && this.ws.readyState === WebSocket.OPEN;
  }

  getReadyState(): number {
    return this.ws ? this.ws.readyState : WebSocket.CLOSED;
  }

  getClientId(): string | null {
    return this.clientId;
  }

  setClientId(clientId: string): void {
    this.clientId = clientId;
  }
}
