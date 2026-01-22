import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/chat_provider.dart';
import '../services/websocket_service.dart';

class ServerStatusIcon extends StatelessWidget {
  const ServerStatusIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final count = chatProvider.connectedServerCount;
        return IconButton(
          tooltip: l10n.serverConnectionsTooltip,
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
        final dialogL10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(dialogL10n.serverConnectionsTitle),
          content: SizedBox(
            width: 520,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: chatProvider.serverConfigs.length,
              itemBuilder: (context, index) {
                final cfg = chatProvider.serverConfigs[index];
                final status = chatProvider.serverStatuses[cfg.id];
                final err = chatProvider.serverErrors[cfg.id];
                final statusLabel = _statusLabel(dialogL10n, status);
                final subtitle = <String>[
                  cfg.url,
                  dialogL10n.serverStatusLine(statusLabel),
                  if (err != null && err.trim().isNotEmpty)
                    dialogL10n.serverErrorLine(err),
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
              child: Text(dialogL10n.close),
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

  String _statusLabel(AppLocalizations l10n, WebSocketServiceStatus? status) {
    switch (status) {
      case WebSocketServiceStatus.connected:
        return l10n.serverStatusConnected;
      case WebSocketServiceStatus.connecting:
        return l10n.serverStatusConnecting;
      case WebSocketServiceStatus.reconnecting:
        return l10n.serverStatusReconnecting;
      case WebSocketServiceStatus.error:
        return l10n.serverStatusError;
      case WebSocketServiceStatus.disconnected:
      default:
        return l10n.serverStatusDisconnected;
    }
  }
}
