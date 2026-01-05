# Project Context

## Purpose

Agent Assistant 是一个让 AI 代理（如 Claude、Cascade 等）通过 Web 或桌面界面与人类用户互动的系统。它主要包含三类组件：

1. **agentassistant-srv**：核心服务端，提供 ConnectRPC（gRPC over HTTP/2 语义）接口，并承载 WebSocket 与静态资源服务。
2. **agentassistant-mcp**：MCP（Model Context Protocol）服务器，为 AI 代理提供 `ask_question`、`work_report` 等工具，并通过 ConnectRPC 调用 `agentassistant-srv`。
3. **客户端**：用于人机交互的 Web 界面（Vue3 + Quasar）以及 Flutter 客户端（支持桌面/移动）。

系统目标是把“人类反馈”引入 AI 的执行回路（human-in-the-loop），并保证交互内容可被结构化传递（文本/图片/音频/资源）。

## Tech Stack（以仓库实现为准）

- **后端（Go）**
  - Go：`go.mod` 当前为 `go 1.24.3`
  - RPC：ConnectRPC / Connect-Go（`connectrpc.com/connect`）
  - WebSocket：Gorilla WebSocket（服务端实现为 **Protobuf 二进制帧**）
  - MCP：`github.com/mark3labs/mcp-go`

- **前端（Web）**
  - Vue 3 + Quasar + TypeScript
  - 状态管理：Pinia
  - Protobuf：protobuf-es（`@bufbuild/protobuf`）

- **前端（Flutter）**
  - Flutter（Dart SDK `^3.5.0`）
  - 状态管理：Provider
  - 通信：WebSocket（`web_socket_channel`）
  - 本地存储：SharedPreferences + SQLite（sqflite）
  - 桌面能力：window_manager、tray_manager、剪贴板/拖拽等

- **协议/序列化**
  - Protobuf：定义于 `proto/agentassist.proto`
  - ConnectRPC：服务 `SrvAgentAssist`，包含 `AskQuestion` 与 `WorkReport`
  - WebSocket：统一消息 `WebsocketMessage`（`Cmd` 字段区分消息类型）
  - 多模态：`McpResultContent` + `TextContent/ImageContent/AudioContent/EmbeddedResource`

- **数据存储（规划）**
  - Protodb：当前代码中未见明确使用，可作为后续数据层演进方向（规划/预留）。

## Repository Layout（关键目录）

- `cmd/agentassistant-srv/`：服务端入口（HTTP/2 + ConnectRPC + WebSocket + 静态文件）
- `cmd/agentassistant-mcp/`：MCP 服务入口（CLI + TOML 配置 + RPC client）
- `cmd/agentassistant-input/`：输入注入工具（CLI），通过 `robotgo` 将指定字符串模拟键盘输入到当前焦点窗口（支持 `-input` 明文与 `-input64` base64）。
- `internal/service/`：服务端核心逻辑（Broadcaster、WebSocket handler、RPC handler 等）
- `proto/`：Protobuf 定义
- `agentassistproto/`：Go 侧生成代码（protoc + connect-go）
- `web/`：Web 前端（Vue/Quasar）
- `flutterclient/`：Flutter 客户端
- `www/`：Web 构建产物与（或）嵌入式静态资源

## Runtime & Configuration

### Ports / Endpoints

- **agentassistant-srv**
  - 监听端口来自 `agentassistant-mcp.toml` 的 `agentassistant_server_port`
  - **默认端口：2000**（配置缺省时）
  - WebSocket：`/ws`
  - Health：`/health`
  - 静态资源：`/`（优先 `www/dist`，否则使用 `www` 包内嵌资源）

- **agentassistant-mcp**
  - 通过 TOML / CLI 参数配置要连接的 srv：`host` / `port` / `token`
  - `-web` 参数会拼接 `http://{host}:{port}?token={token}` 打开浏览器

- **agentassistant-input**
  - CLI 参数：二选一
    - `-input`：明文字符串
    - `-input64`：base64 编码字符串（用于避免 shell 转义或传输特殊字符）
  - 行为：向当前系统焦点窗口模拟键盘输入（用于辅助把内容“输入到其它应用”）

