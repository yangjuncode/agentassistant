import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agentassistant/widgets/inline_reply_widget.dart';
import 'package:agentassistant/models/chat_message.dart';
import 'package:agentassistant/providers/chat_provider.dart';
import 'package:agentassistant/constants/websocket_commands.dart';
import 'package:agentassistant/providers/project_directory_index_provider.dart';
import 'package:agentassistant/providers/mcp_tool_index_provider.dart';
import 'package:agentassistant/config/app_config.dart';
import 'package:agentassistant/services/attachment_service.dart';

class _RecordingChatProvider extends ChatProvider {
  String? lastOutgoingText;
  bool? lastSkipSuffixText;
  bool? lastWasConfirm;

  @override
  Future<void> replyToQuestion(
    String messageId,
    String replyText, {
    List<AttachmentItem>? attachments,
    bool skipSuffixText = false,
  }) async {
    lastWasConfirm = false;
    lastSkipSuffixText = skipSuffixText;
    lastOutgoingText = applySuffixText(
      replyText,
      skipSuffixText: skipSuffixText,
    );
  }

  @override
  Future<void> confirmTask(
    String messageId,
    String? confirmText, {
    List<AttachmentItem>? attachments,
    bool skipSuffixText = false,
  }) async {
    lastWasConfirm = true;
    lastSkipSuffixText = skipSuffixText;
    lastOutgoingText = confirmText == null
        ? null
        : applySuffixText(confirmText, skipSuffixText: skipSuffixText);
  }
}

void main() {
  group('InlineReplyWidget Tests', () {
    late ChatProvider mockChatProvider;
    late ProjectDirectoryIndexProvider projectDirectoryIndexProvider;
    late McpToolIndexProvider mcpToolIndexProvider;
    late ChatMessage testMessage;

    setUp(() {
      SharedPreferences.setMockInitialValues({
        AppConfig.suffixTextStorageKey: 'SUFFIX',
        AppConfig.suffixTextEnabledStorageKey: true,
      });
      mockChatProvider = _RecordingChatProvider();
      projectDirectoryIndexProvider = ProjectDirectoryIndexProvider();
      mcpToolIndexProvider = McpToolIndexProvider();
      addTearDown(() {
        projectDirectoryIndexProvider.dispose();
        mcpToolIndexProvider.dispose();
      });
      testMessage = ChatMessage(
        requestId: 'test-request-id',
        type: MessageType.question,
        question: 'Test question?',
      );
    });

    Widget _wrap(Widget child) {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<ChatProvider>.value(value: mockChatProvider),
            ChangeNotifierProvider<ProjectDirectoryIndexProvider>.value(
              value: projectDirectoryIndexProvider,
            ),
            ChangeNotifierProvider<McpToolIndexProvider>.value(
              value: mcpToolIndexProvider,
            ),
          ],
          child: Scaffold(body: child),
        ),
      );
    }

    Future<void> _pumpWithWideViewport(
        WidgetTester tester, Widget child) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1600, 1200);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_wrap(child));
      await tester.pumpAndSettle();
    }

    testWidgets('should display question reply widget correctly',
        (WidgetTester tester) async {
      await _pumpWithWideViewport(
        tester,
        InlineReplyWidget(message: testMessage),
      );

      // Verify the widget displays correctly
      expect(find.text('回复问题'), findsOneWidget);
      expect(find.text('Test question?'), findsOneWidget);
      expect(find.text('请输入回复内容...'), findsOneWidget);
      expect(find.text('发送'), findsOneWidget);
    });

    testWidgets('should display task confirmation widget correctly',
        (WidgetTester tester) async {
      final taskMessage = ChatMessage(
        requestId: 'test-task-id',
        type: MessageType.task,
        summary: 'Test task summary',
      );

      await _pumpWithWideViewport(
        tester,
        InlineReplyWidget(message: taskMessage),
      );

      // Verify the widget displays correctly for tasks
      expect(find.text('确认任务'), findsOneWidget);
      expect(find.text('Test task summary'), findsOneWidget);
      expect(find.text('添加确认备注...'), findsOneWidget);
      expect(find.text('发送'), findsOneWidget);
    });

    testWidgets('should handle text input correctly',
        (WidgetTester tester) async {
      await _pumpWithWideViewport(
        tester,
        InlineReplyWidget(message: testMessage),
      );

      // Find the text field and enter text
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'Test reply text');
      await tester.pump();

      // Verify text was entered
      expect(find.text('Test reply text'), findsOneWidget);
    });

    testWidgets('should skip suffix when shift-click send button',
        (WidgetTester tester) async {
      final provider = mockChatProvider as _RecordingChatProvider;

      await _pumpWithWideViewport(
        tester,
        InlineReplyWidget(message: testMessage),
      );

      // Enter a text that would normally get suffix appended.
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.tap(find.text('发送').last);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

      expect(provider.lastSkipSuffixText, isTrue);
      expect(provider.lastOutgoingText, equals('Hello'));
    });

    testWidgets('should skip suffix when shift-click quick reply button',
        (WidgetTester tester) async {
      final provider = mockChatProvider as _RecordingChatProvider;

      await _pumpWithWideViewport(
        tester,
        InlineReplyWidget(message: testMessage),
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.tap(find.text('OK'));
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

      expect(provider.lastSkipSuffixText, isTrue);
      expect(provider.lastOutgoingText, equals('OK'));
    });
  });
}
