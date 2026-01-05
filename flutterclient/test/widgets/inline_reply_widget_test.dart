import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agentassistant/widgets/inline_reply_widget.dart';
import 'package:agentassistant/models/chat_message.dart';
import 'package:agentassistant/providers/chat_provider.dart';
import 'package:agentassistant/constants/websocket_commands.dart';

void main() {
  group('InlineReplyWidget Tests', () {
    late ChatProvider mockChatProvider;
    late ChatMessage testMessage;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockChatProvider = ChatProvider();
      testMessage = ChatMessage(
        requestId: 'test-request-id',
        type: MessageType.question,
        question: 'Test question?',
      );
    });

    testWidgets('should display question reply widget correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ChatProvider>.value(
            value: mockChatProvider,
            child: Scaffold(
              body: InlineReplyWidget(message: testMessage),
            ),
          ),
        ),
      );

      // Verify the widget displays correctly
      expect(find.text('回复问题'), findsOneWidget);
      expect(find.text('Test question?'), findsOneWidget);
      expect(find.text('您的回复'), findsOneWidget);
      expect(find.text('发送'), findsOneWidget);
    });

    testWidgets('should display task confirmation widget correctly',
        (WidgetTester tester) async {
      final taskMessage = ChatMessage(
        requestId: 'test-task-id',
        type: MessageType.task,
        summary: 'Test task summary',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ChatProvider>.value(
            value: mockChatProvider,
            child: Scaffold(
              body: InlineReplyWidget(message: taskMessage),
            ),
          ),
        ),
      );

      // Verify the widget displays correctly for tasks
      expect(find.text('确认任务'), findsOneWidget);
      expect(find.text('Test task summary'), findsOneWidget);
      expect(find.text('确认备注（可选）'), findsOneWidget);
      expect(find.text('发送'), findsOneWidget);
    });

    testWidgets('should handle text input correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ChatProvider>.value(
            value: mockChatProvider,
            child: Scaffold(
              body: InlineReplyWidget(message: testMessage),
            ),
          ),
        ),
      );

      // Find the text field and enter text
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'Test reply text');
      await tester.pump();

      // Verify text was entered
      expect(find.text('Test reply text'), findsOneWidget);
    });
  });
}
