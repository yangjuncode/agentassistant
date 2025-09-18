/// WebSocket command constants for Agent Assistant communication
class WebSocketCommands {
  static const String askQuestion = 'AskQuestion';
  static const String workReport = 'WorkReport';
  static const String askQuestionReply = 'AskQuestionReply';
  static const String workReportReply = 'WorkReportReply';
  static const String userLogin = 'UserLogin';
  static const String askQuestionReplyNotification =
      'AskQuestionReplyNotification';
  static const String workReportReplyNotification =
      'WorkReportReplyNotification';
  static const String checkMessageValidity = 'CheckMessageValidity';
  static const String getPendingMessages = 'GetPendingMessages';
  static const String requestCancelled = 'RequestCancelled';
  static const String getOnlineUsers = 'GetOnlineUsers';
  static const String sendChatMessage = 'SendChatMessage';
  static const String chatMessageNotification = 'ChatMessageNotification';
  static const String userConnectionStatusNotification =
      'UserConnectionStatusNotification';
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
  expired,
  cancelled,
}

/// Message type constants
enum MessageType {
  question,
  task,
  reply,
}
