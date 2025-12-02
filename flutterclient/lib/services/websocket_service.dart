import 'dart:async';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logger/logger.dart';

import '../proto/agentassist.pb.dart';
import '../constants/websocket_commands.dart';
import '../config/app_config.dart';

/// WebSocket service for Agent Assistant communication
class WebSocketService {
  static final Logger _logger = Logger();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  String? _url;
  String? _token;
  String? _nickname;
  String? _clientId;
  int _reconnectAttempts = 0;
  bool _isManuallyDisconnected = false;
  bool _isConnecting = false;

  // Stream controllers
  final StreamController<WebsocketMessage> _messageController =
      StreamController<WebsocketMessage>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  // Pending validity check requests
  final Map<String, Completer<Map<String, bool>>> _pendingValidityChecks = {};

  // Public streams
  Stream<WebsocketMessage> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<String> get errorStream => _errorController.stream;

  /// Check if WebSocket is connected
  bool get isConnected => _channel != null && !_isConnecting;

  /// Get current client ID
  String? get clientId => _clientId;

  /// Connect to WebSocket server
  Future<void> connect(String url, String token, {String? nickname}) async {
    if (_isConnecting) return;

    // Clean up any existing connection before creating a new one
    _cleanup();

    _url = url;
    _token = token;
    _nickname = nickname;
    _isConnecting = true;
    _isManuallyDisconnected = false;

    try {
      _logger.i('Connecting to WebSocket: $url');

      _channel = WebSocketChannel.connect(Uri.parse(url));

      // Listen to messages
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      // Send login message
      await _sendUserLogin();

      // Start heartbeat
      _startHeartbeat();

      _isConnecting = false;
      _reconnectAttempts = 0;
      _connectionController.add(true);

      _logger.i('WebSocket connected successfully');
    } catch (error) {
      _isConnecting = false;
      _logger.e('WebSocket connection failed: $error');
      _errorController.add('Connection failed: $error');
      _connectionController.add(false);

      if (!_isManuallyDisconnected) {
        _scheduleReconnect();
      }
    }
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    _isManuallyDisconnected = true;
    _cleanup();
    _connectionController.add(false);
    _logger.i('WebSocket disconnected manually');
  }

  /// Send user login message
  Future<void> _sendUserLogin() async {
    if (_token == null) return;

    final message = WebsocketMessage()
      ..cmd = WebSocketCommands.userLogin
      ..strParam = _token!
      ..nickname = _nickname ?? '';

    await _sendMessage(message);
    _logger
        .d('User login message sent with nickname: ${_nickname ?? "default"}');
  }

  /// Send ask question reply
  Future<void> sendAskQuestionReply(
    AskQuestionRequest originalRequest,
    AskQuestionResponse response,
  ) async {
    final message = WebsocketMessage()
      ..cmd = WebSocketCommands.askQuestionReply
      ..askQuestionRequest = originalRequest
      ..askQuestionResponse = response;

    await _sendMessage(message);
    _logger.d('Ask question reply sent: ${response.iD}');
  }

  /// Send work report reply
  Future<void> sendWorkReportReply(
    WorkReportRequest originalRequest,
    WorkReportResponse response,
  ) async {
    final message = WebsocketMessage()
      ..cmd = WebSocketCommands.workReportReply
      ..workReportRequest = originalRequest
      ..workReportResponse = response;

    await _sendMessage(message);
    _logger.d('Work report reply sent: ${response.iD}');
  }

  /// Update nickname and send to server
  Future<void> updateNickname(String nickname) async {
    _nickname = nickname;
    // Send updated login message to server
    await _sendUserLogin();
    _logger.d('Nickname updated and sent to server: $nickname');
  }

  /// Send get pending messages request
  Future<void> sendGetPendingMessages() async {
    final message = WebsocketMessage()
      ..cmd = WebSocketCommands.getPendingMessages;

    await _sendMessage(message);
    _logger.d('Get pending messages request sent');
  }

  /// Send get online users request
  Future<void> sendGetOnlineUsers() async {
    final message = WebsocketMessage()
      ..cmd = WebSocketCommands.getOnlineUsers
      ..getOnlineUsersRequest =
          (GetOnlineUsersRequest()..userToken = _token ?? '');

    await _sendMessage(message);
    _logger.d('Get online users request sent');
  }

  /// Send chat message to another user
  Future<void> sendChatMessage(String receiverClientId, String content) async {
    final message = WebsocketMessage()
      ..cmd = WebSocketCommands.sendChatMessage
      ..sendChatMessageRequest = (SendChatMessageRequest()
        ..receiverClientId = receiverClientId
        ..content = content);

    await _sendMessage(message);
    _logger.d('Chat message sent to $receiverClientId: $content');
  }

  /// Check message validity
  Future<Map<String, bool>> checkMessageValidity(
      List<String> requestIds) async {
    if (_channel == null) {
      throw Exception('WebSocket not connected');
    }

    final completer = Completer<Map<String, bool>>();

    // Store the completer for this request
    final requestKey =
        'validity_check_${DateTime.now().millisecondsSinceEpoch}';
    _pendingValidityChecks[requestKey] = completer;

    final message = WebsocketMessage()
      ..cmd = WebSocketCommands.checkMessageValidity
      ..checkMessageValidityRequest =
          (CheckMessageValidityRequest()..requestIds.addAll(requestIds));

    try {
      await _sendMessage(message);
      _logger.d(
          'Message validity check sent for ${requestIds.length} request IDs');

      // Set a timeout for the request
      Timer(const Duration(seconds: 10), () {
        if (!completer.isCompleted) {
          _pendingValidityChecks.remove(requestKey);
          completer.completeError(TimeoutException(
              'Message validity check timeout', const Duration(seconds: 10)));
        }
      });

      return completer.future;
    } catch (error) {
      _pendingValidityChecks.remove(requestKey);
      rethrow;
    }
  }

