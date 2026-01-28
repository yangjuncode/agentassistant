# mcp-at-path-autocomplete Specification

## Purpose
TBD - created by archiving change add-file-autocomplete-mcp. Update Purpose after archive.
## Requirements
### Requirement: Trigger @ path autocomplete in MCP reply input

The Flutter client SHALL provide `@`-triggered path autocomplete when replying to MCP messages, using the message's `project_directory` as the search root.

#### Scenario: User types @ to start autocomplete

- **WHEN** the user types `@` in the MCP reply input
- **THEN** the client shows an autocomplete suggestion list for files and directories under `project_directory`

### Requirement: Validate project_directory exists before enabling autocomplete

The client SHALL enable `@` path autocomplete only if the `project_directory` path exists on the local machine.

#### Scenario: project_directory does not exist

- **WHEN** the MCP message contains a `project_directory` that does not exist locally
- **THEN** the client does not show `@` path autocomplete suggestions for that message

### Requirement: Fuzzy match paths using subsequence matching

The client SHALL support fuzzy matching with subsequence matching for directory and file suggestions.

#### Scenario: Subsequence match returns candidates

- **WHEN** the user types `@rdme`
- **THEN** the suggestion list includes paths like `README.md` when available under the root

### Requirement: Insert selected suggestion as @relative-path

The client SHALL insert the selected suggestion into the input as `@<relative-path>` where `<relative-path>` is relative to `project_directory`.

#### Scenario: Selecting a file inserts @relative path

- **WHEN** the user selects a file suggestion
- **THEN** the input text includes `@` followed by the file path relative to `project_directory`

### Requirement: Distinguish directories with trailing slash

The client SHALL display directory suggestions with a trailing `/` and insert directories with a trailing `/`.

#### Scenario: Directory suggestion formatting

- **WHEN** the suggestion list includes a directory
- **THEN** that directory is displayed with a trailing `/` and inserted with a trailing `/`

### Requirement: Keyboard interaction for suggestion list

When the suggestion list is open, the client SHALL support keyboard interaction: `Esc` to close, `Enter` to accept, and `↑/↓` to change selection.

#### Scenario: Keyboard navigation and accept

- **WHEN** the suggestion list is open and the user presses `↑/↓`
- **THEN** the highlighted suggestion changes accordingly
- **WHEN** the user presses `Enter`
- **THEN** the highlighted suggestion is inserted into the input
- **WHEN** the user presses `Esc`
- **THEN** the suggestion list closes without insertion

### Requirement: Suggestions update as user types

The client SHALL update the suggestion list as the user types additional characters after `@`.

#### Scenario: Incremental filtering

- **WHEN** the user types more characters after `@`
- **THEN** the suggestion list updates to reflect the current query

### Requirement: Suggestion list uses optimal placement near screen edges

The client SHALL position the autocomplete suggestion list above or below the input to maximize visible suggestions, accounting for safe areas and on-screen keyboard occlusion.

#### Scenario: Input is near the bottom and keyboard is open

- **WHEN** the reply input is near the bottom of the window and the on-screen keyboard reduces available space below
- **THEN** the suggestion list opens upward (above the input) and is height-limited to fit on screen

