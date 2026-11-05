package service

import (
	"context"
	"sync"
	"testing"
	"time"

	"connectrpc.com/connect"
	agentassistproto "github.com/yangjuncode/agentassistant/agentassistproto"
)

// requestTestClock shrinks the inactivity timeout unit so tests can express
// timeouts in milliseconds instead of seconds and never depend on multi-second
// sleeps.
func requestTestClock(t *testing.T, unit time.Duration) {
	t.Helper()
	origUnit := requestTimeoutUnit
	requestTimeoutUnit = unit
	t.Cleanup(func() { requestTimeoutUnit = origUnit })
}

// requestTestLifetime overrides the absolute lifetime cap.
func requestTestLifetime(t *testing.T, lifetime time.Duration) {
	t.Helper()
	orig := requestAbsoluteLifetime
	requestAbsoluteLifetime = lifetime
	t.Cleanup(func() { requestAbsoluteLifetime = orig })
}

// waitPending polls until the broadcaster knows the request, i.e. until the
// broadcaster loop has consumed the broadcast. Avoids sleeping a fixed amount.
func waitPending(t *testing.T, b *Broadcaster, requestID string) {
	t.Helper()
	deadline := time.Now().Add(2 * time.Second)
	for time.Now().Before(deadline) {
		if b.IsRequestPending(requestID) {
			return
		}
		time.Sleep(time.Millisecond)
	}
	t.Fatalf("request %s never became pending", requestID)
}

