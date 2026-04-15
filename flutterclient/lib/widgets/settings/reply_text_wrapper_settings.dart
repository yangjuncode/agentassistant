import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/chat_provider.dart';

/// Settings widget for configuring automatic reply text prefix/suffix.
class ReplyTextWrapperSettings extends StatefulWidget {
  const ReplyTextWrapperSettings({super.key});

  @override
  State<ReplyTextWrapperSettings> createState() =>
      _ReplyTextWrapperSettingsState();
}

class _ReplyTextWrapperSettingsState extends State<ReplyTextWrapperSettings> {
  late final TextEditingController _prefixController;
  late final TextEditingController _suffixController;
  String _lastSyncedPrefix = '';
  String _lastSyncedSuffix = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _prefixController = TextEditingController();
    _suffixController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncControllers(context.read<ChatProvider>());
  }

  void _syncControllers(ChatProvider chatProvider) {
    final nextPrefix = chatProvider.replyTextPrefix;
    final nextSuffix = chatProvider.replyTextSuffix;

    if (_prefixController.text == _lastSyncedPrefix &&
        _prefixController.text != nextPrefix) {
      _prefixController.text = nextPrefix;
    }

    if (_suffixController.text == _lastSyncedSuffix &&
        _suffixController.text != nextSuffix) {
      _suffixController.text = nextSuffix;
    }

    _lastSyncedPrefix = nextPrefix;
    _lastSyncedSuffix = nextSuffix;
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _suffixController.dispose();
    super.dispose();
  }

  bool _hasChanges(ChatProvider chatProvider) {
    return _prefixController.text != chatProvider.replyTextPrefix ||
        _suffixController.text != chatProvider.replyTextSuffix;
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await context.read<ChatProvider>().setReplyTextWrapping(
            prefix: _prefixController.text,
            suffix: _suffixController.text,
          );

      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.replyTextWrappingSaved)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _clearFields() {
    setState(() {
      _prefixController.clear();
      _suffixController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chatProvider = context.watch<ChatProvider>();
    _syncControllers(chatProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.text_fields,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.replyTextWrappingTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.replyTextWrappingSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _prefixController,
            minLines: 1,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.replyTextPrefixLabel,
              hintText: l10n.replyTextPrefixHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _suffixController,
            minLines: 1,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.replyTextSuffixLabel,
              hintText: l10n.replyTextSuffixHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isSaving ? null : _clearFields,
                child: Text(l10n.clear),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed:
                    _isSaving || !_hasChanges(chatProvider) ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(l10n.save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
