import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/mcp_tool_index_provider.dart';

class SlashCommandCompletionSettings extends StatefulWidget {
  const SlashCommandCompletionSettings({super.key});

  @override
  State<SlashCommandCompletionSettings> createState() =>
      _SlashCommandCompletionSettingsState();
}

class _SlashCommandCompletionSettingsState
    extends State<SlashCommandCompletionSettings> {
  late TextEditingController _commandController;
  late TextEditingController _skillController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<McpToolIndexProvider>();
    _commandController =
        TextEditingController(text: provider.slashCommandCompletionText);
    _skillController =
        TextEditingController(text: provider.slashSkillCompletionText);
  }

  @override
  void dispose() {
    _commandController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<McpToolIndexProvider>();

    // Update text if it changed in provider (e.g. from Reset)
    if (_commandController.text != provider.slashCommandCompletionText) {
      _commandController.text = provider.slashCommandCompletionText;
    }
    if (_skillController.text != provider.slashSkillCompletionText) {
      _skillController.text = provider.slashSkillCompletionText;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildItem(
          context,
          title: l10n.slashCommandCompletionText,
          controller: _commandController,
          onChanged: (v) => provider.setSlashCommandCompletionText(v),
          onReset: () => provider.resetSlashCommandCompletionText(),
          helperText: l10n.slashCompletionTextDesc,
        ),
        const Divider(height: 1),
        _buildItem(
          context,
          title: l10n.slashSkillCompletionText,
          controller: _skillController,
          onChanged: (v) => provider.setSlashSkillCompletionText(v),
          onReset: () => provider.resetSlashSkillCompletionText(),
          helperText: l10n.slashCompletionTextDesc,
        ),
      ],
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required VoidCallback onReset,
    required String helperText,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              TextButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n.resetToDefault),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: title,
              helperText: helperText,
              helperMaxLines: 2,
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            maxLines: 3,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
