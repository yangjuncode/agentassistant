# add-file-autocomplete-mcp tasks

## 1. OpenSpec Artifacts

- [x] 1.1 Verify proposal/design/specs are complete and consistent with requirements
- [x] 1.2 Create tasks.md checklist for implementation and validation

## 2. Core Index Cache (mcp-project-directory-index-cache)

- [x] 2.1 Implement per-root in-memory index cache keyed by `project_directory`
- [x] 2.2 Implement TTL cleanup (default 8 hours since last seen root)
- [x] 2.3 Implement ignore common directories setting (default: `.git`, `node_modules`, `build`, `.dart_tool`) and ensure changes invalidate/rebuild indexes
- [x] 2.4 Implement manual refresh per root
- [x] 2.5 Implement desktop-only directory watching (debounced) to trigger index refresh
- [x] 2.6 Ensure index build runs asynchronously and results are cached for fast search

## 3. Autocomplete UI (mcp-at-path-autocomplete)

- [x] 3.1 Touch root on message load to warm index build
- [x] 3.2 Detect `@` token near cursor and update suggestions with debounce
- [x] 3.3 Render suggestion overlay dropdown and support mouse selection
- [x] 3.4 Keyboard interaction: `Esc` close, `Enter` accept, `↑/↓` navigate
- [x] 3.5 Insert selected suggestion as `@<relative-path>` and append `/` for directories
- [x] 3.6 Disable autocomplete when `project_directory` is missing or does not exist locally

## 4. Management UI

- [x] 4.1 Add ChatScreen AppBar cache-management icon entry
- [x] 4.2 Implement cache management dialog: set TTL, desktop watch toggle, list roots, refresh/clear root
- [x] 4.3 Add SettingsScreen section for ignored directories toggles

## 5. Validation / Performance

- [x] 5.1 Validate performance on large repositories: limit results, debounce input, avoid rescans for each keystroke
- [x] 5.2 Validate behavior for multiple roots: caches are separate and TTL cleanup works
- [x] 5.3 Validate desktop watch toggle: enabling/disabling starts/stops watchers correctly
- [x] 5.4 Validate UX: overlay closes on focus loss and outside click
- [x] 5.5 Run `flutter analyze` and ensure there are no new errors introduced by this change
