// Types for Agent Assistant protobuf messages

export interface TextContent {
  type: string;
  text: string;
}

export interface ImageContent {
  type: string;
  data: string;
  mimeType: string;
}

export interface AudioContent {
  type: string;
  data: string;
  mimeType: string;
}

export interface EmbeddedResource {
  type: string;
  uri: string;
  mimeType: string;
  data: Uint8Array;
}

export interface McpResultContent {
  type: number; // 1: text, 2: image, 3: audio, 4: embedded resource
  text?: TextContent;
  image?: ImageContent;
  audio?: AudioContent;
  embeddedResource?: EmbeddedResource;
}

export interface McpAskQuestionRequest {
  projectDirectory: string;
  question: string;
  timeout: number;
}

export interface AskQuestionRequest {
  ID: string;
  userToken: string;
  request: McpAskQuestionRequest;
}

export interface AskQuestionResponse {
  ID: string;
  isError: boolean;
  meta: Record<string, string>;
  contents: McpResultContent[];
}

export interface McpTaskFinishRequest {
  projectDirectory: string;
  summary: string;
  timeout: number;
}

export interface TaskFinishRequest {
  ID: string;
  userToken: string;
  request: McpTaskFinishRequest;
}

export interface TaskFinishResponse {
  ID: string;
  isError: boolean;
  meta: Record<string, string>;
  contents: McpResultContent[];
}

export interface WebSocketMessage {
  cmd: string;
  askQuestionRequest?: AskQuestionRequest;
  taskFinishRequest?: TaskFinishRequest;
  strParam?: string;
}

// UI Types
export interface RequestItem {
  id: string;
  type: 'ask_question' | 'task_finish';
  projectDirectory: string;
  question?: string;
  summary?: string;
  timeout: number;
  timestamp: Date;
}

export interface ResponseItem {
  id: string;
  isError: boolean;
  contents: McpResultContent[];
  timestamp: Date;
}
