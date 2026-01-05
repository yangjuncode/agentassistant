# Tasks: Support Multi-WS Servers

## Phase 1: Foundation & Data Model

- [ ] Create `flutterclient/lib/models/server_config.dart` with JSON serialization (no per-server token; alias defaults to host:port for display). <!-- id: 0 -->
- [ ] Create `flutterclient/lib/services/server_storage_service.dart` to handle loading/saving server lists and migration from legacy single `server_url` key. <!-- id: 1 -->
- [ ] Update `flutterclient/lib/models/chat_message.dart` to include `serverId` and `serverName`. <!-- id: 2 -->

## Phase 2: Logic Refactoring

- [ ] Refactor `flutterclient/lib/providers/chat_provider.dart` to replace single `_webSocketService` with `Map<String, WebSocketService> _services`. <!-- id: 3 -->
- [ ] Implement `connectAll()` in `ChatProvider` to iterate and connect all enabled configurations. <!-- id: 4 -->
- [ ] Track per-server connection status and implement reconnect with exponential backoff capped at 5 minutes. <!-- id: 5 -->
- [ ] Update `_handleWebSocketMessage` to accept `serverId` and attach it to created `ChatMessage` objects. <!-- id: 6 -->
- [ ] Update `replyToQuestion` and `confirmTask` to look up the correct service by `serverId` before sending. <!-- id: 7 -->
- [ ] Update online user aggregation to track source server and allow selecting the correct server for P2P chat. <!-- id: 8 -->

## Phase 3: UI Implementation

- [ ] Create/update server management UI (List of servers, Add/Edit/Delete dialogs, enable toggle). <!-- id: 9 -->
- [ ] Add Settings left-side status icon (badge shows connected server count) and a popup listing all server statuses. <!-- id: 10 -->
- [ ] Update message UI to display `serverName` in the header/title area. <!-- id: 11 -->
- [ ] Update online user UI to show server origin via a tip/tag and ensure chat page title shows `user@server`. <!-- id: 12 -->

## Phase 4: Verification

- [ ] Verify migration of existing config (legacy URL becomes one server entry; alias default is host:port). <!-- id: 13 -->
- [ ] Verify simultaneous connection to two different servers (mocked or real). <!-- id: 14 -->
- [ ] Verify one server down triggers backoff reconnect (cap 5 minutes) while other server remains usable. <!-- id: 15 -->
- [ ] Verify message replies go to the correct server and UI labels are correct (`message` tag, `user@server` title). <!-- id: 16 -->
