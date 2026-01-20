import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../providers/chat_provider.dart';
import '../config/app_config.dart';
import '../models/server_config.dart';
import 'chat_screen.dart';

/// Login screen for Agent Assistant
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();

  bool _isLoading = false;
  bool _rememberSettings = true;

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  /// Load saved settings from storage
  Future<void> _loadSavedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(AppConfig.tokenStorageKey);

      if (savedToken != null) {
        _tokenController.text = savedToken;
      }

      setState(() {});
    } catch (error) {
      // debugPrint('Failed to load saved settings: $error');
    }
  }

  /// Handle login button press
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final chatProvider = context.read<ChatProvider>();

    // Check if there are enabled servers
    final enabledServers =
        chatProvider.serverConfigs.where((s) => s.isEnabled).toList();
    if (enabledServers.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noEnabledServers),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = _tokenController.text.trim();

      // Save settings if remember is checked
      if (_rememberSettings) {
        await _saveSettings(token);
      }

      // Connect to all enabled servers
      if (mounted) {
        await chatProvider.connectAll();
      }

      // Navigate to chat screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ChatScreen(),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.loginFailed(error.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Save settings to storage
  Future<void> _saveSettings(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.tokenStorageKey, token);
    } catch (error) {
      // debugPrint('Failed to save settings: $error');
    }
  }

  /// Validate token format
  String? _validateToken(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.errorTokenRequired;
    }
    if (!AppConfig.isValidToken(value.trim())) {
      return l10n.errorTokenInvalid;
    }
    return null;
  }

  /// Show add/edit server dialog
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
            final l10n = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Text(existing == null ? l10n.addServer : l10n.editServer),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: l10n.serverAlias,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: urlController,
                      decoration: InputDecoration(
                        labelText: l10n.webSocketUrl,
                        hintText: 'ws://host:port/ws',
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo and title
                      Icon(
                        Icons.smart_toy,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppConfig.appName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.loginSubtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Token input
                      TextFormField(
                        controller: _tokenController,
                        decoration: InputDecoration(
                          labelText: l10n.loginTokenLabel,
                          hintText: l10n.loginTokenHint,
                          prefixIcon: const Icon(Icons.key),
                        ),
                        validator: _validateToken,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 24),

                      // Server configurations section
                      _buildServersSection(chatProvider),

                      const SizedBox(height: 24),

                      // Remember settings checkbox
                      CheckboxListTile(
                        title: Text(l10n.loginRememberSettingsTitle),
                        subtitle: Text(l10n.loginRememberSettingsSubtitle),
                        value: _rememberSettings,
                        onChanged: (value) {
                          setState(() {
                            _rememberSettings = value ?? true;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      const SizedBox(height: 24),

                      // Login button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                l10n.loginButton,
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),

                      const SizedBox(height: 24),

                      // Help text
                      Text(
                        l10n.loginHelp,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Build server configurations section
  Widget _buildServersSection(ChatProvider chatProvider) {
    final l10n = AppLocalizations.of(context)!;
    final servers = chatProvider.serverConfigs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.servers,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            TextButton.icon(
              onPressed: () => _showAddEditServerDialog(chatProvider),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addServer),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (servers.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  l10n.noServersConfigured,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
          )
        else
          Card(
            child: Column(
              children: [
                for (int i = 0; i < servers.length; i++) ...[
                  _buildServerTile(chatProvider, servers[i]),
                  if (i < servers.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
      ],
    );
  }

  /// Build a single server tile
  Widget _buildServerTile(ChatProvider chatProvider, ServerConfig server) {
    return ListTile(
      leading: Icon(
        Icons.dns,
        color: server.isEnabled
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline,
      ),
      title: Text(
        server.displayName,
        style: TextStyle(
          color:
              server.isEnabled ? null : Theme.of(context).colorScheme.outline,
        ),
      ),
      subtitle: Text(
        server.url,
        style: TextStyle(
          fontSize: 12,
          color: server.isEnabled
              ? Theme.of(context).colorScheme.onSurfaceVariant
              : Theme.of(context).colorScheme.outline,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: server.isEnabled,
            onChanged: (value) {
              chatProvider.upsertServerConfig(
                server.copyWith(isEnabled: value),
              );
            },
          ),
          IconButton(
            tooltip: AppLocalizations.of(context)!.edit,
            onPressed: () =>
                _showAddEditServerDialog(chatProvider, existing: server),
            icon: const Icon(Icons.edit, size: 20),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context)!.delete,
            onPressed: () async {
              final confirm = await _showDeleteConfirmDialog(server);
              if (confirm == true) {
                await chatProvider.deleteServerConfig(server.id);
              }
            },
            icon: const Icon(Icons.delete_outline, size: 20),
          ),
        ],
      ),
    );
  }

  /// Show delete confirmation dialog
  Future<bool?> _showDeleteConfirmDialog(ServerConfig server) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteServerConfirmTitle),
        content: Text(l10n.deleteServerConfirmMessage(server.displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
