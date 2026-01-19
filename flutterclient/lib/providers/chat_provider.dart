import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:fixnum/fixnum.dart';

import '../models/chat_message.dart';
import '../models/display_online_user.dart';
import '../models/server_config.dart';
import '../services/websocket_service.dart';
import '../services/server_storage_service.dart';
import '../services/window_service.dart';
import '../services/system_input_service.dart';
import '../services/tray_service.dart';
import '../services/attachment_service.dart';
import '../constants/websocket_commands.dart';
import '../config/app_config.dart';
import '../proto/agentassist.pb.dart' as pb;

/// Chat provider for managing chat state and WebSocket communication
class ChatProvider extends ChangeNotifier {
  static final Logger _logger = Logger(level: Level.nothing);

  final ServerStorageService _serverStorageService = ServerStorageService();
  final Map<String, WebSocketService> _services = {};
  final Map<String, StreamSubscription> _messageSubscriptions = {};
  final Map<String, StreamSubscription> _connectionSubscriptions = {};
  final Map<String, StreamSubscription> _statusSubscriptions = {};
  final Map<String, StreamSubscription> _errorSubscriptions = {};

  final List<ServerConfig> _serverConfigs = [];
  final Map<String, WebSocketServiceStatus> _serverStatuses = {};
  final Map<String, String?> _serverErrors = {};

  final List<ChatMessage> _messages = [];
  final List<DisplayOnlineUser> _onlineUsers = [];
  final Map<String, List<pb.ChatMessage>> _chatMessages = {};
  // Per-message reply/confirm drafts to persist inline editor content
  final Map<String, String> _replyDrafts = {};
  // In-memory history of reply/confirm texts (newest first)
  final List<String> _replyHistory = [];

  bool _isConnected = false;
  bool _isConnecting = false;
  String? _connectionError;
  String? _currentToken;
  String? _activeChatUserKey;
  bool _autoForwardToSystemInput = false;
  bool _showOnlyPendingMessages = false;
  bool _isInputFocused = false;
  int _chatAutoSendInterval = AppConfig.defaultChatAutoSendInterval;
  String? _nickname;

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<ChatMessage> get visibleMessages => _showOnlyPendingMessages
      ? List.unmodifiable(_messages
          .where((m) => m.needsUserAction && m.status != MessageStatus.expired))
      : List.unmodifiable(_messages);
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get connectionError => _connectionError;
  List<DisplayOnlineUser> get onlineUsers => List.unmodifiable(_onlineUsers);
  String? get activeChatUserKey => _activeChatUserKey;
  String? get currentClientId {
    final connected = _services.values.where((s) => s.isConnected).toList();
    if (connected.isEmpty) return null;
    return connected.first.clientId;
  }

  List<ServerConfig> get serverConfigs => List.unmodifiable(_serverConfigs);

  int get connectedServerCount =>
      _services.values.where((s) => s.isConnected).length;

  Map<String, WebSocketServiceStatus> get serverStatuses =>
      Map.unmodifiable(_serverStatuses);

  Map<String, String?> get serverErrors => Map.unmodifiable(_serverErrors);

  bool get autoForwardToSystemInput => _autoForwardToSystemInput;
  // Expose read-only view of drafts if needed
  Map<String, String> get replyDrafts => Map.unmodifiable(_replyDrafts);
  bool get hasAnyDraft => _replyDrafts.values.any((t) => t.trim().isNotEmpty);
  List<String> get replyHistory => List.unmodifiable(_replyHistory);

  List<ChatMessage> get pendingQuestions => _messages
      .where((m) => m.type == MessageType.question && m.needsUserAction)
      .toList();

  List<ChatMessage> get pendingTasks => _messages
      .where((m) => m.type == MessageType.task && m.needsUserAction)
      .toList();

  bool get showOnlyPendingMessages => _showOnlyPendingMessages;
  bool get isInputFocused => _isInputFocused;
  int get chatAutoSendInterval => _chatAutoSendInterval;
  String? get nickname => _nickname;

  bool _isOnlineUsersVisible = true;
  bool get isOnlineUsersVisible => _isOnlineUsersVisible;

  void toggleShowOnlyPendingMessages() {
    _showOnlyPendingMessages = !_showOnlyPendingMessages;
    notifyListeners();
  }

  void setInputFocused(bool focused) {
    if (_isInputFocused != focused) {
      _isInputFocused = focused;
      notifyListeners();
    }
  }

  void toggleOnlineUsersVisibility() {
    _isOnlineUsersVisible = !_isOnlineUsersVisible;
    // When explicitly showing the bar, also reset input focus state
    // so the bar is guaranteed to be visible
    if (_isOnlineUsersVisible) {
      _isInputFocused = false;
    }
    notifyListeners();
  }

  void setOnlineUsersVisible(bool visible) {
    if (_isOnlineUsersVisible != visible) {
      _isOnlineUsersVisible = visible;
      // When explicitly showing the bar, also reset input focus state
      if (visible) {
        _isInputFocused = false;
      }
      notifyListeners();
    }
  }

  ChatProvider() {
    Future.microtask(() async {
      await _loadNickname(); // Load nickname first
      await _loadServerConfigs();
      await _loadAutoForwardSetting();
      await _loadChatSettings();
    });
    // Defer loading settings to avoid calling notifyListeners during build.
  }

  String? currentClientIdForServer(String serverId) {
    return _services[serverId]?.clientId;
  }

  String _chatKey(String serverId, String clientId) => '$serverId|$clientId';

  Future<void> _loadServerConfigs() async {
    try {
      final configs = await _serverStorageService.loadServerConfigs();
      _serverConfigs
        ..clear()
        ..addAll(configs);
      notifyListeners();
    } catch (e) {
      _logger.e('Failed to load server configs: $e');
    }
  }

