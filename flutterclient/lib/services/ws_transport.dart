import 'dart:async';
import 'dart:typed_data';
import 'package:logger/logger.dart';

import '../proto/agentassist.pb.dart';
import '../constants/websocket_commands.dart';

enum WebSocketServiceStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// WebSocket 传输抽象：协议语义（登录/发送助手/帧分发）在基类，
/// 底层链路（本机直连或经 Android 前台 Service 转发）由子类实现。
abstract class WsTransport {
  static final Logger _logger = Logger(level: Level.nothing);

  String? url;
  String? token;
  String? nickname;
  String? clientId;
  String? serverVersion;
  WebSocketServiceStatus currentStatus = WebSocketServiceStatus.disconnected;

  // Stream controllers
  final StreamController<WebsocketMessage> _messageController =
      StreamController<WebsocketMessage>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<WebSocketServiceStatus> _statusController =
      StreamController<WebSocketServiceStatus>.broadcast();

  // Pending validity check requests
  final Map<String, Completer<Map<String, bool>>> pendingValidityChecks = {};

  // Public streams
  Stream<WebsocketMessage> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<WebSocketServiceStatus> get statusStream => _statusController.stream;

  /// Check if WebSocket is connected
  bool get isConnected => currentStatus == WebSocketServiceStatus.connected;

  // ------------------------------------------------------------------
  // 由子类实现的传输原语
  // ------------------------------------------------------------------

  /// Connect to WebSocket server
  Future<void> connect(String url, String token,
      {String? nickname, bool force = false});

  /// Force reconnection irrespective of current state
  Future<void> forceReconnect();

  /// Disconnect from WebSocket server
  void disconnect();

  /// 把序列化后的帧写入传输层
  Future<void> sendFrame(WebsocketMessage message);

  /// 登录结果钩子：直连版用它完成 login completer，Android 版由
  /// Service 状态事件驱动，无需处理
  void onLoginResult(bool success, String? errorMessage) {}

  /// 子类共享的状态/连接事件出口
  void emitStatus(WebSocketServiceStatus status) {
    currentStatus = status;
    _statusController.add(status);
  }

  void emitConnection(bool connected) {
    _connectionController.add(connected);
  }

  void emitError(String error) {
    _errorController.add(error);
  }

  // ------------------------------------------------------------------
  // 帧接收：子类拿到原始字节后调用 dispatchFrame
  // ------------------------------------------------------------------

