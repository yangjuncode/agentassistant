import 'dart:async';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../proto/agentassist.pb.dart';
import 'ws_transport.dart';

/// Android 传输：socket 由前台 Service（Kotlin 侧）持有，
/// 本类只做 MethodChannel/EventChannel 桥接，把原始帧转给
/// [WsTransport] 的协议层处理。
///
/// Dart 引擎死亡时 Service 会继续收消息并缓冲，引擎重新附着
/// （重新打开 App）后缓冲帧会回放，状态不丢。
class AndroidWsTransport extends WsTransport {
  static final Logger _logger = Logger(level: Level.nothing);

  static const MethodChannel _methodChannel =
      MethodChannel('agentassistant/ws');
  static const EventChannel _eventChannel =
      EventChannel('agentassistant/ws_events');

  /// 所有实例共享的一条原生事件订阅，按 serverId 路由
  static StreamSubscription? _eventSubscription;
  static final Map<String, AndroidWsTransport> _instances = {};

  final String serverId;
  Completer<void>? _connectCompleter;
  Timer? _connectTimeoutTimer;

  AndroidWsTransport(this.serverId) {
    _instances[serverId] = this;
    _ensureEventSubscription();
  }

  static void _ensureEventSubscription() {
    if (_eventSubscription != null) return;
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
          _dispatchEvent,
          onError: (error) => _logger.e('WS event stream error: $error'),
        );
  }

  static void _dispatchEvent(dynamic event) {
    if (event is! Map) return;
    final type = event['type'] as String?;
    final serverId = event['serverId'] as String?;
    if (type == null || serverId == null) return;
    final transport = _instances[serverId];
    if (transport == null) return;

    switch (type) {
      case 'frame':
        final data = event['data'];
        if (data is List<int>) {
          transport.dispatchFrame(Uint8List.fromList(data));
        }
        break;
      case 'status':
        transport._onStatus(event['status'] as String? ?? 'disconnected');
        break;
      case 'error':
        transport._onError(event['message'] as String? ?? 'unknown error');
        break;
      case 'login':
        transport._onLogin(
          event['clientId'] as String? ?? '',
          event['serverVersion'] as String? ?? '',
        );
        break;
    }
  }

  // ------------------------------------------------------------------
  // WsTransport 实现
  // ------------------------------------------------------------------

  @override
  Future<void> connect(String url, String token,
      {String? nickname, bool force = false}) async {
    this.url = url;
    this.token = token;
    this.nickname = nickname;
    // socket 由 Service 持有：已连接时无需重建。
    // 重发状态/连接事件，防止监听器错过 Service 附着时的回放。
    if (isConnected && !force) {
      emitStatus(currentStatus);
      emitConnection(true);
      return;
    }
    serverVersion = null;
    currentStatus = WebSocketServiceStatus.connecting;
    emitStatus(WebSocketServiceStatus.connecting);

    _connectCompleter = Completer<void>();
    _connectTimeoutTimer?.cancel();
    _connectTimeoutTimer = Timer(const Duration(seconds: 10), () {
      if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
        _connectCompleter!.completeError(
          TimeoutException('Connect timeout', const Duration(seconds: 10)),
        );
      }
    });

    try {
      if (force) {
        await _methodChannel.invokeMethod('reconnect', {'serverId': serverId});
      } else {
        await _methodChannel.invokeMethod('connect', {
          'serverId': serverId,
          'url': url,
          'token': token,
          'nickname': nickname ?? '',
        });
      }
      // 等待 Service 登录成功后回推 connected 状态
      await _connectCompleter!.future;
    } catch (error) {
      _logger.e('Android WS connect failed: $error');
      emitError('Connection failed: $error');
      emitConnection(false);
      currentStatus = WebSocketServiceStatus.error;
      emitStatus(WebSocketServiceStatus.error);
    }
  }

  @override
  Future<void> forceReconnect() async {
    await _methodChannel.invokeMethod('reconnect', {'serverId': serverId});
  }

  @override
  void disconnect() {
    _methodChannel.invokeMethod('disconnect', {'serverId': serverId});
    emitConnection(false);
    currentStatus = WebSocketServiceStatus.disconnected;
    emitStatus(WebSocketServiceStatus.disconnected);
    _failConnectIfPending(StateError('Disconnected'));
  }

  @override
  Future<void> sendFrame(WebsocketMessage message) async {
    final ok = await _methodChannel.invokeMethod<bool>('sendFrame', {
      'serverId': serverId,
      'data': message.writeToBuffer(),
    });
    if (ok != true) {
      throw Exception('WebSocket not connected');
    }
  }

  /// Service 侧保存昵称用于重连后重发 login，走专用通道而不是发帧
  @override
  Future<void> updateNickname(String newNickname) async {
    nickname = newNickname;
    try {
      await _methodChannel.invokeMethod('updateNickname', {
        'serverId': serverId,
        'nickname': newNickname,
      });
    } catch (error) {
      _logger.e('Failed to update nickname via service: $error');
    }
  }

  @override
  void onLoginResult(bool success, String? errorMessage) {
    // 登录响应帧和 connected 状态事件可能任一先到，两者都能完成 connect 等待
    if (success) {
      _completeConnectIfPending();
    } else {
      _failConnectIfPending(StateError('Login failed: $errorMessage'));
    }
  }

  void _completeConnectIfPending() {
    if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
      _connectCompleter!.complete();
    }
  }

  void _failConnectIfPending(Object error) {
    if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
      _connectCompleter!.completeError(error);
    }
  }

  void _onStatus(String status) {
    _logger.d('[$serverId] service status: $status');
    switch (status) {
      case 'connecting':
        currentStatus = WebSocketServiceStatus.connecting;
        emitStatus(WebSocketServiceStatus.connecting);
        break;
      case 'connected':
        currentStatus = WebSocketServiceStatus.connected;
        emitStatus(WebSocketServiceStatus.connected);
        emitConnection(true);
        _completeConnectIfPending();
        break;
      case 'reconnecting':
        currentStatus = WebSocketServiceStatus.reconnecting;
        emitStatus(WebSocketServiceStatus.reconnecting);
        emitConnection(false);
        break;
      case 'disconnected':
        currentStatus = WebSocketServiceStatus.disconnected;
        emitStatus(WebSocketServiceStatus.disconnected);
        emitConnection(false);
        _failConnectIfPending(StateError('Disconnected'));
        break;
      case 'error':
        currentStatus = WebSocketServiceStatus.error;
        emitStatus(WebSocketServiceStatus.error);
        emitConnection(false);
        _failConnectIfPending(StateError('Connection error'));
        break;
    }
  }

  void _onError(String message) {
    _logger.w('[$serverId] service error: $message');
    emitError(message);
  }

  /// Service 在引擎附着时回放的登录信息
  void _onLogin(String clientId, String serverVersion) {
    this.clientId = clientId;
    this.serverVersion = serverVersion.isEmpty ? null : serverVersion;
    _completeConnectIfPending();
  }

  @override
  void dispose() {
    _connectTimeoutTimer?.cancel();
    _instances.remove(serverId);
    if (_instances.isEmpty) {
      _eventSubscription?.cancel();
      _eventSubscription = null;
    }
    super.dispose();
  }
}

/// Android 侧 Service 控制入口（非连接相关）：生命周期上报、电池优化设置
class AndroidWsBridge {
  static const MethodChannel _channel = MethodChannel('agentassistant/ws');

  /// 上报 App 是否在前台：后台时 Service 会弹系统通知
  static Future<void> setUiForeground(bool foreground) async {
    try {
      await _channel
          .invokeMethod('setUiForeground', {'foreground': foreground});
    } catch (_) {}
  }

  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      return await _channel
              .invokeMethod<bool>('isIgnoringBatteryOptimizations') ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestIgnoreBatteryOptimizations() async {
    try {
      return await _channel
              .invokeMethod<bool>('requestIgnoreBatteryOptimizations') ??
          false;
    } catch (_) {
      return false;
    }
  }

  /// 打开应用详情设置页（国产 ROM 自启动/后台权限需手动开启）
  static Future<bool> openAppSettings() async {
    try {
      return await _channel.invokeMethod<bool>('openAppSettings') ?? false;
    } catch (_) {
      return false;
    }
  }
}
