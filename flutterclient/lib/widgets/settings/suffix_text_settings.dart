import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/chat_provider.dart';

/// Suffix text settings widget for configuring reply suffix
class SuffixTextSettings extends StatefulWidget {
  final String? initialSuffixText;
  final Function(String)? onSuffixTextChanged;

  const SuffixTextSettings({
    super.key,
    this.initialSuffixText,
    this.onSuffixTextChanged,
  });

  @override
  State<SuffixTextSettings> createState() => _SuffixTextSettingsState();
}

class _SuffixTextSettingsState extends State<SuffixTextSettings> {
  late TextEditingController _controller;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialSuffixText ?? '');
    // Schedule loading current suffix text after first frame
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadCurrentSuffixText());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncWithProvider();
  }

  void _syncWithProvider() {
    final chatProvider = context.read<ChatProvider>();
    final suffixText = chatProvider.suffixText;
    if (_controller.text != suffixText && !_isLoading) {
      _controller.text = suffixText;
    }
  }

  void _loadCurrentSuffixText() {
    final chatProvider = context.read<ChatProvider>();
    final suffixText = chatProvider.suffixText;
    if (_controller.text != suffixText) {
      setState(() {
        _controller.text = suffixText;
      });
    }
  }

  Future<void> _saveSuffixText() async {
    if (_isLoading) return;

    final suffixText = _controller.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final chatProvider = context.read<ChatProvider>();
      await chatProvider.setSuffixText(suffixText);

      // Notify parent widget
      widget.onSuffixTextChanged?.call(suffixText);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.suffixTextSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _errorMessage = l10n.suffixTextSaveFailed(e.toString());
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearSuffixText() {
    setState(() {
      _controller.text = '';
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with switch
          SwitchListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            secondary: Icon(
              Icons.post_add,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              l10n.suffixTextSettingsTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            subtitle: Text(
              l10n.suffixTextSettingsSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            value: context.watch<ChatProvider>().suffixTextEnabled,
            onChanged: (value) {
              context.read<ChatProvider>().setSuffixTextEnabled(value);
            },
          ),

          // Input field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(
              controller: _controller,
              enabled: context.watch<ChatProvider>().suffixTextEnabled,
              decoration: InputDecoration(
                labelText: l10n.suffixTextLabel,
                hintText: l10n.suffixTextHint,
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                counterText: '',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSuffixText,
                        tooltip: l10n.suffixTextClear,
                      ),
                    IconButton(
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      onPressed:
                          (!context.watch<ChatProvider>().suffixTextEnabled ||
                                  _isLoading)
                              ? null
                              : _saveSuffixText,
                      tooltip: l10n.suffixTextSave,
                    ),
                  ],
                ),
                errorText: _errorMessage,
              ),
              onSubmitted: (_) => _saveSuffixText(),
              maxLength: 100,
            ),
          ),

          // Preview
          if (_controller.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 2, right: 2, bottom: 2),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.suffixTextPreviewTitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.suffixTextPreviewExample(_controller.text),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: 'monospace',
                          ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
