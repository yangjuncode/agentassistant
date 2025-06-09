import type { WebsocketMessage, AskQuestionRequest, TaskFinishRequest, AskQuestionResponse, TaskFinishResponse } from '../proto/agentassist_pb';
import { WebsocketMessageSchema } from '../proto/agentassist_pb';
import { create } from '@bufbuild/protobuf';
import { WebSocketCommands } from '../types/websocket';
import { APP_CONFIG } from '../config/app';

export type WebSocketMessageHandler = (message: WebsocketMessage) => void;

export interface WebSocketServiceConfig {
  url: string;
  token: string;
  onMessage?: WebSocketMessageHandler;
  onConnect?: () => void;
  onDisconnect?: () => void;
  onError?: (error: Event) => void;
}

export class WebSocketService {
  private ws: WebSocket | null = null;
  private config: WebSocketServiceConfig;
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

            const message = WebsocketMessage.fromBinary(data);
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
          reject(new Error(`WebSocket error: ${error}`));
        };

      } catch (error) {
        this.isConnecting = false;
        reject(error instanceof Error ? error : new Error(String(error)));
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
      const data = WebsocketMessageSchema.toBinary(message);
      this.ws.send(data);
    } catch (error) {
      console.error('Error sending WebSocket message:', error);
    }
  }

  sendUserLogin(): void {
    const message = create(WebsocketMessageSchema, {
      Cmd: WebSocketCommands.USER_LOGIN,
      StrParam: this.config.token
    });
    this.sendMessage(message);
  }

  sendAskQuestionReply(originalRequest: AskQuestionRequest, response: AskQuestionResponse): void {
    const message = create(WebsocketMessageSchema, {
      Cmd: WebSocketCommands.ASK_QUESTION_REPLY,
      AskQuestionRequest: originalRequest,
      AskQuestionResponse: response
    });
    this.sendMessage(message);
  }

  sendTaskFinishReply(originalRequest: TaskFinishRequest, response: TaskFinishResponse): void {
    const message = create(WebsocketMessageSchema, {
      Cmd: WebSocketCommands.TASK_FINISH_REPLY,
      TaskFinishRequest: originalRequest,
      TaskFinishResponse: response
    });
    this.sendMessage(message);
  }

  isConnected(): boolean {
    return this.ws !== null && this.ws.readyState === WebSocket.OPEN;
  }

  getReadyState(): number {
    return this.ws ? this.ws.readyState : WebSocket.CLOSED;
  }
}
