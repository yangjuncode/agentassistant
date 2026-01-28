# add-file-autocomplete-mcp

## Context

Flutter 客户端当前通过 `InlineReplyWidget` 提供对 MCP AskQuestion/WorkReport 的内联回复输入框。回复时用户需要频繁输入 `project_directory` 下的文件/目录相对路径，但目前仅支持纯文本输入与附件粘贴/选择。

本变更将为回复输入框增加 `@` 触发的路径补全能力，并为每个 MCP request 携带的 `project_directory` 建立本地索引缓存以保证匹配性能。同时在 Chat 页面右上角提供缓存管理入口，允许配置缓存保留时间、手动刷新，并在桌面端可选开启目录变更监听以自动刷新缓存。

约束：

- `project_directory` 由 MCP request 传入，必须先检查该路径在本机是否存在；不存在则不启用索引/补全。
- 目录变更监听仅在桌面端启用（Linux/macOS/Windows），移动端不启用该能力。
- 需要支持多 root（不同 message 的 `project_directory`）并分别缓存。

## Goals / Non-Goals

**Goals:**

- 在 Flutter 回复输入框中，输入 `@` 后展示目录/文件建议列表，并支持子序列模糊匹配。
- 选择建议项后插入 `@<relative-path>`（relative path 以 `project_directory` 为 root）。
- 目录项在展示与插入时以 `/` 结尾。
- 键盘交互：`Esc` 关闭、`Enter` 选择、`↑/↓` 切换选中项；输入变化时建议实时更新。
- 对每个 `project_directory` 建立索引缓存，提升匹配性能；缓存支持 TTL、手动刷新；桌面端可选目录监听自动刷新。
- Chat 页面 AppBar 增加缓存管理入口，可配置 TTL/监听开关并对缓存进行刷新操作。

**Non-Goals:**

- 不实现 Web 端同等能力（本变更仅覆盖 Flutter 客户端）。
- 不实现跨进程/跨设备共享索引缓存。
- 不改变 MCP 协议与 `project_directory` 的来源与语义。

## Decisions

- 使用“按 root 分桶的索引缓存”模型：以 `project_directory` 为 key，缓存该 root 下的文件/目录相对路径列表，以及索引的元数据（构建时间、上次访问时间、TTL、是否正在构建等）。
- 性能策略：
  - 目录扫描与索引构建在后台异步执行，并支持取消/去重（避免频繁重复扫描）。
  - 输入侧对查询做 debounce，并对匹配结果数量做上限（例如最多展示 N 条）以保持 UI 流畅。
  - 模糊匹配采用子序列匹配并带排序评分（优先更短路径、命中更集中、前缀更接近等）。
- UI 实现：在 `TextField` 上方使用 Overlay/Portal 展示建议列表，定位相对于输入框；列表支持鼠标点击选择与键盘选择。
- `@` 解析：只对“光标所在位置之前最近一次 `@`”到光标之间的 token 进行匹配；当 token 为空时展示 top-N（按最近使用/字典序）建议。
- 桌面端目录监听：在索引构建完成后，可选对 root 使用 `Directory.watch()` 监听变更；发生变更后触发“延迟重建”（合并短时间内多次事件），避免频繁重建。
- 设置持久化：使用 SharedPreferences 保存 TTL 与桌面端监听开关；缓存内容本身为内存缓存（不持久化），以避免过大磁盘占用与一致性复杂度。

## Risks / Trade-offs

- 大型仓库索引开销：完整扫描可能耗时与耗内存。
  - Mitigation：异步构建 + 结果数量上限 + TTL/LRU 回收 + 可手动刷新 + 桌面端监听增量触发重建。
- Flutter UI 叠层与键盘事件冲突：当前输入框已实现历史导航（↑/↓）与快捷键（Ctrl+Enter）。
  - Mitigation：当建议列表打开时，优先拦截 `↑/↓/Enter/Esc` 给补全组件；关闭时保持原历史导航逻辑。
- 跨平台差异：移动端/桌面端文件系统能力不同。
  - Mitigation：监听能力仅桌面端启用；移动端提供 TTL + 手动刷新。