  Future<void> saveServerConfigs(List<ServerConfig> configs) async {
    _serverConfigs
      ..clear()
      ..addAll(configs);
    await _serverStorageService.saveServerConfigs(_serverConfigs);
    notifyListeners();
  }

  Future<void> upsertServerConfig(ServerConfig config) async {
    final idx = _serverConfigs.indexWhere((c) => c.id == config.id);
    if (idx == -1) {
      _serverConfigs.add(config);
    } else {
      _serverConfigs[idx] = config;
    }
    await _serverStorageService.saveServerConfigs(_serverConfigs);
    notifyListeners();

    // Apply connection changes immediately
    if (config.isEnabled) {
      await _ensureConnected(config);
    } else {
      _disconnectServer(config.id);
    }
  }

  Future<void> deleteServerConfig(String serverId) async {
    _serverConfigs.removeWhere((c) => c.id == serverId);
    await _serverStorageService.saveServerConfigs(_serverConfigs);
    _disconnectServer(serverId);
    notifyListeners();
  }

  void _disconnectServer(String serverId) {
    _messageSubscriptions.remove(serverId)?.cancel();
    _connectionSubscriptions.remove(serverId)?.cancel();
    _statusSubscriptions.remove(serverId)?.cancel();
    _errorSubscriptions.remove(serverId)?.cancel();
    final svc = _services.remove(serverId);
    svc?.disconnect();

    _serverStatuses[serverId] = WebSocketServiceStatus.disconnected;
    _serverErrors.remove(serverId);

    _onlineUsers.removeWhere((u) => u.serverId == serverId);
    _chatMessages.removeWhere((k, _) => k.startsWith('$serverId|'));
    if (_activeChatUserKey != null &&
        _activeChatUserKey!.startsWith('$serverId|')) {
      _activeChatUserKey = null;
    }

    _refreshGlobalConnectionState();
    notifyListeners();
  }

  void _refreshGlobalConnectionState() {
    final anyConnecting = _serverStatuses.values.any((s) =>
        s == WebSocketServiceStatus.connecting ||
        s == WebSocketServiceStatus.reconnecting);
    final anyConnected = _services.values.any((s) => s.isConnected);

    _isConnecting = anyConnecting;
    _isConnected = anyConnected;

    if (!anyConnected) {
      _connectionError = _serverErrors.values.whereType<String>().join('\n');
    } else {
      _connectionError = null;
    }

    TrayService().setConnected(anyConnected);
  }

  /// Get a saved draft for a message
  String? getDraft(String messageId) => _replyDrafts[messageId];

  /// Set/update draft for a message
  void setDraft(String messageId, String text) {
    _replyDrafts[messageId] = text;
    // Intentionally avoid notifyListeners to prevent rebuild on each keystroke
  }

  /// Clear draft for a message
  void clearDraft(String messageId) {
    _replyDrafts.remove(messageId);
  }

  /// Add an entry to reply history (deduplicate, newest first, cap to 50)
  void _addReplyHistory(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    _replyHistory.remove(t);
    _replyHistory.insert(0, t);
    if (_replyHistory.length > 50) {
      _replyHistory.removeLast();
    }
  }

  void _attachServiceListeners(ServerConfig config, WebSocketService service) {
    _messageSubscriptions[config.id]?.cancel();
    _connectionSubscriptions[config.id]?.cancel();
    _statusSubscriptions[config.id]?.cancel();
    _errorSubscriptions[config.id]?.cancel();

    _messageSubscriptions[config.id] = service.messageStream.listen(
      (message) =>
          _handleWebSocketMessage(message, config.id, config.displayName),
      onError: (error) =>
          _logger.e('Message stream error (${config.id}): $error'),
    );

    _connectionSubscriptions[config.id] = service.connectionStream.listen(
      (connected) {
        if (connected) {
          _serverErrors.remove(config.id);
          // Fetch pending messages and online users per server when connected
          fetchPendingMessages(serverId: config.id);
          requestOnlineUsersForServer(serverId: config.id);
        }
        _refreshGlobalConnectionState();
        notifyListeners();
      },
      onError: (error) =>
          _logger.e('Connection stream error (${config.id}): $error'),
    );

    _statusSubscriptions[config.id] = service.statusStream.listen(
      (status) {
        _serverStatuses[config.id] = status;
        _refreshGlobalConnectionState();
        notifyListeners();
      },
      onError: (error) =>
          _logger.e('Status stream error (${config.id}): $error'),
    );

    _errorSubscriptions[config.id] = service.errorStream.listen(
      (error) {
        _serverErrors[config.id] = error;
        _refreshGlobalConnectionState();
        notifyListeners();
      },
      onError: (error) =>
          _logger.e('Error stream error (${config.id}): $error'),
    );
  }

  /// Connect using token + a single server URL (legacy/quick connect)
  Future<void> connect(String serverUrl, String token) async {
    _currentToken = token;
    await _saveConnectionInfo(serverUrl, token);

    // Ensure we have at least one server config (migrate legacy key if needed)
    await _loadServerConfigs();
    if (_serverConfigs.isEmpty) {
      await upsertServerConfig(ServerConfig(
        name: '',
        url: serverUrl,
        isEnabled: true,
      ));
    } else {
      // Update the first config as the "default" quick-connect target
      final first = _serverConfigs.first;
      await upsertServerConfig(first.copyWith(url: serverUrl, isEnabled: true));
    }

    // Do not clear messages; multi-server mode is additive
    await connectAll();
  }

  Future<void> _ensureConnected(ServerConfig config) async {
    if (_currentToken == null || _currentToken!.trim().isEmpty) return;
    final existing = _services[config.id];
    if (existing != null && existing.isConnected) return;
    await _connectServer(config, _currentToken!);
  }

