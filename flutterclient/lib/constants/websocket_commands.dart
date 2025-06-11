/// WebSocket command constants for Agent Assistant communication
class WebSocketCommands {
  static const String askQuestion = 'AskQuestion';
  static const String taskFinish = 'TaskFinish';
  static const String askQuestionReply = 'AskQuestionReply';
  static const String taskFinishReply = 'TaskFinishReply';
  static const String userLogin = 'UserLogin';
  static const String askQuestionReplyNotification = 'AskQuestionReplyNotification';
  static const String taskFinishReplyNotification = 'TaskFinishReplyNotification';
}

/// Content type constants for McpResultContent
class ContentTypes {
  static const int text = 1;
  static const int image = 2;
  static const int audio = 3;
  static const int embeddedResource = 4;
}

/// Message status constants
enum MessageStatus {
  pending,
  replied,
  confirmed,
  error,
}

/// Message type constants
enum MessageType {
  question,
  task,
  reply,
}
