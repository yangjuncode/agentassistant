import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../proto/agentassist.pb.dart' hide ChatMessage;
import '../providers/chat_provider.dart';
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

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each question
    final questions = widget.message.rawQuestions ?? [];
    for (int i = 0; i < questions.length; i++) {
      _customInputs[i] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _customInputs.values) {
      controller.dispose();
    }
    super.dispose();
  }

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
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.message.rawQuestions;
    if (questions == null || questions.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitReply,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
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
  }

  Widget _buildQuestionItem(
      BuildContext context, int index, Question question) {
    final colorScheme = Theme.of(context).colorScheme;
    final selections = _selections[index] ?? {};
    final showCustom = _showCustomInput[index] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) const Divider(height: 24),

        // Header/Question text
        if (question.header.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              question.header,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
          ),

        if (question.question.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              question.question,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),

        // Options
        if (question.options.isNotEmpty)
          ...question.options.asMap().entries.map((entry) {
            final optIndex = entry.key;
            final option = entry.value;
            final isSelected = selections.contains(optIndex);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () =>
                    _toggleSelection(index, optIndex, question.multiple),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primaryContainer.withOpacity(0.4)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary.withOpacity(0.5)
                          : colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Checkbox or Radio icon
                      Icon(
                        question.multiple
                            ? (isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank)
                            : (isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked),
                        size: 20,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline,
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.label,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (option.description.isNotEmpty)
                              Text(
                                option.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colorScheme.outline,
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

        // Edit/Custom input toggle
        if (question.custom ||
            true) // Always allow custom input as per user request ("I hope it at the very end have an edit icon")
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!showCustom)
                  IconButton(
                    icon: const Icon(Icons.edit_note),
                    tooltip: 'Add explanation',
                    onPressed: () {
                      setState(() {
                        _showCustomInput[index] = true;
                      });
                    },
                    iconSize: 20,
                    color: colorScheme.secondary,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),

        // Custom Input Field
        if (showCustom)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextField(
              controller: _customInputs[index],
              decoration: InputDecoration(
                hintText: 'Add explanation or custom answer...',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    setState(() {
                      _showCustomInput[index] = false;
                      _customInputs[index]?.clear();
                    });
                  },
                ),
              ),
              maxLines: 3,
              minLines: 1,
            ),
          ),
      ],
    );
  }
}
