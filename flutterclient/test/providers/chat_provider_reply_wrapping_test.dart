import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agentassistant/config/app_config.dart';
import 'package:agentassistant/providers/chat_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatProvider reply text wrapping toggle', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        AppConfig.replyTextPrefixStorageKey: '[P]',
        AppConfig.replyTextSuffixStorageKey: '[S]',
      });
    });

    test('formatReplyText should bypass prefix/suffix when wrapping disabled',
        () async {
      final provider = ChatProvider();
      await provider.setReplyTextWrapping(prefix: '[P]', suffix: '[S]');

      final result = provider.formatReplyText(
        'hello',
        applyWrapping: false,
      );

      expect(result, 'hello');
    });

    test('formatReplyText should apply prefix/suffix when wrapping enabled',
        () async {
      final provider = ChatProvider();
      await provider.setReplyTextWrapping(prefix: '[P]', suffix: '[S]');
      await provider.setReplyTextWrappingEnabled(true);

      final result = provider.formatReplyText('hello');

      expect(result, '[P]hello[S]');
    });

    test('setReplyTextWrappingEnabled should persist wrapping default',
        () async {
      final provider = ChatProvider();
      await provider.setReplyTextWrappingEnabled(false);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getBool(AppConfig.replyTextWrappingEnabledStorageKey),
        isFalse,
      );
    });
  });
}
