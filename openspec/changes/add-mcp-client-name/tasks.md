# add-mcp-client-name tasks

## 1. OpenSpec Artifacts

- [ ] 1.1 Review proposal/design 是否覆盖需求与约束
- [ ] 1.2 确认 tasks 列表与实现一致

## 2. Proto / 生成代码

- [ ] 2.1 在 `proto/agentassist.proto` 中为 `McpAskQuestionRequest`、`McpWorkReportRequest` 增加字段 `McpClientName`
- [ ] 2.2 重新生成 Go / Web / Flutter protobuf 代码（确保字段在三端可用）

## 3. MCP Server（agentassistant-mcp）

- [ ] 3.1 通过 `server.WithHooks` 注册 `AfterInitialize` hook，读取 `initialize.params.clientInfo.name` 并缓存
- [ ] 3.2 在 `ask_question` / `work_report` 的 ConnectRPC 请求中填充 `Request.McpClientName`
- [ ] 3.3 不在 MCP tool schema 中新增 `mcp_client_name` 入参（保持调用方无感）

## 4. Web 客户端

- [ ] 4.1 chat store 解析并保存 `mcpClientName`
- [ ] 4.2 ChatMessage 消息头展示拼接：`mcpClientName | agentName[reasoningModelName]`

## 5. Flutter 客户端

- [ ] 5.1 ChatMessage 模型解析/持久化 `mcpClientName`
- [ ] 5.2 UI 展示拼接：`mcpClientName | agentName[reasoningModelName]`

## 6. Validation

- [ ] 6.1 Go：确保 `agentassistant-mcp` 可编译
- [ ] 6.2 Web：TypeScript 编译/启动无错误
- [ ] 6.3 Flutter：`flutter analyze` 无新增错误
