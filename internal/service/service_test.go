package service

import (
	"context"
	"testing"
	"time"

	"connectrpc.com/connect"
	agentassistproto "github.com/yangjuncode/agentassistant/agentassistproto"
)

func TestAgentAssistService_AskQuestion(t *testing.T) {
	// Create service
	svc := NewAgentAssistService()

	// Create test request
	req := &connect.Request[agentassistproto.AskQuestionRequest]{
		Msg: &agentassistproto.AskQuestionRequest{
			ID:        "test-request-1",
			UserToken: "test-token",
			Request: &agentassistproto.McpAskQuestionRequest{
				ProjectDirectory: "/test/project",
				Question:         "What should I do next?",
				Timeout:          5, // Short timeout for test
			},
		},
	}

	// Test with no clients (should timeout)
	ctx, cancel := context.WithTimeout(context.Background(), 6*time.Second)
	defer cancel()

	resp, err := svc.AskQuestion(ctx, req)
	if err != nil {
		t.Fatalf("Expected no error, got: %v", err)
	}

	if !resp.Msg.IsError {
		t.Error("Expected error response when no clients available")
	}

	if resp.Msg.Meta["error"] != "no_clients" {
		t.Errorf("Expected 'no_clients' error, got: %s", resp.Msg.Meta["error"])
	}
}

func TestAgentAssistService_WorkReport(t *testing.T) {
	// Create service
	svc := NewAgentAssistService()

	// Create test request
	req := &connect.Request[agentassistproto.WorkReportRequest]{
		Msg: &agentassistproto.WorkReportRequest{
			ID:        "test-request-2",
			UserToken: "test-token",
			Request: &agentassistproto.McpWorkReportRequest{
				ProjectDirectory: "/test/project",
				Summary:          "Task completed successfully",
				Timeout:          5, // Short timeout for test
			},
		},
	}

	// Test with no clients (should timeout)
	ctx, cancel := context.WithTimeout(context.Background(), 6*time.Second)
	defer cancel()

	resp, err := svc.WorkReport(ctx, req)
	if err != nil {
		t.Fatalf("Expected no error, got: %v", err)
	}

	if !resp.Msg.IsError {
		t.Error("Expected error response when no clients available")
	}

	if resp.Msg.Meta["error"] != "no_clients" {
		t.Errorf("Expected 'no_clients' error, got: %s", resp.Msg.Meta["error"])
	}
}

func TestCreateTextContent(t *testing.T) {
	content := CreateTextContent("Hello, world!")

	if content.Type != ContentTypeText {
		t.Errorf("Expected type %d, got %d", ContentTypeText, content.Type)
	}

	if content.Text == nil {
		t.Fatal("Text content should not be nil")
	}

	if content.Text.Type != "text" {
		t.Errorf("Expected text type 'text', got '%s'", content.Text.Type)
	}

	if content.Text.Text != "Hello, world!" {
		t.Errorf("Expected text 'Hello, world!', got '%s'", content.Text.Text)
	}
}

func TestCreateImageContent(t *testing.T) {
	// Valid base64 image data (1x1 pixel PNG)
	validData := "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChAGA6VP8IQAAAABJRU5ErkJggg=="

	content, err := CreateImageContent(validData, "image/png")
	if err != nil {
		t.Fatalf("Expected no error, got: %v", err)
	}

	if content.Type != ContentTypeImage {
		t.Errorf("Expected type %d, got %d", ContentTypeImage, content.Type)
	}

	if content.Image == nil {
		t.Fatal("Image content should not be nil")
	}

	if content.Image.Type != "image" {
		t.Errorf("Expected image type 'image', got '%s'", content.Image.Type)
	}

	if content.Image.MimeType != "image/png" {
		t.Errorf("Expected MIME type 'image/png', got '%s'", content.Image.MimeType)
	}
}

func TestCreateImageContent_InvalidData(t *testing.T) {
	_, err := CreateImageContent("invalid-base64", "image/png")
	if err == nil {
		t.Error("Expected error for invalid base64 data")
	}
}

func TestCreateImageContent_InvalidMimeType(t *testing.T) {
	validData := "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChAGA6VP8IQAAAABJRU5ErkJggg=="

	_, err := CreateImageContent(validData, "text/plain")
	if err == nil {
		t.Error("Expected error for invalid MIME type")
	}
}

func TestBroadcaster(t *testing.T) {
	broadcaster := NewBroadcaster()

	// Test client count
	if count := broadcaster.GetClientCount(); count != 0 {
		t.Errorf("Expected 0 clients, got %d", count)
	}

	// Create and register a client
	client := NewWebClient("test-client")
	broadcaster.RegisterClient(client)

	// Give some time for registration
	time.Sleep(100 * time.Millisecond)

	if count := broadcaster.GetClientCount(); count != 1 {
		t.Errorf("Expected 1 client, got %d", count)
	}

	// Unregister client
	broadcaster.UnregisterClient(client)

	// Give some time for unregistration
	time.Sleep(100 * time.Millisecond)

	if count := broadcaster.GetClientCount(); count != 0 {
		t.Errorf("Expected 0 clients after unregistration, got %d", count)
	}
}
