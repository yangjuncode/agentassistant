// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agentassistant/main.dart';

void main() {
  testWidgets('App starts with login screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const AgentAssistantApp());

    // Let splash screen complete navigation.
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that we start with the login screen
    expect(find.text('Agent Assistant'), findsOneWidget);
    expect(find.text('连接到您的 AI Agent 助手'), findsOneWidget);
    expect(find.text('访问令牌'), findsOneWidget);
  });
}
