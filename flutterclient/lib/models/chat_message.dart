import 'package:fixnum/fixnum.dart';
import 'package:uuid/uuid.dart';
import '../constants/websocket_commands.dart';
import '../proto/agentassist.pb.dart';

/// Chat message model for the Agent Assistant
class ChatMessage {
  final String id;
  final String requestId;
  final String? serverId;
  final String? serverName;
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
  final bool repliedByCurrentUser;
  final String? repliedByNickname;
  final String? mcpClientName;
  final String? agentName;
  final String? reasoningModelName;

  ChatMessage({
    String? id,
    required this.requestId,
    this.serverId,
    this.serverName,
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
    this.repliedByCurrentUser = false,
    this.repliedByNickname,
    this.mcpClientName,
    this.agentName,
    this.reasoningModelName,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  /// Create from AskQuestionRequest
  factory ChatMessage.fromAskQuestionRequest(
    AskQuestionRequest request, {
    String? serverId,
    String? serverName,
  }) {
    return ChatMessage(
      requestId: request.iD,
      serverId: serverId,
      serverName: serverName,
      type: MessageType.question,
      timestamp: request.timestamp > Int64(0)
          ? DateTime.fromMillisecondsSinceEpoch(request.timestamp.toInt())
          : DateTime.now(),
      question: request.request.questions.isNotEmpty
          ? request.request.questions.toString()
          : request.request.question,
      projectDirectory: request.request.projectDirectory,
      mcpClientName: request.request.mcpClientName.isNotEmpty
          ? request.request.mcpClientName
          : null,
      agentName: request.request.agentName.isNotEmpty
          ? request.request.agentName
          : null,
      reasoningModelName: request.request.reasoningModelName.isNotEmpty
          ? request.request.reasoningModelName
          : null,
    );
  }

  /// Create from WorkReportRequest
  factory ChatMessage.fromWorkReportRequest(
    WorkReportRequest request, {
    String? serverId,
    String? serverName,
  }) {
    return ChatMessage(
      requestId: request.iD,
      serverId: serverId,
      serverName: serverName,
      type: MessageType.task,
      timestamp: request.timestamp > Int64(0)
          ? DateTime.fromMillisecondsSinceEpoch(request.timestamp.toInt())
          : DateTime.now(),
      summary: request.request.summary,
      projectDirectory: request.request.projectDirectory,
      mcpClientName: request.request.mcpClientName.isNotEmpty
          ? request.request.mcpClientName
          : null,
      agentName: request.request.agentName.isNotEmpty
          ? request.request.agentName
          : null,
      reasoningModelName: request.request.reasoningModelName.isNotEmpty
          ? request.request.reasoningModelName
          : null,
    );
  }

  /// Create reply message
  ChatMessage createReply(String replyText, List<ContentItem> contents) {
    return ChatMessage(
      requestId: requestId,
      serverId: serverId,
      serverName: serverName,
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
    bool? repliedByCurrentUser,
    String? repliedByNickname,
    String? serverId,
    String? serverName,
  }) {
    return ChatMessage(
      id: id,
      requestId: requestId,
      serverId: serverId ?? this.serverId,
      serverName: serverName ?? this.serverName,
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
      repliedByCurrentUser: repliedByCurrentUser ?? this.repliedByCurrentUser,
      repliedByNickname: repliedByNickname ?? this.repliedByNickname,
      mcpClientName: mcpClientName,
      agentName: agentName,
      reasoningModelName: reasoningModelName,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'serverId': serverId,
      'serverName': serverName,
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
      'repliedByCurrentUser': repliedByCurrentUser,
      'repliedByNickname': repliedByNickname,
      'mcpClientName': mcpClientName,
      'agentName': agentName,
      'reasoningModelName': reasoningModelName,
    };
  }

  /// Create from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      requestId: json['requestId'],
      serverId: json['serverId'],
      serverName: json['serverName'],
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
      repliedAt:
          json['repliedAt'] != null ? DateTime.parse(json['repliedAt']) : null,
      repliedByCurrentUser: json['repliedByCurrentUser'] ?? false,
      repliedByNickname: json['repliedByNickname'],
      mcpClientName: json['mcpClientName'],
      agentName: json['agentName'],
      reasoningModelName: json['reasoningModelName'],
    );
  }

  /// Get display title
  String get displayTitle {
    String baseTitle;
    switch (type) {
      case MessageType.question:
        baseTitle = 'AI Agent Question';
        break;
      case MessageType.task:
        baseTitle = 'Task Completion Notification';
        break;
      case MessageType.reply:
        baseTitle = 'Reply';
        break;
    }

    if (serverName != null && serverName!.trim().isNotEmpty) {
      baseTitle = '$baseTitle [$serverName]';
    }

    final fromParts = <String>[];
    if (mcpClientName != null && mcpClientName!.isNotEmpty) {
      fromParts.add(mcpClientName!);
    }

    if (agentName != null && agentName!.isNotEmpty) {
      if (reasoningModelName != null && reasoningModelName!.isNotEmpty) {
        fromParts.add('$agentName[$reasoningModelName]');
      } else {
        fromParts.add(agentName!);
      }
    } else if (reasoningModelName != null && reasoningModelName!.isNotEmpty) {
      fromParts.add('[$reasoningModelName]');
    }

    if (fromParts.isEmpty) {
      return baseTitle;
    }

    return '$baseTitle from ${fromParts.join(' | ')}';
  }

  /// Get display content
  String get displayContent {
    if (question != null) return question!;
    if (summary != null) return summary!;
    if (replyText != null) return replyText!;
    return 'No content';
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