type rpcOutcome[T any] struct {
	resp *connect.Response[T]
	err  error
}

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

	if resp.Msg.Meta["error"] != "timeout" {
		t.Errorf("Expected 'timeout' error, got: %s", resp.Msg.Meta["error"])
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

	if resp.Msg.Meta["error"] != "timeout" {
		t.Errorf("Expected 'timeout' error, got: %s", resp.Msg.Meta["error"])
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

	if content.Text.Text != "Hello, world!" {
		t.Errorf("Expected text 'Hello, world!', got '%s'", content.Text.Text)
	}
}

func TestCreateImageContent(t *testing.T) {
	// Minimal valid PNG (1x1 transparent pixel)
	pngData := "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="

	content, err := CreateImageContent(pngData, "image/png")
	if err != nil {
		t.Fatalf("Expected no error, got: %v", err)
	}

	if content.Type != ContentTypeImage {
		t.Errorf("Expected type %d, got %d", ContentTypeImage, content.Type)
	}

	if content.Image == nil {
		t.Fatal("Image content should not be nil")
	}

	if content.Image.MimeType != "image/png" {
		t.Errorf("Expected mime type 'image/png', got '%s'", content.Image.MimeType)
	}
}

func TestCreateImageContent_InvalidBase64(t *testing.T) {
	content, err := CreateImageContent("invalid-base64!!!", "image/png")
	if err == nil {
		t.Error("Expected error for invalid base64")
	}
	if content != nil {
		t.Error("Expected nil content for invalid base64")
	}
}

func TestCreateImageContent_InvalidMimeType(t *testing.T) {
	content, err := CreateImageContent("iVBORw0KGgo=", "text/plain")
	if err == nil {
		t.Error("Expected error for non-image mime type")
	}
	if content != nil {
		t.Error("Expected nil content for non-image mime type")
	}
}

func TestBroadcaster(t *testing.T) {
	// Create broadcaster
	broadcaster := NewBroadcaster()

	// Test client registration
	client := NewWebClient("test-client-1")
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

// askQuestionWithTimeout starts AskQuestion in the background and returns the
// result channel. The timeout is expressed in requestTimeoutUnit units.
func askQuestionWithTimeout(t *testing.T, svc *AgentAssistService, requestID string, timeout int) <-chan rpcOutcome[agentassistproto.AskQuestionResponse] {
	t.Helper()
	req := &connect.Request[agentassistproto.AskQuestionRequest]{
		Msg: &agentassistproto.AskQuestionRequest{
			ID:        requestID,
			UserToken: "test-token",
			Request: &agentassistproto.McpAskQuestionRequest{
				ProjectDirectory: "/test/project",
				Question:         "Will you reset me?",
				Timeout:          int32(timeout),
			},
		},
	}

	out := make(chan rpcOutcome[agentassistproto.AskQuestionResponse], 1)
	go func() {
		resp, err := svc.AskQuestion(context.Background(), req)
		out <- rpcOutcome[agentassistproto.AskQuestionResponse]{resp: resp, err: err}
	}()
	return out
}

func workReportWithTimeout(t *testing.T, svc *AgentAssistService, requestID string, timeout int) <-chan rpcOutcome[agentassistproto.WorkReportResponse] {
	t.Helper()
	req := &connect.Request[agentassistproto.WorkReportRequest]{
		Msg: &agentassistproto.WorkReportRequest{
			ID:        requestID,
			UserToken: "test-token",
			Request: &agentassistproto.McpWorkReportRequest{
				ProjectDirectory: "/test/project",
				Summary:          "Will you reset WorkReport?",
				Timeout:          int32(timeout),
			},
		},
	}

	out := make(chan rpcOutcome[agentassistproto.WorkReportResponse], 1)
	go func() {
		resp, err := svc.WorkReport(context.Background(), req)
		out <- rpcOutcome[agentassistproto.WorkReportResponse]{resp: resp, err: err}
	}()
	return out
}

// assertStillWaiting fails if the RPC already returned.
func assertStillWaiting[T any](t *testing.T, out <-chan rpcOutcome[T], when string) {
	t.Helper()
	select {
	case res := <-out:
		t.Fatalf("request finished %s (expected to still be waiting): resp=%+v err=%v", when, res.resp, res.err)
	default:
	}
}

// TestAskQuestion_InactivityTimeoutNotReset is the regression guard for the
// non-reset path: without user activity the request must still expire.
func TestAskQuestion_InactivityTimeoutNotReset(t *testing.T) {
	requestTestClock(t, 10*time.Millisecond)
	svc := NewAgentAssistService()

	out := askQuestionWithTimeout(t, svc, "req-no-reset", 5) // 5*10ms = 50ms

	select {
	case res := <-out:
		if res.err != nil {
			t.Fatalf("unexpected error: %v", res.err)
		}
		if !res.resp.Msg.IsError {
			t.Fatal("expected a timeout error response")
		}
		if res.resp.Msg.Meta["error"] != "timeout" {
			t.Fatalf("expected 'timeout', got %+v", res.resp.Msg.Meta)
		}
	case <-time.After(2 * time.Second):
		t.Fatal("request never expired")
	}

	if svc.broadcaster.IsRequestPending("req-no-reset") {
		t.Fatal("expired request should have been removed from pendingRequests")
	}
}

// TestAskQuestion_InactivityTimeoutReset verifies that user activity restarts
// the FULL inactivity window, so the request outlives its original timeout.
func TestAskQuestion_InactivityTimeoutReset(t *testing.T) {
	requestTestClock(t, 10*time.Millisecond)
	svc := NewAgentAssistService()

	out := askQuestionWithTimeout(t, svc, "req-reset", 10) // 100ms inactivity window
	waitPending(t, svc.broadcaster, "req-reset")

	// Keep the request alive across ~2 original windows.
	for i := 0; i < 3; i++ {
		time.Sleep(60 * time.Millisecond)
		if !svc.broadcaster.ResetRequestTimeout("req-reset", "test-token") {
			t.Fatalf("reset %d rejected for a pending request", i)
		}
	}
	assertStillWaiting(t, out, "after being kept alive by resets")

	svc.broadcaster.HandleResponse("req-reset", &WebResponse{
		Contents: []*agentassistproto.McpResultContent{CreateTextContent("Reply after reset")},
	})

	select {
	case res := <-out:
		if res.err != nil {
			t.Fatalf("unexpected error: %v", res.err)
		}
		if res.resp.Msg.IsError {
			t.Fatalf("expected success, got %+v", res.resp.Msg.Meta)
		}
		if len(res.resp.Msg.Contents) == 0 || res.resp.Msg.Contents[0].Text.Text != "Reply after reset" {
			t.Fatalf("unexpected contents: %+v", res.resp.Msg.Contents)
		}
	case <-time.After(2 * time.Second):
		t.Fatal("request never completed")
	}
}

// TestAskQuestion_ResetAfterTimeoutRejected documents that a request which
// already expired cannot be revived: the RPC has returned and the id is gone.
func TestAskQuestion_ResetAfterTimeoutRejected(t *testing.T) {
	requestTestClock(t, 10*time.Millisecond)
	svc := NewAgentAssistService()

	out := askQuestionWithTimeout(t, svc, "req-late-reset", 2) // 20ms
	waitPending(t, svc.broadcaster, "req-late-reset")

	select {
	case <-out:
	case <-time.After(2 * time.Second):
		t.Fatal("request never expired")
	}

	if svc.broadcaster.ResetRequestTimeout("req-late-reset", "test-token") {
		t.Fatal("reset of an expired request must be rejected")
	}
	if svc.broadcaster.ResetRequestTimeout("does-not-exist", "test-token") {
		t.Fatal("reset of an unknown request id must be rejected")
	}
}

// TestResetRequestTimeout_TokenMustMatch guards against one user's client
// keeping another user's request alive.
func TestResetRequestTimeout_TokenMustMatch(t *testing.T) {
	requestTestClock(t, 10*time.Millisecond)
	svc := NewAgentAssistService()

	out := askQuestionWithTimeout(t, svc, "req-owner", 50) // 500ms, plenty of room
	waitPending(t, svc.broadcaster, "req-owner")

	if svc.broadcaster.ResetRequestTimeout("req-owner", "someone-elses-token") {
		t.Fatal("reset with a foreign token must be rejected")
	}
	if !svc.broadcaster.ResetRequestTimeout("req-owner", "test-token") {
		t.Fatal("reset by the owning token must be accepted")
	}

	svc.broadcaster.HandleResponse("req-owner", &WebResponse{
		Contents: []*agentassistproto.McpResultContent{CreateTextContent("ok")},
	})
	select {
	case <-out:
	case <-time.After(2 * time.Second):
		t.Fatal("request never completed")
	}
}

// TestAskQuestion_AbsoluteLifetimeCapsResets verifies that an always-active
// client cannot keep a request alive forever: the absolute lifetime wins.
func TestAskQuestion_AbsoluteLifetimeCapsResets(t *testing.T) {
	requestTestClock(t, 10*time.Millisecond)
	requestTestLifetime(t, 200*time.Millisecond)
	svc := NewAgentAssistService()

	// Inactivity window much longer than the absolute lifetime, so only the
	// lifetime cap can end this request.
	out := askQuestionWithTimeout(t, svc, "req-forever", 100)
	waitPending(t, svc.broadcaster, "req-forever")

	stop := make(chan struct{})
	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		defer wg.Done()
		ticker := time.NewTicker(20 * time.Millisecond)
		defer ticker.Stop()
		for {
			select {
			case <-stop:
				return
			case <-ticker.C:
				svc.broadcaster.ResetRequestTimeout("req-forever", "test-token")
			}
		}
	}()

	select {
	case res := <-out:
		close(stop)
		wg.Wait()
		if res.resp.Msg.Meta["error"] != "expired" {
			t.Fatalf("expected 'expired' after the lifetime cap, got %+v", res.resp.Msg.Meta)
		}
	case <-time.After(3 * time.Second):
		close(stop)
		wg.Wait()
		t.Fatal("a permanently active request was never capped")
	}

	if svc.broadcaster.IsRequestPending("req-forever") {
		t.Fatal("capped request should have been removed from pendingRequests")
	}
}

func TestWorkReport_InactivityTimeoutReset(t *testing.T) {
	requestTestClock(t, 10*time.Millisecond)
	svc := NewAgentAssistService()

	out := workReportWithTimeout(t, svc, "req-workreport-reset", 10)
	waitPending(t, svc.broadcaster, "req-workreport-reset")

	for i := 0; i < 3; i++ {
		time.Sleep(60 * time.Millisecond)
		if !svc.broadcaster.ResetRequestTimeout("req-workreport-reset", "test-token") {
			t.Fatalf("reset %d rejected", i)
		}
	}
	assertStillWaiting(t, out, "after being kept alive by resets")

	svc.broadcaster.HandleResponse("req-workreport-reset", &WebResponse{
		Contents: []*agentassistproto.McpResultContent{CreateTextContent("WorkReport Reply after reset")},
	})

	select {
	case res := <-out:
		if res.err != nil {
			t.Fatalf("unexpected error: %v", res.err)
		}
		if res.resp.Msg.IsError {
			t.Fatalf("expected success, got %+v", res.resp.Msg.Meta)
		}
		if len(res.resp.Msg.Contents) == 0 || res.resp.Msg.Contents[0].Text.Text != "WorkReport Reply after reset" {
			t.Fatalf("unexpected contents: %+v", res.resp.Msg.Contents)
		}
	case <-time.After(2 * time.Second):
		t.Fatal("request never completed")
	}
}

func TestGetRequestStatus(t *testing.T) {
	requestTestClock(t, 10*time.Millisecond)
	svc := NewAgentAssistService()

	out := askQuestionWithTimeout(t, svc, "req-status", 100) // 1s
	waitPending(t, svc.broadcaster, "req-status")

	resp, err := svc.GetRequestStatus(context.Background(), connect.NewRequest(&agentassistproto.RequestStatusRequest{
		RequestId: "req-status",
	}))
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !resp.Msg.Pending {
		t.Fatal("request should be reported as pending")
	}

	resp, err = svc.GetRequestStatus(context.Background(), connect.NewRequest(&agentassistproto.RequestStatusRequest{
		RequestId: "no-such-request",
	}))
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if resp.Msg.Pending {
		t.Fatal("unknown request must not be reported as pending")
	}

	svc.broadcaster.HandleResponse("req-status", &WebResponse{
		Contents: []*agentassistproto.McpResultContent{CreateTextContent("ok")},
	})
	select {
	case <-out:
	case <-time.After(2 * time.Second):
		t.Fatal("request never completed")
	}
}
