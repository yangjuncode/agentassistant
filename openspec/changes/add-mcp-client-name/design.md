# add-mcp-client-name

## Context

系统包含：

- `agentassistant-mcp`：以 MCP Server 形式对外提供 `ask_question`、`work_report` 工具。
- `agentassistant-srv`：接收来自 MCP Server 的 ConnectRPC 请求，并通过 WebSocket 广播给 Web/Flutter 客户端。
- Web/Flutter：展示 AskQuestion/WorkReport 请求，并允许用户回复。

目前 UI 仅展示 `agent_name` 与 `reasoning_model_name`，缺少 MCP 客户端来源信息。

## Goals / Non-Goals

**Goals:**

- 从 MCP `initialize.params.clientInfo.name` 获取并缓存 `mcp client name`。
- AskQuestion/WorkReport 请求结构透传 `McpClientName` 字段。
- Web/Flutter UI 统一展示：`mcpClientName | agentName[reasoningModelName]`（分隔符固定 `" | "`）。
- 不要求调用方在 tool 入参中提供 `mcp client name`。

**Non-Goals:**

- 不改变 WebSocket 协议结构与消息流（仅扩展已有 request payload 字段）。
- 不实现多 session 的 MCP client name 映射（stdio transport 只有单 session；若未来支持多 session，再扩展）。

## Decisions

- 数据来源：仅以 MCP 生命周期 `initialize` 的 `clientInfo.name` 作为 `mcp client name`。
- 缓存策略：在 `agentassistant-mcp` 进程内缓存单个值（stdio 单客户端模型）。
- 透传方式：
  - Proto 在 `McpAskQuestionRequest` 与 `McpWorkReportRequest` 增加 `McpClientName` 字段。
  - `agentassistant-mcp` 在转发 ConnectRPC 请求时填充该字段。
- UI 拼接策略：
  - 以 `mcpClientName` 为最前缀。
  - 若 `agentName` 与 `reasoningModelName` 都存在，则拼 `agentName[reasoningModelName]`。
  - 若仅存在其一，则按原规则展示。
  - 最终用 `" | "` 连接各段。

## Risks / Trade-offs

- 若客户端未发送 `initialize` 或 `clientInfo.name` 为空：
  - `McpClientName` 可能为空，UI 将退化为原有展示（不显示前缀）。
- 未来若引入非 stdio/多 session transport：
  - 需要将 `mcp client name` 与 session 绑定，而非全局单值缓存。
