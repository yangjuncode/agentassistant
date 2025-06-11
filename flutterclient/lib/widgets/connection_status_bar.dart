import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';

/// Connection status bar widget
class ConnectionStatusBar extends StatelessWidget {
  const ConnectionStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        // Don't show anything if connected and no errors
        if (chatProvider.isConnected && chatProvider.connectionError == null) {
          return const SizedBox.shrink();
        }

        Color backgroundColor;
        Color textColor;
        IconData icon;
        String message;

        if (chatProvider.isConnecting) {
          backgroundColor = Colors.orange.shade100;
          textColor = Colors.orange.shade800;
          icon = Icons.sync;
          message = '正在连接...';
        } else if (!chatProvider.isConnected) {
          backgroundColor = Colors.red.shade100;
          textColor = Colors.red.shade800;
          icon = Icons.wifi_off;
          message = chatProvider.connectionError ?? '连接已断开';
        } else {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: backgroundColor,
          child: Row(
            children: [
              Icon(
                icon,
                color: textColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (!chatProvider.isConnecting && !chatProvider.isConnected)
                TextButton(
                  onPressed: () {
                    // Navigate back to login screen
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: Text(
                    '重新连接',
                    style: TextStyle(color: textColor),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
