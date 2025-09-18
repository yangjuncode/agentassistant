// WebSocket command types
export const WebSocketCommands = {
  USER_LOGIN: 'UserLogin',
  ASK_QUESTION: 'AskQuestion',
  WORK_REPORT: 'WorkReport',
  ASK_QUESTION_REPLY: 'AskQuestionReply',
  WORK_REPORT_REPLY: 'WorkReportReply',
  ASK_QUESTION_REPLY_NOTIFICATION: 'AskQuestionReplyNotification',
  WORK_REPORT_REPLY_NOTIFICATION: 'WorkReportReplyNotification',
  CHECK_MESSAGE_VALIDITY: 'CheckMessageValidity',
  REQUEST_CANCELLED: 'RequestCancelled',
  GET_ONLINE_USERS: 'GetOnlineUsers',
  SEND_CHAT_MESSAGE: 'SendChatMessage',
  CHAT_MESSAGE_NOTIFICATION: 'ChatMessageNotification',
  USER_CONNECTION_STATUS_NOTIFICATION: 'UserConnectionStatusNotification'
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
