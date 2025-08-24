import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
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
                .withOpacity(0.3),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
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
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
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
  final FocusNode _inputFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final Logger _logger = Logger();
  Timer? _autoSendTimer;
  int _lastSentTextLength = 0;

  @override
  void initState() {
    super.initState();
    // Defer focus request to post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _safeInitialize();
      }
    });
  }

  // Safe initialization with error handling
  void _safeInitialize() {
    try {
      _inputFocusNode.requestFocus();
      _logger.d('Chat dialog initialized successfully');
    } catch (e, stack) {
      _logger.e('Error initializing chat dialog', error: e, stackTrace: stack);
    }
  }

  @override
  void dispose() {
    try {
      _messageController.dispose();
      _inputFocusNode.dispose();
      _scrollController.dispose();
      _clearAutoSendTimer();
    } catch (e, stack) {
      _logger.e('Error disposing chat dialog resources',
          error: e, stackTrace: stack);
    } finally {
      super.dispose();
    }
  }

  void _scrollToBottom() {
    try {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e, stack) {
      _logger.e('Error scrolling to bottom', error: e, stackTrace: stack);
    }
  }

  // Auto-send functionality
  void _clearAutoSendTimer() {
    try {
      if (_autoSendTimer != null) {
        _autoSendTimer?.cancel();
        _autoSendTimer = null;
      }
    } catch (e, stack) {
      _logger.e('Error clearing auto-send timer', error: e, stackTrace: stack);
    }
  }

  void _scheduleAutoSend() {
    try {
      _clearAutoSendTimer();
      _autoSendTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          _sendMessage(isAutoSend: true);
        }
      });
    } catch (e, stack) {
      _logger.e('Error scheduling auto-send', error: e, stackTrace: stack);
    }
  }

  void _onInputChanged(String value) {
    if (value.isNotEmpty) {
      _scheduleAutoSend();
    } else {
      _clearAutoSendTimer();
      _lastSentTextLength = 0; // Reset when input is cleared
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _sendMessage({bool isAutoSend = false}) {
    try {
      _clearAutoSendTimer();
      final content = _messageController.text;
      if (content.trim().isEmpty) {
        if (!isAutoSend) {
          _messageController.clear();
          _lastSentTextLength = 0;
        }
        return;
      }

      if (isAutoSend) {
        // Auto-send only the new text since the last send
        if (content.length > _lastSentTextLength) {
          final newText = content.substring(_lastSentTextLength).trim();
          if (newText.isNotEmpty) {
            final messageToSend = newText.endsWith(',') ? newText : '$newText,';
            widget.chatProvider
                .sendChatMessageSilent(widget.user.clientId, messageToSend);
            // Update the length of sent text, but don't clear the controller
            _lastSentTextLength = content.length;
            _logger.d(
                'Auto-sent new text: "$newText", total length now: $_lastSentTextLength');
          }
        }
      } else {
        // Manual send should only send the part not already auto-sent
        String newText = '';
        if (content.length > _lastSentTextLength) {
          newText = content.substring(_lastSentTextLength).trim();
        }
        if (newText.isEmpty) {
          // Nothing new to send; avoid duplicate sending
          _logger.d('Manual send: no new text since last auto-send, skipping');
          return;
        }
        final messageToSend = newText.endsWith(',') ? newText : '$newText,';
        widget.chatProvider
            .sendChatMessage(widget.user.clientId, messageToSend);
        _messageController.clear();
        _lastSentTextLength = 0; // Reset tracker
        _logger.d('Manual send: sent only new text and cleared input');

        // Handle UI updates for manual send
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            try {
              _scrollToBottom();
              if (!_inputFocusNode.hasFocus) {
                _inputFocusNode.requestFocus();
              }
            } catch (e, stack) {
              _logger.e('Error in post-send UI updates',
                  error: e, stackTrace: stack);
            }
          }
        });
      }
    } catch (e, stack) {
      _logger.e('Error sending message', error: e, stackTrace: stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      // Determine if we're on a mobile platform
      final isMobile = MediaQuery.of(context).size.width < 600;

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

      final messagesSection = Expanded(
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
                final isFromMe = message.senderClientId ==
                    widget.chatProvider.currentClientId;
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
                                        .withOpacity(0.7)
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withOpacity(0.7),
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

      final inputSection = Row(
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
                  hintText: '输入消息... (2秒后自动发送或Ctrl+Enter)',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                maxLines: 4,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                onChanged: (value) => _onInputChanged(value),
                onSubmitted:
                    null, // Disable Enter to send, use Ctrl+Enter instead
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _sendMessage(),
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
                inputSection,
                const SizedBox(height: 8),
              ],
              messagesSection,
              if (!isMobile) ...[
                const Divider(),
                inputSection,
              ],
            ],
          ),
        ),
      );
    } catch (e, stack) {
      _logger.e('Error building chat dialog', error: e, stackTrace: stack);
      return Dialog(
        child: Container(
          width: 400,
          height: 200,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('聊天窗口加载失败'),
              const SizedBox(height: 8),
              Text(e.toString(), style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('关闭'),
              ),
            ],
          ),
        ),
      );
    }
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
