# Agent Assistant 协议规范

## 简介

本文档详细介绍了 Agent Assistant 系统的协议规范，该系统由 `agentassistant-mcp` 和 `agentassistant-srv` 两个核心组件构成。`agentassistant-mcp` 作为 MCP (Model Context Protocol) Stdio Server 与 AI Agent进行交互，而 `agentassistant-srv` 则负责处理用户界面交互和请求广播。

## agentassistant-mcp：MCP Stdio 服务器

`agentassistant-mcp` 是一个使用 Golang 开发的 MCP Stdio Server，它利用 `connectrpc-go` 和 `mark3labs/mcp-go` 库实现。

`agentassistant-mcp` 提供了两个主要工具：

- `ask_question`
- `task_finish`

启动时，`agentassistant-mcp` 会加载 `agentassistant-mcp.toml` 配置文件。配置文件中包含以下信息：

```toml
# 服务器信息
agentassistant_server_host = "127.0.0.1"
agentassistant_server_port = 22080

# 令牌
agentassistant_server_token = "test-token"
```

这些配置也可以通过命令行参数进行设置。**命令行参数具有更高的优先级，会覆盖配置文件中的同名参数。**
支持的命令行参数包括：

- `host`
- `port`
- `token`

此外，还支持一个 `web` 命令行参数。使用此参数启动时，会自动在浏览器中打开 `agentassistant-srv` 的 Web 用户界面，URL 格式为：`http://<host>:<port>?token=<token>`。

## agentassistant-srv：用户交互与请求处理服务器

`agentassistant-srv` 是一个使用 Golang 开发的服务器，它集成了 HTTP 服务并提供了 Web 用户界面。它依赖 `connectrpc-go` 库，并监听定义在 `agentassist.proto` 文件中的 RPC 服务。

**工作流程：**

1. 当 `SrvAgentAssist` RPC 服务被调用时，`agentassistant-srv` 会将请求转换为 `BroadcastRequest`。
2. 该 `BroadcastRequest` 会被广播给所有使用相同 `token` 连接的 WebSocket 用户。
3. 当用户通过 Web 界面回应时，`agentassistant-srv` 通过 `SrvAgentAssistReply` 服务中的相应 reply 方法接收回应。
4. 最后，`agentassistant-srv` 将此结果返回给 `agentassistant-mcp`，后者再将其传递给 AI Agent。

## Agent Assistant web 界面

`agentassistant-srv` 的 Web 用户界面是用户与 Agent Assistant 系统进行交互的主要入口。它是一个现代化的单页应用程序 (SPA)，旨在提供流畅的用户体验。

**技术栈：**

- **React：** 作为核心的 JavaScript 库，用于构建动态且响应迅速的用户界面组件。
- **Shadcn/ui：** 提供了一套设计精美、可重用且易于定制的 UI 组件，确保了界面的美观性和一致性。
- **Vite：** 作为前端构建工具，提供了极速的冷启动、即时模块热更新 (HMR) 和优化的构建输出，提升了开发效率和应用性能。

**核心功能：**

- **用户交互：**
  - 允许用户输入问题或任务指令，并通过界面提交给 AI Agent。
  - 展示 AI Agent 返回的结果、解释或提出的澄清问题。
  - 提供必要的控件（如按钮、文本框等）供用户进行操作和响应。
  - 像IM一样保留对话记录，用List展示，用户可以查看历史对话。
- **WebSocket 通信：**
  - 通过 WebSocket 连接实时接收来自 `agentassistant-srv` 的广播消息（`BroadcastRequest`）。
  - 根据接收到的消息内容动态更新界面，例如显示新的请求、等待用户输入等。
  - 将用户的回应通过 SrvAgentAssistReply的相应方法 发送回 `agentassistant-srv`。

**工作流程：**

1. 当用户通过 打开 `agentassistant-srv` 的 Web 用户界面时，url 参数中必须包含 ?token=xxx，xxx为 `agentassistant-mcp` 的 token.
2. web 界面通过 WebSocket 连接 `agentassistant-srv`，并发送 `WebsocketMessage.UserLogin` 消息。
3. `agentassistant-srv` 接收到 `WebsocketMessage.UserLogin` 消息后，将用户登录状态存储在内存中。

4. 当 `agentassistant-mcp` 发起 `ask_question` 时，`agentassistant-srv` 会向 Web 界面发送 `WebsocketMessage.AskQuestion` 消息（包含 `AskQuestionRequest`）。
5. Web 界面接收到 `WebsocketMessage.AskQuestion` 消息后，将问题展示给用户。用户回复时，Web 界面将使用 RPC 调用 `agentassistant-srv` 的 `SrvAgentAssistReply.AskQuestionReply` 方法，并附带用户的回复内容。
6. `agentassistant-srv` 接收到来自 Web 界面的 `AskQuestionReply` 后，将此回复转发给相应的 `agentassistant-mcp`。
7. 当 `agentassistant-mcp` 发起 `task_finish` 时，`agentassistant-srv` 会向 Web 界面发送 `WebsocketMessage.TaskFinish` 消息（包含 `TaskFinishRequest`）。
8. Web 界面接收到 `WebsocketMessage.TaskFinish` 消息后，通常会向用户展示任务已完成的通知。如果 `TaskFinishRequest` 中表明需要用户确认或有进一步的简单交互，用户通过界面操作后，Web 界面将使用 RPC 调用 `agentassistant-srv` 的 `SrvAgentAssistReply.TaskFinishReply` 方法。
9. `agentassistant-srv` 接收到来自 Web 界面的 `TaskFinishReply` 后（如果发生），将此回复转发给相应的 `agentassistant-mcp`。
