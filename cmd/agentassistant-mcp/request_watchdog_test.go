package main

import (
	"context"
	"errors"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/yangjuncode/agentassistant/agentassistproto"
)

// watchdogTestVars shrinks the watchdog timings so tests run in milliseconds.
func watchdogTestVars(t *testing.T, poll, pollTimeout time.Duration, maxFailures int, grace time.Duration) {
	t.Helper()
	origPoll, origTimeout := requestWatchPollInterval, requestWatchPollTimeout
	origFailures, origGrace := requestWatchMaxPollFailures, requestWatchReplyGrace
	requestWatchPollInterval, requestWatchPollTimeout = poll, pollTimeout
	requestWatchMaxPollFailures, requestWatchReplyGrace = maxFailures, grace
	t.Cleanup(func() {
		requestWatchPollInterval, requestWatchPollTimeout = origPoll, origTimeout
		requestWatchMaxPollFailures, requestWatchReplyGrace = origFailures, origGrace
	})
}

func setMockClient(t *testing.T, mock *mockAgentAssistClient) {
	t.Helper()
	orig := client
	client = mock
	t.Cleanup(func() { client = orig })
}

// A slow RPC that outlives many polls must not be cut off while the server
// keeps reporting the request as pending: this is the whole point of moving
// the timeout to the server.
func TestCallWithWatchdog_KeepsWaitingWhilePending(t *testing.T) {
	watchdogTestVars(t, 10*time.Millisecond, time.Second, 3, time.Second)

	polls := make(chan struct{}, 100)
	setMockClient(t, &mockAgentAssistClient{
		getRequestStatusFunc: func(_ context.Context, req *connect.Request[agentassistproto.RequestStatusRequest]) (*connect.Response[agentassistproto.RequestStatusResponse], error) {
			polls <- struct{}{}
			return connect.NewResponse(&agentassistproto.RequestStatusResponse{
				RequestId: req.Msg.RequestId,
				Pending:   true,
			}), nil
		},
	})

	resp, err := callWithWatchdog(context.Background(), "req-pending",
		func(ctx context.Context) (*connect.Response[agentassistproto.AskQuestionResponse], error) {
			select {
			case <-time.After(150 * time.Millisecond): // ~15 poll intervals
				return connect.NewResponse(&agentassistproto.AskQuestionResponse{
					ID:       "req-pending",
					IsError:  false,
					Contents: []*agentassistproto.McpResultContent{CreateTestTextContent("answer")},
				}), nil
			case <-ctx.Done():
				return nil, ctx.Err()
			}
		})

	if err != nil {
		t.Fatalf("a pending request must not be interrupted: %v", err)
	}
	if resp.Msg.ID != "req-pending" {
		t.Fatalf("unexpected response: %+v", resp.Msg)
	}
	if len(polls) < 3 {
		t.Fatalf("expected several status polls, got %d", len(polls))
	}
}

// When the server forgets the request but the RPC yields nothing, the watchdog
// must stop waiting instead of hanging.
func TestCallWithWatchdog_StopsWhenRequestGone(t *testing.T) {
	watchdogTestVars(t, 10*time.Millisecond, time.Second, 3, 20*time.Millisecond)

	setMockClient(t, &mockAgentAssistClient{
		getRequestStatusFunc: func(_ context.Context, req *connect.Request[agentassistproto.RequestStatusRequest]) (*connect.Response[agentassistproto.RequestStatusResponse], error) {
			return connect.NewResponse(&agentassistproto.RequestStatusResponse{
				RequestId: req.Msg.RequestId,
				Pending:   false,
			}), nil
		},
	})

	start := time.Now()
	_, err := callWithWatchdog(context.Background(), "req-gone",
		func(ctx context.Context) (*connect.Response[agentassistproto.AskQuestionResponse], error) {
			<-ctx.Done() // never produces a result on its own
			return nil, ctx.Err()
		})

	if !errors.Is(err, errRequestGone) {
		t.Fatalf("expected errRequestGone, got %v", err)
	}
	if elapsed := time.Since(start); elapsed > 2*time.Second {
		t.Fatalf("watchdog took too long to notice: %v", elapsed)
	}
}

