import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agentassistant/constants/websocket_commands.dart';
import 'package:agentassistant/models/chat_message.dart';
import 'package:agentassistant/providers/chat_provider.dart';
import 'package:agentassistant/proto/agentassist.pb.dart' as pb;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // AudioPlayer 在测试环境无原生实现，mock 掉 audioplayers 通道，
  // 避免异步 MissingPluginException 落在测试完成后把用例标失败。
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

  pb.AskQuestionRequest askReq(String id) => pb.AskQuestionRequest()
    ..iD = id
    ..request = (pb.McpAskQuestionRequest()
      ..projectDirectory = '/tmp/proj'
      ..questions.add(pb.Question()..question = 'Pick one?'));

  pb.WorkReportRequest reportReq(String id) => pb.WorkReportRequest()
    ..iD = id
    ..request = (pb.McpWorkReportRequest()
      ..projectDirectory = '/tmp/proj'
      ..summary = 'work done');

  test('duplicated AskQuestion push is deduplicated by serverId|requestId',
      () async {
    SharedPreferences.setMockInitialValues({});
    final provider = ChatProvider();
    await provider.setPlayMcpQuestionSound(false);

    provider.handleAskQuestionForTesting(
      askReq('req-1'),
      serverId: 'srv',
      serverName: 's',
    );
    provider.handleAskQuestionForTesting(
      askReq('req-1'),
      serverId: 'srv',
      serverName: 's',
    );
    // Different server id is a different key and must not be dropped.
    provider.handleAskQuestionForTesting(
      askReq('req-1'),
      serverId: 'srv2',
      serverName: 's2',
    );
    provider.handleAskQuestionForTesting(
      askReq('req-2'),
      serverId: 'srv',
      serverName: 's',
    );

    expect(provider.messages, hasLength(3));
    expect(
      provider.messages
          .where((m) => m.requestId == 'req-1' && m.serverId == 'srv'),
      hasLength(1),
    );
  });

  test('duplicated WorkReport push is deduplicated by serverId|requestId',
      () async {
    SharedPreferences.setMockInitialValues({});
    final provider = ChatProvider();
    await provider.setPlayWorkReportSound(false);

    provider.handleWorkReportForTesting(
      reportReq('wr-1'),
      serverId: 'srv',
      serverName: 's',
    );
    provider.handleWorkReportForTesting(
      reportReq('wr-1'),
      serverId: 'srv',
      serverName: 's',
    );

    expect(provider.messages, hasLength(1));
    expect(provider.pendingTasks, hasLength(1));
  });

  test('push arriving after pending fetch is deduplicated', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = ChatProvider();
    await provider.setPlayMcpQuestionSound(false);

    // Simulates a message that landed via GetPendingMessages first.
    provider.addMessageForTesting(
      ChatMessage(
        requestId: 'req-p',
        serverId: 'srv',
        type: MessageType.question,
        question: 'Pick one?',
      ),
    );
    provider.handleAskQuestionForTesting(
      askReq('req-p'),
      serverId: 'srv',
      serverName: 's',
    );

    expect(provider.messages, hasLength(1));
  });
}
