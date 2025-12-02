import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';

/// Language settings widget for selecting app language
class LanguageSettings extends StatelessWidget {
  const LanguageSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.language),
      subtitle: Text(_getLocaleDisplayName(context, localeProvider)),
      onTap: () => _showLanguageDialog(context),
    );
  }

  String _getLocaleDisplayName(BuildContext context, LocaleProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    if (provider.locale == null) {
      return l10n.languageAuto;
    } else if (provider.locale!.languageCode == 'zh') {
      return l10n.languageChinese;
    } else {
      return l10n.languageEnglish;
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.read<LocaleProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context,
              l10n.languageAuto,
              null,
              localeProvider,
            ),
            _buildLanguageOption(
              context,
              l10n.languageEnglish,
              const Locale('en'),
              localeProvider,
            ),
            _buildLanguageOption(
              context,
              l10n.languageChinese,
              const Locale('zh', 'CN'),
              localeProvider,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String title,
    Locale? locale,
    LocaleProvider provider,
  ) {
    final isSelected = _isLocaleSelected(locale, provider);

    return ListTile(
      title: Text(title),
      leading: Radio<bool>(
        value: true,
        groupValue: isSelected,
        onChanged: (_) {
          provider.setLocale(locale);
          Navigator.of(context).pop();
        },
      ),
      onTap: () {
        provider.setLocale(locale);
        Navigator.of(context).pop();
      },
    );
  }

  bool _isLocaleSelected(Locale? locale, LocaleProvider provider) {
    if (locale == null) {
      return provider.locale == null;
    }
    if (provider.locale == null) {
      return false;
    }
    return provider.locale!.languageCode == locale.languageCode;
  }
}
