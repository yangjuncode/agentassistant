import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      setState(() {
        _errorMessage = '加载昵称失败: $e';
      });
    }
  }

  Future<void> _saveNickname() async {
    final nickname = _controller.text.trim();

    if (nickname.isEmpty) {
      setState(() {
        _errorMessage = '昵称不能为空';
      });
      return;
    }

    if (nickname.length < 2) {
      setState(() {
        _errorMessage = '昵称至少需要2个字符';
      });
      return;
    }

    if (nickname.length > 20) {
      setState(() {
        _errorMessage = '昵称不能超过20个字符';
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('昵称已保存并同步到服务器'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = '保存昵称失败: $e';
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
    final adjectives = ['聪明的', '勤奋的', '友善的', '活跃的', '创新的', '专业的'];
    final nouns = ['开发者', '用户', '助手', '伙伴', '同事', '朋友'];

    final adjective =
        adjectives[DateTime.now().millisecond % adjectives.length];
    final noun = nouns[DateTime.now().second % nouns.length];
    final number = DateTime.now().millisecond % 1000;

    return '$adjective$noun$number';
  }

  @override
  Widget build(BuildContext context) {
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
                  '昵称设置',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '设置您在聊天中显示的昵称',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),

            // Nickname input
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '昵称',
                hintText: '请输入您的昵称',
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
                  label: const Text('重新生成'),
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
                      child: const Text('清空'),
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
                      label: Text(_isLoading ? '保存中...' : '保存'),
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
                    '提示：',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• 昵称长度为2-20个字符\n'
                    '• 昵称将显示在您的回复中\n'
                    '• 其他用户可以看到您的昵称',
                    style: TextStyle(fontSize: 12),
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
    final adjectives = ['聪明的', '勤奋的', '友善的', '活跃的', '创新的', '专业的'];
    final nouns = ['开发者', '用户', '助手', '伙伴', '同事', '朋友'];

    final now = DateTime.now();
    final adjective = adjectives[now.millisecond % adjectives.length];
    final noun = nouns[now.second % nouns.length];
    final number = now.millisecond % 1000;

    return '$adjective$noun$number';
  }
}
