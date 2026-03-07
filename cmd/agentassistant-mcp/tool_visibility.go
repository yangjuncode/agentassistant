package main

import (
	"fmt"

	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"
)

type toolVisibilityConfig struct {
	DisableAskQuestion bool
	DisableWorkReport  bool
}

// validate checks whether at least one MCP tool remains enabled.
func (config toolVisibilityConfig) validate() error {
	if config.DisableAskQuestion && config.DisableWorkReport {
		return fmt.Errorf("both MCP tools are disabled; keep at least one of -disable-ask-question or -disable-workreport enabled")
	}

	return nil
}

// enabledToolNames returns the tool names that stay exposed for the configuration.
func enabledToolNames(config toolVisibilityConfig) ([]string, error) {
	if err := config.validate(); err != nil {
		return nil, err
	}

	toolNames := make([]string, 0, 2)
	if !config.DisableAskQuestion {
		toolNames = append(toolNames, "ask_question")
	}
	if !config.DisableWorkReport {
		toolNames = append(toolNames, "work_report")
	}

	return toolNames, nil
}

// registerEnabledTools registers only the MCP tools allowed by the configuration.
func registerEnabledTools(mcpServer *server.MCPServer, config toolVisibilityConfig) error {
	if err := config.validate(); err != nil {
		return err
	}

	if !config.DisableAskQuestion {
		mcpServer.AddTool(newAskQuestionTool(), askQuestionHandler)
	}
	if !config.DisableWorkReport {
		mcpServer.AddTool(newWorkReportTool(), workReportHandler)
	}

	return nil
}

// newAskQuestionTool builds the ask_question MCP tool definition.
func newAskQuestionTool() mcp.Tool {
	tool := mcp.NewTool("ask_question",
		mcp.WithDescription(`
Use this tool when you need to ask the user questions during execution. This allows you to:
1. Gather user preferences or requirements
2. Clarify ambiguous instructions
3. Get decisions on implementation choices as you work
4. Offer choices to the user about what direction to take.

Usage notes:
- When "custom" is enabled (default), a "Type your own answer" option is added automatically; don't include "Other" or catch-all options
- Answers are returned as arrays of labels; set "multiple: true" to allow selecting more than one
`),
	)

	tool.InputSchema = mcp.ToolInputSchema{
		Type: "object",
		Properties: map[string]interface{}{
			"project_directory": map[string]interface{}{
				"type":        "string",
				"description": "Current project directory",
			},
			"questions": map[string]interface{}{
				"type":        "array",
				"description": "Questions to ask",
				"items": map[string]interface{}{
					"type": "object",
					"properties": map[string]interface{}{
						"question": map[string]interface{}{
							"type":        "string",
							"description": "Complete question",
						},
						"header": map[string]interface{}{
							"type":        "string",
							"description": "Very short label (max 30 chars)",
						},
						"options": map[string]interface{}{
							"type":        "array",
							"description": "Available choices",
							"items": map[string]interface{}{
								"type": "object",
								"properties": map[string]interface{}{
									"label": map[string]interface{}{
										"type":        "string",
										"description": "Display text (1-5 words, concise)",
									},
									"description": map[string]interface{}{
										"type":        "string",
										"description": "Explanation of choice",
									},
								},
								"required": []string{"label", "description"},
							},
						},
						"multiple": map[string]interface{}{
							"type":        "boolean",
							"description": "Allow selecting multiple choices",
						},
						"custom": map[string]interface{}{
							"type":        "boolean",
							"description": "Allow typing a custom answer (default: true)",
						},
					},
					"required": []string{"question", "header", "options"},
				},
			},
			"timeout": map[string]interface{}{
				"type":        "integer",
				"description": "Timeout in seconds, default is 3600s (1 hour)",
				"default":     3600,
			},
			"agent_name": map[string]interface{}{
				"type":        "string",
				"description": "The name of the AI agent/client calling this tool (e.g., Antigravity, Cascade)",
			},
			"reasoning_model_name": map[string]interface{}{
				"type":        "string",
				"description": "The specific identifier of the LLM/inference model being used (e.g., 'gpt-4o', 'claude-3-5-sonnet', 'gemini-1.5-pro'). Do NOT use generic agent names like 'cascade' or 'windsurf'.",
			},
		},
		Required: []string{"project_directory", "questions", "agent_name", "reasoning_model_name"},
	}

	return tool
}

// newWorkReportTool builds the work_report MCP tool definition.
func newWorkReportTool() mcp.Tool {
	return mcp.NewTool("work_report",
		mcp.WithDescription(`
before finish task/work, send a work report to Agent-Assistant/User asking for confirmation/approval.

This tool allows you to ask for confirmation/approval from Agent-Assistant/User by sending a work report.

Args:
- project_directory: The current project directory
- summary: The summary of the task/work report
- timeout: The timeout in seconds, default is 3600s (1 hour)
- agent_name: The name of the AI agent/client calling this tool (e.g., Antigravity, Cascade)
- reasoning_model_name: The name of the actual LLM/inference model currently being used for this task (e.g., GPT-4, Gemini 3 Pro)

Returns:
- List of TextContent, ImageContent, AudioContent, or EmbeddedResource from Agent-Assistant
`),
		mcp.WithString("project_directory",
			mcp.Required(),
			mcp.Description("Current project directory"),
		),
		mcp.WithString("summary",
			mcp.Required(),
			mcp.Description("Summary of the task/work report"),
		),
		mcp.WithNumber("timeout",
			mcp.DefaultNumber(3600),
			mcp.Description("Timeout in seconds, default is 3600s (1 hour)"),
		),
		mcp.WithString("agent_name",
			mcp.Required(),
			mcp.Description("The name of the AI agent/client calling this tool (e.g., Antigravity, Cascade)"),
		),
		mcp.WithString("reasoning_model_name",
			mcp.Required(),
			mcp.Description("The specific identifier of the LLM/inference model being used (e.g., 'gpt-4o', 'claude-3-5-sonnet', 'gemini-1.5-pro'). Do NOT use generic agent names like 'cascade' or 'windsurf'."),
		),
	)
}
