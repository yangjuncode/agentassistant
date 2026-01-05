# connectivity Specification

## Purpose
TBD - created by archiving change support-multi-ws-servers. Update Purpose after archive.
## Requirements
### Requirement: Concurrent Connections

The application MUST attempt to establish and maintain WebSocket connections for ALL server configurations that are marked as 'enabled'.

#### Scenario: Auto-connect on startup

- Given the user has two enabled servers "Home" and "Work"
- When the application starts (or auto-connect is triggered)
- Then the application attempts to connect to "Home" AND "Work" in parallel (or sequentially)
- And the connection status for each server is tracked independently.

### Requirement: Reconnect with exponential backoff

When an enabled server connection fails to connect or disconnects unexpectedly, the application MUST retry reconnecting using exponential backoff with a maximum delay cap of 5 minutes.

#### Scenario: One server down

- Given the user has two enabled servers "Home" and "Work"
- And "Work" server is offline
- When the application starts
- Then the application connects to "Home"
- And the application retries connecting to "Work" with exponential backoff
- And the retry delay does not exceed 5 minutes.

### Requirement: Reply Routing

The application MUST ensure that replies to messages (AskQuestion answers, WorkReport confirmations) are sent via the WebSocket connection that corresponds to the server from which the original message was received.

#### Scenario: Replying to a message

- Given the user receives a "Deploy" task from "Work" server (ServerID: A)
- And the user receives a "Music" question from "Home" server (ServerID: B)
- When the user confirms the "Deploy" task
- Then the confirmation message is sent ONLY to the "Work" server (ServerID: A).

