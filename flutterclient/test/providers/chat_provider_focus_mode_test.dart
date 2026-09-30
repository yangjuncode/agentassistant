import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agentassistant/config/app_config.dart';
import 'package:agentassistant/constants/websocket_commands.dart';
import 'package:agentassistant/models/chat_message.dart';
import 'package:agentassistant/providers/chat_provider.dart';

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

  /// 等待构造函数里的异步设置加载完成，避免后续断言被加载值覆盖
  Future<void> waitForFocusMode(ChatProvider provider, bool expected) async {
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (
        provider.focusMode != expected && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  test('focus mode persisted value is loaded on init', () async {
    SharedPreferences.setMockInitialValues({
      AppConfig.focusModeStorageKey: true,
    });
    final provider = ChatProvider();
    await waitForFocusMode(provider, true);
    expect(provider.focusMode, isTrue);
    provider.clearMessages();
  });

  test('focus mode hides handled messages while pending exist', () async {
    SharedPreferences.setMockInitialValues({
      AppConfig.focusModeStorageKey: true,
    });
    final provider = ChatProvider();
    await waitForFocusMode(provider, true);

    provider.addMessageForTesting(
      ChatMessage(
        requestId: 'q-replied',
        type: MessageType.question,
        question: 'replied question',
        status: MessageStatus.replied,
      ),
    );
    provider.addMessageForTesting(
      ChatMessage(
        requestId: 'q-cancelled',
        type: MessageType.question,
        question: 'cancelled question',
        status: MessageStatus.cancelled,
      ),
    );
    provider.addMessageForTesting(
      ChatMessage(
        requestId: 'q-pending',
        type: MessageType.question,
        question: 'pending question',
      ),
    );
    provider.addMessageForTesting(
      ChatMessage(
        requestId: 't-pending',
        type: MessageType.task,
        summary: 'pending report',
      ),
    );

    expect(provider.isPendingFilterActive, isTrue);
    expect(
      provider.visibleMessages.map((m) => m.requestId),
      ['q-pending', 't-pending'],
    );

    // 待处理消息全部回复后恢复显示全部
    for (final m
        in provider.messages.where((m) => m.needsUserAction).toList()) {
      provider.updateMessageForTesting(
        m.copyWith(status: MessageStatus.replied),
      );
    }

    expect(provider.isPendingFilterActive, isFalse);
    expect(provider.visibleMessages, hasLength(4));
    provider.clearMessages();
  });

  test('focus mode disabled shows all messages', () async {
    SharedPreferences.setMockInitialValues({
      AppConfig.focusModeStorageKey: false,
    });
    final provider = ChatProvider();
    await waitForFocusMode(provider, false);

    provider.addMessageForTesting(
      ChatMessage(
        requestId: 'q-replied',
        type: MessageType.question,
        question: 'replied question',
        status: MessageStatus.replied,
      ),
    );
    provider.addMessageForTesting(
      ChatMessage(
        requestId: 'q-pending',
        type: MessageType.question,
        question: 'pending question',
      ),
    );

    expect(provider.isPendingFilterActive, isFalse);
    expect(provider.visibleMessages, hasLength(2));
    provider.clearMessages();
  });

  test('setFocusMode persists the value', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = ChatProvider();

    await provider.setFocusMode(true);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(AppConfig.focusModeStorageKey), isTrue);

    await provider.setFocusMode(false);
    expect(prefs.getBool(AppConfig.focusModeStorageKey), isFalse);
    provider.clearMessages();
  });
}
