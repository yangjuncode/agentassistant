import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登录失败: $error'),
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
    if (value == null || value.trim().isEmpty) {
      return '请输入访问令牌';
    }
    if (!AppConfig.isValidToken(value.trim())) {
      return '令牌格式无效（至少1个字符）';
    }
    return null;
  }

  /// Validate server URL format
  String? _validateServerUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入服务器地址';
    }

    final url = value.trim();
    if (!url.startsWith('ws://') && !url.startsWith('wss://')) {
      return '服务器地址必须以 ws:// 或 wss:// 开头';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
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
                    '连接到您的 AI Agent 助手',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Token input
                  TextFormField(
                    controller: _tokenController,
                    decoration: const InputDecoration(
                      labelText: '访问令牌',
                      hintText: '请输入您的访问令牌',
                      prefixIcon: Icon(Icons.key),
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
                    label: const Text('高级设置'),
                  ),

                  // Advanced settings
                  if (_showAdvancedSettings) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _serverController,
                      decoration: const InputDecoration(
                        labelText: '服务器地址',
                        hintText: 'ws://localhost:8080/ws',
                        prefixIcon: Icon(Icons.dns),
                      ),
                      validator: _validateServerUrl,
                      textInputAction: TextInputAction.done,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Remember settings checkbox
                  CheckboxListTile(
                    title: const Text('记住设置'),
                    subtitle: const Text('下次启动时自动填充'),
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
                        : const Text(
                            '连接',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),

                  const SizedBox(height: 24),

                  // Help text
                  Text(
                    '需要帮助？请联系您的系统管理员获取访问令牌。',
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
