import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:package_info_plus/package_info_plus.dart';

import '../providers/chat_provider.dart';
import '../config/app_config.dart';
import 'login_screen.dart';

/// Settings screen for Agent Assistant
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  /// Load app information
  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (error) {
      setState(() {
        _appVersion = AppConfig.appVersion;
      });
    }
  }

  /// Show disconnect confirmation dialog
  void _showDisconnectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('断开连接'),
        content: const Text('确定要断开与服务器的连接吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _disconnect();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('断开'),
          ),
        ],
      ),
    );
  }

  /// Disconnect and return to login
  void _disconnect() {
    context.read<ChatProvider>().disconnect();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  /// Show clear messages confirmation dialog
  void _showClearMessagesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除消息'),
        content: const Text('确定要清除所有聊天记录吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearMessages();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }

  /// Clear all messages
  void _clearMessages() {
    context.read<ChatProvider>().clearMessages();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('聊天记录已清除')),
    );
  }

  /// Show about dialog
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConfig.appName,
      applicationVersion: _appVersion,
      applicationIcon: Icon(
        Icons.smart_toy,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [
        const Text('Agent Assistant 是一个移动客户端应用，用于与 AI Agent 进行实时通信。'),
        const SizedBox(height: 16),
        const Text('功能特性：'),
        const Text('• 实时 WebSocket 通信'),
        const Text('• 支持多种内容类型'),
        const Text('• 自动重连机制'),
        const Text('• 本地消息存储'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return ListView(
            children: [
              // Connection section
              _buildSectionHeader('连接'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        chatProvider.isConnected ? Icons.wifi : Icons.wifi_off,
                        color: chatProvider.isConnected
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: Text(
                        chatProvider.isConnected ? '已连接' : '未连接',
                      ),
                      subtitle: Text(
                        chatProvider.isConnected
                            ? '与服务器连接正常'
                            : chatProvider.connectionError ?? '连接已断开',
                      ),
                    ),
                    if (chatProvider.isConnected)
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('断开连接'),
                        subtitle: const Text('断开与服务器的连接'),
                        onTap: _showDisconnectDialog,
                      ),
                  ],
                ),
              ),

              // Messages section
              _buildSectionHeader('消息'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.message),
                      title: const Text('消息统计'),
                      subtitle: Text(
                        '总计 ${chatProvider.messages.length} 条消息\n'
                        '待处理问题 ${chatProvider.pendingQuestions.length} 个\n'
                        '待处理任务 ${chatProvider.pendingTasks.length} 个',
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.clear_all),
                      title: const Text('清除消息'),
                      subtitle: const Text('删除所有聊天记录'),
                      onTap: _showClearMessagesDialog,
                    ),
                  ],
                ),
              ),

              // App section
              _buildSectionHeader('应用'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('关于'),
                      subtitle: Text('版本 $_appVersion'),
                      onTap: _showAboutDialog,
                    ),
                    ListTile(
                      leading: const Icon(Icons.bug_report),
                      title: const Text('反馈问题'),
                      subtitle: const Text('报告 Bug 或提出建议'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('请联系您的系统管理员反馈问题'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
