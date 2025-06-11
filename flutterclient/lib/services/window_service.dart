import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:window_manager/window_manager.dart';

/// Service for managing desktop window operations
class WindowService {
  static final WindowService _instance = WindowService._internal();
  factory WindowService() => _instance;
  WindowService._internal();

  final Logger _logger = Logger();
  bool _isInitialized = false;

  // Configuration for Linux X11 behavior
  Duration _linuxAlwaysOnTopDuration = const Duration(seconds: 5);
  bool _useAggressiveLinuxMode = true;

  /// Initialize the window service for desktop platforms
  Future<void> initialize() async {
    if (!_isDesktop()) {
      _logger.d('Window service not needed on non-desktop platform');
      return;
    }

    if (_isInitialized) {
      _logger.d('Window service already initialized');
      return;
    }

    try {
      // Ensure window manager is initialized
      await windowManager.ensureInitialized();

      // Set window options
      const windowOptions = WindowOptions(
        size: Size(1200, 800),
        minimumSize: Size(800, 600),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });

      _isInitialized = true;
      _logger.i('Window service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize window service: $e');
    }
  }

  /// Bring the window to front and focus it
  Future<void> bringToFront() async {
    if (!_isDesktop() || !_isInitialized) {
      _logger.d('Cannot bring window to front: not desktop or not initialized');
      return;
    }

    try {
      // Check if window is minimized
      bool isMinimized = await windowManager.isMinimized();
      if (isMinimized) {
        await windowManager.restore();
        _logger.d('Window restored from minimized state');
      }

      // Check if window is visible
      bool isVisible = await windowManager.isVisible();
      if (!isVisible) {
        await windowManager.show();
        _logger.d('Window shown');
      }

      // For Linux X11, use a more aggressive approach
      if (Platform.isLinux) {
        await _bringToFrontLinux();
      } else {
        // Standard approach for other platforms
        await windowManager.show();
        await windowManager.focus();
        await windowManager.setAlwaysOnTop(true);

        // Remove always on top after a short delay to avoid being annoying
        // Future.delayed(const Duration(milliseconds: 500), () async {
        //   try {
        //     await windowManager.setAlwaysOnTop(false);
        //   } catch (e) {
        //     _logger.w('Failed to remove always on top: $e');
        //   }
        // });
      }

      _logger.i('Window brought to front successfully');
    } catch (e) {
      _logger.e('Failed to bring window to front: $e');
    }
  }

  /// Linux-specific method to bring window to front
  Future<void> _bringToFrontLinux() async {
    try {
      // Multiple attempts to ensure window comes to front on Linux X11

      // Step 1: Set always on top
      await windowManager.setAlwaysOnTop(true);
      await Future.delayed(const Duration(milliseconds: 100));

      // Step 2: Focus the window
      await windowManager.focus();
      await Future.delayed(const Duration(milliseconds: 100));

      // Step 3: Show and focus again
      await windowManager.show();
      await windowManager.focus();
      await Future.delayed(const Duration(milliseconds: 100));

      // Step 4: Keep always on top for longer on Linux
      // Future.delayed(const Duration(seconds: 2), () async {
      //   try {
      //     await windowManager.setAlwaysOnTop(false);
      //     _logger.d('Removed always on top after 2 seconds on Linux');
      //   } catch (e) {
      //     _logger.w('Failed to remove always on top on Linux: $e');
      //   }
      // });

      _logger.d('Applied Linux-specific window bring to front');
    } catch (e) {
      _logger.e('Failed to bring window to front on Linux: $e');
    }
  }

  /// Bring window to front and keep it there (more aggressive for Linux)
  Future<void> bringToFrontAndStay() async {
    if (!_isDesktop() || !_isInitialized) {
      _logger.d('Cannot bring window to front: not desktop or not initialized');
      return;
    }

    try {
      if (Platform.isLinux && _useAggressiveLinuxMode) {
        // More aggressive approach for Linux X11
        await _forceToFrontLinux();
      } else {
        // Use standard method for other platforms
        await bringToFront();
      }
    } catch (e) {
      _logger.e('Failed to bring window to front and stay: $e');
    }
  }

  /// Force window to front on Linux and keep it there
  Future<void> _forceToFrontLinux() async {
    try {
      _logger.i('Forcing window to front on Linux X11');

      // Restore if minimized
      if (await windowManager.isMinimized()) {
        await windowManager.restore();
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // Show if not visible
      if (!await windowManager.isVisible()) {
        await windowManager.show();
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // Set always on top first
      await windowManager.setAlwaysOnTop(true);
      await Future.delayed(const Duration(milliseconds: 200));

      // Focus multiple times to ensure it works
      for (int i = 0; i < 3; i++) {
        await windowManager.focus();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Keep always on top for configured duration to ensure user sees it
      Future.delayed(_linuxAlwaysOnTopDuration, () async {
        try {
          await windowManager.setAlwaysOnTop(false);
          _logger.d(
              'Removed always on top after ${_linuxAlwaysOnTopDuration.inSeconds} seconds on Linux');
        } catch (e) {
          _logger.w('Failed to remove always on top on Linux: $e');
        }
      });

      _logger.i('Successfully forced window to front on Linux');
    } catch (e) {
      _logger.e('Failed to force window to front on Linux: $e');
    }
  }

  /// Flash the window in taskbar to get user attention
  Future<void> flashWindow() async {
    if (!_isDesktop() || !_isInitialized) {
      _logger.d('Cannot flash window: not desktop or not initialized');
      return;
    }

    try {
      // On Windows, we can use the flash functionality
      if (Platform.isWindows) {
        // Flash the taskbar icon
        await windowManager.focus();
        _logger.d('Window flashed on Windows');
      } else {
        // On other platforms, just bring to front
        await bringToFront();
      }
    } catch (e) {
      _logger.e('Failed to flash window: $e');
    }
  }

  /// Check if the window is currently focused
  Future<bool> isFocused() async {
    if (!_isDesktop() || !_isInitialized) {
      return false;
    }

    try {
      return await windowManager.isFocused();
    } catch (e) {
      _logger.e('Failed to check if window is focused: $e');
      return false;
    }
  }

  /// Check if the window is currently visible
  Future<bool> isVisible() async {
    if (!_isDesktop() || !_isInitialized) {
      return false;
    }

    try {
      return await windowManager.isVisible();
    } catch (e) {
      _logger.e('Failed to check if window is visible: $e');
      return false;
    }
  }

  /// Check if running on desktop platform
  bool _isDesktop() {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  /// Configure Linux X11 behavior
  void configureLinuxBehavior({
    Duration? alwaysOnTopDuration,
    bool? useAggressiveMode,
  }) {
    if (alwaysOnTopDuration != null) {
      _linuxAlwaysOnTopDuration = alwaysOnTopDuration;
    }
    if (useAggressiveMode != null) {
      _useAggressiveLinuxMode = useAggressiveMode;
    }
    _logger.i(
        'Linux behavior configured: aggressive=$_useAggressiveLinuxMode, duration=${_linuxAlwaysOnTopDuration.inSeconds}s');
  }

  /// Get platform-specific window behavior
  bool get isDesktop => _isDesktop();
  bool get isInitialized => _isInitialized;
}
