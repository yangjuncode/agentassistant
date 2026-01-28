
# add-file-autocomplete-mcp

## Why

在回复 MCP message 时需要频繁引用 `project_directory` 下的目录与文件路径。纯手输路径效率低且易出错，尤其在目录层级较深时。

通过在输入框中提供 `@` 触发的目录/文件模糊补全，并对 `project_directory` 做本地索引缓存，可以显著提升回复效率与准确性。

## What Changes

- 在 Flutter 客户端的 MCP 回复输入框中，支持输入 `@` 触发目录/文件补全下拉列表。
- 支持使用少数字母进行子序列模糊匹配（类似 VSCode/Windsurf agent 的体验）。
- 选择建议项后插入 `@<relative-path>`（相对路径以 `project_directory` 为 root）。
- 目录建议项以 `/` 结尾以便区分文件与目录。
- 按 `Esc` 关闭建议列表；`Enter` 选择；`↑/↓` 移动选中项；输入变化时建议列表实时更新。
- 对每个 `project_directory` 建立目录/文件名索引缓存以保证匹配性能。
- 在聊天页面右上角增加“缓存管理”入口：
  - 可配置缓存保留时间（TTL）
  - 可手动刷新指定 root 的索引
  - 可配置是否监听 root 目录变化并及时刷新缓存

## Capabilities

### New Capabilities

- `mcp-at-path-autocomplete`: 在 Flutter 回复输入框中提供 `@` 触发的文件/目录模糊补全，并插入 `@<relative-path>`。
- `mcp-project-directory-index-cache`: 基于 `project_directory` 的本地文件树索引缓存（TTL、刷新、可选监听自动更新）以及对应的缓存管理入口。

### Modified Capabilities

## Impact

- Flutter UI：`InlineReplyWidget` 输入框需要加入 `@` 解析、建议列表展示（overlay / dropdown）与键盘交互。
- Flutter 状态/服务层：新增或扩展 Provider/Service 用于按 `project_directory` 管理索引缓存、TTL、刷新与（可选）文件系统监听。
- 设置存储：需要通过 SharedPreferences 持久化缓存保留时间与监听开关等配置。
- Chat 页面 AppBar：新增一个缓存管理图标入口与对应弹窗/页面。
