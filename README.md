# Agent Assistant

Agent Assistant is a system that allows AI agents to interact with human users through a web interface. It consists of three main components:

1. **agentassistant-srv**: The main server that handles RPC requests and serves the web interface
2. **agentassistant-mcp**: An MCP (Model Context Protocol) server that provides tools for AI agents
3. **Web Interface**: A modern React-based web application for user interaction

## Architecture

```
AI Agent (Claude, etc.)
    ↓ (MCP Protocol)
agentassistant-mcp
    ↓ (Connect-Go RPC)
agentassistant-srv
    ↓ (WebSocket)
Web Interface (User)
```

## Features

- **MCP Integration**: Provides `ask_question` and `work_report` tools for AI agents
- **Real-time Communication**: WebSocket-based communication between server and web interface
- **Modern Web UI**: React-based interface with Shadcn/ui components
- **Token-based Authentication**: Simple token-based authentication system
- **Cross-platform**: Works on Linux, macOS, and Windows

## Quick Start

### 1. Build the Components

```bash
# Build the server
go build -o agentassistant-srv ./cmd/agentassistant-srv

# Build the MCP server
go build -o agentassistant-mcp ./cmd/agentassistant-mcp
```

### 2. Start the Server

```bash
./agentassistant-srv
```

The server will start on port 8080 and serve:
- Web interface at `http://localhost:8080`
- WebSocket endpoint at `ws://localhost:8080/ws`
- RPC endpoints for Connect-Go

### 3. Configure and Start MCP Server

Edit `agentassistant-mcp.toml`:
```toml
agentassistant_server_host = "127.0.0.1"
agentassistant_server_port = 8080
agentassistant_server_token = "test-token"
```

Start the MCP server:
```bash
./agentassistant-mcp
```

### 4. Access the Web Interface

Open your browser and go to:
```
http://localhost:8080?token=test-token
```

## Development

### Building the Web Interface

The web interface is a React application located in the `web/` directory.

```bash
cd web
npm install
npm run build
```

The built files will be placed in `web/dist/` and automatically served by the server.

For development:
```bash
cd web
npm run dev
```

### Running Tests

```bash
go test ./...
```

## Configuration

### MCP Server Configuration

Create `agentassistant-mcp.toml`:
```toml
agentassistant_server_host = "127.0.0.1"
agentassistant_server_port = 8080
agentassistant_server_token = "your-token-here"
```

### Command Line Options

MCP Server:
```bash
./agentassistant-mcp -host localhost -port 8080 -token your-token -web
```

- `-host`: Server host (default: 127.0.0.1)
- `-port`: Server port (default: 8080)
- `-token`: Authentication token (default: test-token)
- `-web`: Open web interface in browser

## API Reference

### MCP Tools

#### ask_question
Ask a question to the user through the web interface.

**Parameters:**
- `project_directory` (string): Current project directory
- `question` (string): Question to ask the user
- `timeout` (number): Timeout in seconds (default: 600)

#### work_report
Notify the user that a task has been completed and send a work report.

**Parameters:**
- `project_directory` (string): Current project directory
- `summary` (string): Summary of the completed task / work report
- `timeout` (number): Timeout in seconds (default: 600)

### RPC Services

#### SrvAgentAssist
- `AskQuestion(AskQuestionRequest) returns (AskQuestionResponse)`
- `WorkReport(WorkReportRequest) returns (WorkReportResponse)`

## MCP Agent Assistant Interaction Rules

1. During any process, task, or dialogue, whether it's for inquiries, responses, or completing phased tasks, the corresponding MCP tools must be called:
    - Use the `ask_question` tool when user feedback is needed.
    - Use the `work_report` tool when a task is completed.
2. Whenever user feedback is received, if the feedback content is not empty, behavior must be adjusted according to the feedback, and the corresponding tools should be called again if necessary.
3. Only when the user explicitly states "end" or "no further interaction needed" can the calling of MCP tools be stopped, and the process is considered complete.
4. Unless an end instruction is received, all key steps must be confirmed with the user through MCP tools.
5. Before completing a task, the `work_report` tool must be used to report the task completion status to the user and request confirmation.
6. When calling tools, ensure the correct `project_directory` parameter is provided to maintain contextual accuracy.

中文提示词

```markdown
1. **重要**：在任何的任务、对话中，如果你有需要澄清的问题/需求/细节/疑问，必须使用 Agent-Assistant 的 `ask_question` 工具来询问用户,根据用户反馈调整你的行为，继续处理。
2. **重要**：在任何的任务、对话中，在任务/对话完成前，必须使用 Agent-Assistant 的 `work_report` 工具来报告任务完成状态给用户，请求确认，得到用户的反馈后，如果不是明确的结束指令，则必须根据反馈内容调整你的行为，继续处理。
3. **重要**：调用 MCP 工具 Agent-Assistant 时，必须提供正确的 `project_directory` 参数，以确保上下文准确性。
```

英文提示词

```markdown
1. **Important**：In any task or conversation, if you have any questions, requirements, or doubts, you must use the `ask_question` tool of Agent-Assistant to ask the user. Based on the user's feedback, adjust your behavior and continue processing.
2. **Important**：In any task or conversation, before the task or conversation is completed, you must use the `work_report` tool of Agent-Assistant to report the task completion status to the user and request confirmation. After receiving the user's feedback, if it is not a clear end instruction, you must adjust your behavior based on the feedback content and continue processing.
3. **Important**：When calling the MCP tool of Agent-Assistant, you must provide the correct `project_directory` parameter to ensure contextual accuracy.
```

## License

This project is licensed under the MIT License.
