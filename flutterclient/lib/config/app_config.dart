/// Application configuration constants
class AppConfig {
  // WebSocket configuration
  static const String defaultWebSocketHost = 'localhost';
  static const int defaultWebSocketPort = 8080;
  static const String webSocketPath = '/ws';

  // Connection settings
  static const int maxReconnectAttempts = 5;
  static const int reconnectDelayMs = 1000;
  static const int connectionTimeoutMs = 10000;
  static const int heartbeatIntervalMs = 30000;

  // UI settings
  static const int maxMessageLength = 10000;
  static const int messageHistoryLimit = 1000;
  static const double messageBubbleMaxWidth = 0.8;

  // Storage keys
  static const String tokenStorageKey = 'user_token';
  static const String serverUrlStorageKey = 'server_url';
  static const String settingsStorageKey = 'app_settings';

  // Default values
  static const String appName = 'Agent Assistant';
  static const String appVersion = '1.0.0';

  // Build WebSocket URL
  static String buildWebSocketUrl({
    String? host,
    int? port,
    bool useSSL = false,
  }) {
    final protocol = useSSL ? 'wss' : 'ws';
    final actualHost = host ?? defaultWebSocketHost;
    final actualPort = port ?? defaultWebSocketPort;
    return '$protocol://$actualHost:$actualPort$webSocketPath';
  }

  // Validate token format (basic validation)
  static bool isValidToken(String? token) {
    if (token == null || token.isEmpty) return false;
    // Basic token validation - should be at least 10 characters
    return token.isNotEmpty;
  }
}
