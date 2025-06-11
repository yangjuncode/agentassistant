import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
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
  final Map<String, GlobalKey> _messageKeys = {};
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Schedule post-frame callback to handle initial setup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Initialize screen after first frame
  Future<void> _initializeScreen() async {
    if (_hasInitialized) return;
    _hasInitialized = true;

    final chatProvider = context.read<ChatProvider>();

    // Wait for message validity check to complete
    await _waitForValidityCheck(chatProvider);

    // Find and scroll to earliest replyable message
    await _scrollToEarliestReplyableMessage(chatProvider);
  }

  /// Wait for message validity check to complete
  Future<void> _waitForValidityCheck(ChatProvider chatProvider) async {
    // Give some time for the validity check to complete
    // In a real implementation, you might want to listen to a specific state
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  /// Scroll to the earliest replyable message and focus its input
  Future<void> _scrollToEarliestReplyableMessage(
      ChatProvider chatProvider) async {
    final earliestMessage = chatProvider.findEarliestReplyableMessage();

    if (earliestMessage != null) {
      await _scrollToMessage(earliestMessage.id);
      // Additional delay to ensure scroll completes before focusing
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  /// Scroll to a specific message
  Future<void> _scrollToMessage(String messageId) async {
    final messageKey = _messageKeys[messageId];
    if (messageKey?.currentContext != null) {
      await Scrollable.ensureVisible(
        messageKey!.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        alignment: 0.2, // Position message at 20% from top
      );
    }
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

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];

        // Create or get GlobalKey for this message
        _messageKeys[message.id] ??= GlobalKey();

        return Padding(
          key: _messageKeys[message.id],
          padding: const EdgeInsets.only(bottom: 16),
          child: MessageBubble(
            message: message,
          ),
        );
      },
    );
  }
}
