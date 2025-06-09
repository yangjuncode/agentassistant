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
- **@connectrpc/connect-web** web界面使用的connectrpc库

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
5. Web 界面接收到 `WebsocketMessage.AskQuestion` 消息后，将问题展示给用户。用户回复时，Web 界面将使用 websocket 发送 `agentassistant-srv` 的 `WebsocketMessage.cmd=AskQuestionReply` 消息 ，并附带用户的回复内容。
6. `agentassistant-srv` 接收到来自 Web 界面的 `WebsocketMessage.cmd=AskQuestionReply` 后，将此回复转发给相应的 `agentassistant-mcp`。
7. 当 `agentassistant-mcp` 发起 `task_finish` 时，`agentassistant-srv` 会向 Web 界面发送 `WebsocketMessage.TaskFinish` 消息（包含 `TaskFinishRequest`）。
8. Web 界面接收到 `WebsocketMessage.TaskFinish` 消息后，通常会向用户展示任务已完成的通知。如果 `TaskFinishRequest` 中表明需要用户确认或有进一步的简单交互，用户通过界面操作后，Web 界面将使用 websocket 发送 `agentassistant-srv`  `WebsocketMessage.cmd=TaskFinishReply` 消息。
9. `agentassistant-srv` 接收到来自 Web 界面的 `TaskFinishReply` 后（如果发生），将此回复转发给相应的 `agentassistant-mcp`。

## WebSocket 通信协议详细规范

### WebSocket 消息结构

所有 WebSocket 通信都使用 protobuf 定义的 `WebsocketMessage` 结构：

```protobuf
message WebsocketMessage {
  string Cmd = 1;                                    // 命令类型
  AskQuestionRequest AskQuestionRequest = 2;         // 问题请求
  TaskFinishRequest TaskFinishRequest = 3;           // 任务完成请求
  AskQuestionResponse AskQuestionResponse = 4;       // 问题回复
  TaskFinishResponse TaskFinishResponse = 5;         // 任务完成回复
  string StrParam = 12;                              // 字符串参数
}
```

### 支持的命令类型

#### 1. UserLogin - 用户登录

**用途：** 客户端连接 WebSocket 后进行身份验证

**消息结构：**

```protobuf
WebsocketMessage {
  Cmd = "UserLogin"
  StrParam = "<用户令牌>"
}
```

**使用场景：**

- Web 界面建立 WebSocket 连接后立即发送
- 服务器验证令牌并存储用户登录状态
- 只有通过验证的客户端才能接收后续的广播消息

#### 2. AskQuestion - AI 代理提问

**用途：** `agentassistant-mcp` 通过 `agentassistant-srv` 向用户提问

**消息结构：**

```protobuf
WebsocketMessage {
  Cmd = "AskQuestion"
  AskQuestionRequest = {
    ID = "<请求唯一标识符>"
    UserToken = "<用户令牌>"
    Request = {
      ProjectDirectory = "<项目目录路径>"
      Question = "<AI 代理的问题内容>"
      Timeout = <超时时间（秒）>
    }
  }
}
```

**工作流程：**

1. `agentassistant-mcp` 调用 `ask_question` 工具
2. `agentassistant-srv` 接收 RPC 请求并转换为 WebSocket 消息
3. 消息广播给所有匹配令牌的已连接客户端
4. Web 界面展示问题并等待用户回复

#### 3. AskQuestionReply - 用户问题回复

**用途：** 用户通过 Web 界面回复 AI 代理的问题

**消息结构：**

```protobuf
WebsocketMessage {
  Cmd = "AskQuestionReply"
  AskQuestionRequest = {
    ID = "<原始请求的唯一标识符>"
    UserToken = "<用户令牌>"
    Request = {
      ProjectDirectory = "<项目目录路径>"
      Question = "<原始问题内容>"
      Timeout = <超时时间（秒）>
    }
  }
  AskQuestionResponse = {
    ID = "<请求唯一标识符>"
    IsError = <是否为错误响应>
    Meta = {<元数据键值对>}
    Contents = [<回复内容列表>]
  }
}
```

**工作流程：**

1. 用户在 Web 界面中输入回复内容
2. Web 界面发送 `AskQuestionReply` 消息
3. `agentassistant-srv` 处理回复并转发给对应的 `agentassistant-mcp`
4. 同时触发 `AskQuestionReplyNotification` 通知其他客户端

#### 4. TaskFinish - 任务完成通知

**用途：** `agentassistant-mcp` 通知用户任务已完成

**消息结构：**

```protobuf
WebsocketMessage {
  Cmd = "TaskFinish"
  TaskFinishRequest = {
    ID = "<请求唯一标识符>"
    UserToken = "<用户令牌>"
    Request = {
      ProjectDirectory = "<项目目录路径>"
      Summary = "<任务完成摘要>"
      Timeout = <超时时间（秒）>
    }
  }
}
```

**工作流程：**

1. `agentassistant-mcp` 调用 `task_finish` 工具
2. `agentassistant-srv` 接收 RPC 请求并转换为 WebSocket 消息
3. 消息广播给所有匹配令牌的已连接客户端
4. Web 界面展示任务完成通知

#### 5. TaskFinishReply - 任务完成确认

