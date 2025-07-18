package main

import (
	"context"
	_ "embed"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"runtime"

	"connectrpc.com/connect"
	"github.com/BurntSushi/toml"
	"github.com/google/uuid"
	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"
	"github.com/yangjuncode/agentassistant/agentassistproto"
)

//go:embed version.txt
var version string

// Config represents the configuration structure
type Config struct {
	AgentAssistantServerHost  string `toml:"agentassistant_server_host"`
	AgentAssistantServerPort  int    `toml:"agentassistant_server_port"`
	AgentAssistantServerToken string `toml:"agentassistant_server_token"`
}

// Global configuration
var config Config
var client agentassistproto.SrvAgentAssistClient

func main() {
	// Parse command line arguments
	var (
		host  = flag.String("host", "", "Agent Assistant server host")
		port  = flag.Int("port", 0, "Agent Assistant server port")
		token = flag.String("token", "", "Agent Assistant server token")
		web   = flag.Bool("web", false, "Open web interface in browser")
	)
	flag.Parse()

	// Load configuration from file
	loadConfig()

	// Override config with command line arguments if provided
	if *host != "" {
		config.AgentAssistantServerHost = *host
	}
	if *port != 0 {
		config.AgentAssistantServerPort = *port
	}
	if *token != "" {
		config.AgentAssistantServerToken = *token
	}

	// Set defaults if not configured
	if config.AgentAssistantServerHost == "" {
		config.AgentAssistantServerHost = "127.0.0.1"
	}
	if config.AgentAssistantServerPort == 0 {
		config.AgentAssistantServerPort = 8080
	}
	if config.AgentAssistantServerToken == "" {
		config.AgentAssistantServerToken = "test-token"
	}

	// Initialize RPC client
	httpClient := &http.Client{}
	serverURL := fmt.Sprintf("http://%s:%d", config.AgentAssistantServerHost, config.AgentAssistantServerPort)
	client = agentassistproto.NewSrvAgentAssistClient(
		httpClient,
		serverURL,
	)

	// Open web interface if requested
	if *web {
		webURL := fmt.Sprintf("http://%s:%d?token=%s", config.AgentAssistantServerHost, config.AgentAssistantServerPort, config.AgentAssistantServerToken)
		openBrowser(webURL)
		return
	}

	// Create a new MCP server
	s := server.NewMCPServer(
		"Agent Assistant ",
		version,
		server.WithToolCapabilities(false),
	)

	// ask_question tool
	tool := mcp.NewTool("ask_question",
		mcp.WithDescription(`
Ask a question to the Agent Assistant

This tool allows you to ask a question to the Agent Assistant. The Agent Assistant will then ask the user for feedback and return the result to you.

Args:
- project_directory: The current project directory
- question: The question to ask
- timeout: The timeout in seconds, default is 600s

Returns:
- List of TextContent, ImageContent, AudioContent, or EmbeddedResource from  Agent Assistant
`),
		//ProjectDirectory
		mcp.WithString("project_directory",
			mcp.Required(),
			mcp.Description("Current project directory"),
		),
		//question
		mcp.WithString("question",
			mcp.Required(),
			mcp.Description("AI agent's question"),
		),
		//timeout
		mcp.WithNumber("timeout",
			mcp.DefaultNumber(600),
			mcp.Description("Timeout in seconds, default is 600s"),
		),
	)

	taskFinishTool := mcp.NewTool("task_finish",
		mcp.WithDescription(`
Finish a task and ask for feedback from the Agent Assistant

This tool allows you to finish a task and ask for feedback from the Agent Assistant. The Agent Assistant will then ask the user for feedback and return the result to you.

Args:
- project_directory: The current project directory
- summary: The summary of the task
- timeout: The timeout in seconds, default is 600s

Returns:
- List of TextContent, ImageContent, AudioContent, or EmbeddedResource from  Agent Assistant
`),
		//ProjectDirectory
		mcp.WithString("project_directory",
			mcp.Required(),
			mcp.Description("Current project directory"),
		),
		//summary
		mcp.WithString("summary",
			mcp.Required(),
			mcp.Description("Summary of the task"),
		),
		//timeout
		mcp.WithNumber("timeout",
			mcp.DefaultNumber(600),
			mcp.Description("Timeout in seconds, default is 600s"),
		),
	)

	// Add tool handler
	s.AddTool(tool, askQuestionHandler)
	s.AddTool(taskFinishTool, taskFinishHandler)

	// Start the stdio server
	if err := server.ServeStdio(s); err != nil {
		fmt.Printf("Server error: %v\n", err)
	}
}

// loadConfig loads configuration from agentassistant-mcp.toml file
func loadConfig() {
	configFile := "agentassistant-mcp.toml"
	if _, err := os.Stat(configFile); err == nil {
		if _, err := toml.DecodeFile(configFile, &config); err != nil {
			log.Printf("Warning: Failed to load config file %s: %v", configFile, err)
		}
	}
}

