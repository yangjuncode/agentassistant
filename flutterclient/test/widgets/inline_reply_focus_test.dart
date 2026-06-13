import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agentassistant/constants/websocket_commands.dart';
import 'package:agentassistant/models/chat_message.dart';
import 'package:agentassistant/providers/chat_provider.dart';
import 'package:agentassistant/providers/mcp_tool_index_provider.dart';
import 'package:agentassistant/providers/project_directory_index_provider.dart';
import 'package:agentassistant/widgets/inline_reply_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'inline reply does not autofocus when multiple actions are pending',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final provider = ChatProvider();
    final firstMessage = ChatMessage(
      requestId: 'question-1',
      type: MessageType.question,
      question: 'Question 1?',
    );

    provider
      ..addMessageForTesting(firstMessage)
      ..addMessageForTesting(
        ChatMessage(
          requestId: 'task-1',
          type: MessageType.task,
          summary: 'Task 1 complete',
        ),
      );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ChatProvider>.value(value: provider),
          ChangeNotifierProvider(
              create: (_) => ProjectDirectoryIndexProvider()),
          ChangeNotifierProvider(create: (_) => McpToolIndexProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: InlineReplyWidget(message: firstMessage),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(FocusManager.instance.primaryFocus?.context?.widget,
        isNot(isA<EditableText>()));

    provider.clearMessages();
  });
}
