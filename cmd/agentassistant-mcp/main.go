package main

import (
	"context"
	_ "embed"
	"encoding/base64"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"runtime"
	"strings"
	"sync/atomic"

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

type cachedMcpClientInfo struct {
	ProtocolVersion  string
	CapabilitiesJson string
	ClientName       string
	ClientVersion    string
}

func cacheMcpClientInfo(params mcp.InitializeParams) {
	capabilitiesBytes, err := json.Marshal(params.Capabilities)
	if err != nil {
		log.Printf("Failed to marshal MCP capabilities: %v", err)
		capabilitiesBytes = []byte("{}")
	}

	info := &cachedMcpClientInfo{
		ProtocolVersion:  params.ProtocolVersion,
		CapabilitiesJson: string(capabilitiesBytes),
		ClientName:       params.ClientInfo.Name,
		ClientVersion:    params.ClientInfo.Version,
	}

	mcpClientInfo.Store(info)
}

//func ensureMcpClientInfoSent() {
//	if mcpClientInfoSent.Load() {
//		return
//	}
//
//	value := mcpClientInfo.Load()
//	info, ok := value.(*cachedMcpClientInfo)
//	if !ok || info == nil {
//		return
//	}
//
//	req := &agentassistproto.McpClientInfoRequest{
//		ID:        generateRequestID(),
//		UserToken: config.AgentAssistantServerToken,
//		Request: &agentassistproto.McpClientInfoData{
//			ProtocolVersion:  info.ProtocolVersion,
//			CapabilitiesJson: info.CapabilitiesJson,
//			ClientName:       info.ClientName,
//			ClientVersion:    info.ClientVersion,
//		},
//		Timestamp: time.Now().UnixMilli(),
//	}
//
//	if _, err := client.SendMcpClientInfo(context.Background(), connect.NewRequest(req)); err != nil {
//		log.Printf("Failed to send MCP client info: %v", err)
//		return
//	}
//
//	log.Printf("Sent MCP client info for %s (%s)", info.ClientName, info.ClientVersion)
//	mcpClientInfoSent.Store(true)
//}

// Global configuration
var config Config
var client agentassistproto.SrvAgentAssistClient

var mcpClientName atomic.Value
var mcpClientInfo atomic.Value
var mcpClientInfoSent atomic.Bool

func main() {
	// Parse command line arguments
	var (
		host               = flag.String("host", "", "Agent Assistant server host")
		port               = flag.Int("port", 0, "Agent Assistant server port")
		token              = flag.String("token", "", "Agent Assistant server token")
		web                = flag.Bool("web", false, "Open web interface in browser")
		disableWorkReport  = flag.Bool("disable-workreport", false, "Hide the work_report MCP tool")
		disableAskQuestion = flag.Bool("disable-ask-question", false, "Hide the ask_question MCP tool")
	)
	flag.Parse()

	toolVisibility := toolVisibilityConfig{
		DisableAskQuestion: *disableAskQuestion,
		DisableWorkReport:  *disableWorkReport,
	}
	if err := toolVisibility.validate(); err != nil {
		log.Fatalf("Invalid tool visibility configuration: %v", err)
	}

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
		connect.WithReadMaxBytes(50*1024*1024),
	)

	// Open web interface if requested
	if *web {
		webURL := fmt.Sprintf("http://%s:%d?token=%s", config.AgentAssistantServerHost, config.AgentAssistantServerPort, config.AgentAssistantServerToken)
		openBrowser(webURL)
		return
	}

	// Create a new MCP server
	hooks := &server.Hooks{}
	hooks.AddAfterInitialize(func(ctx context.Context, id any, message *mcp.InitializeRequest, result *mcp.InitializeResult) {
		mcpClientName.Store(message.Params.ClientInfo.Name)
		cacheMcpClientInfo(message.Params)
		//go ensureMcpClientInfoSent()
	})

	s := server.NewMCPServer(
		"Agent-Assistant ",
		version,
		server.WithToolCapabilities(false),
		server.WithHooks(hooks),
	)

	if err := registerEnabledTools(s, toolVisibility); err != nil {
		log.Fatalf("Failed to register MCP tools: %v", err)
	}

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

type OptionInput struct {
	Label       string `json:"label"`
	Description string `json:"description"`
}
type QuestionInput struct {
	Question string        `json:"question"`
	Header   string        `json:"header"`
	Options  []OptionInput `json:"options"`
	Multiple bool          `json:"multiple"`
	Custom   *bool         `json:"custom"` // Pointer for optional
}
type AskQuestionInput struct {
	ProjectDirectory   string          `json:"project_directory"`
	Questions          []QuestionInput `json:"questions"`
	Timeout            int             `json:"timeout"`
	AgentName          string          `json:"agent_name"`
	ReasoningModelName string          `json:"reasoning_model_name"`
}

// askQuestionHandler handles the ask_question tool
func askQuestionHandler(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	// Cast arguments to map for initial access
	args, _ := request.Params.Arguments.(map[string]interface{})

	// Parse arguments using JSON unmarshal to handle complex structure
	jsonBytes, err := json.Marshal(request.Params.Arguments)
	if err != nil {
		log.Printf("Warning: Failed to marshal arguments: %v", err)
		// If marshal fails, we can still proceed with what we have in args map
		jsonBytes = []byte("{}")
	}

	var input AskQuestionInput
	// Set defaults
	input.Timeout = 3600

	// Try to unmarshal. If it fails, we will rely on manual extraction below
	if err := json.Unmarshal(jsonBytes, &input); err != nil {
		log.Printf("Warning: Failed to unmarshal ask_question arguments: %v", err)
	}

	// Fallback/validation logic for essential fields
	if input.ProjectDirectory == "" && args != nil {
		if v, ok := args["project_directory"].(string); ok {
			input.ProjectDirectory = v
		}
	}
	if input.AgentName == "" && args != nil {
		if v, ok := args["agent_name"].(string); ok {
			input.AgentName = v
		}
	}
	if input.ReasoningModelName == "" && args != nil {
		if v, ok := args["reasoning_model_name"].(string); ok {
			input.ReasoningModelName = v
		}
	}

	// If no questions are provided or parsing failed to find them, treat the whole thing as a legacy question
	// Use the original JSON string to ensure no content is lost
	if len(input.Questions) == 0 {
		legacyText := string(jsonBytes)
		if legacyText == "" || legacyText == "{}" {
			if args != nil {
				// Fallback to fmt.Sprintf if json marshal failed or returned empty
				legacyText = fmt.Sprintf("%v", args)
			} else {
				legacyText = "LLM sent empty or invalid arguments"
			}
		}

		input.Questions = []QuestionInput{
			{
				Question: legacyText,
				Header:   "Clarification",
			},
		}
	}

	// Ensure essential fields have at least some value to avoid RPC errors if server validates them
	if input.ProjectDirectory == "" {
		input.ProjectDirectory = "unknown"
	}
	if input.AgentName == "" {
		input.AgentName = "Unknown Agent"
	}
	if input.ReasoningModelName == "" {
		input.ReasoningModelName = "unknown"
	}

	currentMcpClientName := ""
	if v := mcpClientName.Load(); v != nil {
		if s, ok := v.(string); ok {
			currentMcpClientName = s
		}
	}

	// Map to proto
	protoQuestions := make([]*agentassistproto.Question, len(input.Questions))
	for i, q := range input.Questions {
		opts := make([]*agentassistproto.Option, len(q.Options))
		for j, o := range q.Options {
			opts[j] = &agentassistproto.Option{
				Label:       o.Label,
				Description: o.Description,
			}
		}

		custom := true // default true
		if q.Custom != nil {
			custom = *q.Custom
		}

		protoQuestions[i] = &agentassistproto.Question{
			Question: q.Question,
			Header:   q.Header,
			Options:  opts,
			Multiple: q.Multiple,
			Custom:   custom,
		}
	}

	// Create RPC request
	// For backward compatibility, we populate the Question field with the first question's text
	legacyQuestion := ""
	if len(input.Questions) > 0 {
		legacyQuestion = input.Questions[0].Question
	}

	req := &agentassistproto.AskQuestionRequest{
		ID:        generateRequestID(),
		UserToken: config.AgentAssistantServerToken,
		Request: &agentassistproto.McpAskQuestionRequest{
			ProjectDirectory:   input.ProjectDirectory,
			Question:           legacyQuestion,
			Questions:          protoQuestions,
			Timeout:            int32(input.Timeout),
			AgentName:          input.AgentName,
			ReasoningModelName: input.ReasoningModelName,
			McpClientName:      currentMcpClientName,
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

// workReportHandler handles the work_report tool
func workReportHandler(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	//ensureMcpClientInfoSent()
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
		timeout = 3600 // Default timeout (1 hour)
	}

	// Get optional agent_name and reasoning_model_name
	agentName, _ := request.RequireString("agent_name")
	reasoningModelName, _ := request.RequireString("reasoning_model_name")

	currentMcpClientName := ""
	if v := mcpClientName.Load(); v != nil {
		if s, ok := v.(string); ok {
			currentMcpClientName = s
		}
	}

	// Create RPC request
	req := &agentassistproto.WorkReportRequest{
		ID:        generateRequestID(),
		UserToken: config.AgentAssistantServerToken,
		Request: &agentassistproto.McpWorkReportRequest{
			ProjectDirectory:   projectDirectory,
			Summary:            summary,
			Timeout:            int32(timeout),
			AgentName:          agentName,
			ReasoningModelName: reasoningModelName,
			McpClientName:      currentMcpClientName,
		},
	}

	// Call the WorkReport RPC
	resp, err := client.WorkReport(context.Background(), connect.NewRequest(req))
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
	case *agentassistproto.WorkReportResponse:
		isError = r.IsError
		contents = r.Contents
	default:
		return mcp.NewToolResultError("Unknown response type")
	}

	// Convert contents to MCP format
	var mcpContents []mcp.Content
	for i, content := range contents {
		switch content.Type {
		case 1: // Text content
			if content.Text != nil {
				mcpContents = append(mcpContents, mcp.NewTextContent(content.Text.Text))
			}
		case 2: // Image content
			if content.Image != nil {
				mcpContents = append(mcpContents, mcp.NewImageContent(content.Image.Data, content.Image.MimeType))
				mcpContents = append(mcpContents, mcp.NewEmbeddedResource(mcp.BlobResourceContents{
					URI:      fmt.Sprintf("attachment://image/%d", i),
					MIMEType: content.Image.MimeType,
					Blob:     content.Image.Data,
				}))
			}
		case 3: // Audio content
			if content.Audio != nil {
				mcpContents = append(mcpContents, mcp.NewAudioContent(content.Audio.Data, content.Audio.MimeType))
				mcpContents = append(mcpContents, mcp.NewEmbeddedResource(mcp.BlobResourceContents{
					URI:      fmt.Sprintf("attachment://audio/%d", i),
					MIMEType: content.Audio.MimeType,
					Blob:     content.Audio.Data,
				}))
			}
		case 4: // Embedded resource
			if content.EmbeddedResource != nil {
				// Prefer returning the embedded bytes to the MCP client.
				// MCP-Go expects embedded resources as EmbeddedResource{type:"resource", resource: BlobResourceContents/TextResourceContents}.
				if len(content.EmbeddedResource.Data) > 0 {
					// if strings.HasPrefix(strings.ToLower(content.EmbeddedResource.MimeType), "image/") {
					// 	mcpContents = append(
					// 		mcpContents,
					// 		mcp.NewImageContent(
					// 			base64.StdEncoding.EncodeToString(content.EmbeddedResource.Data),
					// 			content.EmbeddedResource.MimeType,
					// 		),
					// 	)

					// }

					mcpContents = append(mcpContents, mcp.NewEmbeddedResource(mcp.BlobResourceContents{
						URI:      content.EmbeddedResource.Uri,
						MIMEType: content.EmbeddedResource.MimeType,
						Blob:     base64.StdEncoding.EncodeToString(content.EmbeddedResource.Data),
					}))
				} else {
					// If there is no inline data, fall back to a text description.
					mcpContents = append(mcpContents, mcp.NewTextContent(fmt.Sprintf("Resource: %s", content.EmbeddedResource.Uri)))
				}
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

func isTextMimeType(mimeType string) bool {
	m := strings.ToLower(strings.TrimSpace(mimeType))
	if strings.HasPrefix(m, "text/") {
		return true
	}
	switch m {
	case "application/json", "application/xml", "application/javascript", "application/x-yaml", "application/yaml":
		return true
	default:
		return false
	}
}
