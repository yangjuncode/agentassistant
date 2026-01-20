// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Agent Assistant';

  @override
  String get settings => 'Settings';

  @override
  String get connection => 'Connection';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get connectedToServer => 'Connected to server';

  @override
  String get connectionClosed => 'Connection closed';

  @override
  String get serverAddress => 'Server Address';

  @override
  String get notSet => 'Not set';

  @override
  String get clientId => 'Client ID';

  @override
  String get accessToken => 'Access Token';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get disconnectFromServer => 'Disconnect from server';

  @override
  String get disconnectConfirmTitle => 'Disconnect';

  @override
  String get disconnectConfirmMessage =>
      'Are you sure you want to disconnect from the server?';

  @override
  String get cancel => 'Cancel';

  @override
  String get userSettings => 'User Settings';

  @override
  String get systemInput => 'System Input';

  @override
  String get autoForwardMessages => 'Auto Forward Chat Messages';

  @override
  String get autoForwardMessagesDesc =>
      'Automatically send received chat messages to system input';

  @override
  String get autoForwardEnabled => 'Auto forward enabled';

  @override
  String get autoForwardDisabled => 'Auto forward disabled';

  @override
  String get messages => 'Messages';

  @override
  String get messageStats => 'Message Statistics';

  @override
  String totalMessages(int count) {
    return 'Total $count messages';
  }

  @override
  String pendingQuestions(int count) {
    return 'Pending questions: $count';
  }

  @override
  String pendingTasks(int count) {
    return 'Pending tasks: $count';
  }

  @override
  String get clearMessages => 'Clear Messages';

  @override
  String get clearMessagesDesc => 'Delete all chat history';

  @override
  String get clearMessagesConfirmTitle => 'Clear Messages';

  @override
  String get clearMessagesConfirmMessage =>
      'Are you sure you want to clear all chat history? This action cannot be undone.';

  @override
  String get clear => 'Clear';

  @override
  String get messagesCleared => 'Chat history cleared';

  @override
  String get app => 'App';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get feedback => 'Feedback';

  @override
  String get feedbackDesc => 'Report bugs or suggest features';

  @override
  String get feedbackMessage =>
      'Please contact your system administrator to report issues';

  @override
  String get aboutAppDescription =>
      'Agent Assistant is a mobile client application for real-time communication with AI Agents.';

  @override
  String get features => 'Features:';

  @override
  String get featureWebSocket => 'Real-time WebSocket communication';

  @override
  String get featureMultiContent => 'Support for multiple content types';

  @override
  String get featureAutoReconnect => 'Auto reconnection mechanism';

  @override
  String get featureLocalStorage => 'Local message storage';

  @override
  String get language => 'Language';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageAuto => 'System Default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String nicknameUpdated(String nickname) {
    return 'Nickname updated to: $nickname';
  }

  // Login screen
  @override
  String get loginSubtitle => 'Connect to your AI Agent assistant';

  @override
  String loginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String get loginTokenLabel => 'Access token';

  @override
  String get loginTokenHint => 'Please enter your access token';

  @override
  String get loginAdvancedSettings => 'Advanced settings';

  @override
  String get loginServerLabel => 'Server address';

  @override
  String get loginRememberSettingsTitle => 'Remember settings';

  @override
  String get loginRememberSettingsSubtitle => 'Auto fill on next launch';

  @override
  String get loginButton => 'Connect';

  @override
  String get loginHelp =>
      'Need help? Please contact your system administrator to get an access token.';

  @override
  String get errorTokenRequired => 'Please enter access token';

  @override
  String get errorTokenInvalid => 'Invalid token format (at least 1 character)';

  @override
  String get errorServerRequired => 'Please enter server address';

  @override
  String get errorServerProtocol =>
      'Server address must start with ws:// or wss://';

  // Chat screen
  @override
  String get chatConnecting => 'Connecting to Agent Assistant server...';

  @override
  String get chatConnectionLost => 'Connection lost';

  @override
  String get chatUnableConnect => 'Unable to connect to server';

  @override
  String get chatReconnect => 'Reconnect';

  @override
  String get chatEmptyTitle => 'Waiting for messages from AI Agent...';

  @override
  String get chatEmptySubtitle =>
      'Once connected, questions and tasks from the AI Agent will appear here.';

  // Splash screen
  @override
  String get splashInitializing => 'Initializing...';

  @override
  String get splashConnecting => 'Connecting to server...';

  @override
  String get splashConnected => 'Connected!';

  @override
  String get splashManualConnect => 'Manual connection required';

  @override
  String get splashInitFailed => 'Initialization failed';

  @override
  String get splashRetrying => 'Retrying...';

  @override
  String get splashTitle => 'Agent Assistant Client';

  @override
  String get splashRetryButton => 'Retry';

  // Message bubble
  @override
  String get copyTooltip => 'Copy';

  @override
  String get messageCopied => 'Message copied to clipboard';

  @override
  String get replyCopied => 'Reply copied to clipboard';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusReplied => 'Replied';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusError => 'Error';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get yourReply => 'Your reply';

  @override
  String get otherUser => 'Other user';

  @override
  String replyFrom(String nickname) {
    return 'Reply from $nickname';
  }

  // Nickname settings
  @override
  String get nicknameSettingsTitle => 'Nickname Settings';

  @override
  String get nicknameSettingsSubtitle =>
      'Set the nickname that will be displayed in chat';

  @override
  String get nicknameLabel => 'Nickname';

  @override
  String get nicknameHint => 'Please enter your nickname';

  @override
  String get nicknameRegenerate => 'Regenerate';

  @override
  String get nicknameClear => 'Clear';

  @override
  String get nicknameSaving => 'Saving...';

  @override
  String get nicknameSave => 'Save';

  @override
  String get nicknameTipsTitle => 'Tips:';

  @override
  String get nicknameTipsBody =>
      '• Nickname length must be between 2 and 20 characters\n'
      '• Your nickname will be shown in your replies\n'
      '• Other users can see your nickname';

  @override
  String nicknameLoadFailed(String error) {
    return 'Failed to load nickname: $error';
  }

  @override
  String nicknameSaveFailed(String error) {
    return 'Failed to save nickname: $error';
  }

  @override
  String get nicknameEmptyError => 'Nickname cannot be empty';

  @override
  String get nicknameTooShortError => 'Nickname must be at least 2 characters';

  @override
  String get nicknameTooLongError => 'Nickname cannot exceed 20 characters';

  @override
  String get nicknameSaved => 'Nickname has been saved and synced to server';

  // Server management
  @override
  String get servers => 'Servers';

  @override
  String get addServer => 'Add Server';

  @override
  String get editServer => 'Edit Server';

  @override
  String get serverAlias => 'Alias (optional)';

  @override
  String get webSocketUrl => 'WebSocket URL';

  @override
  String get enabled => 'Enabled';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get noServersConfigured =>
      'No servers configured. Add a server to connect.';

  @override
  String get noEnabledServers =>
      'No servers enabled. Please enable at least one server.';

  @override
  String get deleteServerConfirmTitle => 'Delete Server';

  @override
  String deleteServerConfirmMessage(String serverName) {
    return 'Are you sure you want to delete server "$serverName"?';
  }
}
