package main

import (
	"context"
	"errors"
	"testing"

	"connectrpc.com/connect"
	"github.com/mark3labs/mcp-go/mcp"
	"github.com/yangjuncode/agentassistant/agentassistproto"
)

type mockAgentAssistClient struct {
	askQuestionFunc       func(context.Context, *connect.Request[agentassistproto.AskQuestionRequest]) (*connect.Response[agentassistproto.AskQuestionResponse], error)
	workReportFunc        func(context.Context, *connect.Request[agentassistproto.WorkReportRequest]) (*connect.Response[agentassistproto.WorkReportResponse], error)
	sendMcpClientInfoFunc func(context.Context, *connect.Request[agentassistproto.McpClientInfoRequest]) (*connect.Response[agentassistproto.McpClientInfoResponse], error)
	heartbeatFunc         func(context.Context, *connect.Request[agentassistproto.McpHeartbeatRequest]) (*connect.Response[agentassistproto.McpHeartbeatResponse], error)
}

func (m *mockAgentAssistClient) AskQuestion(ctx context.Context, req *connect.Request[agentassistproto.AskQuestionRequest]) (*connect.Response[agentassistproto.AskQuestionResponse], error) {
	if m.askQuestionFunc != nil {
		return m.askQuestionFunc(ctx, req)
	}
	return nil, errors.New("unimplemented")
}

func (m *mockAgentAssistClient) WorkReport(ctx context.Context, req *connect.Request[agentassistproto.WorkReportRequest]) (*connect.Response[agentassistproto.WorkReportResponse], error) {
	if m.workReportFunc != nil {
		return m.workReportFunc(ctx, req)
	}
	return nil, errors.New("unimplemented")
}

func (m *mockAgentAssistClient) SendMcpClientInfo(ctx context.Context, req *connect.Request[agentassistproto.McpClientInfoRequest]) (*connect.Response[agentassistproto.McpClientInfoResponse], error) {
	if m.sendMcpClientInfoFunc != nil {
		return m.sendMcpClientInfoFunc(ctx, req)
	}
	return nil, errors.New("unimplemented")
}

func (m *mockAgentAssistClient) Heartbeat(ctx context.Context, req *connect.Request[agentassistproto.McpHeartbeatRequest]) (*connect.Response[agentassistproto.McpHeartbeatResponse], error) {
	if m.heartbeatFunc != nil {
		return m.heartbeatFunc(ctx, req)
	}
	return nil, errors.New("unimplemented")
}

func makeCallToolRequest(name string, args map[string]any) mcp.CallToolRequest {
	var req mcp.CallToolRequest
	req.Params.Name = name
	req.Params.Arguments = args
	return req
}

func TestGetWorkReportTimeout(t *testing.T) {
	origConfig := config
	defer func() { config = origConfig }()

	config = Config{}
	if got := getWorkReportTimeout(); got != 300 {
		t.Fatalf("getWorkReportTimeout() = %d, want 300", got)
	}

	config.WorkReportTimeout = 120
	if got := getWorkReportTimeout(); got != 120 {
		t.Fatalf("getWorkReportTimeout() = %d, want 120", got)
	}

	config.WorkReportTimeout = 0
	config.WorkReportTimeoutSeconds = 60
	if got := getWorkReportTimeout(); got != 60 {
		t.Fatalf("getWorkReportTimeout() = %d, want 60", got)
	}
}

func TestWorkReportHandler_TimeoutReturnsOkOnServerTimeout(t *testing.T) {
	origClient := client
	origConfig := config
	defer func() {
		client = origClient
		config = origConfig
	}()

	config = Config{
		AgentAssistantServerToken: "test-token",
		WorkReportTimeout:         300,
	}

	mock := &mockAgentAssistClient{
		workReportFunc: func(ctx context.Context, req *connect.Request[agentassistproto.WorkReportRequest]) (*connect.Response[agentassistproto.WorkReportResponse], error) {
			if req.Msg.Request.Timeout != 300 {
				t.Errorf("req.Msg.Request.Timeout = %d, want 300", req.Msg.Request.Timeout)
			}
			return &connect.Response[agentassistproto.WorkReportResponse]{
				Msg: &agentassistproto.WorkReportResponse{
					ID:      req.Msg.ID,
					IsError: true,
					Meta: map[string]string{
						"error":   "timeout",
						"message": "Request timed out after 300 seconds",
					},
				},
			}, nil
		},
	}
	client = mock

	req := makeCallToolRequest("work_report", map[string]any{
		"project_directory": "/tmp/test",
		"summary":           "Done task",
		"timeout":           3600, // caller passed 3600, should be capped to 300
	})

	res, err := workReportHandler(context.Background(), req)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if res.IsError {
		t.Fatalf("res.IsError = true, want false")
	}
	if len(res.Content) != 1 {
		t.Fatalf("expected 1 content, got %d", len(res.Content))
	}
	textContent, ok := res.Content[0].(mcp.TextContent)
	if !ok {
		t.Fatalf("expected TextContent, got %T", res.Content[0])
	}
	if textContent.Text != "ok" {
		t.Fatalf("expected text 'ok', got %q", textContent.Text)
	}
}

