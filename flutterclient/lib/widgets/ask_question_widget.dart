import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../proto/agentassist.pb.dart' hide ChatMessage;
import '../providers/chat_provider.dart';
import '../providers/project_directory_index_provider.dart';
import '../providers/mcp_tool_index_provider.dart';
import '../l10n/app_localizations.dart';

/// Interactive widget for answering structured questions
class AskQuestionWidget extends StatefulWidget {
  final ChatMessage message;

  const AskQuestionWidget({
    super.key,
    required this.message,
  });

  @override
  State<AskQuestionWidget> createState() => _AskQuestionWidgetState();
}

class _AskQuestionWidgetState extends State<AskQuestionWidget> {
  // Map of question index to selected option indices
  final Map<int, Set<int>> _selections = {};
  // Map of question index to custom input controller
  final Map<int, TextEditingController> _customInputs = {};
  // Map of question index to whether custom input is visible
  final Map<int, bool> _showCustomInput = {};
  // Map of question index to focus node
  final Map<int, FocusNode> _focusNodes = {};
  // Map of question index to LayerLink for overlay positioning
  final Map<int, LayerLink> _layerLinks = {};
  // Map of question index to GlobalKey for overlay positioning context
  final Map<int, GlobalKey> _inputKeys = {};

  bool _isSubmitting = false;

  // Autocomplete Overlay State
  OverlayEntry? _suggestOverlay;
  Timer? _suggestDebounce;
  List<_InlineSuggestion> _suggestions = const [];
  int _selectedSuggestionIndex = 0;
  int? _activeTokenIndex; // The start index of @ or /
  bool _suppressNextSuggestUpdate = false;
  int? _activeInputIndex; // The index of the question currently being edited
  bool _ignoreFocusLossOnce = false;