  /// Handle incoming raw protobuf frame
  void dispatchFrame(Uint8List bytes) {
    try {
      final message = WebsocketMessage.fromBuffer(bytes);

      // Handle validity check responses
      if (message.cmd == WebSocketCommands.checkMessageValidity &&
          message.hasCheckMessageValidityResponse()) {
        _handleValidityCheckResponse(message.checkMessageValidityResponse);
      } else if (message.cmd == WebSocketCommands.userLogin &&
          message.hasUserLoginResponse()) {
        _handleUserLoginResponse(message.userLoginResponse, message.strParam);
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

    // Complete the first pending request (FIFO)
    if (pendingValidityChecks.isNotEmpty) {
      final firstKey = pendingValidityChecks.keys.first;
      final completer = pendingValidityChecks.remove(firstKey);
      if (completer != null && !completer.isCompleted) {
        completer.complete(response.validity);
      }
    }
  }

  /// Handle user login response
  void _handleUserLoginResponse(
      UserLoginResponse response, String serverVersion) {
    if (response.success) {
      clientId = response.clientId;
      final trimmedVersion = serverVersion.trim();
      this.serverVersion = trimmedVersion.isEmpty ? null : trimmedVersion;
      _logger.i('User login successful, client ID: $clientId');
      onLoginResult(true, null);
    } else {
      _logger.e('User login failed: ${response.errorMessage}');
      _errorController.add('Login failed: ${response.errorMessage}');
      onLoginResult(false, response.errorMessage);
    }
  }

  // ------------------------------------------------------------------
  // 发送助手（协议层，与链路无关）
  // ------------------------------------------------------------------

  /// Send user login message
  Future<void> sendUserLogin() async {
    if (token == null) {
      _logger.w('Cannot send UserLogin: token is null');
      return;
    }

    final message = WebsocketMessage()
      ..cmd = WebSocketCommands.userLogin
      ..strParam = token!
      ..nickname = nickname ?? '';

    _logger
        .i('Sending UserLogin command - Nickname: "${nickname ?? "[empty]"}"');
    await sendFrame(message);
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

    await sendFrame(message);
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

    await sendFrame(message);
    _logger.d('Work report reply sent: ${response.iD}');
  }

  /// Update nickname and send to server
  Future<void> updateNickname(String newNickname) async {
    final oldNickname = nickname;
    nickname = newNickname;

    if (isConnected) {
      try {
        _logger.i(
            'Sending nickname update to server: "$oldNickname" -> "$newNickname"');
        await sendUserLogin();
      } catch (error) {
        _logger.e('Failed to send nickname update to server: $error');
      }
    } else {
      _logger.i(
          'Nickname updated locally while disconnected: "$oldNickname" -> "$newNickname"');
    }
  }

  /// Send get pending messages request
  Future<void> sendGetPendingMessages() async {
    final message = WebsocketMessage()
      ..cmd = WebSocketCommands.getPendingMessages;

    await sendFrame(message);
    _logger.d('Get pending messages request sent');
  }

  /// Send get online users request
  Future<void> sendGetOnlineUsers() async {
    final message = WebsocketMessage()
      ..cmd = WebSocketCommands.getOnlineUsers
      ..getOnlineUsersRequest =
          (GetOnlineUsersRequest()..userToken = token ?? '');

    await sendFrame(message);
    _logger.d('Get online users request sent');
  }

  /// Send chat message to another user
  Future<void> sendChatMessage(
    String receiverClientId,
    String content, {
    ForwardTarget? forwardTarget,
  }) async {
    final message = WebsocketMessage()
      ..cmd = WebSocketCommands.sendChatMessage
      ..sendChatMessageRequest = (SendChatMessageRequest()
        ..receiverClientId = receiverClientId
        ..content = content);

    if (forwardTarget != null) {
      message.sendChatMessageRequest.forwardTarget = forwardTarget;
    }

    await sendFrame(message);
    _logger.d('Chat message sent to $receiverClientId: $content');
  }

  /// Query peer forward state and window list
  Future<void> sendForwardStateQuery({
    required String requestId,
    required String targetClientId,
  }) async {
    final message = WebsocketMessage()
      ..cmd = WebSocketCommands.forwardStateQuery
      ..forwardStateQueryRequest = (ForwardStateQueryRequest()
        ..requestId = requestId
        ..targetClientId = targetClientId);

    await sendFrame(message);
  }

  /// Send response for peer forward state query
  Future<void> sendForwardStateQueryResponse({
    required String requestId,
    required String targetClientId,
    required String responderClientId,
    required bool forwardEnabled,
    required List<ForwardWindowItem> windows,
  }) async {
    final response = ForwardStateQueryResponse()
      ..requestId = requestId
      ..targetClientId = targetClientId
      ..responderClientId = responderClientId
      ..forwardEnabled = forwardEnabled
      ..windows.addAll(windows);

    final message = WebsocketMessage()
      ..cmd = WebSocketCommands.forwardStateQueryResponse
      ..forwardStateQueryResponse = response;

    await sendFrame(message);
  }

  /// Broadcast own forward state change to peers
  Future<void> sendForwardStateChanged({
    required String sourceClientId,
    required bool forwardEnabled,
    required List<ForwardWindowItem> windows,
  }) async {
    final notification = ForwardStateChangedNotification()
      ..sourceClientId = sourceClientId
      ..forwardEnabled = forwardEnabled
      ..windows.addAll(windows);

    final message = WebsocketMessage()
      ..cmd = WebSocketCommands.forwardStateChanged
      ..forwardStateChangedNotification = notification;

    await sendFrame(message);
  }

  /// Notify peer that selected forward target is invalid
  Future<void> sendForwardDeliveryError({
    required String targetClientId,
    required String peerClientId,
    required String invalidWindowId,
    required String reason,
  }) async {
    final notification = ForwardDeliveryErrorNotification()
      ..targetClientId = targetClientId
      ..peerClientId = peerClientId
      ..invalidWindowId = invalidWindowId
      ..reason = reason;

    final message = WebsocketMessage()
      ..cmd = WebSocketCommands.forwardDeliveryError
      ..forwardDeliveryErrorNotification = notification;

    await sendFrame(message);
  }

  /// Check message validity
  Future<Map<String, bool>> checkMessageValidity(
      List<String> requestIds) async {
    final completer = Completer<Map<String, bool>>();

    // Store the completer for this request
    final requestKey =
        'validity_check_${DateTime.now().millisecondsSinceEpoch}';
    pendingValidityChecks[requestKey] = completer;

    final message = WebsocketMessage()
      ..cmd = WebSocketCommands.checkMessageValidity
      ..checkMessageValidityRequest =
          (CheckMessageValidityRequest()..requestIds.addAll(requestIds));

    try {
      await sendFrame(message);
      _logger.d(
          'Message validity check sent for ${requestIds.length} request IDs');

      // Set a timeout for the request
      Timer(const Duration(seconds: 10), () {
        if (!completer.isCompleted) {
          pendingValidityChecks.remove(requestKey);
          completer.completeError(TimeoutException(
              'Message validity check timeout', const Duration(seconds: 10)));
        }
      });

      return await completer.future;
    } catch (error) {
      pendingValidityChecks.remove(requestKey);
      rethrow;
    }
  }

  /// Dispose shared resources
  void dispose() {
    _messageController.close();
    _connectionController.close();
    _errorController.close();
    _statusController.close();
  }
}
