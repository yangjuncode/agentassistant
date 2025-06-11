import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../constants/websocket_commands.dart';

/// Inline reply widget for replying to messages without dialog
class InlineReplyWidget extends StatefulWidget {
  final ChatMessage message;

  const InlineReplyWidget({
    super.key,
    required this.message,
  });

  @override
  State<InlineReplyWidget> createState() => _InlineReplyWidgetState();
}

class _InlineReplyWidgetState extends State<InlineReplyWidget> {
  late TextEditingController _controller;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final replyText = _controller.text.trim();
    if (replyText.isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final chatProvider = context.read<ChatProvider>();

      if (widget.message.type == MessageType.question) {
        await chatProvider.replyToQuestion(widget.message.id, replyText);
      } else if (widget.message.type == MessageType.task) {
        await chatProvider.confirmTask(widget.message.id, replyText);
      }
    } catch (error) {
      // Error handling is done in ChatProvider
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发送失败: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with question/task info
          _buildHeader(context),
          const SizedBox(height: 12),

          // Text input field
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: _getInputLabel(),
              hintText: _getInputHint(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            maxLines: 3,
            minLines: 2,
            autofocus: true,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 12),

          // Action button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _handleSubmit,
                icon: _isSubmitting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : const Icon(Icons.send, size: 18),
                label: Text(_isSubmitting ? '发送中...' : '发送'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          _getHeaderIcon(),
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getHeaderTitle(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              if (_getHeaderSubtitle() != null) ...[
                const SizedBox(height: 2),
                Text(
                  _getHeaderSubtitle()!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  IconData _getHeaderIcon() {
    switch (widget.message.type) {
      case MessageType.question:
        return Icons.help_outline;
      case MessageType.task:
        return Icons.task_alt;
      case MessageType.reply:
        return Icons.reply;
    }
  }

  String _getHeaderTitle() {
    switch (widget.message.type) {
      case MessageType.question:
        return '回复问题';
      case MessageType.task:
        return '确认任务';
      case MessageType.reply:
        return '回复';
    }
  }

  String? _getHeaderSubtitle() {
    if (widget.message.question != null) {
      return widget.message.question;
    }
    if (widget.message.summary != null) {
      return widget.message.summary;
    }
    return null;
  }

  String _getInputLabel() {
    switch (widget.message.type) {
      case MessageType.question:
        return '您的回复';
      case MessageType.task:
        return '确认备注（可选）';
      case MessageType.reply:
        return '回复内容';
    }
  }

  String _getInputHint() {
    switch (widget.message.type) {
      case MessageType.question:
        return '请输入回复内容...';
      case MessageType.task:
        return '添加确认备注...';
      case MessageType.reply:
        return '请输入回复内容...';
    }
  }
}
