import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Agent Assistant'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @connection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get connection;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @connectedToServer.
  ///
  /// In en, this message translates to:
  /// **'Connected to server'**
  String get connectedToServer;

  /// No description provided for @connectionClosed.
  ///
  /// In en, this message translates to:
  /// **'Connection closed'**
  String get connectionClosed;

  /// No description provided for @serverAddress.
  ///
  /// In en, this message translates to:
  /// **'Server Address'**
  String get serverAddress;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @clientId.
  ///
  /// In en, this message translates to:
  /// **'Client ID'**
  String get clientId;

  /// No description provided for @accessToken.
  ///
  /// In en, this message translates to:
  /// **'Access Token'**
  String get accessToken;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @disconnectFromServer.
  ///
  /// In en, this message translates to:
  /// **'Disconnect from server'**
  String get disconnectFromServer;

  /// No description provided for @disconnectConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnectConfirmTitle;

  /// No description provided for @disconnectConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to disconnect from the server?'**
  String get disconnectConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @userSettings.
  ///
  /// In en, this message translates to:
  /// **'User Settings'**
  String get userSettings;

  /// No description provided for @systemInput.
  ///
  /// In en, this message translates to:
  /// **'System Input'**
  String get systemInput;

  /// No description provided for @autoForwardMessages.
  ///
  /// In en, this message translates to:
  /// **'Auto Forward Chat Messages'**
  String get autoForwardMessages;

  /// No description provided for @autoForwardMessagesDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically send received chat messages to system input'**
  String get autoForwardMessagesDesc;

  /// No description provided for @autoForwardEnabled.
  ///
  /// In en, this message translates to:
  /// **'Auto forward enabled'**
  String get autoForwardEnabled;

  /// No description provided for @autoForwardDisabled.
  ///
  /// In en, this message translates to:
  /// **'Auto forward disabled'**
  String get autoForwardDisabled;

  /// No description provided for @useInteractiveMode.
  ///
  /// In en, this message translates to:
  /// **'Interactive Question Mode'**
  String get useInteractiveMode;

  /// No description provided for @useInteractiveModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Render questions as interactive forms'**
  String get useInteractiveModeDesc;

  /// No description provided for @autoReplyAskQuestion.
  ///
  /// In en, this message translates to:
  /// **'Auto-reply for single-choice'**
  String get autoReplyAskQuestion;

  /// No description provided for @autoReplyAskQuestionDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically submit reply when all single-choice questions are answered'**
  String get autoReplyAskQuestionDesc;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @messageStats.
  ///
  /// In en, this message translates to:
  /// **'Message Statistics'**
  String get messageStats;

  /// No description provided for @totalMessages.
  ///
  /// In en, this message translates to:
  /// **'Total {count} messages'**
  String totalMessages(int count);

  /// No description provided for @pendingQuestions.
  ///
  /// In en, this message translates to:
  /// **'Pending questions: {count}'**
  String pendingQuestions(int count);

  /// No description provided for @pendingTasks.
  ///
  /// In en, this message translates to:
  /// **'Pending tasks: {count}'**
  String pendingTasks(int count);

  /// No description provided for @clearMessages.
  ///
  /// In en, this message translates to:
  /// **'Clear Messages'**
  String get clearMessages;

  /// No description provided for @clearMessagesDesc.
  ///
  /// In en, this message translates to:
  /// **'Delete all chat history'**
  String get clearMessagesDesc;

  /// No description provided for @clearMessagesConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Messages'**
  String get clearMessagesConfirmTitle;

  /// No description provided for @clearMessagesConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all chat history? This action cannot be undone.'**
  String get clearMessagesConfirmMessage;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @messagesCleared.
  ///
  /// In en, this message translates to:
  /// **'Chat history cleared'**
  String get messagesCleared;

  /// No description provided for @app.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get app;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @buildTime.
  ///
  /// In en, this message translates to:
  /// **'Build Time {time}'**
  String buildTime(String time);

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @feedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Report bugs or suggest features'**
  String get feedbackDesc;

  /// No description provided for @feedbackMessage.
  ///
  /// In en, this message translates to:
  /// **'Please contact your system administrator to report issues'**
  String get feedbackMessage;

  /// No description provided for @aboutAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Agent Assistant is a mobile client application for real-time communication with AI Agents.'**
  String get aboutAppDescription;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features:'**
  String get features;

  /// No description provided for @featureWebSocket.
  ///
  /// In en, this message translates to:
  /// **'Real-time WebSocket communication'**
  String get featureWebSocket;

  /// No description provided for @featureMultiContent.
  ///
  /// In en, this message translates to:
  /// **'Support for multiple content types'**
  String get featureMultiContent;

  /// No description provided for @featureAutoReconnect.
  ///
  /// In en, this message translates to:
  /// **'Auto reconnection mechanism'**
  String get featureAutoReconnect;

  /// No description provided for @featureLocalStorage.
  ///
  /// In en, this message translates to:
  /// **'Local message storage'**
  String get featureLocalStorage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageAuto.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get languageAuto;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageChinese;

  /// No description provided for @nicknameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Nickname updated to: {nickname}'**
  String nicknameUpdated(String nickname);

  /// No description provided for @pathAutocomplete.
  ///
  /// In en, this message translates to:
  /// **'Path Autocomplete'**
  String get pathAutocomplete;

  /// No description provided for @useGitIgnore.
  ///
  /// In en, this message translates to:
  /// **'Use .gitignore rules'**
  String get useGitIgnore;

  /// No description provided for @useGitIgnoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically apply project\'s .gitignore patterns'**
  String get useGitIgnoreDesc;

  /// No description provided for @customIgnorePatterns.
  ///
  /// In en, this message translates to:
  /// **'Custom ignore patterns'**
  String get customIgnorePatterns;

  /// No description provided for @customIgnorePatternsDesc.
  ///
  /// In en, this message translates to:
  /// **'Add custom patterns in gitignore format'**
  String get customIgnorePatternsDesc;

  /// No description provided for @customIgnorePatternsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Custom Ignore Patterns'**
  String get customIgnorePatternsDialogTitle;

  /// No description provided for @customIgnorePatternsHint.
  ///
  /// In en, this message translates to:
  /// **'# Each line is a pattern\n*.log\nbuild/\nnode_modules/'**
  String get customIgnorePatternsHint;

  /// No description provided for @slashCommands.
  ///
  /// In en, this message translates to:
  /// **'Slash Commands'**
  String get slashCommands;

  /// No description provided for @slashCommandsShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get slashCommandsShow;

  /// No description provided for @slashCommandsOptionCommands.
  ///
  /// In en, this message translates to:
  /// **'Commands'**
  String get slashCommandsOptionCommands;

  /// No description provided for @slashCommandsOptionSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get slashCommandsOptionSkills;

  /// No description provided for @slashCommandsOptionCommandsAndSkills.
  ///
  /// In en, this message translates to:
  /// **'Commands & Skills'**
  String get slashCommandsOptionCommandsAndSkills;

  /// No description provided for @slashCommandCompletionText.
  ///
  /// In en, this message translates to:
  /// **'/ Command Completion Text'**
  String get slashCommandCompletionText;

  /// No description provided for @slashSkillCompletionText.
  ///
  /// In en, this message translates to:
  /// **'/ Skill Completion Text'**
  String get slashSkillCompletionText;

  /// No description provided for @slashCompletionTextDesc.
  ///
  /// In en, this message translates to:
  /// **'Customize the input text when / command autocompletes. Available variables: %name%, %path%, %type%'**
  String get slashCompletionTextDesc;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefault;

  /// No description provided for @desktop.
  ///
  /// In en, this message translates to:
  /// **'Desktop'**
  String get desktop;

  /// No description provided for @mcpMessageAttention.
  ///
  /// In en, this message translates to:
  /// **'MCP message attention'**
  String get mcpMessageAttention;

  /// No description provided for @mcpAskQuestionAttention.
  ///
  /// In en, this message translates to:
  /// **'Ask Question attention'**
  String get mcpAskQuestionAttention;

  /// No description provided for @mcpWorkReportAttention.
  ///
  /// In en, this message translates to:
  /// **'Work Report attention'**
  String get mcpWorkReportAttention;

  /// No description provided for @mcpAttentionModeNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get mcpAttentionModeNone;

  /// No description provided for @mcpAttentionModeTray.
  ///
  /// In en, this message translates to:
  /// **'Systray info only'**
  String get mcpAttentionModeTray;

  /// No description provided for @mcpAttentionModePopup.
  ///
  /// In en, this message translates to:
  /// **'Popup only'**
  String get mcpAttentionModePopup;

  /// No description provided for @mcpAttentionModePopupOnTop.
  ///
  /// In en, this message translates to:
  /// **'Popup + Always on top'**
  String get mcpAttentionModePopupOnTop;

  /// No description provided for @mcpAttentionModeTrayPopupOnTop.
  ///
  /// In en, this message translates to:
  /// **'Systray info + Popup + Always on top'**
  String get mcpAttentionModeTrayPopupOnTop;

  /// No description provided for @webSocketUrlHint.
  ///
  /// In en, this message translates to:
  /// **'ws://host:port/ws'**
  String get webSocketUrlHint;

  /// No description provided for @chatAutoSendInterval.
  ///
  /// In en, this message translates to:
  /// **'Chat Auto Send Interval'**
  String get chatAutoSendInterval;

  /// No description provided for @chatAutoSendIntervalSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds'**
  String chatAutoSendIntervalSeconds(int seconds);

  /// No description provided for @profileClientIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Client ID: {clientId}'**
  String profileClientIdLabel(String clientId);

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to your AI Agent assistant'**
  String get loginSubtitle;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailed(String error);

  /// No description provided for @loginTokenLabel.
  ///
  /// In en, this message translates to:
  /// **'Access token'**
  String get loginTokenLabel;

  /// No description provided for @loginTokenHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter your access token'**
  String get loginTokenHint;

  /// No description provided for @loginAdvancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced settings'**
  String get loginAdvancedSettings;

  /// No description provided for @loginServerLabel.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get loginServerLabel;

  /// No description provided for @loginRememberSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Remember settings'**
  String get loginRememberSettingsTitle;

  /// No description provided for @loginRememberSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto fill on next launch'**
  String get loginRememberSettingsSubtitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get loginButton;

  /// No description provided for @loginHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help? Please contact your system administrator to get an access token.'**
  String get loginHelp;

  /// No description provided for @errorTokenRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter access token'**
  String get errorTokenRequired;

  /// No description provided for @errorTokenInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid token format (at least 1 character)'**
  String get errorTokenInvalid;

  /// No description provided for @errorServerRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter server address'**
  String get errorServerRequired;

  /// No description provided for @errorServerProtocol.
  ///
  /// In en, this message translates to:
  /// **'Server address must start with ws:// or wss://'**
  String get errorServerProtocol;

  /// No description provided for @chatConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to Agent Assistant server...'**
  String get chatConnecting;

  /// No description provided for @chatConnectionLost.
  ///
  /// In en, this message translates to:
  /// **'Connection lost'**
  String get chatConnectionLost;

  /// No description provided for @chatUnableConnect.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to server'**
  String get chatUnableConnect;

  /// No description provided for @chatReconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get chatReconnect;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for messages from AI Agent...'**
  String get chatEmptyTitle;

  /// No description provided for @chatEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Once connected, questions and tasks from the AI Agent will appear here.'**
  String get chatEmptySubtitle;

  /// No description provided for @splashInitializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get splashInitializing;

  /// No description provided for @splashConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to server...'**
  String get splashConnecting;

  /// No description provided for @splashConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected!'**
  String get splashConnected;

  /// No description provided for @splashManualConnect.
  ///
  /// In en, this message translates to:
  /// **'Manual connection required'**
  String get splashManualConnect;

  /// No description provided for @splashInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Initialization failed'**
  String get splashInitFailed;

  /// No description provided for @splashRetrying.
  ///
  /// In en, this message translates to:
  /// **'Retrying...'**
  String get splashRetrying;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'Agent Assistant Client'**
  String get splashTitle;

  /// No description provided for @splashRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get splashRetryButton;

  /// No description provided for @copyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyTooltip;

  /// No description provided for @messageCopied.
  ///
  /// In en, this message translates to:
  /// **'Message copied to clipboard'**
  String get messageCopied;

  /// No description provided for @replyCopied.
  ///
  /// In en, this message translates to:
  /// **'Reply copied to clipboard'**
  String get replyCopied;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusReplied.
  ///
  /// In en, this message translates to:
  /// **'Replied'**
  String get statusReplied;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get statusError;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @yourReply.
  ///
  /// In en, this message translates to:
  /// **'Your reply'**
  String get yourReply;

  /// No description provided for @otherUser.
  ///
  /// In en, this message translates to:
  /// **'Other user'**
  String get otherUser;

  /// No description provided for @replyFrom.
  ///
  /// In en, this message translates to:
  /// **'Reply from {nickname}'**
  String replyFrom(String nickname);

  /// No description provided for @nicknameSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nickname Settings'**
  String get nicknameSettingsTitle;

  /// No description provided for @nicknameSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set the nickname that will be displayed in chat'**
  String get nicknameSettingsSubtitle;

  /// No description provided for @nicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nicknameLabel;

  /// No description provided for @nicknameHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter your nickname'**
  String get nicknameHint;

  /// No description provided for @nicknameRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get nicknameRegenerate;

  /// No description provided for @nicknameClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get nicknameClear;

  /// No description provided for @nicknameSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get nicknameSaving;

  /// No description provided for @nicknameSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get nicknameSave;

  /// No description provided for @nicknameTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips:'**
  String get nicknameTipsTitle;

  /// No description provided for @nicknameTipsBody.
  ///
  /// In en, this message translates to:
  /// **'• Nickname length must be between 2 and 20 characters\n• Your nickname will be shown in your replies\n• Other users can see your nickname'**
  String get nicknameTipsBody;

  /// No description provided for @nicknameLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load nickname: {error}'**
  String nicknameLoadFailed(String error);

  /// No description provided for @nicknameSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save nickname: {error}'**
  String nicknameSaveFailed(String error);

  /// No description provided for @nicknameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Nickname cannot be empty'**
  String get nicknameEmptyError;

  /// No description provided for @nicknameTooShortError.
  ///
  /// In en, this message translates to:
  /// **'Nickname must be at least 2 characters'**
  String get nicknameTooShortError;

  /// No description provided for @nicknameTooLongError.
  ///
  /// In en, this message translates to:
  /// **'Nickname cannot exceed 20 characters'**
  String get nicknameTooLongError;

  /// No description provided for @nicknameSaved.
  ///
  /// In en, this message translates to:
  /// **'Nickname has been saved and synced to server'**
  String get nicknameSaved;

  /// No description provided for @servers.
  ///
  /// In en, this message translates to:
  /// **'Servers'**
  String get servers;

  /// No description provided for @addServer.
  ///
  /// In en, this message translates to:
  /// **'Add Server'**
  String get addServer;

  /// No description provided for @editServer.
  ///
  /// In en, this message translates to:
  /// **'Edit Server'**
  String get editServer;

  /// No description provided for @serverAlias.
  ///
  /// In en, this message translates to:
  /// **'Alias (optional)'**
  String get serverAlias;

  /// No description provided for @webSocketUrl.
  ///
  /// In en, this message translates to:
  /// **'WebSocket URL'**
  String get webSocketUrl;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @noServersConfigured.
  ///
  /// In en, this message translates to:
  /// **'No servers configured. Add a server to connect.'**
  String get noServersConfigured;

  /// No description provided for @noEnabledServers.
  ///
  /// In en, this message translates to:
  /// **'No servers enabled. Please enable at least one server.'**
  String get noEnabledServers;

  /// No description provided for @deleteServerConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Server'**
  String get deleteServerConfirmTitle;

  /// No description provided for @deleteServerConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete server \"{serverName}\"?'**
  String deleteServerConfirmMessage(String serverName);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @serverConnectionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Server connections'**
  String get serverConnectionsTooltip;

  /// No description provided for @serverConnectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Server Connections'**
  String get serverConnectionsTitle;

  /// No description provided for @serverStatusLine.
  ///
  /// In en, this message translates to:
  /// **'status: {status}'**
  String serverStatusLine(String status);

  /// No description provided for @serverErrorLine.
  ///
  /// In en, this message translates to:
  /// **'error: {error}'**
  String serverErrorLine(String error);

  /// No description provided for @serverStatusConnected.
  ///
  /// In en, this message translates to:
  /// **'connected'**
  String get serverStatusConnected;

  /// No description provided for @serverStatusConnecting.
  ///
  /// In en, this message translates to:
  /// **'connecting'**
  String get serverStatusConnecting;

  /// No description provided for @serverStatusReconnecting.
  ///
  /// In en, this message translates to:
  /// **'reconnecting'**
  String get serverStatusReconnecting;

  /// No description provided for @serverStatusError.
  ///
  /// In en, this message translates to:
  /// **'error'**
  String get serverStatusError;

  /// No description provided for @serverStatusDisconnected.
  ///
  /// In en, this message translates to:
  /// **'disconnected'**
  String get serverStatusDisconnected;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
