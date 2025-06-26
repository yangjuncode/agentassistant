import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fixnum/fixnum.dart';

import '../providers/chat_provider.dart';
import '../proto/agentassist.pb.dart' as pb;

/// Widget that displays online users in a horizontal bar below the app bar
class OnlineUsersBar extends StatelessWidget {
  const OnlineUsersBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final allOnlineUsers = chatProvider.onlineUsers;
        final currentClientId = chatProvider.currentClientId;

        // Filter out current user
        final onlineUsers = allOnlineUsers
            .where((user) => user.clientId != currentClientId)
            .toList();

        if (!chatProvider.isConnected || onlineUsers.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.3),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '在线用户 (${onlineUsers.length})',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => chatProvider.requestOnlineUsers(),
                    icon: const Icon(Icons.refresh),
                    iconSize: 16,
                    tooltip: '刷新在线用户',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: onlineUsers
                    .map((user) => _buildUserChip(context, chatProvider, user))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserChip(
      BuildContext context, ChatProvider chatProvider, pb.OnlineUser user) {
    final isActive = chatProvider.activeChatUserId == user.clientId;
    final hasUnreadMessages =
        chatProvider.getChatMessages(user.clientId).isNotEmpty;

    return InkWell(
      onTap: () => _showChatDialog(context, chatProvider, user),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              user.nickname.isNotEmpty
                  ? user.nickname
                  : 'User_${user.clientId.substring(0, 8)}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
            if (hasUnreadMessages) ...[
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showChatDialog(
      BuildContext context, ChatProvider chatProvider, pb.OnlineUser user) {
    showDialog(
      context: context,
      builder: (context) => _ChatDialog(
        chatProvider: chatProvider,
        user: user,
      ),
    );
  }
}

class _ChatDialog extends StatefulWidget {
  final ChatProvider chatProvider;
  final pb.OnlineUser user;

  const _ChatDialog({
    required this.chatProvider,
    required this.user,
  });

  @override
  State<_ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends State<_ChatDialog> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Defer setting active chat user to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.chatProvider.setActiveChatUser(widget.user.clientId);
      _scrollToBottom();
    });

    // Listen for active chat user changes (e.g., when user disconnects)
    widget.chatProvider.addListener(_onChatProviderChanged);
  }

  void _onChatProviderChanged() {
    // If the active chat user was cleared (likely due to disconnection), close dialog
    if (widget.chatProvider.activeChatUserId == null) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    widget.chatProvider.removeListener(_onChatProviderChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    // Use addPostFrameCallback to avoid calling setState during dispose
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.chatProvider.setActiveChatUser(null);
    });
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    String content = _messageController.text.trim();
    if (content.isEmpty) return;

    // Check if the message ends with a comma, if not, append one
    if (!content.endsWith(',')) {
      content = '$content,';
    }

    widget.chatProvider.sendChatMessage(widget.user.clientId, content);
    _messageController.clear();

    // Scroll to bottom and refocus input after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      _inputFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS;

    // Define widgets to be used in the layout
    final headerWidget = Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.user.nickname.isNotEmpty
                ? widget.user.nickname
                : 'User_${widget.user.clientId.substring(0, 8)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );

    final messagesWidget = Expanded(
      child: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          final messages = chatProvider.getChatMessages(widget.user.clientId);
          if (messages.isEmpty) {
            return const Center(child: Text('还没有聊天消息'));
          }
          return ListView.builder(
            controller: _scrollController,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isFromMe =
                  message.senderClientId == widget.chatProvider.currentClientId;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: isFromMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 250),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isFromMe
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.content,
                            style: TextStyle(
                              color: isFromMe
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatMessageTime(message.sentAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: isFromMe
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withValues(alpha: 0.7)
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );

    final inputWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Focus(
            onKeyEvent: (FocusNode node, KeyEvent event) {
              // Check for Ctrl+Enter key combination
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.enter &&
                  (HardwareKeyboard.instance.isControlPressed ||
                      HardwareKeyboard.instance.isMetaPressed)) {
                _sendMessage();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: TextField(
              controller: _messageController,
              focusNode: _inputFocusNode,
              decoration: const InputDecoration(
                hintText: '输入消息... (Ctrl+Enter 发送)',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 4,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              onSubmitted:
                  null, // Disable Enter to send, use Ctrl+Enter instead
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _sendMessage,
          icon: const Icon(Icons.send),
        ),
      ],
    );

    // Build the layout based on the platform
    return Dialog(
      child: Container(
        width: 400,
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            headerWidget,
            const Divider(),
            if (isMobile) ...[
              inputWidget,
              const SizedBox(height: 8),
            ],
            messagesWidget,
            if (!isMobile) ...[
              const Divider(),
              inputWidget,
            ],
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(Int64 sentAt) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(sentAt.toInt() * 1000);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today: show only time
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return '昨天 ${DateFormat('HH:mm').format(dateTime)}';
    } else if (dateTime.year == now.year) {
      // This year: show month/day and time
      return DateFormat('MM/dd HH:mm').format(dateTime);
    } else {
      // Different year: show full date and time
      return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
    }
  }
}
