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

  // Login screen
  String get loginSubtitle;
  String loginFailed(String error);
  String get loginTokenLabel;
  String get loginTokenHint;
  String get loginAdvancedSettings;
  String get loginServerLabel;
  String get loginRememberSettingsTitle;
  String get loginRememberSettingsSubtitle;
  String get loginButton;
  String get loginHelp;
  String get errorTokenRequired;
  String get errorTokenInvalid;
  String get errorServerRequired;
  String get errorServerProtocol;

  // Chat screen
  String get chatConnecting;
  String get chatConnectionLost;
  String get chatUnableConnect;
  String get chatReconnect;
  String get chatEmptyTitle;
  String get chatEmptySubtitle;

  // Splash screen
  String get splashInitializing;
  String get splashConnecting;
  String get splashConnected;
  String get splashManualConnect;
  String get splashInitFailed;
  String get splashRetrying;
  String get splashTitle;
  String get splashRetryButton;

  // Message bubble
  String get copyTooltip;
  String get messageCopied;
  String get replyCopied;
  String get statusPending;
  String get statusReplied;
  String get statusConfirmed;
  String get statusError;
  String get statusExpired;
  String get statusCancelled;
  String get yourReply;
  String get otherUser;
  String replyFrom(String nickname);

  // Nickname settings
  String get nicknameSettingsTitle;
  String get nicknameSettingsSubtitle;
  String get nicknameLabel;
  String get nicknameHint;
  String get nicknameRegenerate;
  String get nicknameClear;
  String get nicknameSaving;
  String get nicknameSave;
  String get nicknameTipsTitle;
  String get nicknameTipsBody;
  String nicknameLoadFailed(String error);
  String nicknameSaveFailed(String error);
  String get nicknameEmptyError;
  String get nicknameTooShortError;
  String get nicknameTooLongError;
  String get nicknameSaved;

  // Server management
  String get servers;
  String get addServer;
  String get editServer;
  String get serverAlias;
  String get webSocketUrl;
  String get enabled;
  String get save;
  String get edit;
  String get delete;
  String get noServersConfigured;
  String get noEnabledServers;
  String get deleteServerConfirmTitle;
  String deleteServerConfirmMessage(String serverName);
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
