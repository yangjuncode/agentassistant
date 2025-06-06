package main

import (
	"context"
	_ "embed"
	"fmt"

	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"
)

//go:embed version.txt
var version string

func main() {
	// Create a new MCP server
	s := server.NewMCPServer(
		"Agent Assistant 🚀",
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
			mcp.Description("Question to ask"),
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

	return mcp.NewToolResultText(fmt.Sprintf("Asked question in %s: %s (timeout: %.0fs)", projectDirectory, question, timeout)), nil
}

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

	// TODO: Implement actual task finish logic
	return mcp.NewToolResultText(fmt.Sprintf("Task finished in %s: %s (timeout: %.0fs)", projectDirectory, summary, timeout)), nil
}
