import 'package:agentassistant/config/app_config.dart';
import 'package:agentassistant/providers/chat_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatProvider suffix text', () {
    test('applySuffixText should append suffix by default and support skipping',
        () async {
      SharedPreferences.setMockInitialValues({
        AppConfig.suffixTextStorageKey: 'SUFFIX',
        AppConfig.suffixTextEnabledStorageKey: true,
      });

      final provider = ChatProvider();

      // Ensure the stored suffix is applied (constructor does async loads).
      await provider.setSuffixText('SUFFIX');
      await provider.setSuffixTextEnabled(true);

      expect(provider.applySuffixText('Hello'), equals('Hello\nSUFFIX'));
      expect(
        provider.applySuffixText('Hello', skipSuffixText: true),
        equals('Hello'),
      );
    });
  });
}
