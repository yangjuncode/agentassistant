import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:fixnum/fixnum.dart';

import '../models/chat_message.dart';
import '../services/websocket_service.dart';
import '../services/window_service.dart';
import '../services/system_input_service.dart';
import '../services/tray_service.dart';
import '../constants/websocket_commands.dart';
import '../config/app_config.dart';
import '../proto/agentassist.pb.dart' as pb;

/// Chat provider for managing chat state and WebSocket communication
class ChatProvider extends ChangeNotifier {
  static final Logger _logger = Logger();

  final WebSocketService _webSocketService = WebSocketService();
  final List<ChatMessage> _messages = [];
  final List<pb.OnlineUser> _onlineUsers = [];
  final Map<String, List<pb.ChatMessage>> _chatMessages = {};
  // Per-message reply/confirm drafts to persist inline editor content
  final Map<String, String> _replyDrafts = {};

  bool _isConnected = false;
  bool _isConnecting = false;
  String? _connectionError;
  String? _currentToken;
  String? _activeChatUserId;
  bool _autoForwardToSystemInput = false;

  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _errorSubscription;

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get connectionError => _connectionError;
  List<pb.OnlineUser> get onlineUsers => List.unmodifiable(_onlineUsers);
  String? get activeChatUserId => _activeChatUserId;
  String? get currentClientId => _webSocketService.clientId;
  bool get autoForwardToSystemInput => _autoForwardToSystemInput;
  // Expose read-only view of drafts if needed
  Map<String, String> get replyDrafts => Map.unmodifiable(_replyDrafts);
  bool get hasAnyDraft => _replyDrafts.values.any((t) => t.trim().isNotEmpty);

  List<ChatMessage> get pendingQuestions => _messages
      .where((m) => m.type == MessageType.question && m.needsUserAction)
      .toList();

  List<ChatMessage> get pendingTasks => _messages
      .where((m) => m.type == MessageType.task && m.needsUserAction)
      .toList();

