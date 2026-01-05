import 'dart:async';
import 'package:logger/logger.dart';

import 'package:agentassistant/services/websocket_service.dart';

/// Example demonstrating the WebSocket reconnection fix
/// This example shows how the service now properly cleans up old connections
/// before creating new ones, preventing resource leaks.
void main() async {
  final logger = Logger();
  final webSocketService = WebSocketService();

  // Test server URL (replace with actual server)
  const serverUrl = 'ws://localhost:8080/ws';
  const token = 'test-token-123';

  logger.i('Starting WebSocket reconnection example');

  // Listen to connection events
  webSocketService.connectionStream.listen((connected) {
    logger.i(
        'Connection status changed: ${connected ? 'Connected' : 'Disconnected'}');
  });

  // Listen to error events
  webSocketService.errorStream.listen((error) {
    logger.e('WebSocket error: $error');
  });

  // Listen to messages
  webSocketService.messageStream.listen((message) {
    logger.i('Received message: ${message.cmd}');
  });

  try {
    // Demonstrate multiple connection attempts
    logger.i('Attempting first connection...');
    await webSocketService.connect(serverUrl, token);

    // Wait a bit
    await Future.delayed(const Duration(seconds: 2));

    // Simulate connection loss and reconnection
    logger.i('Disconnecting manually...');
    webSocketService.disconnect();

    // Wait a bit
    await Future.delayed(const Duration(seconds: 1));

    // Reconnect - this should properly clean up the old connection
    logger.i('Attempting reconnection...');
    await webSocketService.connect(serverUrl, token);

    // Wait a bit more
    await Future.delayed(const Duration(seconds: 2));

    // Try connecting again while already connected
    // This should be handled gracefully without creating duplicate connections
    logger.i('Attempting connection while already connected...');
    await webSocketService.connect(serverUrl, token);

    logger.i('Example completed successfully');
  } catch (error) {
    logger.e('Connection failed (expected in example): $error');
  } finally {
    // Clean up
    //logger.i('Cleaning up resources...');
    webSocketService.dispose();
  }
}

/// Helper function to demonstrate the fix
void demonstrateConnectionCleanup() {
  final logger = Logger();

  logger.i('=== WebSocket Connection Cleanup Fix ===');
  logger.i('');
  logger.i('BEFORE FIX:');
  logger.i('- Multiple WebSocket connections could exist simultaneously');
  logger.i('- Old connections were not properly closed during reconnection');
  logger.i('- Resource leaks occurred with frequent reconnections');
  logger.i('- Memory usage increased over time');
  logger.i('');
  logger.i('AFTER FIX:');
  logger.i('- Old connections are cleaned up before creating new ones');
  logger.i('- Only one active connection exists at any time');
  logger.i(
      '- All resources (timers, subscriptions, channels) are properly disposed');
  logger.i('- Memory usage remains stable during reconnections');
  logger.i('');
  logger.i('KEY CHANGES:');
  logger.i('1. Added _cleanup() call at the start of connect() method');
  logger.i('2. Enhanced _cleanup() method with better resource management');
  logger.i('3. Improved error handling to prevent resource leaks');
  logger.i('4. Added proper timer cancellation in _scheduleReconnect()');
  logger.i('5. Enhanced logging for better debugging');
  logger.i('');
}
