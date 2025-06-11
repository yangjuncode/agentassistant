import 'package:uuid/uuid.dart';
import '../constants/websocket_commands.dart';
import '../proto/agentassist.pb.dart';

/// Chat message model for the Agent Assistant
class ChatMessage {
  final String id;
  final String requestId;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? question;
  final String? summary;
  final String? projectDirectory;
  final List<ContentItem> contents;
  final Map<String, String> meta;
  final bool isError;
  final String? replyText;
  final DateTime? repliedAt;

  ChatMessage({
    String? id,
    required this.requestId,
    required this.type,
    this.status = MessageStatus.pending,
    DateTime? timestamp,
    this.question,
    this.summary,
    this.projectDirectory,
    this.contents = const [],
    this.meta = const {},
    this.isError = false,
    this.replyText,
    this.repliedAt,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  /// Create from AskQuestionRequest
  factory ChatMessage.fromAskQuestionRequest(AskQuestionRequest request) {
    return ChatMessage(
      requestId: request.iD,
      type: MessageType.question,
      question: request.request.question,
      projectDirectory: request.request.projectDirectory,
    );
  }

  /// Create from TaskFinishRequest
  factory ChatMessage.fromTaskFinishRequest(TaskFinishRequest request) {
    return ChatMessage(
      requestId: request.iD,
      type: MessageType.task,
      summary: request.request.summary,
      projectDirectory: request.request.projectDirectory,
    );
  }

  /// Create reply message
  ChatMessage createReply(String replyText, List<ContentItem> contents) {
    return ChatMessage(
      requestId: requestId,
      type: MessageType.reply,
      status: MessageStatus.replied,
      replyText: replyText,
      contents: contents,
      repliedAt: DateTime.now(),
    );
  }

  /// Copy with new status
  ChatMessage copyWith({
    MessageStatus? status,
    String? replyText,
    DateTime? repliedAt,
    List<ContentItem>? contents,
    bool? isError,
  }) {
    return ChatMessage(
      id: id,
      requestId: requestId,
      type: type,
      status: status ?? this.status,
      timestamp: timestamp,
      question: question,
      summary: summary,
      projectDirectory: projectDirectory,
      contents: contents ?? this.contents,
      meta: meta,
      isError: isError ?? this.isError,
      replyText: replyText ?? this.replyText,
      repliedAt: repliedAt ?? this.repliedAt,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'type': type.index,
      'status': status.index,
      'timestamp': timestamp.toIso8601String(),
      'question': question,
      'summary': summary,
      'projectDirectory': projectDirectory,
      'contents': contents.map((c) => c.toJson()).toList(),
      'meta': meta,
      'isError': isError,
      'replyText': replyText,
      'repliedAt': repliedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      requestId: json['requestId'],
      type: MessageType.values[json['type']],
      status: MessageStatus.values[json['status']],
      timestamp: DateTime.parse(json['timestamp']),
      question: json['question'],
      summary: json['summary'],
      projectDirectory: json['projectDirectory'],
      contents: (json['contents'] as List?)
              ?.map((c) => ContentItem.fromJson(c))
              .toList() ??
          [],
      meta: Map<String, String>.from(json['meta'] ?? {}),
      isError: json['isError'] ?? false,
      replyText: json['replyText'],
      repliedAt: json['repliedAt'] != null 
          ? DateTime.parse(json['repliedAt']) 
          : null,
    );
  }

  /// Get display title
  String get displayTitle {
    switch (type) {
      case MessageType.question:
        return 'AI Agent 问题';
      case MessageType.task:
        return '任务完成通知';
      case MessageType.reply:
        return '回复';
    }
  }

  /// Get display content
  String get displayContent {
    if (question != null) return question!;
    if (summary != null) return summary!;
    if (replyText != null) return replyText!;
    return '无内容';
  }

  /// Check if message needs user action
  bool get needsUserAction {
    return status == MessageStatus.pending && 
           (type == MessageType.question || type == MessageType.task);
  }
}

/// Content item model for different types of content
class ContentItem {
  final int type;
  final String? text;
  final String? data;
  final String? mimeType;
  final String? uri;

  ContentItem({
    required this.type,
    this.text,
    this.data,
    this.mimeType,
    this.uri,
  });

  /// Create from McpResultContent
  factory ContentItem.fromMcpResultContent(McpResultContent content) {
    switch (content.type) {
      case 1: // text
        return ContentItem(
          type: content.type,
          text: content.text.text,
        );
      case 2: // image
        return ContentItem(
          type: content.type,
          data: content.image.data,
          mimeType: content.image.mimeType,
        );
      case 3: // audio
        return ContentItem(
          type: content.type,
          data: content.audio.data,
          mimeType: content.audio.mimeType,
        );
      case 4: // embedded resource
        return ContentItem(
          type: content.type,
          uri: content.embeddedResource.uri,
          mimeType: content.embeddedResource.mimeType,
        );
      default:
        return ContentItem(type: content.type);
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
      'data': data,
      'mimeType': mimeType,
      'uri': uri,
    };
  }

  /// Create from JSON
  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      type: json['type'],
      text: json['text'],
      data: json['data'],
      mimeType: json['mimeType'],
      uri: json['uri'],
    );
  }

  /// Check if content is text
  bool get isText => type == 1;

  /// Check if content is image
  bool get isImage => type == 2;

  /// Check if content is audio
  bool get isAudio => type == 3;

  /// Check if content is embedded resource
  bool get isEmbeddedResource => type == 4;
}
