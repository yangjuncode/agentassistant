import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

/// Locale provider for managing app language settings
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('zh', 'CN'),
  ];

  /// Current locale (null means follow system)
  Locale? _locale;

  /// Get current locale
  Locale? get locale => _locale;

  /// Check if using system locale
  bool get isSystemLocale => _locale == null;

  LocaleProvider() {
    _loadLocale();
  }

  /// Load saved locale from preferences
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeString = prefs.getString(_localeKey);

      if (localeString != null && localeString.isNotEmpty) {
        if (localeString == 'auto') {
          _locale = null;
        } else if (localeString.contains('_')) {
          final parts = localeString.split('_');
          _locale = Locale(parts[0], parts[1]);
        } else {
          _locale = Locale(localeString);
        }
        notifyListeners();
      }
    } catch (e) {
      // Ignore errors, use default
    }
  }

  /// Set locale and save to preferences
  Future<void> setLocale(Locale? locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.setString(_localeKey, 'auto');
      } else if (locale.countryCode != null) {
        await prefs.setString(
            _localeKey, '${locale.languageCode}_${locale.countryCode}');
      } else {
        await prefs.setString(_localeKey, locale.languageCode);
      }
    } catch (e) {
      // Ignore save errors
    }
  }

  /// Set to system locale (auto)
  Future<void> setSystemLocale() async {
    await setLocale(null);
  }

  /// Set to English
  Future<void> setEnglish() async {
    await setLocale(const Locale('en'));
  }

  /// Set to Chinese
  Future<void> setChinese() async {
    await setLocale(const Locale('zh', 'CN'));
  }

  /// Get display name for current locale setting
  String getLocaleDisplayName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_locale == null) {
      return l10n.languageAuto;
    } else if (_locale!.languageCode == 'zh') {
      return l10n.languageChinese;
    } else {
      return l10n.languageEnglish;
    }
  }
}
