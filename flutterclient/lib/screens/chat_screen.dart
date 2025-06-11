import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/connection_status_bar.dart';
import '../widgets/pending_actions_bar.dart';
import '../config/app_config.dart';
import 'settings_screen.dart';

/// Main chat screen for Agent Assistant
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll to bottom of message list
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Handle message reply
  void _handleReply(ChatMessage message) {
    _showReplyDialog(message);
  }

  /// Handle task confirmation
  void _handleConfirm(ChatMessage message) {
    _showConfirmDialog(message);
  }

  /// Show reply dialog for questions
  void _showReplyDialog(ChatMessage message) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('回复问题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '问题：',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            Text(
              message.question ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '您的回复',
                hintText: '请输入回复内容...',
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final reply = controller.text.trim();
              if (reply.isNotEmpty) {
                context.read<ChatProvider>().replyToQuestion(message.id, reply);
                Navigator.of(context).pop();
                _scrollToBottom();
              }
            },
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog for tasks
  void _showConfirmDialog(ChatMessage message) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认任务'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '任务摘要：',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            Text(
              message.summary ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '确认备注（可选）',
                hintText: '添加确认备注...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final confirmText = controller.text.trim();
              context.read<ChatProvider>().confirmTask(
                message.id, 
                confirmText.isNotEmpty ? confirmText : null,
              );
              Navigator.of(context).pop();
              _scrollToBottom();
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  /// Show settings screen
  void _showSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: '设置',
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return Column(
            children: [
              // Connection status bar
              const ConnectionStatusBar(),
              
              // Pending actions bar
              const PendingActionsBar(),
              
              // Messages list
              Expanded(
                child: _buildMessagesList(chatProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build messages list widget
  Widget _buildMessagesList(ChatProvider chatProvider) {
    if (chatProvider.isConnecting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在连接到 Agent Assistant 服务器...'),
          ],
        ),
      );
    }

    if (!chatProvider.isConnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '连接已断开',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              chatProvider.connectionError ?? '无法连接到服务器',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Try to reconnect or go back to login
                Navigator.of(context).pushReplacementNamed('/login');
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重新连接'),
            ),
          ],
        ),
      );
    }

    if (chatProvider.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '等待 AI Agent 的消息...',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '连接成功后，AI Agent 的问题和任务将在这里显示',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Show messages list
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: MessageBubble(
            message: message,
            onReply: () => _handleReply(message),
            onConfirm: () => _handleConfirm(message),
          ),
        );
      },
    );
  }
}
