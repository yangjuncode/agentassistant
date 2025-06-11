import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message header
            _buildHeader(context),
            const SizedBox(height: 12),

            // Message content
            _buildContent(context),

            // Inline reply widget (if needs user action and not expired)
            if (message.needsUserAction &&
                message.status != MessageStatus.expired) ...[
              const SizedBox(height: 16),
              InlineReplyWidget(message: message),
            ],

            // Reply content (if replied)
            if (message.replyText != null) ...[
              const SizedBox(height: 16),
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
          padding: const EdgeInsets.all(8),
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
              Text(
                message.displayTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  _buildStatusChip(context),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MM/dd HH:mm').format(message.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
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
          const SizedBox(height: 12),
          ...message.contents.map((content) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ContentDisplay(content: content),
              )),
        ],

        // Project directory info
        if (message.projectDirectory != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.folder,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '项目目录: ${message.projectDirectory}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Build reply content section
  Widget _buildReplyContent(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
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
                '您的回复',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
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
          const SizedBox(height: 8),
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
}
