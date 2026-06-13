import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agentassistant/constants/websocket_commands.dart';
import 'package:agentassistant/models/chat_message.dart';
import 'package:agentassistant/providers/chat_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('multiple pending messages do not auto-enable pending-only filter', () {
    SharedPreferences.setMockInitialValues({});

    final provider = ChatProvider();

    provider.addMessageForTesting(
      ChatMessage(
        requestId: 'question-1',
        type: MessageType.question,
        question: 'Question 1?',
      ),
    );
    provider.addMessageForTesting(
      ChatMessage(
        requestId: 'task-1',
        type: MessageType.task,
        summary: 'Task 1 complete',
      ),
    );

    expect(provider.pendingQuestions, hasLength(1));
    expect(provider.pendingTasks, hasLength(1));
    expect(provider.showOnlyPendingMessages, isFalse);
    expect(provider.visibleMessages, hasLength(2));

    provider.clearMessages();
  });
}
