import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agentassistant/widgets/ask_question_widget.dart';
import 'package:agentassistant/models/chat_message.dart';
import 'package:agentassistant/providers/chat_provider.dart';
import 'package:agentassistant/providers/mcp_tool_index_provider.dart';
import 'package:agentassistant/providers/project_directory_index_provider.dart';
import 'package:agentassistant/proto/agentassist.pb.dart' as pb;
import 'package:agentassistant/constants/websocket_commands.dart';

import '../helpers/fake_chat_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AskQuestionWidget @ autocomplete', () {
    late ChatProvider chatProvider;
    late ProjectDirectoryIndexProvider pathProvider;
    late Directory tempDir;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      chatProvider = FakeChatProvider();
      pathProvider = ProjectDirectoryIndexProvider();
      tempDir = Directory.systemTemp.createTempSync('aq_autocomplete');
      File('${tempDir.path}/alpha_file.txt').createSync();
      File('${tempDir.path}/beta_file.txt').createSync();
      Directory('${tempDir.path}/subdir').createSync();
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    ChatMessage makeMessage() {
      return ChatMessage(
        requestId: 'req-1',
        type: MessageType.question,
        projectDirectory: tempDir.path,
        rawQuestions: [
          pb.Question(
            header: 'Pick',
            question: 'Choose one?',
            options: [
              pb.Option(label: 'Option A', description: 'desc a'),
            ],
          ),
        ],
      );
    }

    Widget buildTestWidget(ChatMessage message) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ChatProvider>.value(value: chatProvider),
          ChangeNotifierProvider<ProjectDirectoryIndexProvider>.value(
              value: pathProvider),
          ChangeNotifierProvider(create: (_) => McpToolIndexProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AskQuestionWidget(message: message),
            ),
          ),
        ),
      );
    }

    testWidgets('typing @ in custom input shows file suggestions',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(makeMessage()));
      // 不能用 pumpAndSettle：provider 里有 Timer.periodic，永不 settle
      await tester.pump();

      // 预建索引
      pathProvider.touchRoot(tempDir.path);
      await tester.runAsync(() => pathProvider.refreshRoot(tempDir.path));
      await tester.pump();

      // 点 Customize（edit_note）按钮展开自定义输入框
      await tester.tap(find.byIcon(Icons.edit_note).first);
      await tester.pump();
      await tester.pump();

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // 输入 @ 触发路径建议（80ms 防抖是假时钟，用 pump 推进）
      await tester.enterText(textField, '@');
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump();

      expect(find.text('alpha_file.txt'), findsOneWidget);
      expect(find.text('beta_file.txt'), findsOneWidget);
    });

    testWidgets(
        'suggestions appear after index finishes building, '
        'without further typing', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(makeMessage()));
      await tester.pump();
      // 让 initState 的 postFrame 预热执行
      await tester.pump();

      // 点 Customize 展开输入框
      await tester.tap(find.byIcon(Icons.edit_note).first);
      await tester.pump();
      await tester.pump();

      // 索引尚未建好（大项目首次需要数秒），输入 @
      await tester.enterText(find.byType(TextField), '@');
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump();

      // 等真实 isolate 建完索引；provider notifyListeners 应触发重算，
      // 无需再敲键列表就弹出
      await tester
          .runAsync(() => Future.delayed(const Duration(milliseconds: 500)));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.text('alpha_file.txt'), findsOneWidget);
    });
  });
}
