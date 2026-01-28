import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';

import 'providers/chat_provider.dart';
import 'providers/project_directory_index_provider.dart';
import 'screens/login_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/splash_screen.dart';
import 'config/app_config.dart';
import 'services/window_service.dart';
import 'services/tray_service.dart';

// Global logger instance
final Logger logger = Logger();

// Error reporting function
void reportError(FlutterErrorDetails details) {
  logger.e('Flutter error caught: ${details.exception}',
      error: details.exception, stackTrace: details.stack);
}

// Frame timing monitor
class FrameTimingMonitor {
  static const int _warningThresholdMs = 100; // Frame time warning threshold
  static int _consecutiveSlowFrames = 0;
  static const int _maxConsecutiveSlowFrames = 5;
  static Timer? _recoveryTimer;
  static bool _isMonitoring = false;

  // Start monitoring frame timings
  static void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;

    WidgetsBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
      for (final timing in timings) {
        final buildTime = timing.buildDuration.inMilliseconds;
        final rasterTime = timing.rasterDuration.inMilliseconds;
        final totalTime = buildTime + rasterTime;

        if (totalTime > _warningThresholdMs) {
          _consecutiveSlowFrames++;
          logger.w(
              'Slow frame detected: build=${buildTime}ms, raster=${rasterTime}ms, total=${totalTime}ms');

          if (_consecutiveSlowFrames >= _maxConsecutiveSlowFrames) {
            logger.e(
                'Multiple consecutive slow frames detected, may cause black screen');
            _scheduleRecovery();
          }
        } else {
          _consecutiveSlowFrames = 0;
          if (_recoveryTimer != null) {
            _recoveryTimer!.cancel();
            _recoveryTimer = null;
          }
        }
      }
    });

    logger.i('Frame timing monitor started');
  }

  // Schedule recovery action for potential black screen
  static void _scheduleRecovery() {
    if (_recoveryTimer != null) return;

    _recoveryTimer = Timer(const Duration(seconds: 2), () {
      logger.i('Triggering UI refresh to recover from potential black screen');
      _consecutiveSlowFrames = 0;
      _recoveryTimer = null;

      // Force a rebuild of the widget tree
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.reassembleApplication();
      });
    });
  }
}

void main() {
  runZonedGuarded(
    () async {
      try {
        // Initialize Flutter binding
        WidgetsFlutterBinding.ensureInitialized();

        // Set up error handling
        FlutterError.onError = (FlutterErrorDetails details) {
          FlutterError.presentError(details);
          reportError(details);
        };

        // Initialize window service for desktop platforms
        await WindowService().initialize();
        // Initialize tray service for desktop platforms
        await TrayService().initialize();

        // Start frame timing monitor
        FrameTimingMonitor.startMonitoring();

        // Disable verbose debug output to reduce console noise
        // Only enable these when debugging layout issues
        debugPrintMarkNeedsLayoutStacks = false;
        debugPrintLayouts = false;

        runApp(const AgentAssistantApp());
      } catch (e, stack) {
        logger.e('Error during app initialization',
            error: e, stackTrace: stack);
        // Still try to run the app even if initialization failed
        runApp(const AgentAssistantApp());
      }
    },
    (error, stackTrace) {
      logger.e('Uncaught error in zone', error: error, stackTrace: stackTrace);
    },
  );
}

class AgentAssistantApp extends StatelessWidget {
  const AgentAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(
            create: (context) => ProjectDirectoryIndexProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: AppConfig.appName,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('zh', 'CN'),
            ],
            home: const SplashScreen(),
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/chat': (context) => const ChatScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