  /// Send protobuf message
  Future<void> _sendMessage(WebsocketMessage message) async {
    if (_channel == null) {
      throw Exception('WebSocket not connected');
    }

    try {
      final data = message.writeToBuffer();
      _channel!.sink.add(data);
    } catch (error) {
      _logger.e('Failed to send message: $error');
      _errorController.add('Failed to send message: $error');
      rethrow;
    }
  }

  /// Handle incoming messages
  void _handleMessage(dynamic data) {
    try {
      Uint8List bytes;
      if (data is List<int>) {
        bytes = Uint8List.fromList(data);
      } else if (data is String) {
        // Handle text messages as fallback
        _logger.w('Received text message, expected binary');
        return;
      } else {
        _logger.e('Unexpected message type: ${data.runtimeType}');
        return;
      }

      final message = WebsocketMessage.fromBuffer(bytes);

      // Handle validity check responses
      if (message.cmd == WebSocketCommands.checkMessageValidity &&
          message.hasCheckMessageValidityResponse()) {
        _handleValidityCheckResponse(message.checkMessageValidityResponse);
      } else if (message.cmd == WebSocketCommands.userLogin &&
          message.hasUserLoginResponse()) {
        _handleUserLoginResponse(message.userLoginResponse);
      } else {
        _messageController.add(message);
      }

      _logger.d('Received message: ${message.cmd}');
    } catch (error) {
      _logger.e('Failed to parse message: $error');
      _errorController.add('Failed to parse message: $error');
    }
  }

  /// Handle validity check response
  void _handleValidityCheckResponse(CheckMessageValidityResponse response) {
    _logger.d(
        'Received validity check response for ${response.validity.length} request IDs');

    // Complete all pending validity check requests
    // Since we don't have a specific request ID for validity checks,
    // we complete the first pending request (FIFO)
    if (_pendingValidityChecks.isNotEmpty) {
      final firstKey = _pendingValidityChecks.keys.first;
      final completer = _pendingValidityChecks.remove(firstKey);
      if (completer != null && !completer.isCompleted) {
        completer.complete(response.validity);
      }
    }
  }

  /// Handle user login response
  void _handleUserLoginResponse(UserLoginResponse response) {
    if (response.success) {
      _clientId = response.clientId;
      _logger.i('User login successful, client ID: $_clientId');
    } else {
      _logger.e('User login failed: ${response.errorMessage}');
      _errorController.add('Login failed: ${response.errorMessage}');
    }
  }

  /// Handle WebSocket errors
  void _handleError(error) {
    _logger.e('WebSocket error: $error');
    _errorController.add('Connection error: $error');
    _connectionController.add(false);

    // Clean up current connection resources
    _isConnecting = false;

    if (!_isManuallyDisconnected) {
      _scheduleReconnect();
    }
  }

  /// Handle WebSocket disconnection
  void _handleDisconnection() {
    _logger.w('WebSocket disconnected');
    _connectionController.add(false);

    // Clean up current connection resources
    _isConnecting = false;

    if (!_isManuallyDisconnected) {
      _scheduleReconnect();
    }
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (_reconnectAttempts >= AppConfig.maxReconnectAttempts) {
      _logger.e('Max reconnect attempts reached');
      _errorController.add('Connection failed: maximum retry attempts reached');
      return;
    }

    // Cancel any existing reconnect timer
    _reconnectTimer?.cancel();

    _reconnectAttempts++;
    final delay = Duration(
      milliseconds: AppConfig.reconnectDelayMs * _reconnectAttempts,
    );

    _logger.i(
        'Scheduling reconnect attempt $_reconnectAttempts in ${delay.inSeconds}s');

    _reconnectTimer = Timer(delay, () {
      if (!_isManuallyDisconnected && _url != null && _token != null) {
        _logger.i('Attempting reconnect $_reconnectAttempts');
        connect(_url!, _token!, nickname: _nickname);
      }
    });
  }

  /// Start heartbeat timer
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      Duration(milliseconds: AppConfig.heartbeatIntervalMs),
      (_) {
        if (_channel != null) {
          // Send ping or keep-alive message if needed
          //_logger.d('Heartbeat check');
        }
      },
    );
  }

  /// Clean up resources
  void _cleanup() {
    _logger.d('Cleaning up WebSocket resources');

    // Cancel timers first
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();

    // Cancel subscription and close channel
    if (_subscription != null) {
      _subscription!.cancel();
      _logger.d('WebSocket subscription cancelled');
    }

    if (_channel != null) {
      try {
        _channel!.sink.close();
        _logger.d('WebSocket channel closed');
      } catch (error) {
        _logger.w('Error closing WebSocket channel: $error');
      }
    }

    // Reset all references
    _channel = null;
    _subscription = null;
    _reconnectTimer = null;
    _heartbeatTimer = null;
    _isConnecting = false;

    _logger.d('WebSocket resources cleaned up');
  }

  /// Dispose service
  void dispose() {
    _cleanup();
    _messageController.close();
    _connectionController.close();
    _errorController.close();
  }
}
