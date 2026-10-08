import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agentassistant/constants/websocket_commands.dart';
import 'package:agentassistant/models/chat_message.dart';
import 'package:agentassistant/providers/chat_provider.dart';

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

  test(
      'hasUnansweredMessages is false and findLatestReplyableMessage is null when empty',
      () {
    final provider = ChatProvider();
    expect(provider.hasUnansweredMessages, isFalse);
    expect(provider.findLatestReplyableMessage(), isNull);
    provider.clearMessages();
  });

  test(
      'hasUnansweredMessages is false when only replied or cancelled messages exist',
      () {
    final provider = ChatProvider();
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
        requestId: 't-replied',
        type: MessageType.task,
        summary: 'replied task',
        status: MessageStatus.replied,
      ),
    );

    expect(provider.hasUnansweredMessages, isFalse);
    expect(provider.findLatestReplyableMessage(), isNull);
    provider.clearMessages();
  });

  test('hasUnansweredMessages is true when pending question exists', () {
    final provider = ChatProvider();
    final questionMsg = ChatMessage(
      requestId: 'q-pending',
      type: MessageType.question,
      question: 'pending question',
      status: MessageStatus.pending,
    );
    provider.addMessageForTesting(questionMsg);

    expect(provider.hasUnansweredMessages, isTrue);
    expect(
        provider.findLatestReplyableMessage()?.requestId, equals('q-pending'));
    provider.clearMessages();
  });

  test('hasUnansweredMessages is true when pending work report exists', () {
    final provider = ChatProvider();
    final taskMsg = ChatMessage(
      requestId: 't-pending',
      type: MessageType.task,
      summary: 'pending work report',
      status: MessageStatus.pending,
    );
    provider.addMessageForTesting(taskMsg);

    expect(provider.hasUnansweredMessages, isTrue);
    expect(
        provider.findLatestReplyableMessage()?.requestId, equals('t-pending'));
    provider.clearMessages();
  });

  test('findLatestReplyableMessage returns the latest message by timestamp',
      () {
    final provider = ChatProvider();
    final time1 = DateTime(2026, 1, 1, 10, 0, 0);
    final time2 = DateTime(2026, 1, 1, 10, 5, 0);
    final time3 = DateTime(2026, 1, 1, 10, 10, 0);

    final msg1 = ChatMessage(
      requestId: 'q-1',
      type: MessageType.question,
      question: 'first question',
      status: MessageStatus.pending,
      timestamp: time1,
    );
    final msg2 = ChatMessage(
      requestId: 't-2',
      type: MessageType.task,
      summary: 'second task',
      status: MessageStatus.pending,
      timestamp: time2,
    );
    final msg3 = ChatMessage(
      requestId: 'q-3',
      type: MessageType.question,
      question: 'third question',
      status: MessageStatus.pending,
      timestamp: time3,
    );

    provider.addMessageForTesting(msg1);
    provider.addMessageForTesting(msg2);
    provider.addMessageForTesting(msg3);

    expect(provider.hasUnansweredMessages, isTrue);
    expect(provider.findLatestReplyableMessage()?.requestId, equals('q-3'));

    // When the latest message is replied, the previous one becomes the latest replyable
    provider
        .updateMessageForTesting(msg3.copyWith(status: MessageStatus.replied));
    expect(provider.hasUnansweredMessages, isTrue);
    expect(provider.findLatestReplyableMessage()?.requestId, equals('t-2'));

    // When msg2 is replied, msg1 is latest replyable
    provider
        .updateMessageForTesting(msg2.copyWith(status: MessageStatus.replied));
    expect(provider.hasUnansweredMessages, isTrue);
    expect(provider.findLatestReplyableMessage()?.requestId, equals('q-1'));

    // When all are replied, hasUnansweredMessages is false and findLatestReplyableMessage is null
    provider
        .updateMessageForTesting(msg1.copyWith(status: MessageStatus.replied));
    expect(provider.hasUnansweredMessages, isFalse);
    expect(provider.findLatestReplyableMessage(), isNull);

    provider.clearMessages();
  });
}