// openBrowser opens the specified URL in the default browser
func openBrowser(url string) {
	var err error
	switch runtime.GOOS {
	case "linux":
		err = exec.Command("xdg-open", url).Start()
	case "windows":
		err = exec.Command("rundll32", "url.dll,FileProtocolHandler", url).Start()
	case "darwin":
		err = exec.Command("open", url).Start()
	default:
		err = fmt.Errorf("unsupported platform")
	}
	if err != nil {
		log.Printf("Failed to open browser: %v", err)
	}
}

// askQuestionHandler handles the ask_question tool
func askQuestionHandler(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	projectDirectory, err := request.RequireString("project_directory")
	if err != nil {
		return mcp.NewToolResultError(err.Error()), nil
	}

	question, err := request.RequireString("question")
	if err != nil {
		return mcp.NewToolResultError(err.Error()), nil
	}

	timeout, err := request.RequireInt("timeout")
	if err != nil {
		timeout = 600 // Default timeout
	}

	// Create RPC request
	req := &agentassistproto.AskQuestionRequest{
		ID:        generateRequestID(),
		UserToken: config.AgentAssistantServerToken,
		Request: &agentassistproto.McpAskQuestionRequest{
			ProjectDirectory: projectDirectory,
			Question:         question,
			Timeout:          int32(timeout),
		},
	}

	// Call the AskQuestion RPC
	resp, err := client.AskQuestion(context.Background(), connect.NewRequest(req))
	if err != nil {
		return mcp.NewToolResultError(fmt.Sprintf("RPC call failed: %v", err)), nil
	}

	// Convert response to MCP result
	return convertToMCPResult(resp.Msg), nil
}

// taskFinishHandler handles the task_finish tool
func taskFinishHandler(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	projectDirectory, err := request.RequireString("project_directory")
	if err != nil {
		return mcp.NewToolResultError(err.Error()), nil
	}

	summary, err := request.RequireString("summary")
	if err != nil {
		return mcp.NewToolResultError(err.Error()), nil
	}

	timeout, err := request.RequireInt("timeout")
	if err != nil {
		timeout = 600 // Default timeout
	}

	// Create RPC request
	req := &agentassistproto.TaskFinishRequest{
		ID:        generateRequestID(),
		UserToken: config.AgentAssistantServerToken,
		Request: &agentassistproto.McpTaskFinishRequest{
			ProjectDirectory: projectDirectory,
			Summary:          summary,
			Timeout:          int32(timeout),
		},
	}

	// Call the TaskFinish RPC
	resp, err := client.TaskFinish(context.Background(), connect.NewRequest(req))
	if err != nil {
		return mcp.NewToolResultError(fmt.Sprintf("RPC call failed: %v", err)), nil
	}

	// Convert response to MCP result
	return convertToMCPResult(resp.Msg), nil
}

// generateRequestID generates a unique request ID using UUID V7
func generateRequestID() string {
	return uuid.Must(uuid.NewV7()).String()
}

// convertToMCPResult converts an RPC response to MCP result
func convertToMCPResult(resp interface{}) *mcp.CallToolResult {
	var isError bool
	var contents []*agentassistproto.McpResultContent

	switch r := resp.(type) {
	case *agentassistproto.AskQuestionResponse:
		isError = r.IsError
		contents = r.Contents
	case *agentassistproto.TaskFinishResponse:
		isError = r.IsError
		contents = r.Contents
	default:
		return mcp.NewToolResultError("Unknown response type")
	}

	// Convert contents to MCP format
	var mcpContents []mcp.Content
	for _, content := range contents {
		switch content.Type {
		case 1: // Text content
			if content.Text != nil {
				mcpContents = append(mcpContents, mcp.NewTextContent(content.Text.Text))
			}
		case 2: // Image content
			if content.Image != nil {
				mcpContents = append(mcpContents, mcp.NewImageContent(content.Image.Data, content.Image.MimeType))
			}
		case 3: // Audio content
			if content.Audio != nil {
				// MCP doesn't have direct audio support, convert to text description
				mcpContents = append(mcpContents, mcp.NewTextContent(fmt.Sprintf("Audio content: %s", content.Audio.MimeType)))
			}
		case 4: // Embedded resource
			if content.EmbeddedResource != nil {
				mcpContents = append(mcpContents, mcp.NewTextContent(fmt.Sprintf("Resource: %s", content.EmbeddedResource.Uri)))
			}
		}
	}

	if isError {
		return &mcp.CallToolResult{
			Content: mcpContents,
			IsError: true,
		}
	}

	// if len(mcpContents) == 0 {
	// 	mcpContents = append(mcpContents, mcp.NewTextContent("Request completed successfully"))
	// }

	// Create a tool result with the contents
	result := &mcp.CallToolResult{
		Content: mcpContents,
	}
	return result
}