  Future<void> _connectServer(ServerConfig config, String token) async {
    final nickname = _nickname ?? await _loadNickname();
    final service = _services.putIfAbsent(config.id, () => WebSocketService());
    _attachServiceListeners(config, service);
    _serverStatuses[config.id] = WebSocketServiceStatus.connecting;
    _serverErrors.remove(config.id);
    _refreshGlobalConnectionState();
    notifyListeners();
    await service.connect(config.url, token, nickname: nickname);
  }

  /// Connect to all enabled server configurations
  Future<void> connectAll() async {
    final prefs = await SharedPreferences.getInstance();
    _currentToken = prefs.getString(AppConfig.tokenStorageKey) ?? _currentToken;

    await _loadServerConfigs();
    final token = _currentToken;
    if (token == null || token.trim().isEmpty) {
      _logger.w('connectAll skipped: token not set');
      return;
    }

    _refreshGlobalConnectionState();
    notifyListeners();

    for (final config in _serverConfigs.where((c) => c.isEnabled)) {
      await _connectServer(config, token);
    }
  }

  /// Try to auto-connect using saved connection info
  Future<bool> tryAutoConnect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConfig.tokenStorageKey);

      if (token == null || token.trim().isEmpty) {
        _logger.d('No saved token found');
        return false;
      }

      _currentToken = token;
      await _loadServerConfigs();

      if (_serverConfigs.isEmpty) {
        _logger.d('No server configs found');
        return false;
      }

      _logger.i('Attempting auto-connection to enabled servers');
      await connectAll();
      return connectedServerCount > 0;
    } catch (error) {
      _logger.e('Auto-connection error: $error');
      return false;
    }
  }

  /// Fetch pending messages from server
  Future<void> fetchPendingMessages({String? serverId}) async {
    final targets = serverId != null
        ? <MapEntry<String, WebSocketService>>[
            if (_services.containsKey(serverId))
              MapEntry(serverId, _services[serverId]!)
          ]
        : _services.entries.toList();

    if (targets.isEmpty) {
      _logger.w('Cannot fetch pending messages: not connected');
      return;
    }

    try {
      for (final entry in targets) {
        if (!entry.value.isConnected) continue;
        _logger.i('Fetching pending messages from server: ${entry.key}');
        await entry.value.sendGetPendingMessages();
      }
    } catch (error) {
      _logger.e('Failed to fetch pending messages: $error');
      _connectionError = 'Failed to fetch messages: $error';
      notifyListeners();
    }
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    for (final id in _services.keys.toList()) {
      _disconnectServer(id);
    }
    _connectionError = null;
    notifyListeners();
  }

  /// Handle incoming WebSocket messages
  void _handleWebSocketMessage(
      pb.WebsocketMessage message, String serverId, String serverName) {
    _logger.d('Handling WebSocket message: ${message.cmd} (server=$serverId)');

    switch (message.cmd) {
      case WebSocketCommands.askQuestion:
        _handleAskQuestionMessage(message.askQuestionRequest,
            serverId: serverId, serverName: serverName);
        break;
      case WebSocketCommands.workReport:
        _handleWorkReportMessage(message.workReportRequest,
            serverId: serverId, serverName: serverName);
        break;
      case WebSocketCommands.askQuestionReplyNotification:
        _handleAskQuestionReplyNotification(message,
            serverId: serverId, serverName: serverName);
        break;
      case WebSocketCommands.workReportReplyNotification:
        _handleWorkReportReplyNotification(message,
            serverId: serverId, serverName: serverName);
        break;
      case WebSocketCommands.getPendingMessages:
        _handleGetPendingMessagesResponse(message,
            serverId: serverId, serverName: serverName);
        break;
      case WebSocketCommands.requestCancelled:
        _handleRequestCancelledNotification(message,
            serverId: serverId, serverName: serverName);
        break;
      case WebSocketCommands.getOnlineUsers:
        _handleGetOnlineUsersResponse(message,
            serverId: serverId, serverName: serverName);
        break;
      case WebSocketCommands.chatMessageNotification:
        _handleChatMessageNotification(message,
            serverId: serverId, serverName: serverName);
        break;
      case WebSocketCommands.userConnectionStatusNotification:
        _handleUserConnectionStatusNotification(message,
            serverId: serverId, serverName: serverName);
        break;
      default:
        _logger.w('Unknown message command: ${message.cmd}');
    }
  }

  /// Handle ask question message
  void _handleAskQuestionMessage(
    pb.AskQuestionRequest request, {
    required String serverId,
    required String serverName,
  }) {
    final chatMessage = ChatMessage.fromAskQuestionRequest(
      request,
      serverId: serverId,
      serverName: serverName,
    );
    _addMessage(chatMessage);
    _logger.i('Received question: ${request.request.question}');

    // Bring window to front when new message is received
    _bringWindowToFrontIfNeeded();
  }

  /// Handle work report message
  void _handleWorkReportMessage(
    pb.WorkReportRequest request, {
    required String serverId,
    required String serverName,
  }) {
    final chatMessage = ChatMessage.fromWorkReportRequest(
      request,
      serverId: serverId,
      serverName: serverName,
    );
    _addMessage(chatMessage);
    _logger.i('Received work report: ${request.request.summary}');

    // Bring window to front when new message is received
    _bringWindowToFrontIfNeeded();
  }

  /// Handle ask question reply notification
  void _handleAskQuestionReplyNotification(
    pb.WebsocketMessage message, {
    required String serverId,
    required String serverName,
  }) {
    if (!message.hasAskQuestionRequest()) {
      _logger.w('AskQuestionReplyNotification missing request data');
      return;
    }

    final request = message.askQuestionRequest;
    final requestId = request.iD;

    _logger
        .i('Ask question reply notification received for request: $requestId');

    // Extract reply content from the response
    String? replyText;
    List<ContentItem> replyContents = [];

    if (message.hasAskQuestionResponse()) {
      final response = message.askQuestionResponse;

      // Extract text content from response
      for (final content in response.contents) {
        final contentItem = ContentItem.fromMcpResultContent(content);

        // Get the first text content as reply text
        if (replyText == null &&
            contentItem.isText &&
            contentItem.text != null) {
          replyText = contentItem.text!;
          // Do not add this text item to replyContents to avoid duplication
          continue;
        }

        replyContents.add(contentItem);
      }
    }

    // Find and update the existing message
    final messageIndex = _messages
        .indexWhere((m) => m.requestId == requestId && m.serverId == serverId);
    if (messageIndex != -1) {
      final existingMessage = _messages[messageIndex];

      // Only update if the message is still pending (not already replied by this client)
      if (existingMessage.status == MessageStatus.pending) {
        final repliedByNickname =
            message.nickname.isNotEmpty ? message.nickname : 'Other user';
        final updatedMessage = existingMessage.copyWith(
          status: MessageStatus.replied,
          replyText: replyText ?? 'Replied',
          contents: replyContents,
          repliedAt: DateTime.now(),
          repliedByCurrentUser: false,
          repliedByNickname: repliedByNickname,
        );
        _messages[messageIndex] = updatedMessage;
        notifyListeners();
        _updatePendingState();
        _logger.i(
            'Updated message $requestId status to replied (by another user) with content: $replyText');

        // Show notification to user
        _showReplyNotification('Question has been replied by another user',
            replyText ?? existingMessage.question ?? '');
      }
    } else {
      _logger.w(
          'Message with request ID $requestId not found for reply notification');
    }
  }

  /// Handle work report reply notification
  void _handleWorkReportReplyNotification(
    pb.WebsocketMessage message, {
    required String serverId,
    required String serverName,
  }) {
    if (!message.hasWorkReportRequest()) {
      _logger.w('WorkReportReplyNotification missing request data');
      return;
    }

    final request = message.workReportRequest;
    final requestId = request.iD;

    _logger.i(
        'Task work report reply notification received for request: $requestId');

    // Extract reply content from the response
    String? replyText;
    List<ContentItem> replyContents = [];

    if (message.hasWorkReportResponse()) {
      final response = message.workReportResponse;

      // Extract text content from response
      for (final content in response.contents) {
        final contentItem = ContentItem.fromMcpResultContent(content);

        // Get the first text content as reply text
        if (replyText == null &&
            contentItem.isText &&
            contentItem.text != null) {
          replyText = contentItem.text!;
          // Do not add this text item to replyContents to avoid duplication
          continue;
        }

        replyContents.add(contentItem);
      }
    }

    // Find and update the existing message
    final messageIndex = _messages.indexWhere((m) => m.requestId == requestId);
    if (messageIndex != -1) {
      final existingMessage = _messages[messageIndex];

      // Only update if the message is still pending (not already confirmed by this client)
      if (existingMessage.status == MessageStatus.pending) {
        final repliedByNickname =
            message.nickname.isNotEmpty ? message.nickname : 'Other user';
        final updatedMessage = existingMessage.copyWith(
          status: MessageStatus.confirmed,
          replyText: replyText ?? 'Confirmed',
          contents: replyContents,
          repliedAt: DateTime.now(),
          repliedByCurrentUser: false,
          repliedByNickname: repliedByNickname,
        );
        _messages[messageIndex] = updatedMessage;
        notifyListeners();
        _updatePendingState();
        _logger.i(
            'Updated message $requestId status to confirmed (by another user) with content: $replyText');

        // Show notification to user
        _showReplyNotification('Work report has been confirmed by another user',
            replyText ?? existingMessage.summary ?? '');
      }
    } else {
      _logger.w(
          'Message with request ID $requestId not found for work report notification');
    }
  }

  /// Handle request cancelled notification
  void _handleRequestCancelledNotification(
    pb.WebsocketMessage message, {
    required String serverId,
    required String serverName,
  }) {
    if (!message.hasRequestCancelledNotification()) {
      _logger.w('RequestCancelled message missing notification data');
      return;
    }

    final notification = message.requestCancelledNotification;
    final requestId = notification.requestId;
    final reason = notification.reason;
    final messageType = notification.messageType;

    _logger.i('Request $requestId ($messageType) was cancelled: $reason');

    // Find and update the existing message
    final messageIndex = _messages.indexWhere((m) => m.requestId == requestId);
    if (messageIndex != -1) {
      final existingMessage = _messages[messageIndex];
      final updatedMessage = existingMessage.copyWith(
        status: MessageStatus.cancelled,
      );
      _messages[messageIndex] = updatedMessage;

      _logger.d('Updated message $requestId status to cancelled');
      notifyListeners();
      _updatePendingState();
    } else {
      _logger
          .w('Message with request ID $requestId not found for cancellation');
    }
  }

  /// Handle get pending messages response
  void _handleGetPendingMessagesResponse(
    pb.WebsocketMessage message, {
    required String serverId,
    required String serverName,
  }) {
    if (!message.hasGetPendingMessagesResponse()) {
      _logger.w('GetPendingMessages response missing response data');
      return;
    }

    final response = message.getPendingMessagesResponse;
    _logger.i('Received ${response.totalCount} pending messages from server');

    // Create a set of existing request IDs for fast lookup
    final existingKeys =
        _messages.map((m) => '${m.serverId ?? ""}|${m.requestId}').toSet();
    int addedCount = 0;

    // Convert pending messages to ChatMessage objects and merge
    for (final pendingMessage in response.pendingMessages) {
      ChatMessage? chatMessage;

      if (pendingMessage.messageType == 'AskQuestion' &&
          pendingMessage.hasAskQuestionRequest()) {
        chatMessage = ChatMessage.fromAskQuestionRequest(
          pendingMessage.askQuestionRequest,
          serverId: serverId,
          serverName: serverName,
        );
      } else if (pendingMessage.messageType == 'WorkReport' &&
          pendingMessage.hasWorkReportRequest()) {
        chatMessage = ChatMessage.fromWorkReportRequest(
          pendingMessage.workReportRequest,
          serverId: serverId,
          serverName: serverName,
        );
      }

      if (chatMessage != null) {
        // Only add if not already present
        final key = '${chatMessage.serverId ?? ""}|${chatMessage.requestId}';
        if (!existingKeys.contains(key)) {
          _messages.add(chatMessage);
          existingKeys.add(key);
          addedCount++;
          _logger.d(
              'Added pending message: ${chatMessage.id} (${chatMessage.type})');
        } else {
          _logger
              .d('Skipped existing pending message: ${chatMessage.requestId}');
        }
      } else {
        _logger.w(
            'Failed to convert pending message: ${pendingMessage.messageType}');
      }
    }

    _logger.i(
        'Successfully loaded $addedCount new pending messages. Total: ${_messages.length}');
    notifyListeners();
    _updatePendingState();
  }

  /// Reply to a question
  Future<void> replyToQuestion(
    String messageId,
    String replyText, {
    List<AttachmentItem>? attachments,
  }) async {
    final message = _messages.firstWhere((m) => m.id == messageId);
    if (message.type != MessageType.question) return;

    final serverId = message.serverId;
    if (serverId == null || !_services.containsKey(serverId)) {
      _logger.w('Cannot reply: unknown serverId for message $messageId');
      return;
    }

    try {
      // Create response
      final response = pb.AskQuestionResponse()
        ..iD = message.requestId
        ..isError = false;

      // Add text content if not empty
      if (replyText.isNotEmpty) {
        response.contents.add(
          pb.McpResultContent()
            ..type = 1 // text content type
            ..text = (pb.TextContent()
              ..type = 'text'
              ..text = replyText),
        );
      }

      // Add attachments
      if (attachments != null) {
        for (final attachment in attachments) {
          response.contents.add(attachment.toMcpResultContent());
        }
      }

      // Create original request for reply
      final originalRequest = pb.AskQuestionRequest()
        ..iD = message.requestId
        ..userToken = _currentToken ?? ''
        ..request = (pb.McpAskQuestionRequest()
          ..projectDirectory = message.projectDirectory ?? ''
          ..question = message.question ?? '');

      // Send reply
      await _services[serverId]!
          .sendAskQuestionReply(originalRequest, response);

      // Update message status
      final updatedMessage = message.copyWith(
        status: MessageStatus.replied,
        replyText: replyText,
        repliedAt: DateTime.now(),
        repliedByCurrentUser: true,
      );
      _updateMessage(updatedMessage);

      // Save to in-memory history
      _addReplyHistory(replyText);

      _logger.i('Question reply sent: $messageId');
      // Clear draft after successful send
      _replyDrafts.remove(messageId);
    } catch (error) {
      _logger.e('Failed to reply to question: $error');
      _connectionError = 'Reply failed: $error';
      notifyListeners();
    }
  }

  /// Confirm a task
  Future<void> confirmTask(
    String messageId,
    String? confirmText, {
    List<AttachmentItem>? attachments,
  }) async {
    final message = _messages.firstWhere((m) => m.id == messageId);
    if (message.type != MessageType.task) return;

    final serverId = message.serverId;
    if (serverId == null || !_services.containsKey(serverId)) {
      _logger.w('Cannot confirm: unknown serverId for message $messageId');
      return;
    }

    try {
      // Create response
      final response = pb.WorkReportResponse()
        ..iD = message.requestId
        ..isError = false;

      if (confirmText != null && confirmText.isNotEmpty) {
        response.contents.add(
          pb.McpResultContent()
            ..type = 1 // text content type
            ..text = (pb.TextContent()
              ..type = 'text'
              ..text = confirmText),
        );
      }

      // Add attachments
      if (attachments != null) {
        for (final attachment in attachments) {
          response.contents.add(attachment.toMcpResultContent());
        }
      }

      // Create original request for reply
      final originalRequest = pb.WorkReportRequest()
        ..iD = message.requestId
        ..userToken = _currentToken ?? ''
        ..request = (pb.McpWorkReportRequest()
          ..projectDirectory = message.projectDirectory ?? ''
          ..summary = message.summary ?? '');

      // Send reply
      await _services[serverId]!.sendWorkReportReply(originalRequest, response);

      // Update message status
      final updatedMessage = message.copyWith(
        status: MessageStatus.confirmed,
        replyText: confirmText,
        repliedAt: DateTime.now(),
        repliedByCurrentUser: true,
      );
      _updateMessage(updatedMessage);

      // Save to in-memory history if provided
      if (confirmText != null && confirmText.trim().isNotEmpty) {
        _addReplyHistory(confirmText);
      }

      _logger.i('Task confirmed: $messageId');
      // Clear draft after successful confirm
      _replyDrafts.remove(messageId);
    } catch (error) {
      _logger.e('Failed to confirm task: $error');
      _connectionError = 'Confirm failed: $error';
      notifyListeners();
    }
  }

  /// Add new message
  void _addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
    _updatePendingState();
  }

  /// Update existing message
  void _updateMessage(ChatMessage updatedMessage) {
    final index = _messages.indexWhere((m) => m.id == updatedMessage.id);
    if (index != -1) {
      _messages[index] = updatedMessage;
      notifyListeners();
      _updatePendingState();
    }
  }

  /// Clear all messages
  void clearMessages() {
    _messages.clear();
    notifyListeners();
    _updatePendingState();
  }

  /// Find the earliest replyable message
  ChatMessage? findEarliestReplyableMessage() {
    final replyableMessages = _messages
        .where((m) => m.needsUserAction && m.status != MessageStatus.expired)
        .toList();

    if (replyableMessages.isEmpty) {
      _logger.d('No replyable messages found');
      return null;
    }

    // Sort by timestamp to find the earliest
    replyableMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final earliest = replyableMessages.first;

    _logger.i('Found earliest replyable message: ${earliest.id}');
    return earliest;
  }

  /// Save connection info
  Future<void> _saveConnectionInfo(String serverUrl, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.serverUrlStorageKey, serverUrl);
      await prefs.setString(AppConfig.tokenStorageKey, token);
    } catch (error) {
      _logger.e('Failed to save connection info: $error');
    }
  }

  /// Load nickname from SharedPreferences
  Future<String?> _loadNickname() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nickname = prefs.getString('user_nickname');
      if (nickname != null && nickname.isNotEmpty) {
        _nickname = nickname;
        notifyListeners();
        return nickname;
      }
      // Generate and save default nickname if none exists
      final defaultNickname = _generateDefaultNickname();
      await prefs.setString('user_nickname', defaultNickname);
      _nickname = defaultNickname;
      notifyListeners();
      return defaultNickname;
    } catch (error) {
      _logger.e('Failed to load nickname: $error');
      final def = _generateDefaultNickname();
      _nickname = def;
      notifyListeners();
      return def;
    }
  }

  /// Generate a default nickname
  String _generateDefaultNickname() {
    final adjectives = [
      'Smart',
      'Diligent',
      'Friendly',
      'Active',
      'Creative',
      'Professional'
    ];
    final nouns = [
      'Developer',
      'User',
      'Assistant',
      'Partner',
      'Colleague',
      'Friend'
    ];

    final now = DateTime.now();
    final adjective = adjectives[now.millisecond % adjectives.length];
    final noun = nouns[now.second % nouns.length];
    final number = now.millisecond % 1000;

    return '$adjective$noun$number';
  }

  /// Update nickname and send to server
  Future<void> updateNickname(String nickname) async {
    try {
      // Save locally
      _nickname = nickname;
      notifyListeners();

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_nickname', nickname);

      // Update all services (even if not connected, so it's used on reconnect)
      for (final svc in _services.values) {
        await svc.updateNickname(nickname);
      }

      if (_isConnected) {
        _logger.i('Nickname updated and sent to connected servers: $nickname');
      } else {
        _logger.i(
            'Nickname saved locally, will be sent on next connection: $nickname');
      }
    } catch (error) {
      _logger.e('Failed to update nickname: $error');
      rethrow;
    }
  }

  /// Show notification for reply/confirmation by another user
  void _showReplyNotification(String title, String content) {
    _logger.i('Showing reply notification: $title - $content');

    // For now, just log the notification
    // In a full implementation, this could show a toast/snackbar
    // or trigger a system notification

    // The UI will automatically update due to notifyListeners() being called
    // when the message status is updated
  }

  /// Bring window to front if needed (desktop only)
  Future<void> _bringWindowToFrontIfNeeded() async {
    final windowService = WindowService();

    // Check if there are any pending items that actually need user attention
    final hasPendingItems =
        pendingQuestions.isNotEmpty || pendingTasks.isNotEmpty;

    if (!hasPendingItems) {
      _logger.d('No pending items, skipping bring window to front');
      return;
    }

    // Only proceed if running on desktop
    if (!windowService.isDesktop) {
      return;
    }

    try {
      // Check if window is currently focused
      final isFocused = await windowService.isFocused();
      final isVisible = await windowService.isVisible();

      if (!isFocused || !isVisible) {
        _logger.i('Window not focused or visible, bringing to front');
        // Use the more aggressive method for Linux, standard for others
        await windowService.bringToFrontAndStay();
      } else {
        _logger.d('Window already focused and visible');
      }
    } catch (error) {
      _logger.e('Failed to bring window to front: $error');
    }
  }

  /// Handle get online users response
  void _handleGetOnlineUsersResponse(
    pb.WebsocketMessage message, {
    required String serverId,
    required String serverName,
  }) {
    if (!message.hasGetOnlineUsersResponse()) {
      _logger.w('GetOnlineUsers response missing response data');
      return;
    }

    final response = message.getOnlineUsersResponse;
    _logger.i('Received ${response.totalCount} online users from server');

    // Replace online users for this server
    _onlineUsers.removeWhere((u) => u.serverId == serverId);
    for (final user in response.onlineUsers) {
      _onlineUsers.add(DisplayOnlineUser(
        serverId: serverId,
        serverName: serverName,
        user: user,
      ));
    }
    notifyListeners();

    _logger.i('Updated online users list: ${_onlineUsers.length} users');
  }

  /// Handle chat message notification
  void _handleChatMessageNotification(
    pb.WebsocketMessage message, {
    required String serverId,
    required String serverName,
  }) {
    // Use print for debug output in all modes
    print('[ChatNotification] Received ChatMessageNotification');

    if (!message.hasChatMessageNotification()) {
      print(
          '[ChatNotification] ⚠️ ChatMessageNotification missing notification data');
      return;
    }

    final notification = message.chatMessageNotification;
    final chatMessage = notification.chatMessage;

    print(
        '[ChatNotification] Message from ${chatMessage.senderNickname} (${chatMessage.senderClientId})');
    print(
        '[ChatNotification] Message content length: ${chatMessage.content.length}');
    print(
        '[ChatNotification] Message content: ${chatMessage.content.length > 100 ? chatMessage.content.substring(0, 100) + "..." : chatMessage.content}');

    // Add to chat messages map
    final senderId = chatMessage.senderClientId;
    final key = _chatKey(serverId, senderId);
    if (!_chatMessages.containsKey(key)) {
      _chatMessages[key] = [];
    }
    _chatMessages[key]!.add(chatMessage);

    notifyListeners();

    // Auto forward to system input if enabled and message is from another user
    print(
        '[ChatNotification] Auto forward setting: $_autoForwardToSystemInput');
    print(
        '[ChatNotification] Current client ID: ${_services[serverId]?.clientId}');
    print('[ChatNotification] Sender ID: $senderId');
    print(
        '[ChatNotification] Is from other user: ${senderId != _services[serverId]?.clientId}');

    if (_autoForwardToSystemInput &&
        senderId != _services[serverId]?.clientId) {
      print(
          '[ChatNotification] ✅ Conditions met for auto-forwarding, scheduling microtask...');
      // Use microtask to defer auto-forwarding until after the current build cycle
      Future.microtask(() {
        print(
            '[ChatNotification] Microtask executing, calling _autoForwardMessageToSystemInput...');
        _autoForwardMessageToSystemInput(chatMessage.content);
      });
      // Don't bring window to front when auto-forwarding is enabled
      print(
          '[ChatNotification] Auto-forwarding enabled, not bringing window to front');
    } else {
      print('[ChatNotification] ❌ Auto-forwarding conditions not met');
      if (!_autoForwardToSystemInput) {
        print('[ChatNotification] Reason: Auto-forward is disabled');
      }
      if (senderId == _services[serverId]?.clientId) {
        print('[ChatNotification] Reason: Message is from current user');
      }
      // Only bring window to front if auto-forwarding is disabled
      _bringWindowToFrontIfNeeded();
    }
  }

  /// Handle user connection status notification
  void _handleUserConnectionStatusNotification(
    pb.WebsocketMessage message, {
    required String serverId,
    required String serverName,
  }) {
    _logger.i('Received UserConnectionStatusNotification: ${message.cmd}');

    if (!message.hasUserConnectionStatusNotification()) {
      _logger.w('UserConnectionStatusNotification missing notification data');
      return;
    }

    final notification = message.userConnectionStatusNotification;
    final user = notification.user;
    final status = notification.status;

    _logger.i(
        'Processing user connection status: $status for user: ${user.nickname} (${user.clientId})');

    if (status == 'connected') {
      // Add or update user in online users list
      final existingIndex = _onlineUsers.indexWhere(
          (u) => u.serverId == serverId && u.user.clientId == user.clientId);

      if (user.clientId != currentClientIdForServer(serverId)) {
        if (existingIndex == -1) {
          _onlineUsers.add(DisplayOnlineUser(
            serverId: serverId,
            serverName: serverName,
            user: user,
          ));
          _logger.i(
              '✅ User ${user.nickname} (${user.clientId}) added to online users list');
        } else {
          // Update existing user info (nickname might have changed)
          _onlineUsers[existingIndex] = DisplayOnlineUser(
            serverId: serverId,
            serverName: serverName,
            user: user,
          );
          _logger.i(
              '✅ User ${user.nickname} (${user.clientId}) info updated in online users list');
        }
      } else {
        _logger.d('Ignoring connection status for current user');
      }
    } else if (status == 'disconnected') {
      // Remove user from online users list
      final userIndex = _onlineUsers.indexWhere(
          (u) => u.serverId == serverId && u.user.clientId == user.clientId);
      if (userIndex != -1) {
        final disconnectedUser = _onlineUsers[userIndex];
        _onlineUsers.removeAt(userIndex);
        _logger.i(
            '✅ User ${disconnectedUser.user.nickname} (${disconnectedUser.user.clientId}) removed from online users list');

        // Close chat dialog if it's open for this user
        if (_activeChatUserKey == _chatKey(serverId, user.clientId)) {
          setActiveChatUser(null);
          _logger
              .i('✅ Closed chat dialog for disconnected user ${user.clientId}');
        }
      } else {
        _logger.w(
            '⚠️ User ${user.nickname} (${user.clientId}) not found in online users list');
      }
    }

    notifyListeners();
  }

  /// Request online users from all connected servers
  Future<void> requestOnlineUsersAll() async {
    try {
      for (final entry in _services.entries) {
        if (!entry.value.isConnected) continue;
        await entry.value.sendGetOnlineUsers();
      }
      _logger.i('Online users request sent (all servers)');
    } catch (error) {
      _logger.e('Failed to request online users: $error');
    }
  }

  Future<void> requestOnlineUsersForServer({required String serverId}) async {
    final svc = _services[serverId];
    if (svc == null || !svc.isConnected) {
      _logger.w('Cannot request online users: server not connected: $serverId');
      return;
    }
    try {
      await svc.sendGetOnlineUsers();
      _logger.i('Online users request sent: $serverId');
    } catch (error) {
      _logger.e('Failed to request online users ($serverId): $error');
    }
  }

  /// Send chat message to another user
  Future<void> sendChatMessage(String receiverClientId, String content,
      {required String serverId}) async {
    await _sendChatMessageInternal(serverId, receiverClientId, content,
        notifyUI: true);
    // Chat messages don't count toward MCP pending, but keep tray in sync anyway
    _updateTrayPendingCount();
  }

  /// Send chat message without triggering UI updates (for auto-send)
  Future<void> sendChatMessageSilent(String receiverClientId, String content,
      {required String serverId}) async {
    await _sendChatMessageInternal(serverId, receiverClientId, content,
        notifyUI: false);
    _updateTrayPendingCount();
  }

  /// Internal method to send chat messages with optional UI notification
  Future<void> _sendChatMessageInternal(
      String serverId, String receiverClientId, String content,
      {required bool notifyUI}) async {
    final svc = _services[serverId];
    if (svc == null || !svc.isConnected) {
      _logger.w('Cannot send chat message: not connected');
      return;
    }

    try {
      await svc.sendChatMessage(receiverClientId, content);

      // Add message to local chat history
      final key = _chatKey(serverId, receiverClientId);
      if (!_chatMessages.containsKey(key)) {
        _chatMessages[key] = [];
      }

      final localMessage = pb.ChatMessage()
        ..messageId = 'local-${DateTime.now().millisecondsSinceEpoch}'
        ..senderClientId = svc.clientId ?? ''
        ..senderNickname = _nickname ?? 'Me'
        ..receiverClientId = receiverClientId
        ..receiverNickname = ''
        ..content = content
        ..sentAt = Int64(DateTime.now().millisecondsSinceEpoch ~/ 1000);

      _chatMessages[key]!.add(localMessage);

      // Only notify listeners if requested (for manual sends)
      if (notifyUI) {
        notifyListeners();
      }

      _logger.i(
          'Chat message sent to $receiverClientId: $content (UI notify: $notifyUI)');
    } catch (error) {
      _logger.e('Failed to send chat message: $error');
    }
  }

  /// Set active chat user
  void setActiveChatUser(String? userId) {
    _activeChatUserKey = userId;
    notifyListeners();
  }

  /// Get chat messages for a specific user
  List<pb.ChatMessage> getChatMessages(String serverId, String userId) {
    final key = _chatKey(serverId, userId);
    final messages = _chatMessages[key] ?? [];
    print(
        '[getChatMessages] serverId=$serverId, userId=$userId, key=$key, count=${messages.length}');
    print('[getChatMessages] Available keys: ${_chatMessages.keys.toList()}');
    return messages;
  }

  /// Load auto forward to system input setting
  Future<void> _loadAutoForwardSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _autoForwardToSystemInput =
          prefs.getBool('auto_forward_to_system_input') ?? false;
      _logger.i('Loaded auto forward setting: $_autoForwardToSystemInput');
    } catch (error) {
      _logger.e('Failed to load auto forward setting: $error');
      _autoForwardToSystemInput = false;
    }
  }

  /// Set auto forward to system input setting
  Future<void> setAutoForwardToSystemInput(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_forward_to_system_input', enabled);
      _autoForwardToSystemInput = enabled;
      notifyListeners();
      _logger.i('Auto forward setting updated: $enabled');
    } catch (error) {
      _logger.e('Failed to save auto forward setting: $error');
    }
  }

  /// Load chat settings
  Future<void> _loadChatSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _chatAutoSendInterval =
          prefs.getInt(AppConfig.chatAutoSendIntervalStorageKey) ??
              AppConfig.defaultChatAutoSendInterval;
      notifyListeners();
    } catch (error) {
      _logger.e('Failed to load chat settings: $error');
    }
  }

  /// Set chat auto send interval
  Future<void> setChatAutoSendInterval(int seconds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConfig.chatAutoSendIntervalStorageKey, seconds);
      _chatAutoSendInterval = seconds;
      notifyListeners();
    } catch (error) {
      _logger.e('Failed to save chat auto send interval: $error');
    }
  }

  /// Auto forward message to system input
  Future<void> _autoForwardMessageToSystemInput(String content) async {
    // Use print for debug output in all modes
    print('[AutoForward] Starting auto forward to system input');
    print('[AutoForward] Content length: ${content.length}');
    print(
        '[AutoForward] Content preview: ${content.length > 100 ? content.substring(0, 100) + "..." : content}');

    try {
      print('[AutoForward] Calling SystemInputService.sendToSystemInput...');
      final stopwatch = Stopwatch()..start();
      final success = await SystemInputService.sendToSystemInput(content);
      stopwatch.stop();
      print(
          '[AutoForward] SystemInputService.sendToSystemInput returned in ${stopwatch.elapsedMilliseconds}ms');

      if (success) {
        print(
            '[AutoForward] ✅ Successfully auto forwarded message to system input: ${content.length} characters');
      } else {
        print(
            '[AutoForward] ❌ Failed to auto forward message to system input (returned false)');
      }
    } catch (error, stackTrace) {
      print(
          '[AutoForward] ❌ Exception during auto forward to system input: $error');
      print('[AutoForward] Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    for (final sub in _messageSubscriptions.values) {
      sub.cancel();
    }
    for (final sub in _connectionSubscriptions.values) {
      sub.cancel();
    }
    for (final sub in _statusSubscriptions.values) {
      sub.cancel();
    }
    for (final sub in _errorSubscriptions.values) {
      sub.cancel();
    }
    for (final svc in _services.values) {
      svc.dispose();
    }
    // Optionally, do not destroy tray globally here (it's app-wide service)
    super.dispose();
  }

  // Update tray pending count: number of messages that need user action
  void _updateTrayPendingCount() {
    try {
      final int count = pendingQuestions.length + pendingTasks.length;
      TrayService().setPendingCount(count);
    } catch (_) {}
  }

  // Update pending-related UI state: tray count + auto-toggle of pending filter
  void _updatePendingState() {
    _updateTrayPendingCount();

    final int totalPending = pendingQuestions.length + pendingTasks.length;

    // Auto-enable filter only when there are multiple pending items
    if (totalPending > 1 && !_showOnlyPendingMessages) {
      _showOnlyPendingMessages = true;
      notifyListeners();
    }

    // Auto-disable filter when there are no pending items
    if (totalPending == 0 && _showOnlyPendingMessages) {
      _showOnlyPendingMessages = false;
      notifyListeners();
    }

    // Reset always on top when there are no pending messages
    if (totalPending == 0) {
      final windowService = WindowService();
      if (windowService.isDesktop) {
        windowService.resetAlwaysOnTop();
        _logger.d('Reset window always on top: no pending messages');
      }
    }
  }
}
