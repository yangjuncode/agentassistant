import 'dart:async';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

/// Manages system tray icon, tooltip, context menu and blinking state
class TrayService with TrayListener {
  static final TrayService _instance = TrayService._internal();
  factory TrayService() => _instance;
  TrayService._internal();

  final Logger _logger = Logger();

  bool _initialized = false;
  bool _notifierReady = false;
  bool _connected = false;
  int _pendingCount = 0;

  Timer? _blinkTimer;
  bool _blinkOn = false;

  // Icon asset paths
  static const String _iconGreenPng = 'assets/tray/green.png';
  static const String _iconRedPng = 'assets/tray/red.png';
  static const String _iconGreenBlinkPng = 'assets/tray/green_blink.png';
  static const String _iconRedBlinkPng = 'assets/tray/red_blink.png';

  static const String _iconGreenIco = 'assets/tray/green.ico';
  static const String _iconRedIco = 'assets/tray/red.ico';
  static const String _iconGreenBlinkIco = 'assets/tray/green_blink.ico';
  static const String _iconRedBlinkIco = 'assets/tray/red_blink.ico';

  bool get isDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  Future<void> initialize() async {
    if (!isDesktop) {
      _logger.d('Tray not initialized: non-desktop platform');
      return;
    }
    if (_initialized) return;

    try {
      try {
        await localNotifier.setup(appName: 'AgentAssistant-flutter');
        _notifierReady = true;
      } catch (e) {
        _notifierReady = false;
        _logger.w('Failed to setup local_notifier: $e');
      }

      trayManager.addListener(this);
      await _applyIcon();
      await _setToolTip('AgentAssistant-flutter');
      await _setupContextMenu();
      _initialized = true;
      _logger.i('TrayService initialized');
    } catch (e) {
      _logger.w('Failed to initialize tray: $e');
    }
  }

  Future<void> showInfoNotification({
    required String title,
    required String body,
  }) async {
    if (!isDesktop) return;
    if (!_notifierReady) {
      _logger.d('local_notifier not ready; skip info notification');
      return;
    }

    try {
      final notification = LocalNotification(
        title: title,
        body: body,
      );
      notification.show();
    } catch (e) {
      _logger.w('Failed to show info notification: $e');
    }
  }

  Future<void> dispose() async {
    if (!_initialized) return;
    try {
      _cancelBlink();
      trayManager.removeListener(this);
      await trayManager.destroy();
      _initialized = false;
    } catch (e) {
      _logger.w('Error disposing tray: $e');
    }
  }

  Future<void> setConnected(bool connected) async {
    _connected = connected;
    await _applyIcon();
    await _setToolTip(_tooltipText());
  }

  Future<void> setPendingCount(int count) async {
    _pendingCount = count;
    if (_pendingCount > 0) {
      _startBlink();
    } else {
      _cancelBlink();
      await _applyIcon();
    }
    await _setToolTip(_tooltipText());
  }

  // Convenience hooks
  Future<void> onNewMcpMessage() async {
    await setPendingCount(_pendingCount + 1);
  }

  Future<void> onAllMessagesHandled() async {
    await setPendingCount(0);
  }

  // TrayListener events
  @override
  void onTrayIconMouseDown() {
    // Show window on left-click
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'show_window') {
      _showMainWindow();
    } else if (menuItem.key == 'exit_app') {
      _exitApp();
    }
  }

  // Internal helpers
  String _tooltipText() {
    final status = _connected ? 'Connected' : 'Disconnected';
    final pending = _pendingCount > 0 ? ' | Pending: $_pendingCount' : '';
    return 'AgentAssistant-flutter ($status)$pending';
  }

  Future<void> _applyIcon() async {
    if (!isDesktop) return;
    final bool blinking = _pendingCount > 0;
    final bool isWin = Platform.isWindows;

    String iconPath;
    if (_connected) {
      iconPath = blinking
          ? (isWin ? _iconGreenBlinkIco : _iconGreenBlinkPng)
          : (isWin ? _iconGreenIco : _iconGreenPng);
    } else {
      iconPath = blinking
          ? (isWin ? _iconRedBlinkIco : _iconRedBlinkPng)
          : (isWin ? _iconRedIco : _iconRedPng);
    }

    try {
      await trayManager.setIcon(iconPath);
    } catch (e) {
      _logger.w('setIcon failed for $iconPath: $e');
    }
  }

  void _startBlink() {
    if (_blinkTimer != null) return;
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 700), (_) async {
      _blinkOn = !_blinkOn;
      // Toggle between normal and blink variant
      try {
        if (_blinkOn) {
          await _applyIcon();
        } else {
          // alternate to base color without blink
          final isWin = Platform.isWindows;
          final iconPath = _connected
              ? (isWin ? _iconGreenIco : _iconGreenPng)
              : (isWin ? _iconRedIco : _iconRedPng);
          await trayManager.setIcon(iconPath);
        }
      } catch (e) {
        _logger.w('Blink toggle failed: $e');
      }
    });
  }

  void _cancelBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = null;
    _blinkOn = false;
  }

  Future<void> _setToolTip(String text) async {
    try {
      // setToolTip is not supported on Linux by tray_manager (no-op)
      await trayManager.setToolTip(text);
    } catch (_) {}
  }

  Future<void> _setupContextMenu() async {
    try {
      final menu = Menu(items: [
        MenuItem(key: 'show_window', label: 'Show Window'),
        MenuItem.separator(),
        MenuItem(key: 'exit_app', label: 'Exit App'),
      ]);
      await trayManager.setContextMenu(menu);
    } catch (e) {
      _logger.w('Failed to set context menu: $e');
    }
  }

  Future<void> _showMainWindow() async {
    try {
      // Bring window to front
      if (await windowManager.isMinimized()) {
        await windowManager.restore();
      }
      if (!await windowManager.isVisible()) {
        await windowManager.show();
      }
      await windowManager.focus();
    } catch (e) {
      _logger.w('Failed to show main window: $e');
    }
  }

  void _exitApp() {
    _cancelBlink();
    // Use windowManager.close() to trigger the native window-close sequence,
    // which we've hooked in C++ to exit cleanly without core dump.
    if (isDesktop) {
      windowManager.close();
    }
  }
}
