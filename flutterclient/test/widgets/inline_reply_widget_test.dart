import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agentassistant/widgets/inline_reply_widget.dart';
import 'package:agentassistant/config/app_config.dart';
import 'package:agentassistant/models/chat_message.dart';
import 'package:agentassistant/providers/chat_provider.dart';
import 'package:agentassistant/constants/websocket_commands.dart';
import 'package:agentassistant/services/attachment_service.dart';

void main() {
  group('InlineReplyWidget Tests', () {
    late _TestChatProvider mockChatProvider;
    late ChatMessage testMessage;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockChatProvider = _TestChatProvider();
      testMessage = ChatMessage(
        requestId: 'test-request-id',
        type: MessageType.question,
        question: 'Test question?',
      );
    });

    tearDown(() {
      mockChatProvider.dispose();
    });

    Widget buildTestHost(ChatMessage message) {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<ChatProvider>.value(value: mockChatProvider),
          ],
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 460,
                child: InlineReplyWidget(message: message),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('should display question reply widget correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestHost(testMessage));
      await tester.pumpAndSettle();

      // Verify the widget displays correctly
      expect(find.text('回复问题'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should display task confirmation widget correctly',
        (WidgetTester tester) async {
      final taskMessage = ChatMessage(
        requestId: 'test-task-id',
        type: MessageType.task,
        summary: 'Test task summary',
      );

      await tester.pumpWidget(buildTestHost(taskMessage));
      await tester.pumpAndSettle();

      // Verify the widget displays correctly for tasks
      expect(find.text('确认任务'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should handle text input correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestHost(testMessage));
      await tester.pumpAndSettle();

      // Find the text field and enter text
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'Test reply text');
      await tester.pump();

      // Verify text was entered
      expect(find.text('Test reply text'), findsOneWidget);
    });

    testWidgets('should show wrapping toggle below reply input',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestHost(testMessage));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('should honor persisted wrapping default in toggle',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        AppConfig.replyTextWrappingEnabledStorageKey: false,
      });
      mockChatProvider = _TestChatProvider();

      await tester.pumpWidget(buildTestHost(testMessage));
      await tester.pumpAndSettle();

      final wrappingSwitch = tester.widget<Switch>(find.byType(Switch));
      expect(wrappingSwitch.value, isFalse);
    });

    testWidgets('should pass toggle state when submitting reply',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestHost(testMessage));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '结束会话');
      final wrappingSwitch = tester.widget<Switch>(find.byType(Switch));
      expect(wrappingSwitch.value, isTrue);
      wrappingSwitch.onChanged?.call(false);
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(mockChatProvider.lastReplyText, '结束会话');
      expect(mockChatProvider.lastReplyApplyWrapping, isFalse);
    });
  });
}

class _TestChatProvider extends ChatProvider {
  String? lastReplyText;
  bool? lastReplyApplyWrapping;
  String? lastConfirmText;
  bool? lastConfirmApplyWrapping;

  @override
  Future<void> replyToQuestion(
    String messageId,
    String replyText, {
    List<AttachmentItem>? attachments,
    bool? applyWrapping,
  }) async {
    lastReplyText = replyText;
    lastReplyApplyWrapping = applyWrapping;
  }

  @override
  Future<void> confirmTask(
    String messageId,
    String? confirmText, {
    List<AttachmentItem>? attachments,
    bool? applyWrapping,
  }) async {
    lastConfirmText = confirmText;
    lastConfirmApplyWrapping = applyWrapping;
  }
}
