import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../l10n/app_localizations.dart';
import '../providers/chat_provider.dart';
import '../models/server_config.dart';

import '../config/app_config.dart';
import '../widgets/settings/nickname_settings.dart';
import '../widgets/server_status_icon.dart';
import '../widgets/settings/language_settings.dart';
import 'login_screen.dart';

/// Settings screen for Agent Assistant
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';
  String? _serverUrl;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
    _loadConnectionConfig();
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

  /// Load websocket connection configuration from SharedPreferences
  Future<void> _loadConnectionConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString(AppConfig.serverUrlStorageKey);
      final savedToken = prefs.getString(AppConfig.tokenStorageKey);

      if (!mounted) return;
      setState(() {
        _serverUrl = savedUrl;
        _token = savedToken;
      });
    } catch (_) {
      // keep defaults; do not crash settings
    }
  }

  /// Show disconnect confirmation dialog
  void _showDisconnectDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.disconnectConfirmTitle),
        content: Text(l10n.disconnectConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
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
            child: Text(l10n.disconnect),
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

  Future<void> _showAddEditServerDialog(ChatProvider chatProvider,
      {ServerConfig? existing}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final urlController = TextEditingController(text: existing?.url ?? '');
    bool enabled = existing?.isEnabled ?? true;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(existing == null ? 'Add Server' : 'Edit Server'),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Alias (optional)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: urlController,
                      decoration: const InputDecoration(
                        labelText: 'WebSocket URL',
                        hintText: 'ws://host:port/ws',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: enabled,
                      onChanged: (v) => setState(() => enabled = v),
                      title: const Text('Enabled'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final url = urlController.text.trim();
                    if (!url.startsWith('ws://') && !url.startsWith('wss://')) {
                      return;
                    }
                    final cfg = (existing ??
                            ServerConfig(
                              name: '',
                              url: '',
                              isEnabled: true,
                            ))
                        .copyWith(
                      name: nameController.text,
                      url: url,
                      isEnabled: enabled,
                    );
                    await chatProvider.upsertServerConfig(cfg);
                    if (mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    urlController.dispose();
  }

  /// Show clear messages confirmation dialog
  void _showClearMessagesDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearMessagesConfirmTitle),
        content: Text(l10n.clearMessagesConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
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
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }

  /// Clear all messages
  void _clearMessages() {
    final l10n = AppLocalizations.of(context)!;
    context.read<ChatProvider>().clearMessages();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.messagesCleared)),
    );
  }

  /// Show about dialog
  void _showAboutDialog() {
    final l10n = AppLocalizations.of(context)!;
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
        Text(l10n.aboutAppDescription),
        const SizedBox(height: 16),
        Text(l10n.features),
        Text('• ${l10n.featureWebSocket}'),
        Text('• ${l10n.featureMultiContent}'),
        Text('• ${l10n.featureAutoReconnect}'),
        Text('• ${l10n.featureLocalStorage}'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        actions: [
          const ServerStatusIcon(),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return ListView(
            children: [
              _buildSectionHeader('Servers'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    for (final server in chatProvider.serverConfigs) ...[
                      ListTile(
                        leading: const Icon(Icons.dns),
                        title: Text(server.displayName),
                        subtitle: Text(server.url),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: server.isEnabled,
                              onChanged: (value) {
                                chatProvider.upsertServerConfig(
                                    server.copyWith(isEnabled: value));
                              },
                            ),
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: () => _showAddEditServerDialog(
                                  chatProvider,
                                  existing: server),
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: () async {
                                await chatProvider
                                    .deleteServerConfig(server.id);
                              },
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Add server'),
                      onTap: () => _showAddEditServerDialog(chatProvider),
                    ),
                  ],
                ),
              ),

              // Connection section
              _buildSectionHeader(l10n.connection),
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
                        chatProvider.isConnected
                            ? l10n.connected
                            : l10n.disconnected,
                      ),
                      subtitle: Text(
                        chatProvider.isConnected
                            ? l10n.connectedToServer
                            : chatProvider.connectionError ??
                                l10n.connectionClosed,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.cloud),
                      title: Text(l10n.serverAddress),
                      subtitle: Text(_serverUrl ?? l10n.notSet),
                    ),
                    ListTile(
                      leading: const Icon(Icons.badge),
                      title: Text(l10n.clientId),
                      subtitle: Text(chatProvider.currentClientId ?? '—'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.vpn_key),
                      title: Text(l10n.accessToken),
                      subtitle: Text(_token ?? l10n.notSet),
                    ),
                    if (chatProvider.isConnected)
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: Text(l10n.disconnect),
                        subtitle: Text(l10n.disconnectFromServer),
                        onTap: _showDisconnectDialog,
                      ),
                  ],
                ),
              ),

              // User section
              _buildSectionHeader(l10n.userSettings),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    NicknameSettings(
                      onNicknameChanged: (nickname) {
                        // Handle nickname change if needed
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.nicknameUpdated(nickname)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const LanguageSettings(),
                  ],
                ),
              ),

              // System Input section
              _buildSectionHeader(l10n.systemInput),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.input),
                      title: Text(l10n.autoForwardMessages),
                      subtitle: Text(l10n.autoForwardMessagesDesc),
                      value: chatProvider.autoForwardToSystemInput,
                      onChanged: (value) {
                        chatProvider.setAutoForwardToSystemInput(value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(value
                                ? l10n.autoForwardEnabled
                                : l10n.autoForwardDisabled),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Messages section
              _buildSectionHeader(l10n.messages),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.timer),
                      title: const Text('Chat Auto Send Interval'),
                      subtitle: Text(
                          '${chatProvider.chatAutoSendInterval} seconds'),
                    ),
                    Slider(
                      value: chatProvider.chatAutoSendInterval.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      label: '${chatProvider.chatAutoSendInterval} seconds',
                      onChanged: (value) {
                         chatProvider.setChatAutoSendInterval(value.toInt());
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.message),
                      title: Text(l10n.messageStats),
                      subtitle: Text(
                        '${l10n.totalMessages(chatProvider.messages.length)}\n'
                        '${l10n.pendingQuestions(chatProvider.pendingQuestions.length)}\n'
                        '${l10n.pendingTasks(chatProvider.pendingTasks.length)}',
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.clear_all),
                      title: Text(l10n.clearMessages),
                      subtitle: Text(l10n.clearMessagesDesc),
                      onTap: _showClearMessagesDialog,
                    ),
                  ],
                ),
              ),

              // App section
              _buildSectionHeader(l10n.app),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: Text(l10n.about),
                      subtitle: Text(l10n.version(_appVersion)),
                      onTap: _showAboutDialog,
                    ),
                    ListTile(
                      leading: const Icon(Icons.bug_report),
                      title: Text(l10n.feedback),
                      subtitle: Text(l10n.feedbackDesc),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.feedbackMessage),
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
