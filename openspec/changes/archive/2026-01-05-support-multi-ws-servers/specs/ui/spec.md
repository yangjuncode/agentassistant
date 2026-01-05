# Multi-Server UI Display

## ADDED Requirements

### Requirement: Message Source Indication

The application MUST display the name of the source server in the UI element for every received message (Task, Question, Chat), allowing the user to distinguish between messages from different environments.

#### Scenario: Interleaved messages

- Given the user has messages from "Server A" and "Server B"
- When viewing the message stream
- Then the message card for Server A shows "Server A" in its header/metadata area
- And the message card for Server B shows "Server B".

### Requirement: Online User Source Indication

The application MUST display the source server name for each user in the "Online Users" list or chat selection interface.

#### Scenario: Two users with same name

- Given "User1" is online on "Server A"
- And "User1" is also online on "Server B" (different identity)
- When viewing the online users list
- Then two distinct entries are shown: "User1 (Server A)" and "User1 (Server B)" (or visual equivalent).

### Requirement: Chat title includes server origin

When opening a chat with an online user, the application MUST display the chat page title including server origin as `user@server`.

#### Scenario: Open chat from online list

- Given "Alice" is online on "Server A"
- When the user opens a chat with "Alice"
- Then the chat page title shows "Alice@Server A" (or visual equivalent).

### Requirement: Connection status entry in Settings

In the Settings navigation, the application MUST show an indicator icon that reflects how many servers are currently connected, and provide a popup listing the connection status of each configured server.

#### Scenario: View connection summary

- Given the user has three servers configured
- And two servers are connected
- When the user views the Settings navigation
- Then an indicator shows "2" connected servers
- And when the user clicks the indicator, a popup shows all servers and their current statuses.
