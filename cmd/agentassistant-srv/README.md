# Agent Assistant Server

The `agentassistant-srv` is the core service component of the Agent Assistant system, implementing the `SrvAgentAssist` service using Connect-Go RPC framework.

## Features

- **Connect-Go RPC Server**: Implements the `SrvAgentAssist` service with `AskQuestion` and `TaskFinish` methods
- **WebSocket Support**: Real-time communication with web clients for user interaction
- **Content Type Support**: Handles TextContent, ImageContent, AudioContent, and EmbeddedResource
- **Timeout Management**: Configurable timeouts with 600-second default
- **Broadcasting**: Distributes requests to all connected web clients
- **Error Handling**: Comprehensive error responses with metadata

## API Endpoints

### RPC Methods

#### AskQuestion
- **Path**: `/agentassistproto.SrvAgentAssist/AskQuestion`
- **Purpose**: AI agent asks a question and waits for user feedback
- **Request**: `AskQuestionRequest`
  - `ProjectDirectory`: Current project directory
  - `Question`: Question to ask the user
  - `Timeout`: Timeout in seconds (default: 600)
- **Response**: `AskQuestionResponse`
  - `IsError`: Whether an error occurred
  - `Meta`: Error metadata or additional information
  - `Contents`: Array of `McpResultContent` with user responses

#### TaskFinish
- **Path**: `/agentassistproto.SrvAgentAssist/TaskFinish`
- **Purpose**: AI agent reports task completion and requests confirmation
- **Request**: `TaskFinishRequest`
  - `ProjectDirectory`: Current project directory
  - `Summary`: Task completion summary
  - `Timeout`: Timeout in seconds (default: 600)
- **Response**: `TaskFinishResponse`
  - `IsError`: Whether an error occurred
  - `Meta`: Error metadata or additional information
  - `Contents`: Array of `McpResultContent` with user responses

### WebSocket Endpoint

#### /ws
- **Purpose**: WebSocket connection for web clients
- **Protocol**: JSON message exchange
- **Message Types**:
  - `request`: Server sends requests to web clients
  - `response`: Web clients send responses back
  - `ping`/`pong`: Keep-alive mechanism

### Health Check

#### /health
- **Method**: GET
- **Purpose**: Health check endpoint
- **Response**: "OK" with 200 status

## Content Types

The service supports four types of content in responses:

1. **TextContent** (Type: 1)
   - Plain text responses
   - Fields: `type`, `text`

2. **ImageContent** (Type: 2)
   - Base64-encoded images
   - Fields: `type`, `data`, `mime_type`
   - Supported MIME types: image/jpeg, image/png, image/gif, etc.

3. **AudioContent** (Type: 3)
   - Base64-encoded audio
   - Fields: `type`, `data`, `mime_type`
   - Supported MIME types: audio/mpeg, audio/wav, audio/ogg, etc.

4. **EmbeddedResource** (Type: 4)
   - Resource references with optional data
   - Fields: `type`, `uri`, `mime_type`, `data`

## Usage

### Starting the Server

```bash
go run ./cmd/agentassistant-srv
```

The server will start on port 8080 with the following endpoints:
- RPC: `http://localhost:8080/agentassistproto.SrvAgentAssist/`
- WebSocket: `ws://localhost:8080/ws`
- Health: `http://localhost:8080/health`

### Using the RPC Client

```go
package main

import (
    "context"
    "net/http"
    "connectrpc.com/connect"
    "github.com/yangjuncode/agentassistant"
    "github.com/yangjuncode/agentassistant/agentassistantconnect"
)

func main() {
    client := agentassistantconnect.NewSrvAgentAssistClient(
        http.DefaultClient,
        "http://localhost:8080",
    )

    req := connect.NewRequest(&agentassistant.AskQuestionRequest{
        ProjectDirectory: "/my/project",
        Question:         "Should I proceed?",
        Timeout:          30,
    })

    resp, err := client.AskQuestion(context.Background(), req)
    // Handle response...
}
```

### Web Client Integration

Connect to the WebSocket endpoint at `ws://localhost:8080/ws` and handle JSON messages:

```javascript
const ws = new WebSocket('ws://localhost:8080/ws');

ws.onmessage = function(event) {
    const message = JSON.parse(event.data);
    if (message.type === 'request') {
        // Handle request from AI agent
        const request = message.payload;
        console.log('Question:', request.question);
        
        // Send response
        const response = {
            type: 'response',
            payload: {
                id: request.id,
                is_error: false,
                contents: [{
                    type: 1,
                    text: { type: 'text', text: 'Yes, proceed!' }
                }]
            }
        };
        ws.send(JSON.stringify(response));
    }
};
```

## Error Handling

The service returns structured error responses:

- **no_clients**: No web clients available to handle requests
- **timeout**: Request timed out waiting for user response
- **invalid_content**: Invalid content format in response
- **user_error**: User-reported error

## Configuration

Environment variables and configuration options:

- **Port**: Default 8080 (configurable via code)
- **CORS**: Enabled for all origins (development mode)
- **Timeouts**: Default 600 seconds, configurable per request

## Development

### Running Tests

```bash
go test ./internal/service
```

### Building

```bash
go build ./cmd/agentassistant-srv
```

### Example Client

See `examples/client/main.go` for a complete RPC client example.

### Example Web Client

See `examples/webclient/index.html` for a web interface example.

## Architecture

The service consists of:

1. **Main Server**: HTTP/2 server with Connect-Go handlers
2. **Service Layer**: Business logic for RPC methods
3. **Broadcaster**: Manages web client connections and message routing
4. **WebSocket Handler**: Real-time communication with web clients
5. **Content Utilities**: Validation and creation of content types

## Security Considerations

- CORS is currently open for development
- No authentication implemented (add as needed)
- WebSocket connections accept all origins
- Input validation on content types and formats
