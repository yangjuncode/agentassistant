import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/chat_provider.dart';

/// Nickname settings widget for configuring user display name
class NicknameSettings extends StatefulWidget {
  final String? initialNickname;
  final Function(String)? onNicknameChanged;

  const NicknameSettings({
    super.key,
    this.initialNickname,
    this.onNicknameChanged,
  });

  @override
  State<NicknameSettings> createState() => _NicknameSettingsState();
}

class _NicknameSettingsState extends State<NicknameSettings> {
  late TextEditingController _controller;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNickname ?? '');
    // Schedule loading current nickname after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurrentNickname());
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
    final nickname = chatProvider.nickname;

    // Only update if the controller is empty or if the nickname changed
    // and we are not currently editing (to avoid jumping cursor)
    if (nickname != null &&
        (_controller.text.isEmpty ||
            (_controller.text != nickname && !_isLoading))) {
      setState(() {
        _controller.text = nickname;
      });
    }
  }

  void _loadCurrentNickname() {
    _syncWithProvider();
  }

  Future<void> _saveNickname() async {
    final nickname = _controller.text.trim();

    if (nickname.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.nicknameEmptyError;
      });
      return;
    }

    if (nickname.length < 2) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.nicknameTooShortError;
      });
      return;
    }

    if (nickname.length > 20) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.nicknameTooLongError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use ChatProvider to update nickname and send to server
      final chatProvider = context.read<ChatProvider>();
      await chatProvider.updateNickname(nickname);

      // Notify parent widget
      widget.onNicknameChanged?.call(nickname);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.nicknameSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _errorMessage = l10n.nicknameSaveFailed(e.toString());
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

  void _resetNickname() {
    final defaultNickname = NicknameHelper.generateDefaultNickname();
    setState(() {
      _controller.text = defaultNickname;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.nicknameSettingsTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              l10n.nicknameSettingsSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 16),

          // Nickname input
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: l10n.nicknameLabel,
              hintText: l10n.nicknameHint,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.badge),
              errorText: _errorMessage,
              counterText: '${_controller.text.length}/20',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            maxLength: 20,
            onChanged: (value) {
              setState(() {
                _errorMessage = null;
              });
            },
            onSubmitted: (_) => _saveNickname(),
          ),
          const SizedBox(height: 12),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _isLoading ? null : _resetNickname,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.refresh, size: 20),
                label: Text(l10n.nicknameRegenerate),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            _controller.clear();
                            setState(() {
                              _errorMessage = null;
                            });
                          },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(l10n.nicknameClear),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveNickname,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save, size: 20),
                    label: Text(
                        _isLoading ? l10n.nicknameSaving : l10n.nicknameSave),
                  ),
                ],
              ),
            ],
          ),

          // Help text
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.nicknameTipsTitle,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.nicknameTipsBody,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Static helper methods for nickname management
class NicknameHelper {
  /// Generate a default nickname
  static String generateDefaultNickname() {
    final adjectives = [
      'Smart',
      'Diligent',
      'Friendly',
      'Active',
      'Creative',
      'Professional'
    ];
    final nouns = [
      'Developer',
      'User',
      'Assistant',
      'Partner',
      'Colleague',
      'Friend'
    ];

    final now = DateTime.now();
    final adjective = adjectives[now.millisecond % adjectives.length];
    final noun = nouns[now.second % nouns.length];
    final number = now.millisecond % 1000;

    return '$adjective$noun$number';
  }
}
