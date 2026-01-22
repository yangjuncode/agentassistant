import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
                    tooltip: l10n.copyTooltip,
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () async {
                      final text = _composeMainMessageCopyText();
                      await Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.messageCopied)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownBody(
                  data: message.displayContent,
                  selectable: false,
                  styleSheet:
                      MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                    p: Theme.of(context).textTheme.bodyMedium,
                    code: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                    codeblockDecoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onTapLink: (text, href, title) {
                    if (href != null) {
                      launchUrl(Uri.parse(href));
                    }
                  },
                ),
                if (message.status == MessageStatus.error) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.error,
                        color: Theme.of(context).colorScheme.error,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ],
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
    final l10n = AppLocalizations.of(context)!;
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
                _getReplyTitle(context),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              IconButton(
                tooltip: l10n.copyTooltip,
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () async {
                  final text = _composeReplyCopyText();
                  await Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.replyCopied)),
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
          MarkdownBody(
            data: message.replyText!,
            selectable: false,
            styleSheet:
                MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: Theme.of(context).textTheme.bodyMedium,
              code: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
              codeblockDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onTapLink: (text, href, title) {
              if (href != null) {
                launchUrl(Uri.parse(href));
              }
            },
          ),
        ],
      ),
    );
  }

  /// Build status chip
  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    String statusText;

    final l10n = AppLocalizations.of(context)!;
    switch (message.status) {
      case MessageStatus.pending:
        chipColor = Theme.of(context).colorScheme.error;
        statusText = l10n.statusPending;
        break;
      case MessageStatus.replied:
        chipColor = Theme.of(context).colorScheme.primary;
        statusText = l10n.statusReplied;
        break;
      case MessageStatus.confirmed:
        chipColor = Colors.green;
        statusText = l10n.statusConfirmed;
        break;
      case MessageStatus.error:
        chipColor = Theme.of(context).colorScheme.error;
        statusText = l10n.statusError;
        break;
      case MessageStatus.expired:
        chipColor = Colors.grey;
        statusText = l10n.statusExpired;
        break;
      case MessageStatus.cancelled:
        chipColor = Colors.orange;
        statusText = l10n.statusCancelled;
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
  String _getReplyTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (message.repliedByCurrentUser) {
      return l10n.yourReply;
    } else {
      final nickname = message.repliedByNickname ?? l10n.otherUser;
      return l10n.replyFrom(nickname);
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
