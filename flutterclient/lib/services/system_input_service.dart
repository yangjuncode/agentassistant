import 'dart:io';
import 'dart:convert';
import 'package:logger/logger.dart';

/// Service for handling system input functionality on Flutter PC
/// This service allows sending text to the system's active input field
class SystemInputService {
  static final Logger _logger = Logger();
  static const String _inputToolPath = '../bin/agentassistant-input';

  /// Send text to system input using agentassistant-input tool
  /// 
  /// [content] - The text content to send to system input
  /// [isBase64Encoded] - Whether the content is base64 encoded
  /// 
  /// Returns true if successful, false otherwise
  static Future<bool> sendToSystemInput(String content, {bool isBase64Encoded = false}) async {
    try {
      if (content.isEmpty) {
        _logger.w('Cannot send empty content to system input');
        return false;
      }

      // Check if we're running on desktop platform
      if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
        _logger.w('System input is only supported on desktop platforms');
        return false;
      }

      // Check if agentassistant-input tool exists
      final inputTool = File(_inputToolPath);
      if (!await inputTool.exists()) {
        _logger.e('agentassistant-input tool not found at: $_inputToolPath');
        return false;
      }

      // Prepare command arguments
      List<String> args;
      if (isBase64Encoded) {
        args = ['-input64', content];
      } else {
        args = ['-input', content];
      }

      _logger.d('Executing agentassistant-input with args: $args');

      // Execute the command
      final result = await Process.run(_inputToolPath, args);

      if (result.exitCode == 0) {
        _logger.i('Successfully sent text to system input: ${content.length} characters');
        return true;
      } else {
        _logger.e('Failed to send text to system input. Exit code: ${result.exitCode}');
        _logger.e('Error output: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logger.e('Exception while sending text to system input: $e');
      return false;
    }
  }

  /// Send text to system input with base64 encoding
  /// This is useful for text containing special characters
  static Future<bool> sendToSystemInputBase64(String content) async {
    try {
      final encodedContent = base64Encode(utf8.encode(content));
      return await sendToSystemInput(encodedContent, isBase64Encoded: true);
    } catch (e) {
      _logger.e('Failed to encode content to base64: $e');
      return false;
    }
  }

  /// Check if system input functionality is available
  /// Returns true if the platform supports it and the tool is available
  static Future<bool> isAvailable() async {
    try {
      // Check platform support
      if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
        return false;
      }

      // Check if tool exists
      final inputTool = File(_inputToolPath);
      return await inputTool.exists();
    } catch (e) {
      _logger.e('Error checking system input availability: $e');
      return false;
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
