import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late FocusNode _focusNode;
  bool _isSubmitting = false;
  // -1 means no history selection (blank beyond newest)
  int _historyIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    // Initialize from saved draft if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      final draft = chatProvider.getDraft(widget.message.id);
      if (draft != null && draft.isNotEmpty) {
        _controller.text = draft;
      }
      // Listen to changes and persist as draft (lightweight, no notify)
      _controller.addListener(() {
        chatProvider.setDraft(widget.message.id, _controller.text);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit([String? quickReply]) async {
    var replyText = quickReply ?? _controller.text.trim();
    // If input is empty, use default reply text
    if (replyText.isEmpty) {
      replyText = 'ok, well done, task end. stop.';
    }
    if (_isSubmitting) return;

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

      // Clear the text field if it was a manual input (not quick reply)
      if (quickReply == null) {
        _controller.clear();
      }
      // Clear saved draft after successful send
      chatProvider.clearDraft(widget.message.id);
      // Reset history index after sending
      _historyIndex = -1;
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
      margin: const EdgeInsets.only(top: 1),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with question/task info
          _buildHeader(context),
          const SizedBox(height: 1),

          // Text input field with keyboard shortcut
          Focus(
            onKeyEvent: (FocusNode node, KeyEvent event) {
              // Check for Ctrl+Enter key combination
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.enter &&
                  (HardwareKeyboard.instance.isControlPressed ||
                      HardwareKeyboard.instance.isMetaPressed)) {
                _handleSubmit();
                return KeyEventResult.handled;
              }

              // Bash-like history navigation (cyclic) with blank sentinels at both ends
              if (event is KeyDownEvent &&
                  (event.logicalKey == LogicalKeyboardKey.arrowUp ||
                      event.logicalKey == LogicalKeyboardKey.arrowDown)) {
                final chatProvider = context.read<ChatProvider>();
                final history = chatProvider.replyHistory;
                // Allow cycling even if history is empty: toggles between blanks
                if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  setState(() {
                    if (history.isEmpty) {
                      // Toggle blanks: -1 -> 0(blank) -> -1 ...
                      _historyIndex = (_historyIndex == -1) ? 0 : -1;
                      _controller.clear();
                    } else {
                      if (_historyIndex < history.length - 1) {
                        // Move to older item or from blank-newest to first item
                        _historyIndex += 1;
                        _controller.text = history[_historyIndex];
                      } else if (_historyIndex == history.length - 1) {
                        // Move to blank-oldest sentinel
                        _historyIndex = history.length;
                        _controller.clear();
                      } else if (_historyIndex == history.length) {
                        // Wrap to blank-newest sentinel
                        _historyIndex = -1;
                        _controller.clear();
                      } else {
                        // _historyIndex == -1 and history not empty
                        _historyIndex = 0;
                        _controller.text = history[_historyIndex];
                      }
                    }
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length),
                    );
                  });
                  return KeyEventResult.handled;
                } else {
                  // Arrow Down: towards newer; includes blank sentinels
                  setState(() {
                    if (history.isEmpty) {
                      // Toggle blanks: -1 <-> 0(blank)
                      _historyIndex = (_historyIndex == -1) ? 0 : -1;
                      _controller.clear();
                    } else {
                      if (_historyIndex > 0) {
                        _historyIndex -= 1; // newer item
                        _controller.text = history[_historyIndex];
                      } else if (_historyIndex == 0) {
                        // Move to blank-newest
                        _historyIndex = -1;
                        _controller.clear();
                      } else if (_historyIndex == -1) {
                        // From blank-newest to blank-oldest (wrap via blank)
                        _historyIndex = history.length;
                        _controller.clear();
                      } else if (_historyIndex == history.length) {
                        // From blank-oldest to last (oldest) item
                        _historyIndex = history.length - 1;
                        _controller.text = history[_historyIndex];
                      }
                    }
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length),
                    );
                  });
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: _getInputHint(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
                helperText: '按 Ctrl+Enter 快速发送 · ↑/↓ 浏览历史',
                helperStyle: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              maxLines: 3,
              minLines: 2,
              // Don't steal focus if any draft exists (user is likely editing elsewhere)
              autofocus: !context.read<ChatProvider>().hasAnyDraft,
              enabled: !_isSubmitting,
            ),
          ),
          const SizedBox(height: 4),

          // Action buttons
          LayoutBuilder(
            builder: (context, constraints) {
              // Use vertical layout on small screens
              if (constraints.maxWidth < 400) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Quick reply buttons row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSubmitting
                                ? null
                                : () => _handleSubmit('OK'),
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('OK'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: BorderSide(
                                  color: Colors.green.withValues(alpha: 0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSubmitting
                                ? null
                                : () => _handleSubmit('Continue'),
                            icon: const Icon(Icons.arrow_forward, size: 16),
                            label: const Text('Continue'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: BorderSide(
                                  color: Colors.blue.withValues(alpha: 0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSubmitting
                                ? null
                                : () => _handleSubmit("ok, let's do it"),
                            icon: const Icon(Icons.play_arrow, size: 16),
                            label: const Text("OK, let's do it"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.deepPurple,
                              side: BorderSide(
                                  color:
                                      Colors.deepPurple.withValues(alpha: 0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Send button
                    ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : () => _handleSubmit(),
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
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                );
              } else {
                // Horizontal layout for larger screens
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quick reply buttons
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed:
                              _isSubmitting ? null : () => _handleSubmit('OK'),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('OK'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: BorderSide(
                                color: Colors.green.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _isSubmitting
                              ? null
                              : () => _handleSubmit('Continue'),
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('Continue'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: BorderSide(
                                color: Colors.blue.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _isSubmitting
                              ? null
                              : () => _handleSubmit("ok, let's do it"),
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text("OK, let's do it"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.deepPurple,
                            side: BorderSide(
                                color:
                                    Colors.deepPurple.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),

                    // Send button
                    ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : () => _handleSubmit(),
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
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                );
              }
            },
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
