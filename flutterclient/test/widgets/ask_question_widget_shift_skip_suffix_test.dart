import 'package:agentassistant/config/app_config.dart';
import 'package:agentassistant/models/chat_message.dart';
import 'package:agentassistant/constants/websocket_commands.dart';
import 'package:agentassistant/providers/chat_provider.dart';
import 'package:agentassistant/providers/mcp_tool_index_provider.dart';
import 'package:agentassistant/providers/project_directory_index_provider.dart';
import 'package:agentassistant/proto/agentassist.pb.dart' as pb;
import 'package:agentassistant/services/attachment_service.dart';
import 'package:agentassistant/widgets/ask_question_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingChatProvider extends ChatProvider {
  String? lastOutgoingText;
  bool? lastSkipSuffixText;

  @override
  Future<void> replyToQuestion(
    String messageId,
    String replyText, {
    List<AttachmentItem>? attachments,
    bool skipSuffixText = false,
  }) async {
    lastSkipSuffixText = skipSuffixText;
    lastOutgoingText =
        applySuffixText(replyText, skipSuffixText: skipSuffixText);
  }
}

void main() {
  testWidgets('shift-click option auto-reply should skip suffix',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      AppConfig.suffixTextStorageKey: 'SUFFIX',
      AppConfig.suffixTextEnabledStorageKey: true,
      // Make the behavior explicit (default is true).
      'auto_reply_ask_question': true,
    });

    final provider = _RecordingChatProvider();
    final projectDirectoryIndexProvider = ProjectDirectoryIndexProvider();
    final mcpToolIndexProvider = McpToolIndexProvider();
    await provider.setSuffixText('SUFFIX');
    await provider.setSuffixTextEnabled(true);

    final question = pb.Question()
      ..header = 'Header'
      ..question = 'Question'
      ..multiple = false
      ..options.add(pb.Option()..label = 'OptionA');

    final message = ChatMessage(
      requestId: 'test-request-id',
      type: MessageType.question,
      rawQuestions: [question],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<ChatProvider>.value(value: provider),
            ChangeNotifierProvider<ProjectDirectoryIndexProvider>.value(
              value: projectDirectoryIndexProvider,
            ),
            ChangeNotifierProvider<McpToolIndexProvider>.value(
              value: mcpToolIndexProvider,
            ),
          ],
          child: Scaffold(
            body: AskQuestionWidget(message: message),
          ),
        ),
      ),
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.tap(find.text('OptionA'));
    await tester.pump();
    await tester.pump();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

    expect(provider.lastSkipSuffixText, isTrue);
    expect(provider.lastOutgoingText, equals('Q: Header\nA: OptionA'));

    await tester.pumpWidget(const SizedBox.shrink());
    projectDirectoryIndexProvider.dispose();
    mcpToolIndexProvider.dispose();
  });
}
