import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logger/logger.dart';

import '../proto/agentassist.pb.dart';
import '../config/app_config.dart';
import 'ws_transport.dart';

// 保持旧导入路径可用（WebSocketServiceStatus 已移到 ws_transport.dart）
export 'ws_transport.dart' show WebSocketServiceStatus;

/// 直连 WebSocket 传输：桌面/移动通用默认实现。
/// 协议语义（发送助手、帧分发）继承自 [WsTransport]，
/// 这里只管链路：建连、登录等待、心跳、重连。
class WebSocketService extends WsTransport {
  static final Logger _logger = Logger(level: Level.nothing);

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  Completer<void>? _loginCompleter;
  Timer? _loginTimeoutTimer;

  int _reconnectAttempts = 0;
  bool _isManuallyDisconnected = false;
  bool _isConnecting = false;

  /// Connect to WebSocket server
  @override
  Future<void> connect(String url, String token,
      {String? nickname, bool force = false}) async {
    if (_isConnecting && !force) return;

    // Clean up any existing connection before creating a new one
    _cleanup();

    this.url = url;
    this.token = token;
    this.nickname = nickname;
    serverVersion = null;
    _isConnecting = true;
    _isManuallyDisconnected = false;
    currentStatus = WebSocketServiceStatus.connecting;
    emitStatus(WebSocketServiceStatus.connecting);

    // Reset login wait state
    _loginCompleter = Completer<void>();
    _loginTimeoutTimer?.cancel();
    _loginTimeoutTimer = Timer(const Duration(seconds: 5), () {
      if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
        _loginCompleter!.completeError(
          TimeoutException('Login timeout', const Duration(seconds: 5)),
        );
      }
    });

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
      await sendUserLogin();

      // Wait for login response before marking as connected.
      await _loginCompleter!.future;

      // Start heartbeat
      _startHeartbeat();

      _isConnecting = false;
      _reconnectAttempts = 0;
      emitConnection(true);
      currentStatus = WebSocketServiceStatus.connected;
      emitStatus(WebSocketServiceStatus.connected);

      _logger.i('WebSocket connected successfully');
    } catch (error) {
      _isConnecting = false;
      _logger.e('WebSocket connection failed: $error');
      emitError('Connection failed: $error');
      emitConnection(false);
      currentStatus = WebSocketServiceStatus.error;
      emitStatus(WebSocketServiceStatus.error);

      if (!_isManuallyDisconnected) {
        _scheduleReconnect();
      }
    }
  }

  /// Force reconnection irrespective of current state
  @override
  Future<void> forceReconnect() async {
    _logger.i('Forcing reconnection...');
    if (url != null && token != null) {
      // Cancel any pending reconnect timer
      _reconnectTimer?.cancel();
      // Reset attempts so we don't have a long delay if this fails
      _reconnectAttempts = 0;
      await connect(url!, token!, nickname: nickname, force: true);
    }
  }

  void _failLoginIfPending(Object error) {
    if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
      _loginCompleter!.completeError(error);
    }
  }

  /// Disconnect from WebSocket server
  @override
  void disconnect() {
    _isManuallyDisconnected = true;
    _failLoginIfPending(StateError('Disconnected'));
    _cleanup();
    emitConnection(false);
    emitStatus(WebSocketServiceStatus.disconnected);
    _logger.i('WebSocket disconnected manually');
  }

  /// 登录结果：完成 connect() 等待
  @override
  void onLoginResult(bool success, String? errorMessage) {
    if (success) {
      if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
        _loginCompleter!.complete();
      }
    } else {
      _failLoginIfPending(StateError('Login failed: $errorMessage'));
    }
  }

  /// Send protobuf message
  @override
  Future<void> sendFrame(WebsocketMessage message) async {
    if (_channel == null) {
      throw Exception('WebSocket not connected');
    }

    try {
      final data = message.writeToBuffer();
      _channel!.sink.add(data);
    } catch (error) {
      _logger.e('Failed to send message: $error');
      emitError('Failed to send message: $error');
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

      dispatchFrame(bytes);
    } catch (error) {
      _logger.e('Failed to parse message: $error');
      emitError('Failed to parse message: $error');
    }
  }

  /// Handle WebSocket errors
  void _handleError(error) {
    _logger.e('WebSocket error: $error');
    emitError('Connection error: $error');
    emitConnection(false);
    currentStatus = WebSocketServiceStatus.error;
    emitStatus(WebSocketServiceStatus.error);

    _failLoginIfPending(StateError('WebSocket error: $error'));

    // Clean up current connection resources
    _isConnecting = false;

    if (!_isManuallyDisconnected) {
      _scheduleReconnect();
    }
  }

  /// Handle WebSocket disconnection
  void _handleDisconnection() {
    _logger.w('WebSocket disconnected');
    emitConnection(false);
    currentStatus = WebSocketServiceStatus.disconnected;
    emitStatus(WebSocketServiceStatus.disconnected);

    _failLoginIfPending(StateError('WebSocket disconnected'));

    // Clean up current connection resources
    _isConnecting = false;

    if (!_isManuallyDisconnected) {
      _scheduleReconnect();
    }
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    // Cancel any existing reconnect timer
    _reconnectTimer?.cancel();

    _reconnectAttempts++;
    final backoffMs =
        AppConfig.reconnectDelayMs * pow(2, _reconnectAttempts - 1);
    // Determine maximum delay based on platform or importance
    // For mobile apps showing "connecting", we want faster retries when active
    // But exponential backoff is good for background.
    // Let's resetattempts on successful connect.
    final delayMs = min(60000, backoffMs.toInt()); // Cap at 60s instead of 300s
    final delay = Duration(milliseconds: delayMs);

    _logger.i(
        'Scheduling reconnect attempt $_reconnectAttempts in ${delay.inSeconds}s');

    currentStatus = WebSocketServiceStatus.reconnecting;
    emitStatus(WebSocketServiceStatus.reconnecting);

    _reconnectTimer = Timer(delay, () {
      if (!_isManuallyDisconnected && url != null && token != null) {
        _logger.i('Attempting reconnect $_reconnectAttempts');
        connect(url!, token!, nickname: nickname);
      }
    });
  }

  /// Start heartbeat timer
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      Duration(milliseconds: AppConfig.heartbeatIntervalMs),
      (_) {
        if (_channel != null && isConnected) {
          // Send ping or keep-alive message if needed
          _logger.d('Sending Heartbeat (GetPendingMessages)');
          // Use GetPendingMessages as a safe heartbeat
          sendGetPendingMessages().catchError((e) {
            _logger.w('Heartbeat failed: $e');
            // Optionally trigger reconnection if heartbeat fails consistently
            // But usually the socket error handler will catch this soon.
          });
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
    _loginTimeoutTimer?.cancel();

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
    _loginTimeoutTimer = null;
    _isConnecting = false;

    _loginCompleter = null;

    _logger.d('WebSocket resources cleaned up');
  }

  /// Dispose service
  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}
