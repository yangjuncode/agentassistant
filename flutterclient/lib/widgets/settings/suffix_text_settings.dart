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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurrentSuffixText());
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
            content: Text('后缀文本已保存'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '保存失败: $e';
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
                  Icons.post_add,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '后缀文本设置',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '设置回复时自动添加的后缀文本，会在你的输入后面自动加上空格和后缀',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 12),

          // Input field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '后缀文本',
                hintText: '例如：--来自手机',
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSuffixText,
                        tooltip: '清空',
                      ),
                    IconButton(
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      onPressed: _isLoading ? null : _saveSuffixText,
                      tooltip: '保存',
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '预览效果：',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '用户输入："好的" → 实际发送："好的 ${_controller.text}"',
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