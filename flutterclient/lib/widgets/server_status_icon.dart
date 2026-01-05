import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../services/websocket_service.dart';

class ServerStatusIcon extends StatelessWidget {
  const ServerStatusIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final count = chatProvider.connectedServerCount;
        return IconButton(
          tooltip: 'Server connections',
          onPressed: () => _showServerStatusPopup(context, chatProvider),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.dns),
              if (count > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      // User requested green for connected status
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showServerStatusPopup(BuildContext context, ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Server Connections'),
          content: SizedBox(
            width: 520,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: chatProvider.serverConfigs.length,
              itemBuilder: (context, index) {
                final cfg = chatProvider.serverConfigs[index];
                final status = chatProvider.serverStatuses[cfg.id];
                final err = chatProvider.serverErrors[cfg.id];
                final subtitle = <String>[
                  cfg.url,
                  'status: ${_statusLabel(status)}',
                  if (err != null && err.trim().isNotEmpty) 'error: $err',
                ].join('\n');

                return ListTile(
                  title: Text(cfg.displayName),
                  subtitle: Text(subtitle),
                  trailing: _buildStatusIcon(cfg.isEnabled, status),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusIcon(bool isEnabled, WebSocketServiceStatus? status) {
    if (!isEnabled) {
      return const Icon(Icons.pause_circle, color: Colors.grey);
    }
    switch (status) {
      case WebSocketServiceStatus.connected:
        return const Icon(Icons.check_circle, color: Colors.green);
      case WebSocketServiceStatus.connecting:
      case WebSocketServiceStatus.reconnecting:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case WebSocketServiceStatus.error:
        return const Icon(Icons.error, color: Colors.red);
      case WebSocketServiceStatus.disconnected:
      default:
        return const Icon(Icons.cloud_off, color: Colors.grey);
    }
  }

  String _statusLabel(WebSocketServiceStatus? status) {
    switch (status) {
      case WebSocketServiceStatus.connected:
        return 'connected';
      case WebSocketServiceStatus.connecting:
        return 'connecting';
      case WebSocketServiceStatus.reconnecting:
        return 'reconnecting';
      case WebSocketServiceStatus.error:
        return 'error';
      case WebSocketServiceStatus.disconnected:
      default:
        return 'disconnected';
    }
  }
}
