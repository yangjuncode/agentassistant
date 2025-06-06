# agent assistant 需求文档

agent assistant是一个基于mcp的AI agent assistant，它通过引导 AI agent 与用户确认而非进行推测性操作，可将多次工具调用合并为单次反馈导向请求，大幅节省平台成本并提升开发效率。

**支持的AI agent平台：** [Cursor](https://www.cursor.com) | [Cline](https://cline.bot) | [Windsurf](https://windsurf.com) | [Augment](https://www.augmentcode.com) | [Trae](https://www.trae.ai)

## 工作流程

1. AI agent 使用mcp协议调用cli `agentassistant-mcp`
2. agentassistant-mcp 通过rpc 将请求转发给 agentassistant-srv
3. agentassistant-srv 根据请求转发/广播给当前在线的web user
4. web user 根据请求的内容，返回反馈信息给 agentassistant-srv
5. agentassistant-srv 将反馈信息返回给 AI agent

## 设定提示工程

为了获得最佳效果，请在 AI 助手中添加以下规则：

```markdown
# MCP agent assistant 规则

1. 在任何流程、任务、对话进行时，无论是询问、回复、或完成阶段性任务，皆必须调用 MCP agentassistant-mcp。
2. 每当收到用户反馈，若反馈内容非空，必须再次调用 MCP agentassistant-mcp，并根据反馈内容调整行为。
3. 仅当用户明确表示「结束」或「不再需要交互」时，才可停止调用 MCP agentassistant-mcp，流程才算结束。
4. 除非收到结束指令，否则所有步骤都必须重复调用 MCP agentassistant-mcp。
5. 完成任务前，必须使用 MCP agentassistant-mcp 工具向用户询问反馈。
```