func TestWorkReportHandler_TimeoutReturnsOkOnDeadlineExceeded(t *testing.T) {
	origClient := client
	origConfig := config
	defer func() {
		client = origClient
		config = origConfig
	}()

	config = Config{
		AgentAssistantServerToken: "test-token",
		WorkReportTimeout:         300,
	}

	mock := &mockAgentAssistClient{
		workReportFunc: func(ctx context.Context, req *connect.Request[agentassistproto.WorkReportRequest]) (*connect.Response[agentassistproto.WorkReportResponse], error) {
			return nil, context.DeadlineExceeded
		},
	}
	client = mock

	req := makeCallToolRequest("work_report", map[string]any{
		"project_directory": "/tmp/test",
		"summary":           "Done task",
	})

	res, err := workReportHandler(context.Background(), req)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if res.IsError {
		t.Fatalf("res.IsError = true, want false")
	}
	if len(res.Content) != 1 {
		t.Fatalf("expected 1 content, got %d", len(res.Content))
	}
	textContent, ok := res.Content[0].(mcp.TextContent)
	if !ok {
		t.Fatalf("expected TextContent, got %T", res.Content[0])
	}
	if textContent.Text != "ok" {
		t.Fatalf("expected text 'ok', got %q", textContent.Text)
	}
}

func TestWorkReportHandler_CustomConfigTimeoutAndCapping(t *testing.T) {
	origClient := client
	origConfig := config
	defer func() {
		client = origClient
		config = origConfig
	}()

	config = Config{
		AgentAssistantServerToken: "test-token",
		WorkReportTimeout:         120, // custom 2 minutes
	}

	var capturedTimeout int32
	mock := &mockAgentAssistClient{
		workReportFunc: func(ctx context.Context, req *connect.Request[agentassistproto.WorkReportRequest]) (*connect.Response[agentassistproto.WorkReportResponse], error) {
			capturedTimeout = req.Msg.Request.Timeout
			return &connect.Response[agentassistproto.WorkReportResponse]{
				Msg: &agentassistproto.WorkReportResponse{
					ID:      req.Msg.ID,
					IsError: false,
					Contents: []*agentassistproto.McpResultContent{
						{
							Type: 1,
							Text: &agentassistproto.TextContent{
								Type: "text",
								Text: "LGTM approved",
							},
						},
					},
				},
			}, nil
		},
	}
	client = mock

	// Test case 1: Caller omitted timeout -> should default to custom 120
	req1 := makeCallToolRequest("work_report", map[string]any{
		"project_directory": "/tmp/test",
		"summary":           "Done task",
	})

	res, err := workReportHandler(context.Background(), req1)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if res.IsError {
		t.Fatalf("res.IsError = true, want false")
	}
	if capturedTimeout != 120 {
		t.Fatalf("capturedTimeout = %d, want 120", capturedTimeout)
	}
	textContent := res.Content[0].(mcp.TextContent)
	if textContent.Text != "LGTM approved" {
		t.Fatalf("expected text 'LGTM approved', got %q", textContent.Text)
	}

	// Test case 2: Caller passed timeout = 50 (< 120) -> should keep 50
	req2 := makeCallToolRequest("work_report", map[string]any{
		"project_directory": "/tmp/test",
		"summary":           "Done task",
		"timeout":           50,
	})
	res, err = workReportHandler(context.Background(), req2)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if capturedTimeout != 50 {
		t.Fatalf("capturedTimeout = %d, want 50", capturedTimeout)
	}

	// Test case 3: Caller passed timeout = 500 (> 120) -> should cap to 120
	req3 := makeCallToolRequest("work_report", map[string]any{
		"project_directory": "/tmp/test",
		"summary":           "Done task",
		"timeout":           500,
	})
	res, err = workReportHandler(context.Background(), req3)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if capturedTimeout != 120 {
		t.Fatalf("capturedTimeout = %d, want 120", capturedTimeout)
	}
}

func TestWorkReportHandler_NonTimeoutError(t *testing.T) {
	origClient := client
	origConfig := config
	defer func() {
		client = origClient
		config = origConfig
	}()

	mock := &mockAgentAssistClient{
		workReportFunc: func(ctx context.Context, req *connect.Request[agentassistproto.WorkReportRequest]) (*connect.Response[agentassistproto.WorkReportResponse], error) {
			return nil, errors.New("connection refused")
		},
	}
	client = mock

	req := makeCallToolRequest("work_report", map[string]any{
		"project_directory": "/tmp/test",
		"summary":           "Done task",
	})

	res, err := workReportHandler(context.Background(), req)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !res.IsError {
		t.Fatalf("res.IsError = false, want true for non-timeout error")
	}
}
