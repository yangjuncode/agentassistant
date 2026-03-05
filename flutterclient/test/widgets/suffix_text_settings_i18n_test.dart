import 'package:agentassistant/l10n/app_localizations.dart';
import 'package:agentassistant/providers/chat_provider.dart';
import 'package:agentassistant/widgets/settings/suffix_text_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows English copy when locale is en', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChangeNotifierProvider<ChatProvider>(
          create: (_) => ChatProvider(),
          child: const Scaffold(
            body: SuffixTextSettings(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Suffix Text Settings'), findsOneWidget);
    expect(find.text('Suffix Text'), findsOneWidget);
    expect(find.byTooltip('Save'), findsOneWidget);
  });
}
