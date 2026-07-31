import 'package:agentassistant/widgets/chat_input_auto_send_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('does not auto-send while the IME is composing', (tester) async {
    var sends = 0;
    final controller = ChatInputAutoSendController(
      idleDelay: () => const Duration(seconds: 2),
      onReady: () => sends++,
    );
    addTearDown(controller.dispose);

    controller.handleValueChanged(const TextEditingValue(
      text: '语音输入',
      composing: TextRange(start: 0, end: 4),
    ));
    await tester.pump(const Duration(seconds: 10));

    expect(sends, 0);
  });

  testWidgets('waits for IME settling and idle delay after commit',
      (tester) async {
    var sends = 0;
    final controller = ChatInputAutoSendController(
      idleDelay: () => const Duration(seconds: 2),
      imeCommitSettleDelay: const Duration(milliseconds: 500),
      onReady: () => sends++,
    );
    addTearDown(controller.dispose);

    controller.handleValueChanged(const TextEditingValue(
      text: '初稿',
      composing: TextRange(start: 0, end: 2),
    ));
    controller.handleValueChanged(const TextEditingValue(text: '初稿'));

    await tester.pump(const Duration(milliseconds: 2499));
    expect(sends, 0);
    await tester.pump(const Duration(milliseconds: 1));
    expect(sends, 1);
  });

  testWidgets('a late voice correction invalidates the pending send',
      (tester) async {
    var sends = 0;
    final controller = ChatInputAutoSendController(
      idleDelay: () => const Duration(seconds: 2),
      onReady: () => sends++,
    );
    addTearDown(controller.dispose);

    controller.handleValueChanged(const TextEditingValue(text: '明天上午'));
    await tester.pump(const Duration(milliseconds: 1900));
    controller.handleValueChanged(const TextEditingValue(text: '明天下午'));
    await tester.pump(const Duration(milliseconds: 101));
    expect(sends, 0);
    await tester.pump(const Duration(milliseconds: 1899));
    expect(sends, 1);
  });

  testWidgets('cancel prevents an already scheduled send', (tester) async {
    var sends = 0;
    final controller = ChatInputAutoSendController(
      idleDelay: () => const Duration(seconds: 1),
      onReady: () => sends++,
    );
    addTearDown(controller.dispose);

    controller.handleValueChanged(const TextEditingValue(text: 'message'));
    controller.cancel();
    await tester.pump(const Duration(seconds: 2));

    expect(sends, 0);
  });
}
