import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agentassistant/providers/chat_provider.dart';
import 'package:agentassistant/models/chat_message.dart';
import 'package:agentassistant/proto/agentassist.pb.dart' as pb;

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

  test('回复草稿按 serverId|requestId 命中，消息对象重建（新 id）不丢', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = ChatProvider();
    await Future.delayed(const Duration(milliseconds: 50));

    final m1 = makeQuestion('s1', 'req-1');
    provider.setDraft(m1, '未发送的回复');
    expect(provider.getDraft(m1), '未发送的回复');

    // pending 重拉会新建 ChatMessage（随机 id），requestId 相同 → 草稿仍命中
    final m2 = makeQuestion('s1', 'req-1');
    expect(m2.id, isNot(m1.id));
    expect(provider.getDraft(m2), '未发送的回复');

    provider.clearDraft(m2);
    expect(provider.getDraft(m1), isNull);
  });

  test('AskQuestion 草稿保存/读取/清空', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = ChatProvider();
    await Future.delayed(const Duration(milliseconds: 50));

    final m = makeQuestion('s1', 'req-ask');
    expect(provider.getAskQuestionDraft(m), isNull);

    provider.saveAskQuestionDraft(
      m,
      selections: {
        0: {1, 2}
      },
      inputs: {1: '自定义回答'},
      showInput: {1: true},
    );

    final draft = provider.getAskQuestionDraft(m);
    expect(draft, isNotNull);
    expect(draft!.selections[0], {1, 2});
    expect(draft.inputs[1], '自定义回答');
    expect(draft.showInput[1], true);

    // 增量保存：只更新 inputs 时保留 selections
    provider.saveAskQuestionDraft(m, inputs: {1: '改过的回答'});
    final draft2 = provider.getAskQuestionDraft(m)!;
    expect(draft2.selections[0], {1, 2});
    expect(draft2.inputs[1], '改过的回答');
  });

  test('草稿持久化到 SharedPreferences，新建 provider（模拟重启）可恢复', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = ChatProvider();
    await Future.delayed(const Duration(milliseconds: 50));

    final m = makeQuestion('s1', 'req-persist');
    provider.setDraft(m, '重启前的输入');
    provider.saveAskQuestionDraft(m, selections: {
      0: {0}
    });
    // 等待 fire-and-forget 落盘完成
    await Future.delayed(const Duration(milliseconds: 100));

    final provider2 = ChatProvider();
    await Future.delayed(const Duration(milliseconds: 100));

    expect(provider2.getDraft(makeQuestion('s1', 'req-persist')), '重启前的输入');
    final d = provider2.getAskQuestionDraft(makeQuestion('s1', 'req-persist'));
    expect(d, isNotNull);
    expect(d!.selections[0], {0});
  });

  test('clearMessages 清空全部草稿', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = ChatProvider();
    await Future.delayed(const Duration(milliseconds: 50));

    final m = makeQuestion('s1', 'req-clear');
    provider.setDraft(m, 'draft');
    provider.saveAskQuestionDraft(m, selections: {
      0: {1}
    });

    provider.clearMessages();
    expect(provider.getDraft(m), isNull);
    expect(provider.getAskQuestionDraft(m), isNull);
  });
}