  ChatProvider() {
    _initializeWebSocketListeners();
    // Defer loading settings to avoid calling notifyListeners during build.
    Future.microtask(() => _loadAutoForwardSetting());
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

  /// Initialize WebSocket event listeners
  void _initializeWebSocketListeners() {
    _messageSubscription = _webSocketService.messageStream.listen(
      _handleWebSocketMessage,
      onError: (error) => _logger.e('Message stream error: $error'),
    );

    _connectionSubscription = _webSocketService.connectionStream.listen(
      (connected) {
        _isConnected = connected;
        _isConnecting = false;
        // Update tray connection status
        TrayService().setConnected(connected);
        if (connected) {
          _connectionError = null;
          // Fetch pending messages when connected
          fetchPendingMessages();
          // Request online users when connected
          requestOnlineUsers();
        }
        notifyListeners();
      },
      onError: (error) => _logger.e('Connection stream error: $error'),
    );

    _errorSubscription = _webSocketService.errorStream.listen(
      (error) {
        _connectionError = error;
        _isConnecting = false;
        notifyListeners();
      },
      onError: (error) => _logger.e('Error stream error: $error'),
    );
  }

  /// Connect to WebSocket server
  Future<void> connect(String serverUrl, String token) async {
    if (_isConnecting || _isConnected) return;

    _isConnecting = true;
    _connectionError = null;
    _currentToken = token;
    notifyListeners();

    try {
      // Load nickname before connecting
      final nickname = await _loadNickname();
      await _webSocketService.connect(serverUrl, token, nickname: nickname);
      await _saveConnectionInfo(serverUrl, token);
    } catch (error) {
      _connectionError = '连接失败: $error';
      _isConnecting = false;
      notifyListeners();
    }
  }

  /// Try to auto-connect using saved connection info
  Future<bool> tryAutoConnect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serverUrl = prefs.getString(AppConfig.serverUrlStorageKey);
      final token = prefs.getString(AppConfig.tokenStorageKey);

      if (serverUrl != null && token != null) {
        _logger.i('Attempting auto-connection to: $serverUrl');
        await connect(serverUrl, token);

        // Wait a bit to see if connection succeeds
        await Future.delayed(const Duration(seconds: 2));

        if (_isConnected) {
          _logger.i('Auto-connection successful');
          // Fetch pending messages after successful connection
          await fetchPendingMessages();
          // Request online users after successful connection
          await requestOnlineUsers();
          return true;
        } else {
          _logger.w('Auto-connection failed: not connected after timeout');
          return false;
        }
      } else {
        _logger.d('No saved connection info found');
        return false;
      }
    } catch (error) {
      _logger.e('Auto-connection error: $error');
      return false;
    }
  }

  /// Fetch pending messages from server
  Future<void> fetchPendingMessages() async {
    if (!_isConnected) {
      _logger.w('Cannot fetch pending messages: not connected');
      return;
    }

    try {
      _logger.i('Fetching pending messages from server...');

      // Clear existing messages since we're getting fresh data from server
      _messages.clear();

      // Send request to get pending messages
      await _webSocketService.sendGetPendingMessages();

      _logger.i('Pending messages request sent');
    } catch (error) {
      _logger.e('Failed to fetch pending messages: $error');
      _connectionError = '获取消息失败: $error';
      notifyListeners();
    }
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    _webSocketService.disconnect();
    _isConnected = false;
    _isConnecting = false;
    _connectionError = null;
    notifyListeners();
  }

  /// Handle incoming WebSocket messages
  void _handleWebSocketMessage(pb.WebsocketMessage message) {
    _logger.d('Handling WebSocket message: ${message.cmd}');

    switch (message.cmd) {
      case WebSocketCommands.askQuestion:
        _handleAskQuestionMessage(message.askQuestionRequest);
        break;
      case WebSocketCommands.taskFinish:
        _handleTaskFinishMessage(message.taskFinishRequest);
        break;
      case WebSocketCommands.askQuestionReplyNotification:
        _handleAskQuestionReplyNotification(message);
        break;
      case WebSocketCommands.taskFinishReplyNotification:
        _handleTaskFinishReplyNotification(message);
        break;
      case WebSocketCommands.getPendingMessages:
        _handleGetPendingMessagesResponse(message);
        break;
      case WebSocketCommands.requestCancelled:
        _handleRequestCancelledNotification(message);
        break;
      case WebSocketCommands.getOnlineUsers:
        _handleGetOnlineUsersResponse(message);
        break;
      case WebSocketCommands.chatMessageNotification:
        _handleChatMessageNotification(message);
        break;
      case WebSocketCommands.userConnectionStatusNotification:
        _handleUserConnectionStatusNotification(message);
        break;
      default:
        _logger.w('Unknown message command: ${message.cmd}');
    }
  }

  /// Handle ask question message
  void _handleAskQuestionMessage(pb.AskQuestionRequest request) {
    final chatMessage = ChatMessage.fromAskQuestionRequest(request);
    _addMessage(chatMessage);
    _logger.i('Received question: ${request.request.question}');

    // Bring window to front when new message is received
    _bringWindowToFrontIfNeeded();
  }

  /// Handle task finish message
  void _handleTaskFinishMessage(pb.TaskFinishRequest request) {
    final chatMessage = ChatMessage.fromTaskFinishRequest(request);
    _addMessage(chatMessage);
    _logger.i('Received task finish: ${request.request.summary}');

    // Bring window to front when new message is received
    _bringWindowToFrontIfNeeded();
  }

  /// Handle ask question reply notification
  void _handleAskQuestionReplyNotification(pb.WebsocketMessage message) {
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
        replyContents.add(contentItem);

        // Get the first text content as reply text
        if (replyText == null &&
            contentItem.isText &&
            contentItem.text != null) {
          replyText = contentItem.text!;
        }
      }
    }

    // Find and update the existing message
    final messageIndex = _messages.indexWhere((m) => m.requestId == requestId);
    if (messageIndex != -1) {
      final existingMessage = _messages[messageIndex];

      // Only update if the message is still pending (not already replied by this client)
      if (existingMessage.status == MessageStatus.pending) {
        final repliedByNickname =
            message.nickname.isNotEmpty ? message.nickname : '其他用户';
        final updatedMessage = existingMessage.copyWith(
          status: MessageStatus.replied,
          replyText: replyText ?? '已回复',
          contents: replyContents,
          repliedAt: DateTime.now(),
          repliedByCurrentUser: false,
          repliedByNickname: repliedByNickname,
        );
        _messages[messageIndex] = updatedMessage;
        notifyListeners();
        _logger.i(
            'Updated message $requestId status to replied (by another user) with content: $replyText');

        // Show notification to user
        _showReplyNotification(
            '问题已被其他用户回复', replyText ?? existingMessage.question ?? '');
      }
    } else {
      _logger.w(
          'Message with request ID $requestId not found for reply notification');
    }
  }

  /// Handle task finish reply notification
  void _handleTaskFinishReplyNotification(pb.WebsocketMessage message) {
    if (!message.hasTaskFinishRequest()) {
      _logger.w('TaskFinishReplyNotification missing request data');
      return;
    }

    final request = message.taskFinishRequest;
    final requestId = request.iD;

    _logger
        .i('Task finish reply notification received for request: $requestId');

    // Extract reply content from the response
    String? replyText;
    List<ContentItem> replyContents = [];

    if (message.hasTaskFinishResponse()) {
      final response = message.taskFinishResponse;

      // Extract text content from response
      for (final content in response.contents) {
        final contentItem = ContentItem.fromMcpResultContent(content);
        replyContents.add(contentItem);

        // Get the first text content as reply text
        if (replyText == null &&
            contentItem.isText &&
            contentItem.text != null) {
          replyText = contentItem.text!;
        }
      }
    }

    // Find and update the existing message
    final messageIndex = _messages.indexWhere((m) => m.requestId == requestId);
    if (messageIndex != -1) {
      final existingMessage = _messages[messageIndex];

      // Only update if the message is still pending (not already confirmed by this client)
      if (existingMessage.status == MessageStatus.pending) {
        final repliedByNickname =
            message.nickname.isNotEmpty ? message.nickname : '其他用户';
        final updatedMessage = existingMessage.copyWith(
          status: MessageStatus.confirmed,
          replyText: replyText ?? '已确认',
          contents: replyContents,
          repliedAt: DateTime.now(),
          repliedByCurrentUser: false,
          repliedByNickname: repliedByNickname,
        );
        _messages[messageIndex] = updatedMessage;
        notifyListeners();
        _logger.i(
            'Updated message $requestId status to confirmed (by another user) with content: $replyText');

        // Show notification to user
        _showReplyNotification(
            '任务已被其他用户确认', replyText ?? existingMessage.summary ?? '');
      }
    } else {
      _logger.w(
          'Message with request ID $requestId not found for task finish notification');
    }
  }

  /// Handle request cancelled notification
  void _handleRequestCancelledNotification(pb.WebsocketMessage message) {
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
      notifyListeners();
      _logger.d('Updated message $requestId status to cancelled');
    } else {
      _logger
          .w('Message with request ID $requestId not found for cancellation');
    }
  }

  /// Handle get pending messages response
  void _handleGetPendingMessagesResponse(pb.WebsocketMessage message) {
    if (!message.hasGetPendingMessagesResponse()) {
      _logger.w('GetPendingMessages response missing response data');
      return;
    }

    final response = message.getPendingMessagesResponse;
    _logger.i('Received ${response.totalCount} pending messages from server');

    // Clear existing messages
    _messages.clear();

    // Convert pending messages to ChatMessage objects
    for (final pendingMessage in response.pendingMessages) {
      ChatMessage? chatMessage;

      if (pendingMessage.messageType == 'AskQuestion' &&
          pendingMessage.hasAskQuestionRequest()) {
        chatMessage = ChatMessage.fromAskQuestionRequest(
          pendingMessage.askQuestionRequest,
        );
      } else if (pendingMessage.messageType == 'TaskFinish' &&
          pendingMessage.hasTaskFinishRequest()) {
        chatMessage = ChatMessage.fromTaskFinishRequest(
          pendingMessage.taskFinishRequest,
        );
      }

      if (chatMessage != null) {
        _messages.add(chatMessage);
        _logger.d(
            'Added pending message: ${chatMessage.id} (${chatMessage.type})');
      } else {
        _logger.w(
            'Failed to convert pending message: ${pendingMessage.messageType}');
      }
    }

    _logger.i('Successfully loaded ${_messages.length} pending messages');
    notifyListeners();
    _updateTrayPendingCount();
  }

  /// Reply to a question
  Future<void> replyToQuestion(String messageId, String replyText) async {
    final message = _messages.firstWhere((m) => m.id == messageId);
    if (message.type != MessageType.question) return;

    try {
      // Create response
      final response = pb.AskQuestionResponse()
        ..iD = message.requestId
        ..isError = false
        ..contents.addAll([
          pb.McpResultContent()
            ..type = 1 // text content type
            ..text = (pb.TextContent()
              ..type = 'text'
              ..text = replyText),
        ]);

      // Create original request for reply
      final originalRequest = pb.AskQuestionRequest()
        ..iD = message.requestId
        ..userToken = _currentToken ?? ''
        ..request = (pb.McpAskQuestionRequest()
          ..projectDirectory = message.projectDirectory ?? ''
          ..question = message.question ?? '');

      // Send reply
      await _webSocketService.sendAskQuestionReply(originalRequest, response);

      // Update message status
      final updatedMessage = message.copyWith(
        status: MessageStatus.replied,
        replyText: replyText,
        repliedAt: DateTime.now(),
        repliedByCurrentUser: true,
      );
      _updateMessage(updatedMessage);

      _logger.i('Question reply sent: $messageId');
      // Clear draft after successful send
      _replyDrafts.remove(messageId);
    } catch (error) {
      _logger.e('Failed to reply to question: $error');
      _connectionError = '回复失败: $error';
      notifyListeners();
    }
  }

  /// Confirm a task
  Future<void> confirmTask(String messageId, [String? confirmText]) async {
    final message = _messages.firstWhere((m) => m.id == messageId);
    if (message.type != MessageType.task) return;

    try {
      // Create response
      final response = pb.TaskFinishResponse()
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

      // Create original request for reply
      final originalRequest = pb.TaskFinishRequest()
        ..iD = message.requestId
        ..userToken = _currentToken ?? ''
        ..request = (pb.McpTaskFinishRequest()
          ..projectDirectory = message.projectDirectory ?? ''
          ..summary = message.summary ?? '');

      // Send reply
      await _webSocketService.sendTaskFinishReply(originalRequest, response);

      // Update message status
      final updatedMessage = message.copyWith(
        status: MessageStatus.confirmed,
        replyText: confirmText,
        repliedAt: DateTime.now(),
        repliedByCurrentUser: true,
      );
      _updateMessage(updatedMessage);

      _logger.i('Task confirmed: $messageId');
      // Clear draft after successful confirm
      _replyDrafts.remove(messageId);
    } catch (error) {
      _logger.e('Failed to confirm task: $error');
      _connectionError = '确认失败: $error';
      notifyListeners();
    }
  }

  /// Add new message
  void _addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
    _updateTrayPendingCount();
  }

  /// Update existing message
  void _updateMessage(ChatMessage updatedMessage) {
    final index = _messages.indexWhere((m) => m.id == updatedMessage.id);
    if (index != -1) {
      _messages[index] = updatedMessage;
      notifyListeners();
      _updateTrayPendingCount();
    }
  }

  /// Clear all messages
  void clearMessages() {
    _messages.clear();
    notifyListeners();
    _updateTrayPendingCount();
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
        return nickname;
      }
      // Generate and save default nickname if none exists
      final defaultNickname = _generateDefaultNickname();
      await prefs.setString('user_nickname', defaultNickname);
      return defaultNickname;
    } catch (error) {
      _logger.e('Failed to load nickname: $error');
      return _generateDefaultNickname();
    }
  }

  /// Generate a default nickname
  String _generateDefaultNickname() {
    final adjectives = ['聪明的', '勤奋的', '友善的', '活跃的', '创新的', '专业的'];
    final nouns = ['开发者', '用户', '助手', '伙伴', '同事', '朋友'];

    final now = DateTime.now();
    final adjective = adjectives[now.millisecond % adjectives.length];
    final noun = nouns[now.second % nouns.length];
    final number = now.millisecond % 1000;

    return '$adjective$noun$number';
  }

  /// Update nickname and send to server
  Future<void> updateNickname(String nickname) async {
    try {
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_nickname', nickname);

      // If connected, update nickname on server immediately
      if (_isConnected) {
        await _webSocketService.updateNickname(nickname);
        _logger.i('Nickname updated and sent to server: $nickname');
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
  void _handleGetOnlineUsersResponse(pb.WebsocketMessage message) {
    if (!message.hasGetOnlineUsersResponse()) {
      _logger.w('GetOnlineUsers response missing response data');
      return;
    }

    final response = message.getOnlineUsersResponse;
    _logger.i('Received ${response.totalCount} online users from server');

    // Update online users list
    _onlineUsers.clear();
    _onlineUsers.addAll(response.onlineUsers);
    notifyListeners();

    _logger.i('Updated online users list: ${_onlineUsers.length} users');
  }

  /// Handle chat message notification
  void _handleChatMessageNotification(pb.WebsocketMessage message) {
    if (!message.hasChatMessageNotification()) {
      _logger.w('ChatMessageNotification missing notification data');
      return;
    }

    final notification = message.chatMessageNotification;
    final chatMessage = notification.chatMessage;

    _logger.i(
        'Received chat message from ${chatMessage.senderNickname}: ${chatMessage.content}');

    // Add to chat messages map
    final senderId = chatMessage.senderClientId;
    if (!_chatMessages.containsKey(senderId)) {
      _chatMessages[senderId] = [];
    }
    _chatMessages[senderId]!.add(chatMessage);

    notifyListeners();

    // Auto forward to system input if enabled and message is from another user
    if (_autoForwardToSystemInput && senderId != _webSocketService.clientId) {
      // Use microtask to defer auto-forwarding until after the current build cycle
      Future.microtask(
          () => _autoForwardMessageToSystemInput(chatMessage.content));
      // Don't bring window to front when auto-forwarding is enabled
      _logger.i('Auto-forwarding enabled, not bringing window to front');
    } else {
      // Only bring window to front if auto-forwarding is disabled
      _bringWindowToFrontIfNeeded();
    }
  }

  /// Handle user connection status notification
  void _handleUserConnectionStatusNotification(pb.WebsocketMessage message) {
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
      // Add user to online users list if not already present
      final existingIndex =
          _onlineUsers.indexWhere((u) => u.clientId == user.clientId);
      if (existingIndex == -1 && user.clientId != currentClientId) {
        _onlineUsers.add(user);
        _logger.i(
            '✅ User ${user.nickname} (${user.clientId}) added to online users list');
      } else {
        _logger.w(
            '⚠️ User ${user.nickname} (${user.clientId}) already in list or is current user');
      }
    } else if (status == 'disconnected') {
      // Remove user from online users list
      final userIndex =
          _onlineUsers.indexWhere((u) => u.clientId == user.clientId);
      if (userIndex != -1) {
        final disconnectedUser = _onlineUsers[userIndex];
        _onlineUsers.removeAt(userIndex);
        _logger.i(
            '✅ User ${disconnectedUser.nickname} (${disconnectedUser.clientId}) removed from online users list');

        // Close chat dialog if it's open for this user
        if (_activeChatUserId == user.clientId) {
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

  /// Request online users from server
  Future<void> requestOnlineUsers() async {
    if (!_isConnected) {
      _logger.w('Cannot request online users: not connected');
      return;
    }

    try {
      await _webSocketService.sendGetOnlineUsers();
      _logger.i('Online users request sent');
    } catch (error) {
      _logger.e('Failed to request online users: $error');
    }
  }

  /// Send chat message to another user
  Future<void> sendChatMessage(String receiverClientId, String content) async {
    await _sendChatMessageInternal(receiverClientId, content, notifyUI: true);
    // Chat messages don't count toward MCP pending, but keep tray in sync anyway
    _updateTrayPendingCount();
  }

  /// Send chat message without triggering UI updates (for auto-send)
  Future<void> sendChatMessageSilent(
      String receiverClientId, String content) async {
    await _sendChatMessageInternal(receiverClientId, content, notifyUI: false);
    _updateTrayPendingCount();
  }

  /// Internal method to send chat messages with optional UI notification
  Future<void> _sendChatMessageInternal(String receiverClientId, String content,
      {required bool notifyUI}) async {
    if (!_isConnected) {
      _logger.w('Cannot send chat message: not connected');
      return;
    }

    try {
      await _webSocketService.sendChatMessage(receiverClientId, content);

      // Add message to local chat history
      if (!_chatMessages.containsKey(receiverClientId)) {
        _chatMessages[receiverClientId] = [];
      }

      final localMessage = pb.ChatMessage()
        ..messageId = 'local-${DateTime.now().millisecondsSinceEpoch}'
        ..senderClientId = _webSocketService.clientId ?? ''
        ..senderNickname = await _loadNickname() ?? 'Me'
        ..receiverClientId = receiverClientId
        ..receiverNickname = ''
        ..content = content
        ..sentAt = Int64(DateTime.now().millisecondsSinceEpoch ~/ 1000);

      _chatMessages[receiverClientId]!.add(localMessage);

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
    _activeChatUserId = userId;
    notifyListeners();
  }

  /// Get chat messages for a specific user
  List<pb.ChatMessage> getChatMessages(String userId) {
    return _chatMessages[userId] ?? [];
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

  /// Auto forward message to system input
  Future<void> _autoForwardMessageToSystemInput(String content) async {
    try {
      final success = await SystemInputService.sendToSystemInput(content);
      if (success) {
        _logger.i(
            'Auto forwarded message to system input: ${content.length} characters');
      } else {
        _logger.w('Failed to auto forward message to system input');
      }
    } catch (error) {
      _logger.e('Exception during auto forward to system input: $error');
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _errorSubscription?.cancel();
    _webSocketService.dispose();
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
}
