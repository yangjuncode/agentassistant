import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:desktop_drop/desktop_drop.dart';

import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../providers/project_directory_index_provider.dart';
import '../constants/websocket_commands.dart';
import '../services/attachment_service.dart';

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
  bool _isDragging = false;
  // -1 means no history selection (blank beyond newest)
  int _historyIndex = -1;
  // Attachments list
  final List<AttachmentItem> _attachments = [];

  final LayerLink _layerLink = LayerLink();
  final GlobalKey _inputFieldKey = GlobalKey();
  OverlayEntry? _suggestOverlay;
  Timer? _suggestDebounce;
  List<PathSuggestion> _suggestions = const [];
  int _selectedSuggestionIndex = 0;
  int? _activeAtIndex;
  bool _suppressNextSuggestUpdate = false;

  static const double _suggestOverlayGap = 8;
  static const double _suggestOverlayMaxHeight = 240;

  _SuggestOverlayPlacement _computeSuggestOverlayPlacement(
    BuildContext overlayContext,
  ) {
    final targetContext = _inputFieldKey.currentContext;
    if (targetContext == null) {
      return const _SuggestOverlayPlacement.below(_suggestOverlayMaxHeight);
    }

    final ro = targetContext.findRenderObject();
    if (ro is! RenderBox || !ro.hasSize) {
      return const _SuggestOverlayPlacement.below(_suggestOverlayMaxHeight);
    }

    final topLeft = ro.localToGlobal(Offset.zero);
    final size = ro.size;

    final media = MediaQuery.of(overlayContext);
    final usableTop = media.padding.top;
    final usableBottom =
        media.size.height - media.viewInsets.bottom - media.padding.bottom;

    final spaceAbove = (topLeft.dy - usableTop).clamp(0.0, double.infinity);
    final spaceBelow =
        (usableBottom - (topLeft.dy + size.height)).clamp(0.0, double.infinity);

    final showBelow = spaceBelow >= _suggestOverlayMaxHeight ||
        (spaceBelow >= spaceAbove && spaceBelow >= 60);

    final available =
        (showBelow ? spaceBelow : spaceAbove) - _suggestOverlayGap;
    final maxHeight = available.clamp(60.0, _suggestOverlayMaxHeight);

    return showBelow
        ? _SuggestOverlayPlacement.below(maxHeight)
        : _SuggestOverlayPlacement.above(maxHeight);
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    // Initialize from saved draft if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      final pathIndexProvider = context.read<ProjectDirectoryIndexProvider>();
      final root = widget.message.projectDirectory;
      if (root != null && root.isNotEmpty) {
        pathIndexProvider.touchRoot(root);
      }

      final draft = chatProvider.getDraft(widget.message.id);
      if (draft != null && draft.isNotEmpty) {
        _controller.text = draft;
      }
      // Listen to changes and persist as draft (lightweight, no notify)
      _controller.addListener(() {
        chatProvider.setDraft(widget.message.id, _controller.text);
      });

      // Listen for @ autocomplete
      _controller.addListener(_onTextChanged);
    });

    _focusNode.addListener(() {
      if (mounted) {
        context.read<ChatProvider>().setInputFocused(_focusNode.hasFocus);
        if (!_focusNode.hasFocus) {
          _removeSuggestOverlay();
        }
      }
    });
  }

  ChatProvider? _chatProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatProvider = context.read<ChatProvider>();
  }

  @override
  void dispose() {
    // If the widget is being disposed while it has focus (e.g. message was replied by someone else),
    // we need to reset the focus state in ChatProvider so the OnlineUsersBar can be shown again.
    if (_focusNode.hasFocus) {
      final provider = _chatProvider;
      if (provider != null) {
        // Use scheduleMicrotask to avoid notifying listeners during build
        Future.microtask(() {
          provider.setInputFocused(false);
        });
      }
    }
    _suggestDebounce?.cancel();
    _removeSuggestOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_suppressNextSuggestUpdate) {
      _suppressNextSuggestUpdate = false;
      return;
    }
    _suggestDebounce?.cancel();
    _suggestDebounce = Timer(const Duration(milliseconds: 80), () {
      if (!mounted) return;
      _updateSuggestions();
    });
  }

  void _updateSuggestions() {
    final root = widget.message.projectDirectory;
    if (root == null || root.isEmpty) {
      _activeAtIndex = null;
      _suggestions = const [];
      _removeSuggestOverlay();
      return;
    }

    final provider = context.read<ProjectDirectoryIndexProvider>();
    if (!provider.rootExists(root)) {
      _activeAtIndex = null;
      _suggestions = const [];
      _removeSuggestOverlay();
      return;
    }

    final value = _controller.value;
    final cursor = value.selection.isValid ? value.selection.baseOffset : -1;
    if (cursor < 0) {
      _activeAtIndex = null;
      _suggestions = const [];
      _removeSuggestOverlay();
      return;
    }

    final info = _findAtToken(value.text, cursor);
    if (info == null) {
      _activeAtIndex = null;
      _suggestions = const [];
      _removeSuggestOverlay();
      return;
    }

    _activeAtIndex = info.atIndex;
    final query = info.query;
    provider.touchRoot(root);
    final results = provider.search(root, query, limit: 20);
    _suggestions = results;
    if (_selectedSuggestionIndex >= _suggestions.length) {
      _selectedSuggestionIndex = 0;
    }

    if (_suggestions.isEmpty) {
      _removeSuggestOverlay();
      return;
    }
    _ensureSuggestOverlay();
  }

  _AtToken? _findAtToken(String text, int cursor) {
    final before = text.substring(0, cursor);
    var i = before.length - 1;
    while (i >= 0) {
      final c = before.codeUnitAt(i);
      if (c == 64) {
        // '@'
        // Must be start of token
        if (i == 0) {
          return _AtToken(atIndex: i, query: before.substring(i + 1));
        }
        final prev = before.codeUnitAt(i - 1);
        final isBoundary = prev == 32 || prev == 10 || prev == 9;
        if (isBoundary) {
          return _AtToken(atIndex: i, query: before.substring(i + 1));
        }
        return null;
      }
      // stop at whitespace
      if (c == 32 || c == 10 || c == 9) return null;
      i--;
    }
    return null;
  }

  void _ensureSuggestOverlay() {
    if (_suggestOverlay != null) {
      _suggestOverlay!.markNeedsBuild();
      return;
    }
    _suggestOverlay = OverlayEntry(
      builder: (context) {
        final placement = _computeSuggestOverlayPlacement(context);
        return Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _removeSuggestOverlay,
                  ),
                ),
                CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  targetAnchor: placement.targetAnchor,
                  followerAnchor: placement.followerAnchor,
                  offset: placement.offset,
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 520,
                        maxHeight: placement.maxHeight,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final s = _suggestions[index];
                          final selected = index == _selectedSuggestionIndex;
                          return InkWell(
                            onTap: () => _applySuggestion(index),
                            child: Container(
                              color: selected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.12)
                                  : null,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              child: Text(
                                s.displayText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  height: 1.15,
                                  color: selected
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_suggestOverlay!);
  }

  void _removeSuggestOverlay() {
    _suggestOverlay?.remove();
    _suggestOverlay = null;
  }

  void _applySuggestion(int index) {
    if (index < 0 || index >= _suggestions.length) return;
    final atIndex = _activeAtIndex;
    if (atIndex == null) return;

    final root = widget.message.projectDirectory;
    if (root == null || root.isEmpty) return;
    final provider = context.read<ProjectDirectoryIndexProvider>();

    final suggestion = _suggestions[index];
    final insert = '@${suggestion.displayText}';

    final keepOpen = suggestion.isDir &&
        provider.directoryHasChildren(root, suggestion.relativePath);

    final value = _controller.value;
    final selection = value.selection;
    final cursor = selection.isValid ? selection.baseOffset : value.text.length;
    final safeCursor = cursor.clamp(0, value.text.length);
    final safeAt = atIndex.clamp(0, safeCursor);

    final newText = value.text.replaceRange(safeAt, safeCursor, insert);

    // Prevent suggestion list from immediately re-opening due to programmatic text update.
    if (!keepOpen) {
      _suppressNextSuggestUpdate = true;
    }

    _controller.value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: safeAt + insert.length),
      composing: TextRange.empty,
    );

    if (!keepOpen) {
      _activeAtIndex = null;
      _removeSuggestOverlay();
      return;
    }

    // Keep overlay open for directories that have children; refresh suggestions.
    _activeAtIndex = safeAt;
    _selectedSuggestionIndex = 0;
    Future.microtask(() {
      if (!mounted) return;
      _updateSuggestions();
    });
  }

  /// Handle paste from clipboard
  /// Returns true if an attachment was successfully pasted, false otherwise
  Future<bool> _handlePaste() async {
    final attachment = await AttachmentService.loadFromClipboard();
    if (attachment != null && mounted) {
      setState(() {
        _attachments.add(attachment);
      });
      return true;
    }
    return false;
  }

  Future<void> _pasteTextFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return;

    final value = _controller.value;
    final selection = value.selection;

    final start = selection.isValid ? selection.start : value.text.length;
    final end = selection.isValid ? selection.end : value.text.length;
    final safeStart = start.clamp(0, value.text.length);
    final safeEnd = end.clamp(0, value.text.length);

    final newText = value.text.replaceRange(safeStart, safeEnd, text);
    _controller.value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: safeStart + text.length),
      composing: TextRange.empty,
    );
  }

  Future<bool> _handleFileUriTextPasteAsAttachment() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.trim().isEmpty) return false;

    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (lines.isEmpty) return false;

    final filePaths = <String>[];
    for (final line in lines) {
      if (!line.startsWith('file://')) continue;
      try {
        final uri = Uri.parse(line);
        final path = uri.toFilePath();
        if (File(path).existsSync()) {
          filePaths.add(path);
        }
      } catch (_) {}
    }

    if (filePaths.isEmpty) return false;

    var anyAdded = false;
    for (final path in filePaths) {
      final attachment = await AttachmentService.loadFromFile(path);
      if (attachment != null && mounted) {
        setState(() {
          _attachments.add(attachment);
        });
        anyAdded = true;
      }
    }
    return anyAdded;
  }

  Future<void> _handlePasteOrText() async {
    final handled = await _handlePaste();
    if (handled) return;

    final handledFileUriText = await _handleFileUriTextPasteAsAttachment();
    if (handledFileUriText) return;

    await _pasteTextFromClipboard();
  }

  /// Handle file drop using desktop_drop
  Future<void> _handleDrop(DropDoneDetails details) async {
    for (final file in details.files) {
      final attachment = await AttachmentService.loadFromFile(file.path);
      if (attachment != null && mounted) {
        setState(() {
          _attachments.add(attachment);
        });
      }
    }
  }

  /// Pick files using file picker
  Future<void> _pickFiles() async {
    final attachments = await AttachmentService.pickFiles();
    if (attachments.isNotEmpty && mounted) {
      setState(() {
        _attachments.addAll(attachments);
      });
    }
  }

  /// Remove attachment at index
  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  Future<void> _handleSubmit([String? quickReply]) async {
    var replyText = quickReply ?? _controller.text.trim();
    // If input is empty and no attachments, use default reply text
    if (replyText.isEmpty && _attachments.isEmpty) {
      replyText = 'ok, well done, task end. stop.';
    }
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Unfocus immediately to restore UI state (e.g. show Online Users bar)
      _focusNode.unfocus();

      final chatProvider = context.read<ChatProvider>();

      if (widget.message.type == MessageType.question) {
        await chatProvider.replyToQuestion(
          widget.message.id,
          replyText,
          attachments: _attachments,
        );
      } else if (widget.message.type == MessageType.task) {
        await chatProvider.confirmTask(
          widget.message.id,
          replyText,
          attachments: _attachments,
        );
      }

      if (!mounted) return;

      // Clear the text field if it was a manual input (not quick reply)
      if (quickReply == null) {
        _controller.clear();
      }
      // Clear attachments after successful send
      _attachments.clear();
      // Clear saved draft after successful send
      chatProvider.clearDraft(widget.message.id);

      // Auto-show online users bar if no more pending actions
      if (chatProvider.pendingQuestions.isEmpty &&
          chatProvider.pendingTasks.isEmpty) {
        chatProvider.setOnlineUsersVisible(true);
      }

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 500;

        return DropTarget(
          onDragDone: _handleDrop,
          onDragEntered: (details) {
            setState(() => _isDragging = true);
          },
          onDragExited: (details) {
            setState(() => _isDragging = false);
          },
          child: Container(
            margin: const EdgeInsets.only(top: 1),
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isDragging
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.2),
                width: _isDragging ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with question/task info
                _buildHeader(context, isCompact),
                const SizedBox(height: 1),

                // Drag indicator
                if (_isDragging)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '拖放文件到此处',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Attachment previews
                if (_attachments.isNotEmpty) ...[
                  _buildAttachmentPreviews(context),
                  const SizedBox(height: 4),
                ],

                // Text input field with keyboard shortcut
                Focus(
                  onKeyEvent: (FocusNode node, KeyEvent event) {
                    // Autocomplete keyboard handling (higher priority)
                    if (_suggestOverlay != null && event is KeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.escape) {
                        _removeSuggestOverlay();
                        return KeyEventResult.handled;
                      }
                      if (event.logicalKey == LogicalKeyboardKey.enter &&
                          !(HardwareKeyboard.instance.isControlPressed ||
                              HardwareKeyboard.instance.isMetaPressed)) {
                        _applySuggestion(_selectedSuggestionIndex);
                        return KeyEventResult.handled;
                      }
                      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                        setState(() {
                          if (_suggestions.isNotEmpty) {
                            _selectedSuggestionIndex =
                                (_selectedSuggestionIndex - 1) < 0
                                    ? _suggestions.length - 1
                                    : _selectedSuggestionIndex - 1;
                          }
                        });
                        _suggestOverlay?.markNeedsBuild();
                        return KeyEventResult.handled;
                      }
                      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                        setState(() {
                          if (_suggestions.isNotEmpty) {
                            _selectedSuggestionIndex =
                                (_selectedSuggestionIndex + 1) %
                                    _suggestions.length;
                          }
                        });
                        _suggestOverlay?.markNeedsBuild();
                        return KeyEventResult.handled;
                      }
                    }

                    // Check for Ctrl+V paste (for images/files only, let text paste through)
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.keyV &&
                        (HardwareKeyboard.instance.isControlPressed ||
                            HardwareKeyboard.instance.isMetaPressed)) {
                      _handlePasteOrText();
                      return KeyEventResult.handled;
                    }

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
                  child: Actions(
                    actions: <Type, Action<Intent>>{
                      PasteTextIntent: CallbackAction<PasteTextIntent>(
                        onInvoke: (intent) {
                          _handlePasteOrText();
                          return null;
                        },
                      ),
                    },
                    child: CompositedTransformTarget(
                      key: _inputFieldKey,
                      link: _layerLink,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: _getInputHint(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          helperText: isCompact
                              ? null
                              : '按 Ctrl+Enter 快速发送 · ↑/↓ 浏览历史 · Ctrl+V 粘贴图片',
                          helperStyle: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.attach_file),
                            tooltip: '添加附件',
                            onPressed: _isSubmitting ? null : _pickFiles,
                          ),
                        ),
                        maxLines: 3,
                        minLines: isCompact ? 1 : 2,
                        autofocus: !context.read<ChatProvider>().hasAnyDraft,
                        enabled: !_isSubmitting,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Action buttons
                if (isCompact) ...[
                  const SizedBox(height: 4),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        OutlinedButton(
                          onPressed:
                              _isSubmitting ? null : () => _handleSubmit('OK'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 0),
                            minimumSize: const Size(0, 32),
                          ),
                          child: const Text('OK'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed:
                              _isSubmitting ? null : () => _handleSubmit('Yes'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 0),
                            minimumSize: const Size(0, 32),
                          ),
                          child: const Text('Yes'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => _handleSubmit('Continue'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 0),
                            minimumSize: const Size(0, 32),
                          ),
                          child: const Text('Continue'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => _handleSubmit("ok, let's do it"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 0),
                            minimumSize: const Size(0, 32),
                          ),
                          child: const Text("Let's do it"),
                        ),
                      ],
                    ),
                  ),
                ] else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quick reply buttons
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _isSubmitting
                                ? null
                                : () => _handleSubmit('OK'),
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
                                : () => _handleSubmit('Yes'),
                            icon: const Icon(Icons.thumb_up, size: 16),
                            label: const Text('Yes'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.teal,
                              side: BorderSide(
                                  color: Colors.teal.withValues(alpha: 0.5)),
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
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build attachment previews row
  Widget _buildAttachmentPreviews(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _attachments.length,
        itemBuilder: (context, index) {
          final attachment = _attachments[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: attachment.isImage &&
                            attachment.thumbnailData != null
                        ? Image.memory(
                            attachment.thumbnailData!,
                            fit: BoxFit.cover,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                attachment.isAudio
                                    ? Icons.audiotrack
                                    : Icons.insert_drive_file,
                                size: 28,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                attachment.displayName,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                  ),
                ),
                // Remove button
                Positioned(
                  top: -4,
                  right: -4,
                  child: Material(
                    color: Theme.of(context).colorScheme.error,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => _removeAttachment(index),
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isCompact) {
    if (isCompact) {
      return Row(
        children: [
          Icon(
            _getHeaderIcon(),
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getHeaderTitle(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          // Send button in header for compact mode
          IconButton(
            onPressed: _isSubmitting ? null : () => _handleSubmit(),
            icon: _isSubmitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            tooltip: '发送',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      );
    }
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

class _AtToken {
  final int atIndex;
  final String query;

  const _AtToken({
    required this.atIndex,
    required this.query,
  });
}

class _SuggestOverlayPlacement {
  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final Offset offset;
  final double maxHeight;

  const _SuggestOverlayPlacement._({
    required this.targetAnchor,
    required this.followerAnchor,
    required this.offset,
    required this.maxHeight,
  });

  const _SuggestOverlayPlacement.above(double maxHeight)
      : this._(
          targetAnchor: Alignment.topLeft,
          followerAnchor: Alignment.bottomLeft,
          offset: const Offset(0, -_InlineReplyWidgetState._suggestOverlayGap),
          maxHeight: maxHeight,
        );

  const _SuggestOverlayPlacement.below(double maxHeight)
      : this._(
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, _InlineReplyWidgetState._suggestOverlayGap),
          maxHeight: maxHeight,
        );
}
