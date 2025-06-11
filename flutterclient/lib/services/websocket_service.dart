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

  // Public streams
  Stream<WebsocketMessage> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<String> get errorStream => _errorController.stream;

  /// Check if WebSocket is connected
  bool get isConnected => _channel != null;

  /// Connect to WebSocket server
  Future<void> connect(String url, String token) async {
    if (_isConnecting) return;
    
    _url = url;
    _token = token;
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
      _errorController.add('连接失败: $error');
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
      ..strParam = _token!;
    
    await _sendMessage(message);
    _logger.d('User login message sent');
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

  /// Send task finish reply
  Future<void> sendTaskFinishReply(
    TaskFinishRequest originalRequest,
    TaskFinishResponse response,
  ) async {
    final message = WebsocketMessage()
      ..cmd = WebSocketCommands.taskFinishReply
      ..taskFinishRequest = originalRequest
      ..taskFinishResponse = response;
    
    await _sendMessage(message);
    _logger.d('Task finish reply sent: ${response.iD}');
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
      _errorController.add('发送消息失败: $error');
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
      _messageController.add(message);
      
      _logger.d('Received message: ${message.cmd}');
      
    } catch (error) {
      _logger.e('Failed to parse message: $error');
      _errorController.add('消息解析失败: $error');
    }
  }

  /// Handle WebSocket errors
  void _handleError(error) {
    _logger.e('WebSocket error: $error');
    _errorController.add('连接错误: $error');
    _connectionController.add(false);
    
    if (!_isManuallyDisconnected) {
      _scheduleReconnect();
    }
  }

  /// Handle WebSocket disconnection
  void _handleDisconnection() {
    _logger.w('WebSocket disconnected');
    _connectionController.add(false);
    
    if (!_isManuallyDisconnected) {
      _scheduleReconnect();
    }
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (_reconnectAttempts >= AppConfig.maxReconnectAttempts) {
      _logger.e('Max reconnect attempts reached');
      _errorController.add('连接失败，已达到最大重试次数');
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(
      milliseconds: AppConfig.reconnectDelayMs * _reconnectAttempts,
    );

    _logger.i('Scheduling reconnect attempt $_reconnectAttempts in ${delay.inSeconds}s');

    _reconnectTimer = Timer(delay, () {
      if (!_isManuallyDisconnected && _url != null && _token != null) {
        connect(_url!, _token!);
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
          _logger.d('Heartbeat check');
        }
      },
    );
  }

  /// Clean up resources
  void _cleanup() {
    _subscription?.cancel();
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    
    _channel = null;
    _subscription = null;
    _reconnectTimer = null;
    _heartbeatTimer = null;
    _isConnecting = false;
  }

  /// Dispose service
  void dispose() {
    _cleanup();
    _messageController.close();
    _connectionController.close();
    _errorController.close();
  }
}
