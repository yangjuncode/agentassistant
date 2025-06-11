// WebSocket command types
export const WebSocketCommands = {
  USER_LOGIN: 'UserLogin',
  ASK_QUESTION: 'AskQuestion',
  TASK_FINISH: 'TaskFinish',
  ASK_QUESTION_REPLY: 'AskQuestionReply',
  TASK_FINISH_REPLY: 'TaskFinishReply',
  ASK_QUESTION_REPLY_NOTIFICATION: 'AskQuestionReplyNotification',
  TASK_FINISH_REPLY_NOTIFICATION: 'TaskFinishReplyNotification',
  CHECK_MESSAGE_VALIDITY: 'CheckMessageValidity',
  REQUEST_CANCELLED: 'RequestCancelled'
} as const;

export type WebSocketCommand = typeof WebSocketCommands[keyof typeof WebSocketCommands];

// Connection states
export enum ConnectionState {
  DISCONNECTED = 'disconnected',
  CONNECTING = 'connecting',
  CONNECTED = 'connected',
  RECONNECTING = 'reconnecting',
  ERROR = 'error'
}

// Message content types
export enum ContentType {
  TEXT = 1,
  IMAGE = 2,
  AUDIO = 3,
  EMBEDDED_RESOURCE = 4
}

// Utility types
export interface ServerConfig {
  host: string;
  port: number;
  protocol: 'ws' | 'wss';
}

export interface TokenInfo {
  token: string;
  isValid: boolean;
  expiresAt?: Date;
}
