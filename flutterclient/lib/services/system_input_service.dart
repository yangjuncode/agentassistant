import 'dart:io';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

class ForwardableWindow {
  final String windowId;
  final String title;

  const ForwardableWindow({required this.windowId, required this.title});

  factory ForwardableWindow.fromJson(Map<String, dynamic> json) {
    return ForwardableWindow(
      windowId: (json['window_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
    );
  }
}

class SystemInputResult {
  final bool success;
  final bool windowNotFound;
  final String? error;

  const SystemInputResult({
    required this.success,
    this.windowNotFound = false,
    this.error,
  });
}

class SystemInputAvailability {
  final bool supportedPlatform;
  final bool inputToolFound;
  final bool requiresXdotool;
  final bool xdotoolInstalled;

  const SystemInputAvailability({
    required this.supportedPlatform,
    required this.inputToolFound,
    required this.requiresXdotool,
    required this.xdotoolInstalled,
  });

  bool get isAvailable =>
      supportedPlatform &&
      inputToolFound &&
      (!requiresXdotool || xdotoolInstalled);

  bool get isMissingXdotool => requiresXdotool && !xdotoolInstalled;
}

/// Service for handling system input functionality on Flutter PC
/// This service allows sending text to the system's active input field
class SystemInputService {
  static final Logger _logger = Logger();

  /// Get the path to agentassistant-input tool
  /// Search order:
  /// 1. PATH environment variable (like `which` command)
  /// 2. ~/bin/ directory
  /// 3. Same directory as the Flutter executable
  /// 4. Various relative paths from executable
  static String _getInputToolPath() {
    const toolName = 'agentassistant-input';

    // print('[SystemInput] Searching for tool: $toolName');

    // 1. Search in PATH environment variable (like `which` command)
    final pathEnv = Platform.environment['PATH'] ?? '';
    final pathSeparator = Platform.isWindows ? ';' : ':';
    final pathDirs = pathEnv.split(pathSeparator);

    // print('[SystemInput] Searching in PATH (${pathDirs.length} directories)...');
    for (final dir in pathDirs) {
      if (dir.isEmpty) continue;
      final toolPath = path.join(dir, toolName);
      if (File(toolPath).existsSync()) {
        // print('[SystemInput] ✅ Found tool in PATH: $toolPath');
        return toolPath;
      }
    }
    // print('[SystemInput] Not found in PATH');

    // 2. Search in ~/bin/ directory
    final homeDir = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '';
    if (homeDir.isNotEmpty) {
      final homeBinPath = path.join(homeDir, 'bin', toolName);
      // print('[SystemInput] Checking ~/bin/: $homeBinPath');
      if (File(homeBinPath).existsSync()) {
        // print('[SystemInput] ✅ Found tool in ~/bin/: $homeBinPath');
        return homeBinPath;
      }
    }

    // 3. Get the directory where the Flutter executable is located
    final executablePath = Platform.resolvedExecutable;
    final executableDir = path.dirname(executablePath);
    // print('[SystemInput] Executable path: $executablePath');
    // print('[SystemInput] Executable directory: $executableDir');

    // Try multiple possible locations relative to the executable
    final possiblePaths = [
      // Same directory as executable
      path.join(executableDir, toolName),
      // ../bin relative to executable (for development)
      path.join(executableDir, '..', 'bin', toolName),
      // ../../bin relative to executable (for bundle structure)
      path.join(executableDir, '..', '..', 'bin', toolName),
      // Relative to project root (for flutter run)
      path.join(executableDir, '..', '..', '..', '..', '..', 'bin', toolName),
    ];

    for (final toolPath in possiblePaths) {
      final normalizedPath = path.normalize(toolPath);
      // print('[SystemInput] Checking: $normalizedPath');
      if (File(normalizedPath).existsSync()) {
        // print('[SystemInput] ✅ Found tool at: $normalizedPath');
        return normalizedPath;
      }
    }

    // 4. Search in current working directory and relative paths
    final cwdPaths = [
      path.join(Directory.current.path, toolName),
      path.join(Directory.current.path, 'bin', toolName),
      path.join(Directory.current.path, '..', 'bin', toolName),
    ];

    // print('[SystemInput] Checking paths relative to CWD: ${Directory.current.path}');
    for (final toolPath in cwdPaths) {
      final normalizedPath = path.normalize(toolPath);
      if (File(normalizedPath).existsSync()) {
        // print('[SystemInput] ✅ Found tool at: $normalizedPath');
        return normalizedPath;
      }
    }

    // Fallback: just return the tool name and hope it's in PATH
    // print('[SystemInput] ⚠️ Tool not found in any standard locations');
    // print('[SystemInput] Returning tool name as fallback (will fail if not in PATH)');
    return toolName;
  }

  static bool _isCommandAvailable(String command) {
    final pathEnv = Platform.environment['PATH'] ?? '';
    if (pathEnv.isEmpty) {
      return false;
    }

    final pathSeparator = Platform.isWindows ? ';' : ':';
    final pathDirs = pathEnv.split(pathSeparator);

    for (final dir in pathDirs) {
      if (dir.isEmpty) continue;
      final commandPath = path.join(dir, command);
      if (File(commandPath).existsSync()) {
        return true;
      }
      if (Platform.isWindows) {
        final commandExePath = '$commandPath.exe';
        if (File(commandExePath).existsSync()) {
          return true;
        }
      }
    }
    return false;
  }

  /// Send text to system input using agentassistant-input tool
  ///
  /// [content] - The text content to send to system input
  /// [isBase64Encoded] - Whether the content is already base64 encoded
  /// [windowId] - Optional target window id for directed input
  ///
  /// Returns true if successful, false otherwise
  static Future<bool> sendToSystemInput(String content,
      {bool isBase64Encoded = false, String? windowId}) async {
    final result = await sendToSystemInputWithResult(
      content,
      isBase64Encoded: isBase64Encoded,
      windowId: windowId,
    );
    return result.success;
  }

  /// Send text to system input and return structured result.
  static Future<SystemInputResult> sendToSystemInputWithResult(
    String content, {
    bool isBase64Encoded = false,
    String? windowId,
  }) async {
    // Use print for debug output in all modes (Logger may not show in release)
    // print('[SystemInput] sendToSystemInput called');
    // print('[SystemInput] Content length: ${content.length}');
    // print('[SystemInput] Content preview: ${content.length > 100 ? content.substring(0, 100) + "..." : content}');
    // print('[SystemInput] isBase64Encoded: $isBase64Encoded');

    try {
      if (content.isEmpty) {
        // print('[SystemInput] ⚠️ Cannot send empty content to system input');
        return const SystemInputResult(success: false, error: 'empty_content');
      }

      // Check if we're running on desktop platform
      // print('[SystemInput] Platform check - Windows: ${Platform.isWindows}, Linux: ${Platform.isLinux}, macOS: ${Platform.isMacOS}');
      if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
        // print('[SystemInput] ⚠️ System input is only supported on desktop platforms');
        return const SystemInputResult(
            success: false, error: 'unsupported_platform');
      }

      // Get the tool path using our smart path finder
      final inputToolPath = _getInputToolPath();
      final inputTool = File(inputToolPath);

      final toolExists = await inputTool.exists();
      // print('[SystemInput] Final tool path: $inputToolPath');
      // print('[SystemInput] Tool exists: $toolExists');

      if (!toolExists) {
        // print('[SystemInput] ❌ agentassistant-input tool not found at: $inputToolPath');
        return const SystemInputResult(success: false, error: 'tool_not_found');
      }

      // Always use base64 encoding to prevent issues with special characters
      String encodedContent;
      if (isBase64Encoded) {
        encodedContent = content;
        // print('[SystemInput] Using pre-encoded base64 content');
      } else {
        encodedContent = base64Encode(utf8.encode(content));
        // print('[SystemInput] Encoded content to base64, encoded length: ${encodedContent.length}');
      }

      // Always use -input64 argument for safety
      final args = ['-input64', encodedContent];
      if (windowId != null && windowId.trim().isNotEmpty) {
        args
          ..add('-window-id')
          ..add(windowId.trim());
      }
      // print('[SystemInput] Command: $inputToolPath ${args[0]} <base64_content>');
      // print('[SystemInput] About to execute Process.run...');

      // Execute the command
      final stopwatch = Stopwatch()..start();
      final result = await Process.run(inputToolPath, args);
      stopwatch.stop();

      // print('[SystemInput] Process.run completed in ${stopwatch.elapsedMilliseconds}ms');
      // print('[SystemInput] Exit code: ${result.exitCode}');
      // print('[SystemInput] stdout: ${result.stdout}');
      // print('[SystemInput] stderr: ${result.stderr}');

      if (result.exitCode == 0) {
        // print('[SystemInput] ✅ Successfully sent text to system input: ${content.length} characters');
        return const SystemInputResult(success: true);
      } else {
        // print('[SystemInput] ❌ Failed to send text to system input. Exit code: ${result.exitCode}');
        // print('[SystemInput] Error output: ${result.stderr}');
        final stderrText = (result.stderr ?? '').toString();
        final windowNotFound = stderrText.contains('ERR_WINDOW_NOT_FOUND');
        return SystemInputResult(
          success: false,
          windowNotFound: windowNotFound,
          error: stderrText.isEmpty ? 'command_failed' : stderrText,
        );
      }
    } catch (e) {
      // print('[SystemInput] ❌ Exception while sending text to system input: $e');
      // print('[SystemInput] Stack trace: $stackTrace');
      return SystemInputResult(success: false, error: e.toString());
    }
  }

  /// Send text to specified window id.
  static Future<SystemInputResult> sendToSystemWindow(
    String windowId,
    String content,
  ) async {
    return sendToSystemInputWithResult(content, windowId: windowId);
  }

  /// List forwardable windows from local system.
  static Future<List<ForwardableWindow>> listForwardableWindows() async {
    try {
      if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
        return [];
      }

      final inputToolPath = _getInputToolPath();
      final inputTool = File(inputToolPath);
      if (!await inputTool.exists()) {
        return [];
      }

      final result = await Process.run(inputToolPath, ['-list-windows']);
      if (result.exitCode != 0) {
        _logger.w('listForwardableWindows failed: ${result.stderr}');
        return [];
      }

      final stdoutText = (result.stdout ?? '').toString().trim();
      if (stdoutText.isEmpty) {
        return [];
      }

      final decoded = jsonDecode(stdoutText);
      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map((item) =>
              ForwardableWindow.fromJson(item.cast<String, dynamic>()))
          .where((item) => item.windowId.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Send text to system input with base64 encoding
  /// This method is now equivalent to sendToSystemInput since base64 is always used
  /// Kept for backward compatibility
  static Future<bool> sendToSystemInputBase64(String content) async {
    return await sendToSystemInput(content);
  }

  /// Check if system input functionality is available
  /// Returns true if the platform supports it and the tool is available
  static Future<bool> isAvailable() async {
    final availability = await getAvailability();
    return availability.isAvailable;
  }

  /// Check detailed system input availability, including xdotool on Linux.
  static Future<SystemInputAvailability> getAvailability() async {
    try {
      final supportedPlatform =
          Platform.isWindows || Platform.isLinux || Platform.isMacOS;
      if (!supportedPlatform) {
        return const SystemInputAvailability(
          supportedPlatform: false,
          inputToolFound: false,
          requiresXdotool: false,
          xdotoolInstalled: false,
        );
      }

      final inputToolPath = _getInputToolPath();
      final inputTool = File(inputToolPath);
      final inputToolFound = await inputTool.exists();

      final requiresXdotool = Platform.isLinux;
      final xdotoolInstalled =
          !requiresXdotool || _isCommandAvailable('xdotool');

      return SystemInputAvailability(
        supportedPlatform: true,
        inputToolFound: inputToolFound,
        requiresXdotool: requiresXdotool,
        xdotoolInstalled: xdotoolInstalled,
      );
    } catch (e) {
      return const SystemInputAvailability(
        supportedPlatform: false,
        inputToolFound: false,
        requiresXdotool: false,
        xdotoolInstalled: false,
      );
    }
  }

  /// Get platform-specific information about system input support
  static String getPlatformInfo() {
    if (Platform.isWindows) {
      return 'Windows - System input supported';
    } else if (Platform.isLinux) {
      return 'Linux - System input supported';
    } else if (Platform.isMacOS) {
      return 'macOS - System input supported';
    } else {
      return 'Mobile platform - System input not supported';
    }
  }
}