### Token 的定位（重要约定）

系统里的 `token` 同时承担两类作用：

1. **会话分组/路由**：srv 端会按 token 将消息广播到相同 token 的在线客户端（见 Broadcaster 的 token filter）。
2. **简单访问控制信号**：客户端登录时会发送 `UserLogin`（`StrParam=token`），srv 用 token 作为“是否属于同一组/是否应收到消息”的判断依据。

注意：当前实现不等同于严格的安全鉴权体系（无签名/过期/权限模型）。若未来需要安全增强，应在此处补充：token 生命周期、签名校验、TLS、来源限制等。

## Project Conventions

### Code Style

- **Go**：`gofmt` 为准，尽量保持惯用写法（errors wrapping、context 传递、清晰的日志）。
- **Dart/Flutter**：`dart format`，遵循 `flutter_lints`（见 `analysis_options.yaml`）。
- **Web（Vue/TS）**：ESLint + Prettier（见 `web/package.json` 的 `lint` / `format`）。
- **Protobuf**：`proto/agentassist.proto` 为单一权威来源；字段命名与兼容性遵循 Buf 的 lint/breaking 规则（仓库含 `buf.yaml`）。

### Protobuf / Code Generation

以 `Makefile` 的 `proto-gen` 为标准流程：

- Go：`protoc -Iproto --go_out=... --connect-go_out=... proto/agentassist.proto`
- Web：`cd web && pnpm run proto:gen`
- Flutter：`cd flutterclient && ./generate_proto.sh`

仓库同时提供 `buf.yaml/buf.gen.yaml` 用于 lint/breaking 与可选生成链路；若团队统一采用 Buf 生成，请在此处补充“唯一入口命令”以避免双轨不一致。

### Architecture Patterns

- **Srv（HTTP/2 + h2c）**：ConnectRPC 走 HTTP/2 语义（h2c），WebSocket 走 `/ws`。
- **WebSocket 消息格式**：服务端/客户端使用 Protobuf `WebsocketMessage` 进行二进制传输（客户端需设置 `binaryType` 并用 protobuf-es 解析）。
- **Broadcaster**：
  - 维护在线客户端与 pending request
  - 按 token 过滤广播
  - 支持超时取消与“已取消通知”（`RequestCancelled`）
  - 支持“在线用户列表/待处理消息/用户聊天”等扩展消息

### Testing Strategy

- **Go**：`go test ./...`（仓库含针对 `internal/service` 的测试）。
- **脚本测试**：根目录存在多个端到端脚本（如 `test_chat_feature.sh`、`test_window_popup.sh` 等），用于回归关键交互链路。
- **Web/Flutter**：遵循各自生态的 lint/test 命令（Web 的 test 当前为占位；Flutter 支持 `flutter test`）。

### Git Workflow

- 建议使用“按功能分支开发”流程：一个功能/修复一个分支。
- 提交信息要求清晰可追溯（建议包含模块前缀，例如 `srv:` / `mcp:` / `web:` / `flutter:` / `proto:`）。

## Domain Context（你在写规格/实现时需要牢记）

- **Human-in-the-loop**：用户反馈是 AI 执行链路的一部分，不可被默默忽略。
- **Context Management**：MCP 工具必须携带准确的 `project_directory`；`agent_name` 与 `reasoning_model_name` 必填。
- **Request 生命周期**：AskQuestion/WorkReport 都有 timeout；超时会触发取消通知与错误返回。

## Important Constraints

- 跨平台：Linux/Windows/macOS（尤其桌面端能力差异）。
- 兼容性：Protobuf 变更需考虑向后兼容（建议通过 Buf breaking 检查约束）。
- 安全：当前 token 机制偏轻量，生产环境需明确安全边界（TLS、来源限制、token 策略）。

## External Dependencies

- 外部 AI 模型（由 AI 代理侧调用，不在本仓库内实现）。
- 操作系统能力（通知、剪贴板、窗口管理、托盘等）。
