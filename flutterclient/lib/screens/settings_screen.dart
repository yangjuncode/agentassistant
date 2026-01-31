import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../l10n/app_localizations.dart';
import '../providers/chat_provider.dart';
import '../providers/project_directory_index_provider.dart';
import '../providers/mcp_tool_index_provider.dart';
import '../models/server_config.dart';

import '../config/app_config.dart';
import '../services/window_service.dart';
import '../widgets/settings/nickname_settings.dart';
import '../widgets/settings/slash_command_completion_settings.dart';
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

  String _desktopMcpAttentionModeLabel(
      AppLocalizations l10n, DesktopMcpAttentionMode mode) {
    switch (mode) {
      case DesktopMcpAttentionMode.none:
        return l10n.mcpAttentionModeNone;
      case DesktopMcpAttentionMode.tray:
        return l10n.mcpAttentionModeTray;
      case DesktopMcpAttentionMode.popup:
        return l10n.mcpAttentionModePopup;
      case DesktopMcpAttentionMode.popupOnTop:
        return l10n.mcpAttentionModePopupOnTop;
      case DesktopMcpAttentionMode.trayPopupOnTop:
        return l10n.mcpAttentionModeTrayPopupOnTop;
    }
  }

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
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final urlController = TextEditingController(text: existing?.url ?? '');
    bool enabled = existing?.isEnabled ?? true;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(existing == null ? l10n.addServer : l10n.editServer),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: l10n.serverAlias),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: urlController,
                      decoration: InputDecoration(
                        labelText: l10n.webSocketUrl,
                        hintText: l10n.webSocketUrlHint,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: enabled,
                      onChanged: (v) => setState(() => enabled = v),
                      title: Text(l10n.enabled),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
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
                  child: Text(l10n.save),
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
          final pathIndexProvider =
              context.watch<ProjectDirectoryIndexProvider>();
          final toolIndexProvider = context.watch<McpToolIndexProvider>();
          return ListView(
            children: [
              _buildCurrentProfile(context, chatProvider),

              _buildSectionHeader(l10n.servers),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  children: [
                    for (int i = 0;
                        i < chatProvider.serverConfigs.length;
                        i++) ...[
                      _buildServerTile(
                          chatProvider, chatProvider.serverConfigs[i]),
                      if (i < chatProvider.serverConfigs.length - 1)
                        const Divider(height: 1),
                    ],
                    if (chatProvider.serverConfigs.isNotEmpty)
                      const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: Text(l10n.addServer),
                      onTap: () => _showAddEditServerDialog(chatProvider),
                    ),
                  ],
                ),
              ),

              // Connection section
              _buildSectionHeader(l10n.connection),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                      subtitle:
                          Text(chatProvider.currentClientId ?? l10n.notSet),
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
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.touch_app),
                      title: Text(l10n.useInteractiveMode),
                      subtitle: Text(l10n.useInteractiveModeDesc),
                      value: chatProvider.useInteractiveAskQuestion,
                      onChanged: (value) {
                        chatProvider.setUseInteractiveAskQuestion(value);
                      },
                    ),
                  ],
                ),
              ),

              _buildSectionHeader(l10n.pathAutocomplete),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  children: [
                    for (int i = 0;
                        i <
                            ProjectDirectoryIndexProvider
                                .defaultIgnoredDirs.length;
                        i++) ...[
                      SwitchListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        secondary: const Icon(Icons.folder_off, size: 20),
                        title: Text(
                          l10n.ignoredDirectory(ProjectDirectoryIndexProvider
                              .defaultIgnoredDirs[i]),
                          style: const TextStyle(fontSize: 13),
                        ),
                        value: pathIndexProvider.ignoredDirs.contains(
                            ProjectDirectoryIndexProvider
                                .defaultIgnoredDirs[i]),
                        onChanged: (v) {
                          pathIndexProvider.setIgnoredDirEnabled(
                              ProjectDirectoryIndexProvider
                                  .defaultIgnoredDirs[i],
                              v);
                        },
                      ),
                      if (i <
                          ProjectDirectoryIndexProvider
                                  .defaultIgnoredDirs.length -
                              1)
                        const Divider(height: 1),
                    ],
                  ],
                ),
              ),

              _buildSectionHeader(l10n.slashCommands),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.code),
                      title: Text(l10n.slashCommandsShow),
                      trailing: DropdownButton<McpSlashSuggestContent>(
                        value: toolIndexProvider.slashSuggestContent,
                        onChanged: (v) {
                          if (v != null) {
                            toolIndexProvider.setSlashSuggestContent(v);
                          }
                        },
                        items: [
                          DropdownMenuItem(
                            value: McpSlashSuggestContent.command,
                            child: Text(l10n.slashCommandsOptionCommands),
                          ),
                          DropdownMenuItem(
                            value: McpSlashSuggestContent.skill,
                            child: Text(l10n.slashCommandsOptionSkills),
                          ),
                          DropdownMenuItem(
                            value: McpSlashSuggestContent.commandAndSkill,
                            child:
                                Text(l10n.slashCommandsOptionCommandsAndSkills),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    const SlashCommandCompletionSettings(),
                  ],
                ),
              ),

              if (WindowService().isDesktop) ...[
                _buildSectionHeader(l10n.desktop),
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Column(
                    children: [
                      _buildAttentionModeTile(
                        l10n,
                        l10n.mcpAskQuestionAttention,
                        chatProvider.askQuestionAttentionMode,
                        (mode) =>
                            chatProvider.setAskQuestionAttentionMode(mode),
                      ),
                      const Divider(height: 1),
                      _buildAttentionModeTile(
                        l10n,
                        l10n.mcpWorkReportAttention,
                        chatProvider.workReportAttentionMode,
                        (mode) => chatProvider.setWorkReportAttentionMode(mode),
                      ),
                    ],
                  ),
                ),
              ],

              // Messages section
              _buildSectionHeader(l10n.messages),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.timer),
                      title: Text(l10n.chatAutoSendInterval),
                      subtitle: Text(
                        l10n.chatAutoSendIntervalSeconds(
                            chatProvider.chatAutoSendInterval),
                      ),
                    ),
                    Slider(
                      value: chatProvider.chatAutoSendInterval.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      label: l10n.chatAutoSendIntervalSeconds(
                          chatProvider.chatAutoSendInterval),
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
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: Text(l10n.about),
                      subtitle: Text(l10n.version(_appVersion)),
                      onTap: _showAboutDialog,
                    ),
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(l10n.buildTime(AppConfig.buildTime)),
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

  Widget _buildCurrentProfile(BuildContext context, ChatProvider chatProvider) {
    final l10n = AppLocalizations.of(context)!;
    final nickname = chatProvider.nickname ?? '...';
    final clientId = chatProvider.currentClientId ?? l10n.notConnected;

    return Card(
      margin: const EdgeInsets.fromLTRB(8, 16, 8, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                nickname.isNotEmpty ? nickname[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nickname,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.profileClientIdLabel(clientId),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            if (chatProvider.isConnected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.5)),
                ),
                child: Text(
                  l10n.online,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build a single server tile
  Widget _buildServerTile(ChatProvider chatProvider, ServerConfig server) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = server.isEnabled;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First row: icon, name, actions
          Row(
            children: [
              // Server icon
              Icon(
                Icons.dns,
                size: 20,
                color: isEnabled ? colorScheme.primary : colorScheme.outline,
              ),
              const SizedBox(width: 12),
              // Server name (expandable)
              Expanded(
                child: Text(
                  server.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isEnabled ? null : colorScheme.outline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Actions: enable switch, edit, delete
              SizedBox(
                height: 32,
                child: Switch(
                  value: isEnabled,
                  onChanged: (value) {
                    chatProvider.upsertServerConfig(
                      server.copyWith(isEnabled: value),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  tooltip: l10n.edit,
                  padding: EdgeInsets.zero,
                  onPressed: () =>
                      _showAddEditServerDialog(chatProvider, existing: server),
                  icon: Icon(
                    Icons.edit,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  tooltip: l10n.delete,
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    await chatProvider.deleteServerConfig(server.id);
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: colorScheme.error.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          // Second row: URL (indented to align with name)
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 4),
            child: Text(
              server.url,
              style: TextStyle(
                fontSize: 12,
                color: isEnabled
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.outline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildAttentionModeTile(
    AppLocalizations l10n,
    String title,
    DesktopMcpAttentionMode currentMode,
    ValueChanged<DesktopMcpAttentionMode> onChanged,
  ) {
    return ListTile(
      leading: const Icon(Icons.notifications_active),
      title: Text(title),
      subtitle: Text(_desktopMcpAttentionModeLabel(l10n, currentMode)),
      trailing: SizedBox(
        width: 260,
        child: DropdownButton<DesktopMcpAttentionMode>(
          value: currentMode,
          isExpanded: true,
          onChanged: (mode) {
            if (mode != null) onChanged(mode);
          },
          items: DesktopMcpAttentionMode.values
              .map(
                (m) => DropdownMenuItem(
                  value: m,
                  child: Text(
                    _desktopMcpAttentionModeLabel(l10n, m),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
