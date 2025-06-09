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

- **MCP Integration**: Provides `ask_question` and `task_finish` tools for AI agents
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

#### task_finish
Notify the user that a task has been completed.

**Parameters:**
- `project_directory` (string): Current project directory
- `summary` (string): Summary of the completed task
- `timeout` (number): Timeout in seconds (default: 600)

### RPC Services

#### SrvAgentAssist
- `AskQuestion(AskQuestionRequest) returns (AskQuestionResponse)`
- `TaskFinish(TaskFinishRequest) returns (TaskFinishResponse)`

## License

This project is licensed under the MIT License.
