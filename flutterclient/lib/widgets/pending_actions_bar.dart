import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';

/// Pending actions bar widget
class PendingActionsBar extends StatelessWidget {
  const PendingActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final pendingQuestions = chatProvider.pendingQuestions;
        final pendingTasks = chatProvider.pendingTasks;
        
        // Don't show if no pending actions
        if (pendingQuestions.isEmpty && pendingTasks.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.orange.shade50,
          child: Row(
            children: [
              Icon(
                Icons.pending_actions,
                color: Colors.orange.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '待处理项目',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (pendingQuestions.isNotEmpty) ...[
                          Icon(
                            Icons.help_outline,
                            size: 14,
                            color: Colors.orange.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${pendingQuestions.length} 个问题',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (pendingQuestions.isNotEmpty && pendingTasks.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '•',
                              style: TextStyle(
                                color: Colors.orange.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if (pendingTasks.isNotEmpty) ...[
                          Icon(
                            Icons.task_alt,
                            size: 14,
                            color: Colors.orange.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${pendingTasks.length} 个任务',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.orange.shade600,
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}
