# Support Multiple WebSocket Servers

## Why

The Flutter client currently supports only one WebSocket server connection. Users may need to keep multiple Agent Assistant instances online at the same time (e.g., work + personal environments), while still being able to clearly identify which server a message/user belongs to.

## What Changes

- Add support for configuring multiple WebSocket servers (list of servers), each with:
  - Unique server ID
  - URL
  - Optional user-editable alias
  - Enabled/disabled toggle
- Connection behavior:
  - On startup, the client MUST attempt to connect to all enabled servers.
  - Each server connection MUST maintain its own status (connecting/connected/error).
  - When a server fails to connect or disconnects unexpectedly, the client MUST retry using exponential backoff up to a maximum delay of 5 minutes.
- Authentication:
  - The client continues to use a single global `token` shared across all server connections.
- Aggregation & routing:
  - Messages from different servers are displayed in the same unified stream (interleaved by time).
  - Each message MUST display its source server label (alias or default).
  - Replies/confirmations MUST be routed back to the originating server connection.
- UI:
  - The server label displayed in UI uses:
    - Alias if provided
    - Otherwise default to `host:port` derived from the server URL
  - Online user list shows server origin via a tip/tag for each user.
  - The chat page title MUST include server origin as `nickname@server`.
  - In the Settings left navigation, add an indicator icon (similar to unread badge) showing how many servers are currently connected. Clicking it opens a popup listing all server connection statuses.

## Impact

- **Affected specs**:
  - `changes/support-multi-ws-servers/specs/settings/spec.md`
  - `changes/support-multi-ws-servers/specs/connectivity/spec.md`
  - `changes/support-multi-ws-servers/specs/ui/spec.md`
- **Affected code (expected)**:
  - Flutter client storage for server list (SharedPreferences)
  - `ChatProvider` multi-connection fan-in/fan-out
  - Message models and online user UI models to carry `serverId/serverLabel`
  - Settings UI navigation + status popup

## Non-Goals

- No server-side change.
- No per-server token/auth (single global token only).
- No attempt to merge identities across servers (same nickname on two servers is treated as different entries).

## Acceptance Criteria

- With two enabled servers, the client connects to both on startup.
- If one server is down, it retries with exponential backoff and caps the delay at 5 minutes; the other server continues working.
- Messages from two servers appear in a single list and each message clearly shows its server label.
- Online users display server origin; opening a chat with an online user displays `user@server` in the title.
- Reply/confirm actions are always sent back to the same server that produced the original message.
