import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';

/// Compact pending actions indicator for AppBar
class PendingActionsIndicator extends StatelessWidget {
  const PendingActionsIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final pendingQuestions = chatProvider.pendingQuestions;
        final pendingTasks = chatProvider.pendingTasks;
        final totalPending = pendingQuestions.length + pendingTasks.length;
        
        // Don't show if no pending actions
        if (totalPending == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(right: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showPendingActionsDialog(context, pendingQuestions, pendingTasks),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.orange.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pending_actions,
                      color: Colors.orange.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$totalPending',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Show detailed pending actions dialog
  void _showPendingActionsDialog(
    BuildContext context,
    List<dynamic> pendingQuestions,
    List<dynamic> pendingTasks,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.pending_actions, color: Colors.orange),
            SizedBox(width: 8),
            Text('待处理项目'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pendingQuestions.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 18,
                    color: Colors.orange.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '待回答问题: ${pendingQuestions.length} 个',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (pendingTasks.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 18,
                    color: Colors.orange.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '待确认任务: ${pendingTasks.length} 个',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            const Text(
              '点击消息可以直接回复或确认',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}
