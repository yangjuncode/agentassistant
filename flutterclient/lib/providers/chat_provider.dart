import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import '../models/chat_message.dart';
import '../services/websocket_service.dart';
import '../constants/websocket_commands.dart';
import '../config/app_config.dart';
import '../proto/agentassist.pb.dart';

/// Chat provider for managing chat state and WebSocket communication
class ChatProvider extends ChangeNotifier {
  static final Logger _logger = Logger();

  final WebSocketService _webSocketService = WebSocketService();
  final List<ChatMessage> _messages = [];

  bool _isConnected = false;
  bool _isConnecting = false;
  String? _connectionError;
  String? _currentToken;

  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _errorSubscription;

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get connectionError => _connectionError;

  List<ChatMessage> get pendingQuestions => _messages
      .where((m) => m.type == MessageType.question && m.needsUserAction)
      .toList();

  List<ChatMessage> get pendingTasks => _messages
      .where((m) => m.type == MessageType.task && m.needsUserAction)
      .toList();

  ChatProvider() {
    _initializeWebSocketListeners();
    _loadStoredData();
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
        if (connected) {
          _connectionError = null;
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
      await _webSocketService.connect(serverUrl, token);
      await _saveConnectionInfo(serverUrl, token);
    } catch (error) {
      _connectionError = '连接失败: $error';
      _isConnecting = false;
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
  void _handleWebSocketMessage(WebsocketMessage message) {
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
      default:
        _logger.w('Unknown message command: ${message.cmd}');
    }
  }

  /// Handle ask question message
  void _handleAskQuestionMessage(AskQuestionRequest request) {
    final chatMessage = ChatMessage.fromAskQuestionRequest(request);
    _addMessage(chatMessage);
    _logger.i('Received question: ${request.request.question}');
  }

  /// Handle task finish message
  void _handleTaskFinishMessage(TaskFinishRequest request) {
    final chatMessage = ChatMessage.fromTaskFinishRequest(request);
    _addMessage(chatMessage);
    _logger.i('Received task finish: ${request.request.summary}');
  }

  /// Handle ask question reply notification
  void _handleAskQuestionReplyNotification(WebsocketMessage message) {
    // Update message status if needed
    _logger.d('Ask question reply notification received');
  }

  /// Handle task finish reply notification
  void _handleTaskFinishReplyNotification(WebsocketMessage message) {
    // Update message status if needed
    _logger.d('Task finish reply notification received');
  }

  /// Reply to a question
  Future<void> replyToQuestion(String messageId, String replyText) async {
    final message = _messages.firstWhere((m) => m.id == messageId);
    if (message.type != MessageType.question) return;

    try {
      // Create response
      final response = AskQuestionResponse()
        ..iD = message.requestId
        ..isError = false
        ..contents.addAll([
          McpResultContent()
            ..type = ContentTypes.text
            ..text = (TextContent()
              ..type = 'text'
              ..text = replyText),
        ]);

      // Create original request for reply
      final originalRequest = AskQuestionRequest()
        ..iD = message.requestId
        ..userToken = _currentToken ?? ''
        ..request = (McpAskQuestionRequest()
          ..projectDirectory = message.projectDirectory ?? ''
          ..question = message.question ?? '');

      // Send reply
      await _webSocketService.sendAskQuestionReply(originalRequest, response);

      // Update message status
      final updatedMessage = message.copyWith(
        status: MessageStatus.replied,
        replyText: replyText,
        repliedAt: DateTime.now(),
      );
      _updateMessage(updatedMessage);

      _logger.i('Question reply sent: $messageId');
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
      final response = TaskFinishResponse()
        ..iD = message.requestId
        ..isError = false;

      if (confirmText != null && confirmText.isNotEmpty) {
        response.contents.add(
          McpResultContent()
            ..type = ContentTypes.text
            ..text = (TextContent()
              ..type = 'text'
              ..text = confirmText),
        );
      }

      // Create original request for reply
      final originalRequest = TaskFinishRequest()
        ..iD = message.requestId
        ..userToken = _currentToken ?? ''
        ..request = (McpTaskFinishRequest()
          ..projectDirectory = message.projectDirectory ?? ''
          ..summary = message.summary ?? '');

      // Send reply
      await _webSocketService.sendTaskFinishReply(originalRequest, response);

      // Update message status
      final updatedMessage = message.copyWith(
        status: MessageStatus.confirmed,
        replyText: confirmText,
        repliedAt: DateTime.now(),
      );
      _updateMessage(updatedMessage);

      _logger.i('Task confirmed: $messageId');
    } catch (error) {
      _logger.e('Failed to confirm task: $error');
      _connectionError = '确认失败: $error';
      notifyListeners();
    }
  }

  /// Add new message
  void _addMessage(ChatMessage message) {
    _messages.add(message);
    _saveMessages();
    notifyListeners();
  }

  /// Update existing message
  void _updateMessage(ChatMessage updatedMessage) {
    final index = _messages.indexWhere((m) => m.id == updatedMessage.id);
    if (index != -1) {
      _messages[index] = updatedMessage;
      _saveMessages();
      notifyListeners();
    }
  }

  /// Clear all messages
  void clearMessages() {
    _messages.clear();
    _saveMessages();
    notifyListeners();
  }

  /// Load stored data
  Future<void> _loadStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load messages
      final messagesJson = prefs.getString(AppConfig.messageHistoryStorageKey);
      if (messagesJson != null) {
        final messagesList = jsonDecode(messagesJson) as List;
        _messages.addAll(
          messagesList.map((json) => ChatMessage.fromJson(json)),
        );
      }

      // Load connection info
      _currentToken = prefs.getString(AppConfig.tokenStorageKey);

      notifyListeners();
    } catch (error) {
      _logger.e('Failed to load stored data: $error');
    }
  }

  /// Save messages to storage
  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = jsonEncode(
        _messages.map((m) => m.toJson()).toList(),
      );
      await prefs.setString(AppConfig.messageHistoryStorageKey, messagesJson);
    } catch (error) {
      _logger.e('Failed to save messages: $error');
    }
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

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _errorSubscription?.cancel();
    _webSocketService.dispose();
    super.dispose();
  }
}
