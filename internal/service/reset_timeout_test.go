package service

import (
	"testing"
	"time"

	agentassistproto "github.com/yangjuncode/agentassistant/agentassistproto"
)

// pendingAskQuestionFor registers a client with token, then broadcasts a
// pending AskQuestion so that handleResetTimeout has something to reset.
func pendingAskQuestionFor(t *testing.T, broadcaster *Broadcaster, client *WebClient, requestID, token string) chan struct{} {
	t.Helper()

	broadcaster.RegisterClient(client)
	deadline := time.Now().Add(2 * time.Second)
	for time.Now().Before(deadline) && broadcaster.GetClientCount() == 0 {
		time.Sleep(time.Millisecond)
	}

	resetChan := broadcaster.BroadcastToToken(&agentassistproto.WebsocketMessage{
		Cmd: "AskQuestion",
		AskQuestionRequest: &agentassistproto.AskQuestionRequest{
			ID:        requestID,
			UserToken: token,
			Request:   &agentassistproto.McpAskQuestionRequest{Question: "q"},
		},
	}, token, make(chan *WebResponse, 1))
	waitPending(t, broadcaster, requestID)

	// The broadcast lands in SendChan; drop it so that later reads only see
	// frames produced by the handler under test.
	select {
	case <-client.SendChan:
	case <-time.After(time.Second):
		t.Fatalf("broadcast frame for %s never reached the client", requestID)
	}

	return resetChan
}

// drainReset drains a reset signal, reporting whether one was queued.
func drainReset(ch chan struct{}) bool {
	select {
	case <-ch:
		return true
	default:
		return false
	}
}

// TestHandleResetTimeout_SuccessIsSilent checks that a successful reset emits
// no downstream frame (otherwise every keystroke would cost a round trip) but
// does signal the waiting RPC.
func TestHandleResetTimeout_SuccessIsSilent(t *testing.T) {
	broadcaster := NewBroadcaster()
	client := NewWebClient("client-a")
	client.SetToken("token-a")

	resetChan := pendingAskQuestionFor(t, broadcaster, client, "req-1", "token-a")

	h := NewWebSocketHandler(broadcaster, "test")
	h.handleResetTimeout(client, &agentassistproto.WebsocketMessage{
		Cmd:                 "ResetTimeout",
		ResetTimeoutRequest: &agentassistproto.ResetTimeoutRequest{RequestId: "req-1"},
	})

	if !drainReset(resetChan) {
		t.Fatal("successful reset must signal the waiting RPC")
	}
	select {
	case msg := <-client.SendChan:
		t.Fatalf("successful reset must not send a frame, got %q", msg.Cmd)
	default:
	}
}

// TestHandleResetTimeout_FailureIsReported checks that a reset which has no
// effect is reported back, so clients learn their request is gone.
func TestHandleResetTimeout_FailureIsReported(t *testing.T) {
	broadcaster := NewBroadcaster()
	client := NewWebClient("client-b")
	client.SetToken("token-b")

	pendingAskQuestionFor(t, broadcaster, client, "req-2", "token-b")

	h := NewWebSocketHandler(broadcaster, "test")

	cases := map[string]struct {
		requestID string
		message   *agentassistproto.WebsocketMessage
	}{
		"unknown request id": {
			requestID: "no-such-request",
			message: &agentassistproto.WebsocketMessage{
				Cmd:                 "ResetTimeout",
				ResetTimeoutRequest: &agentassistproto.ResetTimeoutRequest{RequestId: "no-such-request"},
			},
		},
		"empty request id": {
			message: &agentassistproto.WebsocketMessage{
				Cmd:                 "ResetTimeout",
				ResetTimeoutRequest: &agentassistproto.ResetTimeoutRequest{},
			},
		},
		"legacy StrParam fallback for unknown id": {
			requestID: "also-unknown",
			message: &agentassistproto.WebsocketMessage{
				Cmd:      "ResetTimeout",
				StrParam: "also-unknown",
			},
		},
	}

	for name, tc := range cases {
		t.Run(name, func(t *testing.T) {
			h.handleResetTimeout(client, tc.message)

			select {
			case msg := <-client.SendChan:
				if msg.Cmd != "ResetTimeoutResponse" {
					t.Fatalf("expected ResetTimeoutResponse, got %q", msg.Cmd)
				}
				if msg.ResetTimeoutResponse == nil {
					t.Fatal("ResetTimeoutResponse payload missing")
				}
				if msg.ResetTimeoutResponse.Success {
					t.Fatal("failure must be reported as Success=false")
				}
				if msg.ResetTimeoutResponse.RequestId != tc.requestID {
					t.Fatalf("expected request id %q, got %q",
						tc.requestID, msg.ResetTimeoutResponse.RequestId)
				}
			case <-time.After(time.Second):
				t.Fatal("failed reset must send a ResetTimeoutResponse")
			}
		})
	}
}

// TestHandleResetTimeout_LegacyStrParamSucceeds keeps the old client shape
// working: request id carried only in StrParam.
func TestHandleResetTimeout_LegacyStrParamSucceeds(t *testing.T) {
	broadcaster := NewBroadcaster()
	client := NewWebClient("client-c")
	client.SetToken("token-c")

	resetChan := pendingAskQuestionFor(t, broadcaster, client, "req-3", "token-c")

	h := NewWebSocketHandler(broadcaster, "test")
	h.handleResetTimeout(client, &agentassistproto.WebsocketMessage{
		Cmd:      "ResetTimeout",
		StrParam: "req-3",
	})

	if !drainReset(resetChan) {
		t.Fatal("legacy StrParam reset must signal the waiting RPC")
	}
}

// TestHandleResetTimeout_RejectsForeignToken checks the handler passes the
// client token through, so a different user cannot keep a request alive.
func TestHandleResetTimeout_RejectsForeignToken(t *testing.T) {
	broadcaster := NewBroadcaster()
	owner := NewWebClient("owner")
	owner.SetToken("owner-token")
	other := NewWebClient("other")
	other.SetToken("other-token")

	resetChan := pendingAskQuestionFor(t, broadcaster, owner, "req-4", "owner-token")

	h := NewWebSocketHandler(broadcaster, "test")
	h.handleResetTimeout(other, &agentassistproto.WebsocketMessage{
		Cmd:                 "ResetTimeout",
		ResetTimeoutRequest: &agentassistproto.ResetTimeoutRequest{RequestId: "req-4"},
	})

	if drainReset(resetChan) {
		t.Fatal("a foreign token must not reset the timer")
	}
	select {
	case msg := <-other.SendChan:
		if msg.ResetTimeoutResponse == nil || msg.ResetTimeoutResponse.Success {
			t.Fatalf("expected Success=false, got %+v", msg.ResetTimeoutResponse)
		}
	case <-time.After(time.Second):
		t.Fatal("rejected reset must be reported to the caller")
	}
}
