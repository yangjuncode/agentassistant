import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agentassistant/widgets/inline_reply_widget.dart';
import 'package:agentassistant/models/chat_message.dart';
import 'package:agentassistant/providers/chat_provider.dart';
import 'package:agentassistant/providers/mcp_tool_index_provider.dart';
import 'package:agentassistant/providers/project_directory_index_provider.dart';
import 'package:agentassistant/constants/websocket_commands.dart';

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

    Widget buildTestWidget(ChatMessage message) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ChatProvider>.value(value: mockChatProvider),
          ChangeNotifierProvider(
              create: (_) => ProjectDirectoryIndexProvider()),
          ChangeNotifierProvider(create: (_) => McpToolIndexProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: InlineReplyWidget(message: message),
          ),
        ),
      );
    }

    testWidgets('should display question reply widget correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(testMessage));

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

      await tester.pumpWidget(buildTestWidget(taskMessage));

      // Verify the widget displays correctly for tasks
      expect(find.text('确认任务'), findsOneWidget);
      expect(find.text('Test task summary'), findsOneWidget);
      expect(find.text('添加确认备注...'), findsOneWidget);
      expect(find.text('发送'), findsOneWidget);
    });

    testWidgets('should handle text input correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(testMessage));

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