// A reply that lands just as the server reports "not pending" must still be
// delivered rather than reported as gone (grace window).
func TestCallWithWatchdog_DeliversLateReply(t *testing.T) {
	watchdogTestVars(t, 10*time.Millisecond, time.Second, 3, time.Second)

	setMockClient(t, &mockAgentAssistClient{
		getRequestStatusFunc: func(_ context.Context, req *connect.Request[agentassistproto.RequestStatusRequest]) (*connect.Response[agentassistproto.RequestStatusResponse], error) {
			return connect.NewResponse(&agentassistproto.RequestStatusResponse{
				RequestId: req.Msg.RequestId,
				Pending:   false,
			}), nil
		},
	})

	resp, err := callWithWatchdog(context.Background(), "req-racy",
		func(ctx context.Context) (*connect.Response[agentassistproto.AskQuestionResponse], error) {
			// The reply arrives slightly after the status flips to "not
			// pending" — exactly the race a real reply causes.
			select {
			case <-time.After(30 * time.Millisecond):
				return connect.NewResponse(&agentassistproto.AskQuestionResponse{
					ID:      "req-racy",
					IsError: false,
				}), nil
			case <-ctx.Done():
				return nil, ctx.Err()
			}
		})

	if err != nil {
		t.Fatalf("late reply must be delivered, got error: %v", err)
	}
	if resp.Msg.ID != "req-racy" {
		t.Fatalf("unexpected response: %+v", resp.Msg)
	}
}

// Repeated poll failures mean we lost the server; give up with a clear error
// instead of waiting forever on a wedged connection.
func TestCallWithWatchdog_GivesUpAfterRepeatedPollFailures(t *testing.T) {
	watchdogTestVars(t, 10*time.Millisecond, 50*time.Millisecond, 3, time.Second)

	setMockClient(t, &mockAgentAssistClient{
		getRequestStatusFunc: func(context.Context, *connect.Request[agentassistproto.RequestStatusRequest]) (*connect.Response[agentassistproto.RequestStatusResponse], error) {
			return nil, connect.NewError(connect.CodeUnavailable, errors.New("connection refused"))
		},
	})

	_, err := callWithWatchdog(context.Background(), "req-lost",
		func(ctx context.Context) (*connect.Response[agentassistproto.AskQuestionResponse], error) {
			<-ctx.Done()
			return nil, ctx.Err()
		})

	if err == nil {
		t.Fatal("expected an error after repeated poll failures")
	}
	if errors.Is(err, errRequestGone) {
		t.Fatalf("a connectivity failure is not 'request gone': %v", err)
	}
}

// A transient failure must be tolerated, not treated as fatal.
func TestCallWithWatchdog_TolerateTransientPollFailure(t *testing.T) {
	watchdogTestVars(t, 10*time.Millisecond, 50*time.Millisecond, 3, time.Second)

	var calls int
	setMockClient(t, &mockAgentAssistClient{
		getRequestStatusFunc: func(_ context.Context, req *connect.Request[agentassistproto.RequestStatusRequest]) (*connect.Response[agentassistproto.RequestStatusResponse], error) {
			calls++
			if calls == 1 {
				return nil, connect.NewError(connect.CodeUnavailable, errors.New("blip"))
			}
			return connect.NewResponse(&agentassistproto.RequestStatusResponse{
				RequestId: req.Msg.RequestId,
				Pending:   true,
			}), nil
		},
	})

	resp, err := callWithWatchdog(context.Background(), "req-blip",
		func(ctx context.Context) (*connect.Response[agentassistproto.AskQuestionResponse], error) {
			select {
			case <-time.After(80 * time.Millisecond):
				return connect.NewResponse(&agentassistproto.AskQuestionResponse{ID: "req-blip"}), nil
			case <-ctx.Done():
				return nil, ctx.Err()
			}
		})

	if err != nil {
		t.Fatalf("a single poll failure must be tolerated, got: %v", err)
	}
	if resp.Msg.ID != "req-blip" {
		t.Fatalf("unexpected response: %+v", resp.Msg)
	}
}

// Disabling the poll interval degrades to a plain blocking call.
func TestCallWithWatchdog_Disabled(t *testing.T) {
	watchdogTestVars(t, 0, time.Second, 3, time.Second)
	setMockClient(t, &mockAgentAssistClient{})

	resp, err := callWithWatchdog(context.Background(), "req-plain",
		func(context.Context) (*connect.Response[agentassistproto.AskQuestionResponse], error) {
			return connect.NewResponse(&agentassistproto.AskQuestionResponse{ID: "req-plain"}), nil
		})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if resp.Msg.ID != "req-plain" {
		t.Fatalf("unexpected response: %+v", resp.Msg)
	}
}

// CreateTestTextContent builds a text result content for assertions.
func CreateTestTextContent(text string) *agentassistproto.McpResultContent {
	return &agentassistproto.McpResultContent{
		Type: 1,
		Text: &agentassistproto.TextContent{Text: text},
	}
}
