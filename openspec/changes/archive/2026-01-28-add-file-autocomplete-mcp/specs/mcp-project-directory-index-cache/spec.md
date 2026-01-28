## ADDED Requirements

### Requirement: Cache an index per project_directory
The client SHALL maintain an in-memory index of file and directory paths for each distinct `project_directory` observed in MCP messages.

#### Scenario: Multiple roots are cached separately
- **WHEN** the user receives MCP messages with different `project_directory` values
- **THEN** the client maintains separate indexes per root

### Requirement: Index uses relative paths and includes files and directories
The index SHALL include both files and directories as relative paths from the root `project_directory`.

#### Scenario: Index contains relative paths
- **WHEN** an index is built for a root
- **THEN** indexed entries are stored as relative paths from that root

### Requirement: Performance via cached directory listing
The client SHALL cache the directory/file listing to ensure fast autocomplete matching after the index is built.

#### Scenario: Autocomplete uses cached index
- **WHEN** the user triggers autocomplete under a root with an existing index
- **THEN** suggestions are computed without rescanning the filesystem

### Requirement: Cache retention time (TTL) is configurable
The client SHALL allow configuring a cache retention time (TTL) that controls when an index should be considered expired.

#### Scenario: TTL expires an index
- **WHEN** an index has exceeded the configured TTL
- **THEN** the client treats it as expired and rebuilds it before providing suggestions

### Requirement: Manual refresh is available
The client SHALL provide a manual refresh action to rebuild the index for a selected `project_directory`.

#### Scenario: User triggers manual refresh
- **WHEN** the user selects refresh for a root in the cache management UI
- **THEN** the client rebuilds that root's index

### Requirement: Cache management entry in Chat AppBar
The client SHALL provide a cache management entry point via an icon button in the Chat screen AppBar.

#### Scenario: User opens cache management
- **WHEN** the user clicks the cache management icon
- **THEN** the client shows a UI that lists cached roots and allows configuration/actions

### Requirement: Desktop-only directory watching option
On desktop platforms, the client SHALL allow enabling a setting to watch `project_directory` for changes and refresh the index accordingly.

#### Scenario: Directory change triggers refresh on desktop
- **WHEN** directory watching is enabled on desktop and files change under the root
- **THEN** the client schedules an index refresh for that root
