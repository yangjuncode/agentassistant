import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../providers/chat_provider.dart';
import '../config/app_config.dart';
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
  final _serverController = TextEditingController();

  bool _isLoading = false;
  bool _rememberSettings = true;
  bool _showAdvancedSettings = false;

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _serverController.dispose();
    super.dispose();
  }

  /// Load saved settings from storage
  Future<void> _loadSavedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(AppConfig.tokenStorageKey);
      final savedServer = prefs.getString(AppConfig.serverUrlStorageKey);

      if (savedToken != null) {
        _tokenController.text = savedToken;
      }

      if (savedServer != null) {
        _serverController.text = savedServer;
      } else {
        _serverController.text = AppConfig.buildWebSocketUrl();
      }

      setState(() {});
    } catch (error) {
      debugPrint('Failed to load saved settings: $error');
    }
  }

  /// Handle login button press
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final token = _tokenController.text.trim();
      final serverUrl = _serverController.text.trim();

      // Save settings if remember is checked
      if (_rememberSettings) {
        await _saveSettings(token, serverUrl);
      }

      // Connect to server
      if (mounted) {
        final chatProvider = context.read<ChatProvider>();
        await chatProvider.connect(serverUrl, token);
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
  Future<void> _saveSettings(String token, String serverUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.tokenStorageKey, token);
      await prefs.setString(AppConfig.serverUrlStorageKey, serverUrl);
    } catch (error) {
      debugPrint('Failed to save settings: $error');
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

  /// Validate server URL format
  String? _validateServerUrl(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.errorServerRequired;
    }

    final url = value.trim();
    if (!url.startsWith('ws://') && !url.startsWith('wss://')) {
      return l10n.errorServerProtocol;
    }

    return null;
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
            child: SingleChildScrollView(
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
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.loginSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

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
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Advanced settings toggle
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showAdvancedSettings = !_showAdvancedSettings;
                      });
                    },
                    icon: Icon(
                      _showAdvancedSettings
                          ? Icons.expand_less
                          : Icons.expand_more,
                    ),
                    label: Text(l10n.loginAdvancedSettings),
                  ),

                  // Advanced settings
                  if (_showAdvancedSettings) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _serverController,
                      decoration: InputDecoration(
                        labelText: l10n.loginServerLabel,
                        hintText: 'ws://localhost:8080/ws',
                        prefixIcon: const Icon(Icons.dns),
                      ),
                      validator: _validateServerUrl,
                      textInputAction: TextInputAction.done,
                    ),
                  ],

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

                  const SizedBox(height: 32),

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
                            child: CircularProgressIndicator(strokeWidth: 2),
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
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
