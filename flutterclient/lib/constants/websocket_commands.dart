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
  static const String forwardStateQuery = 'ForwardStateQuery';
  static const String forwardStateQueryResponse = 'ForwardStateQueryResponse';
  static const String forwardStateChanged = 'ForwardStateChanged';
  static const String forwardDeliveryError = 'ForwardDeliveryError';
}

/// Content type constants for McpResultContent
class ContentTypes {
  static const int text = 1;
  static const int image = 2;
  static const int audio = 3;
  static const int embeddedResource = 4;
}

/// Request cancellation reason codes sent by the server
class CancelReasonCodes {
  static const String timeout = 'timeout';
  static const String cancelled = 'cancelled';
  static const String initiatorDisconnected = 'initiator_disconnected';
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
