# Design: Multi-Server Connection Architecture

## Context

The current `ChatProvider` initializes a single `WebSocketService` and manages the state for that single connection. We need to support N connections.

## Architecture

### 1. Server Configuration Model

We will introduce a `ServerConfig` class:

```dart
class ServerConfig {
  final String id; // UUID
  final String name; // Optional user-defined label (alias). If empty, default UI label is host:port.
  final String url;
  final bool isEnabled;
}
```

These will be serialized to JSON and stored in `SharedPreferences` under a new key (e.g., `server_configs`).

Authentication token remains a single global setting (legacy `token` stays as-is). The legacy `server_url` key will be migrated to a single-item list on first run.

### 2. Connection Pool Management

`ChatProvider` (or a new intermediary `ConnectionManager`) will maintain a map of active connections:
`Map<String, WebSocketService> _activeServices;` // Keyed by ServerConfig.id

- **Connect**: Loop through enabled `ServerConfig` items. Check if already connected. If not, create new `WebSocketService` and connect.
- **Disconnect**: When a server is disabled or deleted, look up its service, call `disconnect()`, and remove from map.
- **Aggregation**:
  - `ChatProvider` will subscribe to *each* service's streams.
  - When `_handleWebSocketMessage` is called, it will need context of *which* server sent it.
  - *Implementation Detail*: The listener callback will be a closure that captures the `serverConfig`.

      ```dart
      service.messageStream.listen((msg) => _handleWebSocketMessage(msg, sourceServerId));
      ```

### 3. Reconnect & Status Tracking

- Maintain per-server connection state (`connecting`, `connected`, `error`).
- On unexpected disconnect / connect failure, schedule reconnect using exponential backoff per server.
- Backoff delay increases until it reaches a maximum of 5 minutes.
- One server's failure MUST NOT affect other connections.

### 4. Data Model Updates

- **ChatMessage**: Add `String? serverId` and `String? serverName`.
- **OnlineUser**: Since `OnlineUser` is a protobuf generated class, we cannot easily modifying it. We will wrap it or use a separate UI model `DisplayOnlineUser` which contains the proto `OnlineUser` and `serverName`.

### 5. UI Representation

- **Message List**: In the message title/header, display the `serverName` (alias or default host:port).
- **Online Users**: Each entry shows server origin via a tag/tip.
- **Chat Title**: The chat page title shows `UserNickname@ServerName`.
- **Settings & Main Chat Status**: Add an indicator icon in the AppBar actions (right side) to show number of connected servers (green badge); clicking opens a popup listing all servers and their connection statuses.
- **Input Handling**:
  - When replying to a message (Task/Question), the `ChatMessage` object already contains the `serverId`. The provider will look up the correct `WebSocketService` using `serverId` to send the reply.
  - When initiating a NEW chat (P2P), the user must select *which server* the target user belongs to (implicit if selecting from the Online User list).

## Trade-offs

- **Complexity**: `ChatProvider` becomes more complex as it acts as a multiplexer.
- **Performance**: N open WebSocket connections. Given typical usage (N < 5), this is negligible.
- **Error Handling**: One server failing shouldn't impact others. Individual connection statuses need to be tracked.
