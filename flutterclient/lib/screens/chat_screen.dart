import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../constants/websocket_commands.dart';
import '../widgets/message_bubble.dart';
import '../widgets/connection_status_bar.dart';
import '../widgets/pending_actions_indicator.dart';
import '../widgets/online_users_bar.dart';
import '../config/app_config.dart';
import 'settings_screen.dart';
import '../widgets/server_status_icon.dart';

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
  List<ChatMessage> _previousMessages = [];

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

    // Always scroll to earliest replyable message on init
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
    print('🎯 Attempting to scroll to message: $messageId');

    final messageKey = _messageKeys[messageId];
    if (messageKey?.currentContext != null) {
      print(
          '✅ Found message context, scrolling with Scrollable.ensureVisible...');
      await Scrollable.ensureVisible(
        messageKey!.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        alignment: 0.2, // Position message at 20% from top
      );
      print('✅ Scroll completed for message: $messageId');
    } else {
      print(
          '❌ No context found for message: $messageId, trying index-based scroll...');
      await _scrollToMessageByIndex(messageId);
    }
  }

  /// Scroll to message by finding its index and calculating position
  Future<void> _scrollToMessageByIndex(String messageId) async {
    // Get current messages from the provider
    final chatProvider = context.read<ChatProvider>();
    final messages = chatProvider.visibleMessages;

    // Find the index of the target message
    final messageIndex = messages.indexWhere((m) => m.id == messageId);

    if (messageIndex == -1) {
      print('❌ Message not found in list: $messageId');
      return;
    }

    print('📍 Found message at index: $messageIndex');

    // Get viewport information
    final double viewportHeight = _scrollController.position.viewportDimension;
    final double maxScrollExtent = _scrollController.position.maxScrollExtent;

    print('📍 Viewport height: $viewportHeight, Max scroll: $maxScrollExtent');

    // Calculate approximate scroll position
    // Use a more conservative estimate and position message higher in viewport
    const double estimatedItemHeight = 150.0; // Increased estimate

    final double targetOffset =
        (messageIndex * estimatedItemHeight) - (viewportHeight * 0.3);

    // Ensure we don't scroll beyond the maximum, but prefer to scroll to the end
    // if the target is near the bottom to ensure input box is visible
    final double scrollOffset;
    if (messageIndex >= messages.length - 3) {
      // If it's one of the last 3 messages, scroll to the very bottom
      scrollOffset = maxScrollExtent;
      print('📍 Target is near bottom, scrolling to max extent: $scrollOffset');
    } else {
      scrollOffset = targetOffset > maxScrollExtent
          ? maxScrollExtent
          : (targetOffset < 0 ? 0 : targetOffset);
      print('📍 Calculated scroll offset: $scrollOffset');
    }

    // Animate to the calculated position
    await _scrollController.animateTo(
      scrollOffset,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );

    print('✅ Index-based scroll completed for message: $messageId');

    // After scrolling, wait a bit and try to use GlobalKey if available
    await Future.delayed(const Duration(milliseconds: 300));

    final messageKey = _messageKeys[messageId];
    if (messageKey?.currentContext != null) {
      print('🔄 Refining scroll position with GlobalKey...');
      await Scrollable.ensureVisible(
        messageKey!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.8, // Position message towards bottom to show input box
      );
      print('✅ Refined scroll completed');
    }
  }

  /// Check for new replyable messages and auto-scroll if needed
  void _checkForNewReplyableMessages(List<ChatMessage> currentMessages) {
    // Skip if not initialized yet
    if (!_hasInitialized) {
      print('⏳ Not initialized yet, skipping message check');
      return;
    }

    print('🔍 Checking messages. Total: ${currentMessages.length}');
    print('🗝️ Available message keys: ${_messageKeys.keys.toList()}');

    // Find new replyable messages
    final currentReplyableMessages = currentMessages
        .where((m) => m.needsUserAction && m.status != MessageStatus.expired)
        .toList();

    final previousReplyableMessages = _previousMessages
        .where((m) => m.needsUserAction && m.status != MessageStatus.expired)
        .toList();

    print(
        '📝 Current replyable messages: ${currentReplyableMessages.map((m) => m.id).toList()}');
    print(
        '📝 Previous replyable messages: ${previousReplyableMessages.map((m) => m.id).toList()}');

    // Check if there are new replyable messages
    final newReplyableMessages = currentReplyableMessages
        .where((current) => !previousReplyableMessages
            .any((previous) => previous.id == current.id))
        .toList();

    print('🆕 New replyable messages found: ${newReplyableMessages.length}');
    if (newReplyableMessages.isNotEmpty) {
      print(
          '🆕 New message IDs: ${newReplyableMessages.map((m) => m.id).toList()}');
    }

    if (newReplyableMessages.isNotEmpty) {
      // Find the earliest new replyable message
      newReplyableMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final earliestNewMessage = newReplyableMessages.first;

      print(
          '🎯 Earliest new message: ${earliestNewMessage.id} (${earliestNewMessage.type})');
      print(
          '🗝️ Key exists for message: ${_messageKeys.containsKey(earliestNewMessage.id)}');

      // Always scroll to new replyable messages to ensure input is visible
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print(
            '⏰ Post-frame callback triggered for message: ${earliestNewMessage.id}');
        // Add a small delay to ensure the ListView has been built
        Future.delayed(const Duration(milliseconds: 100), () {
          print(
              '⏰ Delayed scroll triggered for message: ${earliestNewMessage.id}');
          _scrollToMessage(earliestNewMessage.id);
        });
      });
    }

    // Update previous messages
    _previousMessages = List.from(currentMessages);
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        actions: [
          const PendingActionsIndicator(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: l10n.settings,
          ),
          const ServerStatusIcon(),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return Column(
            children: [
              // Connection status bar
              const ConnectionStatusBar(),

              // Online users bar
              const OnlineUsersBar(),

              // Messages list
              Expanded(
                child: _buildMessagesList(context, chatProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build messages list widget
  Widget _buildMessagesList(BuildContext context, ChatProvider chatProvider) {
    final l10n = AppLocalizations.of(context)!;
    if (chatProvider.isConnecting && !chatProvider.isConnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.chatConnecting),
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
              l10n.chatConnectionLost,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              chatProvider.connectionError ?? l10n.chatUnableConnect,
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
              label: Text(l10n.chatReconnect),
            ),
          ],
        ),
      );
    }

    if (chatProvider.visibleMessages.isEmpty) {
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
              l10n.chatEmptyTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.chatEmptySubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Pre-create GlobalKeys for all messages
    for (final message in chatProvider.visibleMessages) {
      _messageKeys[message.id] ??= GlobalKey();
    }

    // Check for new replyable messages after ensuring all keys are created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForNewReplyableMessages(chatProvider.visibleMessages);
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatProvider.visibleMessages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.visibleMessages[index];

        return Padding(
          key: _messageKeys[message.id],
          padding: const EdgeInsets.only(bottom: 8),
          child: MessageBubble(
            message: message,
          ),
        );
      },
    );
  }
}
