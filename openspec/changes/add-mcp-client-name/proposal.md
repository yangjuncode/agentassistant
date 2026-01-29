# add-mcp-client-name

## Why

当前系统在 UI 中仅显示 `agent_name` 与 `reasoning_model_name`（例如 `Cascade[gpt-4o]`），但在多 MCP 客户端/宿主并存时（例如 WindSurf、Claude Desktop 等），仅靠 agent 名称不足以快速判断请求来自哪个 MCP 客户端。

因此需要从 MCP 生命周期的 `initialize` 请求中获取 `clientInfo.name`（本文称 `mcp client name`），并把它透传到 AgentAssistant 的 AskQuestion/WorkReport 请求中，在 Web/Flutter 客户端进行统一展示。

## What Changes

- 从 MCP `initialize.params.clientInfo.name` 获取 `mcp client name` 并在 MCP Server 进程内缓存。
- MCP 工具 `ask_question` / `work_report` 不新增入参（不要求调用方传 `mcp client name`），由 MCP Server 自动透传。
- 在 AgentAssistant 协议中为 AskQuestion/WorkReport 的请求体增加 `McpClientName` 字段。
- Web / Flutter UI 在现有 agent 展示前追加 `mcp client name`，显示为：`windsurf | Cascade[gpt4o]`（固定分隔符 `" | "`）。

## Capabilities

### New Capabilities

- 在 AskQuestion/WorkReport 的消息展示中，增加“来源 MCP 客户端”的可视化信息。

### Modified Capabilities

- MCP ask_question/work_report：服务端将自动透传 `mcp client name` 到请求结构中。

## Impact

- Proto：需要为请求结构新增字段，并同步生成 Go / Web / Flutter 的生成代码。
- MCP Server（Go）：需要接入 `initialize` hook 并缓存 client name，在后续 RPC 请求中填充。
- Web（Vue/Quasar）：需要在 store 中解析并在消息头渲染中拼接展示。
- Flutter：需要在消息模型解析/持久化与消息头渲染中拼接展示。
