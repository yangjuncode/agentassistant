# settings Specification

## Purpose
TBD - created by archiving change support-multi-ws-servers. Update Purpose after archive.
## Requirements
### Requirement: Store multiple server configurations

The application MUST persist a list of server configurations, where each configuration includes a unique ID, the server URL, an optional user-defined alias, and an enabled/disabled state.

The application MUST continue to use a single global authentication token shared across all configured servers.

#### Scenario: User adds a new server

- Given the user is on the Settings screen
- When the user adds a new server with Name "Office" and URL "ws://10.0.0.1:2000"
- Then the new server configuration is saved to the local storage
- And the new server appears in the server list.

### Requirement: Toggle server active state

The application MUST allow users to enable or disable individual server configurations without deleting them.

#### Scenario: User disables a server

- Given the user has an enabled server "Office"
- When the user toggles the server switch to "Off"
- Then the server configuration is marked as disabled in storage
- And the application initiates a disconnection for that specific server.

### Requirement: Default server label

If a server configuration has an empty alias, the application MUST display the server label as `host:port` derived from the server URL.

#### Scenario: Alias omitted

- Given the user adds a server with an empty Name and URL "ws://10.0.0.1:2000"
- When the server is displayed in the UI
- Then the server label is shown as "10.0.0.1:2000" (or equivalent `host:port` formatting).