**用途：** 用户确认任务完成或提供反馈

**消息结构：**

```protobuf
WebsocketMessage {
  Cmd = "TaskFinishReply"
  TaskFinishRequest = {
    ID = "<原始请求的唯一标识符>"
    UserToken = "<用户令牌>"
    Request = {
      ProjectDirectory = "<项目目录路径>"
      Summary = "<原始任务摘要>"
      Timeout = <超时时间（秒）>
    }
  }
  TaskFinishResponse = {
    ID = "<请求唯一标识符>"
    IsError = <是否为错误响应>
    Meta = {<元数据键值对>}
    Contents = [<确认内容列表>]
  }
}
```

**工作流程：**

1. 用户在 Web 界面中确认任务完成或提供反馈
2. Web 界面发送 `TaskFinishReply` 消息
3. `agentassistant-srv` 处理回复并转发给对应的 `agentassistant-mcp`
4. 同时触发 `TaskFinishReplyNotification` 通知其他客户端

#### 6. AskQuestionReplyNotification - 问题回复通知

**用途：** 通知所有其他已连接的客户端有用户已回复了某个问题

**消息结构：**

```protobuf
WebsocketMessage {
  Cmd = "AskQuestionReplyNotification"
  AskQuestionRequest = {
    ID = "<原始请求的唯一标识符>"
    UserToken = "<用户令牌>"
    Request = {
      ProjectDirectory = "<项目目录路径>"
      Question = "<原始问题内容>"
      Timeout = <超时时间（秒）>
    }
  }
  AskQuestionResponse = {
    ID = "<请求唯一标识符>"
    IsError = <是否为错误响应>
    Meta = {<元数据键值对>}
    Contents = [<回复内容列表>]
  }
  StrParam = "Response received from client <客户端ID>"
}
```

**功能特性：**

- **协作感知：** 在多用户环境中，当一个用户回复问题时，其他用户能够实时看到有人已经回复
- **避免重复工作：** 防止多个用户同时回复同一个问题
- **实时同步：** 所有客户端的界面状态保持同步

**工作流程：**

1. 客户端 A 发送 `AskQuestionReply` 消息
2. `agentassistant-srv` 处理该回复
3. 服务器自动生成 `AskQuestionReplyNotification` 消息
4. 该通知广播给除客户端 A 之外的所有其他已连接客户端
5. 其他客户端接收通知并更新界面状态（如标记问题已被回复）

**使用示例：**

```javascript
// Web 客户端处理通知
websocket.onmessage = (event) => {
  const message = parseProtobufMessage(event.data);

  if (message.cmd === 'AskQuestionReplyNotification') {
    // 更新界面显示该问题已被其他用户回复
    updateQuestionStatus(message.askQuestionRequest.ID, 'answered');
    showNotification(`问题已被其他用户回复: ${message.strParam}`);
  }
};
```

#### 7. TaskFinishReplyNotification - 任务完成回复通知

**用途：** 通知所有其他已连接的客户端有用户已确认了某个任务完成

**消息结构：**

```protobuf
WebsocketMessage {
  Cmd = "TaskFinishReplyNotification"
  TaskFinishRequest = {
    ID = "<原始请求的唯一标识符>"
    UserToken = "<用户令牌>"
    Request = {
      ProjectDirectory = "<项目目录路径>"
      Summary = "<原始任务摘要>"
      Timeout = <超时时间（秒）>
    }
  }
  TaskFinishResponse = {
    ID = "<请求唯一标识符>"
    IsError = <是否为错误响应>
    Meta = {<元数据键值对>}
    Contents = [<确认内容列表>]
  }
  StrParam = "Task completion confirmed by client <客户端ID>"
}
```

**功能特性：**

- **状态同步：** 确保所有用户看到相同的任务完成状态
- **协作透明度：** 让团队成员了解谁确认了任务完成
- **避免重复确认：** 防止多个用户重复确认同一个任务

**工作流程：**

1. 客户端 A 发送 `TaskFinishReply` 消息确认任务完成
2. `agentassistant-srv` 处理该确认
3. 服务器自动生成 `TaskFinishReplyNotification` 消息
4. 该通知广播给除客户端 A 之外的所有其他已连接客户端
5. 其他客户端接收通知并更新界面状态（如标记任务已被确认）

**使用示例：**

```javascript
// Web 客户端处理通知
websocket.onmessage = (event) => {
  const message = parseProtobufMessage(event.data);

  if (message.cmd === 'TaskFinishReplyNotification') {
    // 更新界面显示该任务已被其他用户确认
    updateTaskStatus(message.taskFinishRequest.ID, 'confirmed');
    showNotification(`任务完成已被确认: ${message.strParam}`);
  }
};
```

### 错误处理

**连接错误：**

- 如果 WebSocket 连接失败，客户端应实现重连机制
- 重连时需要重新发送 `UserLogin` 消息进行身份验证

**超时处理：**

- 所有请求都有超时时间限制（默认 600 秒）
- 超时后服务器会自动清理待处理的请求
- 客户端应处理超时情况并提供适当的用户反馈

**消息格式错误：**

- 如果接收到格式不正确的 protobuf 消息，服务器会记录错误并忽略该消息
- 客户端应确保发送的消息符合 protobuf 规范

