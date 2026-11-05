import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agentassistant/constants/websocket_commands.dart';
import 'package:agentassistant/models/chat_message.dart';
import 'package:agentassistant/proto/agentassist.pb.dart' as pb;
import 'package:agentassistant/providers/chat_provider.dart';
import 'package:agentassistant/services/ws_transport.dart';

/// Transport double that records the ResetTimeout frames it is asked to send.
class RecordingTransport extends WsTransport {
  final List<String> resetRequests = [];
  bool connected = true;

  @override
  bool get isConnected => connected;

  @override
  Future<void> sendResetTimeout(String requestId) async {
    resetRequests.add(requestId);
  }

  @override
  Future<void> connect(String url, String token,
      {String? nickname, bool force = false}) async {}

  @override
  Future<void> forceReconnect() async {}

  @override
  void disconnect() {}

  @override
  Future<void> sendFrame(pb.WebsocketMessage message) async {}
}

ChatMessage makeQuestion(String serverId, String requestId) {
  return ChatMessage.fromAskQuestionRequest(
    pb.AskQuestionRequest()
      ..iD = requestId
      ..request = (pb.McpAskQuestionRequest()
        ..projectDirectory = '/tmp/proj'
        ..questions.add(pb.Question()..question = 'q?')),
    serverId: serverId,
    serverName: 'srv',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
    const MethodChannel('xyz.luan/audioplayers.global'),
    (call) async => null,
  );
  messenger.setMockMethodCallHandler(
    const MethodChannel('xyz.luan/audioplayers'),
    (call) async => null,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('touchUserActivity sends one ResetTimeout per throttle window',
      () async {
    final provider = ChatProvider();
    final transport = RecordingTransport();
    provider.registerTransportForTesting('s1', transport);
    final message = makeQuestion('s1', 'req-1');

    provider.touchUserActivity(message);
    provider.touchUserActivity(message); // throttled
    provider.touchUserActivity(message); // throttled
    await Future.delayed(Duration.zero);

    expect(transport.resetRequests, ['req-1']);
  });

  test('force still collapses bursts into one frame', () async {
    final provider = ChatProvider();
    final transport = RecordingTransport();
    provider.registerTransportForTesting('s1', transport);
    final message = makeQuestion('s1', 'req-1');

    // A user clicking several options in quick succession must not produce a
    // frame per click: force only bypasses the 1s keystroke throttle down to a
    // small floor.
    for (var i = 0; i < 5; i++) {
      provider.touchUserActivity(message, force: true);
    }
    await Future.delayed(Duration.zero);

    expect(transport.resetRequests, ['req-1']);
  });

  test('no ResetTimeout when the message has no serverId', () async {
    final provider = ChatProvider();
    final transport = RecordingTransport();
    provider.registerTransportForTesting('s1', transport);
    final message = makeQuestion('', 'req-1');

    provider.touchUserActivity(message, force: true);
    await Future.delayed(Duration.zero);

    expect(transport.resetRequests, isEmpty,
        reason: 'guessing a transport would target the wrong server');
  });

  test('no ResetTimeout when the transport is disconnected', () async {
    final provider = ChatProvider();
    final transport = RecordingTransport()..connected = false;
    provider.registerTransportForTesting('s1', transport);
    final message = makeQuestion('s1', 'req-1');

    provider.touchUserActivity(message, force: true);
    await Future.delayed(Duration.zero);

    expect(transport.resetRequests, isEmpty);
  });

  test('no ResetTimeout for a message that is no longer pending', () async {
    final provider = ChatProvider();
    final transport = RecordingTransport();
    provider.registerTransportForTesting('s1', transport);
    final answered =
        makeQuestion('s1', 'req-1').copyWith(status: MessageStatus.replied);

    provider.touchUserActivity(answered, force: true);
    await Future.delayed(Duration.zero);

    expect(transport.resetRequests, isEmpty);
  });

  test('throttle bookkeeping is released with the draft', () async {
    final provider = ChatProvider();
    final transport = RecordingTransport();
    provider.registerTransportForTesting('s1', transport);
    final message = makeQuestion('s1', 'req-1');

    provider.setDraft(message, 'typing');
    expect(provider.resetTimeoutThrottleEntryCount, 1);

    provider.clearDraft(message);
    expect(provider.resetTimeoutThrottleEntryCount, 0);
  });

  test('throttle bookkeeping does not survive handled messages', () async {
    final provider = ChatProvider();
    final transport = RecordingTransport();
    provider.registerTransportForTesting('s1', transport);

    for (var i = 0; i < 5; i++) {
      final message = makeQuestion('s1', 'req-$i');
      provider.addMessageForTesting(message);
      provider.setDraft(message, 'typing');
    }
    expect(provider.resetTimeoutThrottleEntryCount, 5);

    // Messages that expire (or are otherwise finished) get cleared; their
    // throttle entries must go with them instead of accumulating forever.
    for (var i = 0; i < 5; i++) {
      provider.updateMessageForTesting(
        provider.messages[i].copyWith(status: MessageStatus.expired),
      );
    }
    provider.clearHandledMessages();

    expect(provider.messages, isEmpty);
    expect(provider.resetTimeoutThrottleEntryCount, 0);
  });

  test('pruning drafts for a server also prunes throttle bookkeeping',
      () async {
    final provider = ChatProvider();
    final transport = RecordingTransport();
    provider.registerTransportForTesting('s1', transport);

    final gone = makeQuestion('s1', 'req-gone');
    provider.setDraft(gone, 'typing');
    final live = makeQuestion('s1', 'req-live');
    provider.addMessageForTesting(live);
    provider.setDraft(live, 'typing');
    expect(provider.resetTimeoutThrottleEntryCount, 2);

    // The server no longer lists req-gone, so its draft and throttle entry go.
    provider.pruneDraftsForServerForTesting('s1');

    expect(provider.resetTimeoutThrottleEntryCount, 1);
    expect(provider.getDraft(live), 'typing');
  });

  test('clearMessages drops throttle bookkeeping too', () async {
    final provider = ChatProvider();
    final transport = RecordingTransport();
    provider.registerTransportForTesting('s1', transport);

    final message = makeQuestion('s1', 'req-1');
    provider.setDraft(message, 'typing');
    expect(provider.resetTimeoutThrottleEntryCount, 1);

    provider.clearMessages();
    expect(provider.resetTimeoutThrottleEntryCount, 0);
  });
}