  static const double _suggestOverlayGap = 8;
  static const double _suggestOverlayMaxHeight = 240;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each question
    final questions = widget.message.rawQuestions ?? [];
    for (int i = 0; i < questions.length; i++) {
      _customInputs[i] = TextEditingController();
      _focusNodes[i] = FocusNode();
      _layerLinks[i] = LayerLink();
      _inputKeys[i] = GlobalKey();

      // Listen for text changes for autocomplete
      _customInputs[i]!.addListener(() => _onTextChanged(i));

      // Listen for focus changes
      _focusNodes[i]!.addListener(() {
        if (_focusNodes[i]!.hasFocus) {
          _activeInputIndex = i;
          // Touch context when focused
          final root = widget.message.projectDirectory;
          if (root != null && root.isNotEmpty) {
            context.read<ProjectDirectoryIndexProvider>().touchRoot(root);
            context
                .read<McpToolIndexProvider>()
                .touchContext(root, widget.message.mcpClientName);
          }
        } else {
          // If losing focus and it was the active one, remove overlay
          if (_ignoreFocusLossOnce) {
            _ignoreFocusLossOnce = false;
            return;
          }
          if (_activeInputIndex == i) {
            _removeSuggestOverlay();
            _activeInputIndex = null;
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _suggestDebounce?.cancel();
    _removeSuggestOverlay();
    for (final controller in _customInputs.values) {
      controller.dispose();
    }
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  // --- Autocomplete Logic Start ---

  void _onTextChanged(int index) {
    if (_suppressNextSuggestUpdate) {
      _suppressNextSuggestUpdate = false;
      return;
    }
    _suggestDebounce?.cancel();
    _suggestDebounce = Timer(const Duration(milliseconds: 80), () {
      if (!mounted) return;
      _updateSuggestions(index);
    });
  }

  void _updateSuggestions(int index) {
    // Only update if this index is still active
    if (_activeInputIndex != index) return;

    final root = widget.message.projectDirectory;
    if (root == null || root.isEmpty) {
      _activeTokenIndex = null;
      _suggestions = const [];
      _removeSuggestOverlay();
      return;
    }

    final provider = context.read<ProjectDirectoryIndexProvider>();
    if (!provider.rootExists(root)) {
      _activeTokenIndex = null;
      _suggestions = const [];
      _removeSuggestOverlay();
      return;
    }

    final controller = _customInputs[index];
    if (controller == null) return;

    final value = controller.value;
    final cursor = value.selection.isValid ? value.selection.baseOffset : -1;
    if (cursor < 0) {
      _activeTokenIndex = null;
      _suggestions = const [];
      _removeSuggestOverlay();
      return;
    }

    final atInfo = _findToken(value.text, cursor, 64); // @
    final slashInfo = _findToken(value.text, cursor, 47); // /

    _AtToken? info;
    _SuggestMode? mode;
    if (atInfo == null && slashInfo == null) {
      info = null;
      mode = null;
    } else if (atInfo == null) {
      info = slashInfo;
      mode = _SuggestMode.mcpTool;
    } else if (slashInfo == null) {
      info = atInfo;
      mode = _SuggestMode.path;
    } else {
      if (slashInfo.atIndex > atInfo.atIndex) {
        info = slashInfo;
        mode = _SuggestMode.mcpTool;
      } else {
        info = atInfo;
        mode = _SuggestMode.path;
      }
    }

    if (info == null || mode == null) {
      _activeTokenIndex = null;
      _suggestions = const [];
      _removeSuggestOverlay();
      return;
    }

    _activeTokenIndex = info.atIndex;
    final query = info.query;

    if (mode == _SuggestMode.path) {
      provider.touchRoot(root);
      final results = provider.search(root, query, limit: 20);
      _suggestions = results.map(_InlineSuggestion.path).toList();
    } else {
      final toolProvider = context.read<McpToolIndexProvider>();
      toolProvider.touchContext(root, widget.message.mcpClientName);
      final results = toolProvider.search(
        root,
        widget.message.mcpClientName,
        query,
        limit: 20,
      );
      _suggestions = results.map(_InlineSuggestion.tool).toList();
    }

    if (_selectedSuggestionIndex >= _suggestions.length) {
      _selectedSuggestionIndex = 0;
    }

    if (_suggestions.isEmpty) {
      _removeSuggestOverlay();
      return;
    }
    _ensureSuggestOverlay(index);
  }

  _AtToken? _findToken(String text, int cursor, int triggerCodeUnit) {
    final before = text.substring(0, cursor);
    var i = before.length - 1;
    while (i >= 0) {
      final c = before.codeUnitAt(i);
      if (c == triggerCodeUnit) {
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

  void _ensureSuggestOverlay(int index) {
    if (_suggestOverlay != null) {
      _suggestOverlay!.markNeedsBuild();
      return;
    }
    _suggestOverlay = OverlayEntry(
      builder: (context) {
        final placement = _computeSuggestOverlayPlacement(context, index);
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
                  link: _layerLinks[index]!,
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
                        itemBuilder: (context, idx) {
                          final s = _suggestions[idx];
                          final selected = idx == _selectedSuggestionIndex;
                          return InkWell(
                            canRequestFocus: false,
                            mouseCursor: SystemMouseCursors.click,
                            onHover: (hovering) {
                              if (!hovering) return;
                              if (_selectedSuggestionIndex == idx) return;
                              _selectedSuggestionIndex = idx;
                              _suggestOverlay?.markNeedsBuild();
                            },
                            onTapDown: (_) {
                              _ignoreFocusLossOnce = true;
                              if (_focusNodes[index] != null &&
                                  !_focusNodes[index]!.hasFocus) {
                                _focusNodes[index]!.requestFocus();
                              }
                              _applySuggestion(index, idx);
                            },
                            onTapCancel: () {
                              _ignoreFocusLossOnce = false;
                            },
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
                              child: Row(
                                children: [
                                  if (s.icon != null) ...[
                                    Icon(
                                      s.icon,
                                      size: 16,
                                      color: selected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Expanded(
                                    child: Text(
                                      s.displayText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 13,
                                        height: 1.15,
                                        color: selected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
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

  _SuggestOverlayPlacement _computeSuggestOverlayPlacement(
    BuildContext overlayContext,
    int index,
  ) {
    // Try to get context from global key of the input field
    final targetContext = _inputKeys[index]?.currentContext;

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

  void _applySuggestion(int index, int suggestionIndex) {
    if (suggestionIndex < 0 || suggestionIndex >= _suggestions.length) return;
    _ignoreFocusLossOnce = false;
    final tokenIndex = _activeTokenIndex;
    if (tokenIndex == null) return;

    final root = widget.message.projectDirectory;
    if (root == null || root.isEmpty) return;

    final suggestion = _suggestions[suggestionIndex];
    final controller = _customInputs[index];
    if (controller == null) return;

    final value = controller.value;
    final cursor = value.selection.isValid
        ? value.selection.baseOffset
        : value.text.length;
    final safeCursor = cursor.clamp(0, value.text.length);
    final safeToken = tokenIndex.clamp(0, safeCursor);

    if (suggestion.kind == _InlineSuggestionKind.path) {
      final provider = context.read<ProjectDirectoryIndexProvider>();
      final ps = suggestion.pathSuggestion;
      if (ps == null) return;

      final insert = '@${ps.displayText}';
      final keepOpen =
          ps.isDir && provider.directoryHasChildren(root, ps.relativePath);

      final newText = value.text.replaceRange(safeToken, safeCursor, insert);

      if (!keepOpen) {
        _suppressNextSuggestUpdate = true;
      }

      controller.value = value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: safeToken + insert.length),
        composing: TextRange.empty,
      );

      if (!keepOpen) {
        _activeTokenIndex = null;
        _removeSuggestOverlay();
        return;
      }

      _activeTokenIndex = safeToken;
      _selectedSuggestionIndex = 0;
      Future.microtask(() {
        if (!mounted) return;
        _updateSuggestions(index);
      });
      return;
    }

    final tool = suggestion.toolSuggestion;
    if (tool == null) return;

    final toolProvider = context.read<McpToolIndexProvider>();
    final isSkill = tool.type == McpToolSuggestionType.skill;
    final template = isSkill
        ? toolProvider.slashSkillCompletionText
        : toolProvider.slashCommandCompletionText;
    final type = isSkill ? 'skill' : 'command';
    final insert = template
        .replaceAll('%name%', tool.name)
        .replaceAll('%path%', tool.filePath)
        .replaceAll('%type%', type);

    final newText = value.text.replaceRange(safeToken, safeCursor, insert);
    _suppressNextSuggestUpdate = true;
    controller.value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: safeToken + insert.length),
      composing: TextRange.empty,
    );

    _activeTokenIndex = null;
    _removeSuggestOverlay();
  }
  // --- Autocomplete Logic End ---

  Future<void> _submitReply() async {
    if (_isSubmitting) return;

    final questions = widget.message.rawQuestions;
    if (questions == null || questions.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final buffer = StringBuffer();

      for (int i = 0; i < questions.length; i++) {
        final q = questions[i];
        final selections = _selections[i] ?? {};
        final customInput = _customInputs[i]?.text.trim() ?? '';

        // Determine the label for the question: prioritize header, fallback to question text
        String label = q.header;
        if (label.isEmpty) {
          label = q.question;
        }

        final List<String> parts = [];

        // Add selected options
        if (q.options.isNotEmpty) {
          // Sort selections to maintain order
          final sortedSelections = selections.toList()..sort();
          for (final idx in sortedSelections) {
            if (idx >= 0 && idx < q.options.length) {
              String text = q.options[idx].label;
              // Remove "(Recommended)" and trimmed spaces
              text = text.replaceAll(RegExp(r'\s*\(Recommended\)'), '').trim();
              parts.add(text);
            }
          }
        }

        // Add custom input
        if (customInput.isNotEmpty) {
          parts.add(customInput);
        }

        if (parts.isNotEmpty) {
          buffer.writeln('Q: $label');
          buffer.writeln('A: ${parts.join(', ')}');
          // Add an extra newline between questions if there are multiple
          if (i < questions.length - 1) {
            buffer.writeln();
          }
        }
      }

      final replyText = buffer.toString().trim();
      if (replyText.isEmpty) {
        // Nothing selected or typed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select an option or provide an answer')),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      await context.read<ChatProvider>().replyToQuestion(
            widget.message.id,
            replyText,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting reply: $e')),
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

  void _toggleSelection(int questionIndex, int optionIndex, bool multiple) {
    setState(() {
      final currentSelections = _selections[questionIndex] ?? {};
      if (multiple) {
        if (currentSelections.contains(optionIndex)) {
          currentSelections.remove(optionIndex);
        } else {
          currentSelections.add(optionIndex);
        }
      } else {
        currentSelections.clear();
        currentSelections.add(optionIndex);
      }
      _selections[questionIndex] = currentSelections;
    });

    // 检查是否应该自动提交
    _checkAutoReply();
  }

  /// 检查是否满足自动回复条件：
  /// 1. 设置中开启了自动回复
  /// 2. 所有问题都是单选
  /// 3. 每个问题都已有选择，或自定义输入框有内容
  void _checkAutoReply() {
    final chatProvider = context.read<ChatProvider>();
    if (!chatProvider.autoReplyAskQuestion) return;
    if (_isSubmitting) return;

    final questions = widget.message.rawQuestions;
    if (questions == null || questions.isEmpty) return;

    // 检查所有问题是否都是单选
    final allSingleChoice = questions.every((q) => !q.multiple);
    if (!allSingleChoice) return;

    // 检查每个问题是否已回答
    for (int i = 0; i < questions.length; i++) {
      final hasSelection = (_selections[i]?.isNotEmpty ?? false);
      final showCustom = _showCustomInput[i] ?? false;
      final customText = _customInputs[i]?.text.trim() ?? '';

      // 如果自定义输入框显示中但没有内容，且没有选择选项，则未回答
      if (showCustom && customText.isEmpty && !hasSelection) {
        return;
      }
      // 如果没有选择且自定义输入框也没有内容，则未回答
      if (!hasSelection && customText.isEmpty) {
        return;
      }
    }

    // 所有条件满足，延迟自动提交
    Future.microtask(() {
      if (!mounted) return;
      if (_isSubmitting) return;
      _submitReply();
    });
  }

  void _showAndFocusInput(int index) {
    setState(() {
      _showCustomInput[index] = true;
    });
    // Delay to ensure the TextField is built before requesting focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[index]?.requestFocus();
    });
  }

  KeyEventResult _handleKeyEvent(int index, FocusNode node, KeyEvent event) {
    // Autocomplete handling has high priority
    if (_suggestOverlay != null && event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _removeSuggestOverlay();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.enter &&
          !(HardwareKeyboard.instance.isControlPressed ||
              HardwareKeyboard.instance.isMetaPressed)) {
        _applySuggestion(index, _selectedSuggestionIndex);
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          if (_suggestions.isNotEmpty) {
            _selectedSuggestionIndex = (_selectedSuggestionIndex - 1) < 0
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
                (_selectedSuggestionIndex + 1) % _suggestions.length;
          }
        });
        _suggestOverlay?.markNeedsBuild();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.message.rawQuestions;
    if (questions == null || questions.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 500;
        final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

        return Container(
          margin: const EdgeInsets.only(top: 1),
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...questions.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value;
                return _buildQuestionItem(context, index, question);
              }),
              const SizedBox(height: 2),
              if (!(isCompact && isKeyboardOpen))
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitReply,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 32,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send, size: 18),
                    label: Text(_isSubmitting ? 'Sending...' : 'Reply'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionItem(
      BuildContext context, int index, Question question) {
    final colorScheme = Theme.of(context).colorScheme;
    final selections = _selections[index] ?? {};
    final showCustom = _showCustomInput[index] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (question.header.isNotEmpty ||
            question.question.isNotEmpty ||
            (question.custom || true))
          Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: MarkdownBody(
                    data: [
                      if (question.header.isNotEmpty)
                        '**${question.header.trim()}**',
                      if (question.question.isNotEmpty)
                        question.question.trim(),
                    ].join(' '),
                    selectable: false,
                    styleSheet: MarkdownStyleSheet.fromTheme(
                      Theme.of(context),
                    ).copyWith(
                      strong: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                      p: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                      code: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          ),
                      codeblockDecoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                if ((question.custom || true) && !showCustom)
                  InkWell(
                    onTap: () => _showAndFocusInput(index),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_note,
                            size: 22,
                            color: colorScheme.secondary.withOpacity(0.8),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // Options
        if (question.options.isNotEmpty)
          ...question.options.asMap().entries.map((entry) {
            final optIndex = entry.key;
            final option = entry.value;
            final isSelected = selections.contains(optIndex);

            return Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: InkWell(
                onTap: () =>
                    _toggleSelection(index, optIndex, question.multiple),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 32),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primaryContainer.withOpacity(0.3)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary.withOpacity(0.4)
                          : colorScheme.outlineVariant.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Checkbox or Radio icon
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Icon(
                          question.multiple
                              ? (isSelected
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank)
                              : (isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked),
                          size: 18,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: MarkdownBody(
                                data: [
                                  if (option.label.isNotEmpty)
                                    '**${option.label.trim()}**',
                                  if (option.description.isNotEmpty)
                                    option.description.trim(),
                                ].join(' '),
                                selectable: false,
                                styleSheet: MarkdownStyleSheet.fromTheme(
                                  Theme.of(context),
                                ).copyWith(
                                  strong: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.bold,
                                    color: isSelected
                                        ? colorScheme.onSurface
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  p: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontSize: 12,
                                        color: isSelected
                                            ? colorScheme.onSurface
                                                .withOpacity(0.8)
                                            : colorScheme.outline,
                                      ),
                                  code: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontFamily: 'monospace',
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                      ),
                                  codeblockDecoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            if (isSelected && !showCustom)
                              Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: InkWell(
                                  onTap: () => _showAndFocusInput(index),
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Icon(
                                      Icons.edit_note,
                                      size: 18,
                                      color: colorScheme.secondary
                                          .withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

        // Custom Input Field
        if (showCustom)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Focus(
              onKeyEvent: (node, event) =>
                  _handleKeyEvent(index, _focusNodes[index]!, event),
              child: CompositedTransformTarget(
                key: _inputKeys[index],
                link: _layerLinks[index]!,
                child: Stack(
                  children: [
                    TextField(
                      controller: _customInputs[index],
                      focusNode: _focusNodes[index],
                      decoration: InputDecoration(
                        hintText: 'Add explanation or custom answer...',
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding:
                            const EdgeInsets.fromLTRB(12, 12, 56, 12),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.10),
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: _isSubmitting ? null : _submitReply,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.send,
                                  size: 18,
                                  color: _isSubmitting
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.6)
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Material(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                setState(() {
                                  _showCustomInput[index] = false;
                                  _customInputs[index]?.clear();
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// --- Helper classes copied from InlineReplyWidget ---

class _AtToken {
  final int atIndex;
  final String query;

  const _AtToken({
    required this.atIndex,
    required this.query,
  });
}

enum _SuggestMode {
  path,
  mcpTool,
}

enum _InlineSuggestionKind {
  path,
  tool,
}

class _InlineSuggestion {
  final _InlineSuggestionKind kind;
  final PathSuggestion? pathSuggestion;
  final McpToolSuggestion? toolSuggestion;

  const _InlineSuggestion._({
    required this.kind,
    this.pathSuggestion,
    this.toolSuggestion,
  });

  factory _InlineSuggestion.path(PathSuggestion suggestion) {
    return _InlineSuggestion._(
      kind: _InlineSuggestionKind.path,
      pathSuggestion: suggestion,
    );
  }

  factory _InlineSuggestion.tool(McpToolSuggestion suggestion) {
    return _InlineSuggestion._(
      kind: _InlineSuggestionKind.tool,
      toolSuggestion: suggestion,
    );
  }

  String get displayText {
    if (kind == _InlineSuggestionKind.path) {
      return pathSuggestion?.displayText ?? '';
    }
    final tool = toolSuggestion;
    if (tool == null) return '';
    return tool.name;
  }

  IconData? get icon {
    if (kind == _InlineSuggestionKind.path) {
      final ps = pathSuggestion;
      if (ps == null) return null;
      return ps.isDir ? Icons.folder : Icons.insert_drive_file;
    }
    final tool = toolSuggestion;
    if (tool == null) return null;
    if (tool.type == McpToolSuggestionType.skill) {
      return Icons.extension;
    }
    return Icons.bolt;
  }
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
          offset: const Offset(0, -_AskQuestionWidgetState._suggestOverlayGap),
          maxHeight: maxHeight,
        );

  const _SuggestOverlayPlacement.below(double maxHeight)
      : this._(
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, _AskQuestionWidgetState._suggestOverlayGap),
          maxHeight: maxHeight,
        );
}
