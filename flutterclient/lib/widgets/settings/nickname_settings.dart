import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _loadNickname();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadNickname() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedNickname = prefs.getString('user_nickname');
      if (savedNickname != null && savedNickname.isNotEmpty) {
        setState(() {
          _controller.text = savedNickname;
        });
      } else if (_controller.text.isEmpty) {
        // Generate default nickname if none exists
        final defaultNickname = _generateDefaultNickname();
        setState(() {
          _controller.text = defaultNickname;
        });
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = l10n.nicknameLoadFailed(e.toString());
      });
    }
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
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = l10n.nicknameSaveFailed(e.toString());
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetNickname() {
    final defaultNickname = _generateDefaultNickname();
    setState(() {
      _controller.text = defaultNickname;
      _errorMessage = null;
    });
  }

  String _generateDefaultNickname() {
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

    final adjective =
        adjectives[DateTime.now().millisecond % adjectives.length];
    final noun = nouns[DateTime.now().second % nouns.length];
    final number = DateTime.now().millisecond % 1000;

    return '$adjective$noun$number';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
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
            const SizedBox(height: 8),
            Text(
              l10n.nicknameSettingsSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              ),
              maxLength: 20,
              onChanged: (value) {
                setState(() {
                  _errorMessage = null;
                });
              },
              onSubmitted: (_) => _saveNickname(),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _isLoading ? null : _resetNickname,
                  icon: const Icon(Icons.refresh),
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
                      child: Text(l10n.nicknameClear),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveNickname,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                          _isLoading ? l10n.nicknameSaving : l10n.nicknameSave),
                    ),
                  ],
                ),
              ],
            ),

            // Help text
            const SizedBox(height: 16),
            Container(
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
      ),
    );
  }
}

/// Static helper methods for nickname management
class NicknameHelper {
  static const String _nicknameKey = 'user_nickname';

  /// Get saved nickname from SharedPreferences
  static Future<String?> getSavedNickname() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_nicknameKey);
    } catch (e) {
      return null;
    }
  }

  /// Save nickname to SharedPreferences
  static Future<bool> saveNickname(String nickname) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_nicknameKey, nickname);
    } catch (e) {
      return false;
    }
  }

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
