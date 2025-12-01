import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../models/chat_message.dart';
import '../constants/websocket_commands.dart';
import 'content_display.dart';
import 'inline_reply_widget.dart';

/// Message bubble widget for displaying chat messages
class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message header
            _buildHeader(context),
            const SizedBox(height: 2),

            // Message content
            _buildContent(context),

            // Inline reply widget (if needs user action and not expired)
            if (message.needsUserAction &&
                message.status != MessageStatus.expired) ...[
              const SizedBox(height: 2),
              InlineReplyWidget(message: message),
            ],

            // Reply content (if replied)
            if (message.replyText != null) ...[
              const SizedBox(height: 2),
              _buildReplyContent(context),
            ],
          ],
        ),
      ),
    );
  }

  /// Build message header with type, status, and timestamp
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Message type icon
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _getTypeColor(context).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTypeIcon(),
            color: _getTypeColor(context),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),

        // Message title and status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      message.displayTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: '复制',
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () async {
                      final text = _composeMainMessageCopyText();
                      await Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('消息已复制到剪贴板')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  _buildStatusChip(context),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MM/dd HH:mm').format(message.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  if (message.projectDirectory != null) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.folder,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${message.projectDirectory}',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build message content
  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main text content
        if (message.displayContent.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message.displayContent,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],

        // Additional content items
        if (message.contents.isNotEmpty) ...[
          const SizedBox(height: 2),
          ...message.contents.map((content) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ContentDisplay(content: content),
              )),
        ],
      ],
    );
  }

  /// Build reply content section
  Widget _buildReplyContent(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.reply,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                _getReplyTitle(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              IconButton(
                tooltip: '复制',
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () async {
                  final text = _composeReplyCopyText();
                  await Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('回复已复制到剪贴板')),
                  );
                },
              ),
              const Spacer(),
              if (message.repliedAt != null)
                Text(
                  DateFormat('MM/dd HH:mm').format(message.repliedAt!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            message.replyText!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Build status chip
  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    String statusText;

    switch (message.status) {
      case MessageStatus.pending:
        chipColor = Theme.of(context).colorScheme.error;
        statusText = '待处理';
        break;
      case MessageStatus.replied:
        chipColor = Theme.of(context).colorScheme.primary;
        statusText = '已回复';
        break;
      case MessageStatus.confirmed:
        chipColor = Colors.green;
        statusText = '已确认';
        break;
      case MessageStatus.error:
        chipColor = Theme.of(context).colorScheme.error;
        statusText = '错误';
        break;
      case MessageStatus.expired:
        chipColor = Colors.grey;
        statusText = '已过期';
        break;
      case MessageStatus.cancelled:
        chipColor = Colors.orange;
        statusText = '已取消';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  /// Get icon for message type
  IconData _getTypeIcon() {
    switch (message.type) {
      case MessageType.question:
        return Icons.help_outline;
      case MessageType.task:
        return Icons.task_alt;
      case MessageType.reply:
        return Icons.reply;
    }
  }

  /// Get color for message type
  Color _getTypeColor(BuildContext context) {
    switch (message.type) {
      case MessageType.question:
        return Theme.of(context).colorScheme.primary;
      case MessageType.task:
        return Colors.orange;
      case MessageType.reply:
        return Colors.green;
    }
  }

  /// Get reply title based on who replied
  String _getReplyTitle() {
    if (message.repliedByCurrentUser) {
      return '您的回复';
    } else {
      final nickname = message.repliedByNickname ?? '其他用户';
      return '$nickname的回复';
    }
  }

  /// Compose text to copy for the main message (received question/task or generic reply message)
  String _composeMainMessageCopyText() {
    // Only original text body
    return message.displayContent.trim();
  }

  /// Compose text to copy for the reply section
  String _composeReplyCopyText() {
    // Only reply text
    return (message.replyText ?? '').trim();
  }
}
