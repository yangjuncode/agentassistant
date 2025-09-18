package service

import (
	"testing"
	"time"

	agentassistproto "github.com/yangjuncode/agentassistant/agentassistproto"
)

func TestBroadcastToAllExcept(t *testing.T) {
	broadcaster := NewBroadcaster()

	// Create test clients
	client1 := NewWebClient("client1")
	client2 := NewWebClient("client2")
	client3 := NewWebClient("client3")

	// Register clients
	broadcaster.RegisterClient(client1)
	broadcaster.RegisterClient(client2)
	broadcaster.RegisterClient(client3)

	// Give some time for registration
	time.Sleep(100 * time.Millisecond)

	// Create a test message
	testMessage := &agentassistproto.WebsocketMessage{
		Cmd:      "TestMessage",
		StrParam: "Hello from test",
	}

	// Broadcast to all except client1
	broadcaster.BroadcastToAllExcept(testMessage, "client1")

	// Give some time for message delivery
	time.Sleep(100 * time.Millisecond)

	// Check that client1 did not receive the message
	select {
	case <-client1.SendChan:
		t.Error("client1 should not have received the message")
	default:
		// Expected - client1 should not receive the message
	}

	// Check that client2 received the message
	select {
	case msg := <-client2.SendChan:
		if msg.Cmd != "TestMessage" || msg.StrParam != "Hello from test" {
			t.Errorf("client2 received wrong message: %+v", msg)
		}
	default:
		t.Error("client2 should have received the message")
	}

	// Check that client3 received the message
	select {
	case msg := <-client3.SendChan:
		if msg.Cmd != "TestMessage" || msg.StrParam != "Hello from test" {
			t.Errorf("client3 received wrong message: %+v", msg)
		}
	default:
		t.Error("client3 should have received the message")
	}

	// Clean up
	broadcaster.UnregisterClient(client1)
	broadcaster.UnregisterClient(client2)
	broadcaster.UnregisterClient(client3)
}

func TestBroadcastAskQuestionReply(t *testing.T) {
	broadcaster := NewBroadcaster()
	handler := NewWebSocketHandler(broadcaster)

	// Create test clients
	sender := NewWebClient("sender")
	receiver := NewWebClient("receiver")

	// Register clients
	broadcaster.RegisterClient(sender)
	broadcaster.RegisterClient(receiver)

	// Give some time for registration
	time.Sleep(100 * time.Millisecond)

	// Create a test AskQuestionReply message
	testMessage := &agentassistproto.WebsocketMessage{
		Cmd: "AskQuestionReply",
		AskQuestionRequest: &agentassistproto.AskQuestionRequest{
			ID:        "test-request-123",
			UserToken: "test-token",
			Request: &agentassistproto.McpAskQuestionRequest{
				ProjectDirectory: "/test/project",
				Question:         "What should I do?",
				Timeout:          30,
			},
		},
		AskQuestionResponse: &agentassistproto.AskQuestionResponse{
			ID:       "test-request-123",
			IsError:  false,
			Meta:     map[string]string{"source": "test"},
			Contents: nil,
		},
	}

	// Call the broadcast method
	handler.broadcastAskQuestionReply(sender, testMessage)

	// Give some time for message delivery
	time.Sleep(100 * time.Millisecond)

	// Check that sender did not receive the notification
	select {
	case <-sender.SendChan:
		t.Error("sender should not have received the notification")
	default:
		// Expected - sender should not receive the notification
	}

	// Check that receiver received the notification
	select {
	case msg := <-receiver.SendChan:
		if msg.Cmd != "AskQuestionReplyNotification" {
			t.Errorf("receiver received wrong message type: %s", msg.Cmd)
		}
		if msg.AskQuestionRequest == nil || msg.AskQuestionRequest.ID != "test-request-123" {
			t.Error("receiver did not receive correct request data")
		}
	default:
		t.Error("receiver should have received the notification")
	}

	// Clean up
	broadcaster.UnregisterClient(sender)
	broadcaster.UnregisterClient(receiver)
}

func TestBroadcastWorkReportReply(t *testing.T) {
	broadcaster := NewBroadcaster()
	handler := NewWebSocketHandler(broadcaster)

	// Create test clients
	sender := NewWebClient("sender")
	receiver := NewWebClient("receiver")

	// Register clients
	broadcaster.RegisterClient(sender)
	broadcaster.RegisterClient(receiver)

	// Give some time for registration
	time.Sleep(100 * time.Millisecond)

	// Create a test WorkReportReply message
	testMessage := &agentassistproto.WebsocketMessage{
		Cmd: "WorkReportReply",
		WorkReportRequest: &agentassistproto.WorkReportRequest{
			ID:        "test-task-456",
			UserToken: "test-token",
			Request: &agentassistproto.McpWorkReportRequest{
				ProjectDirectory: "/test/project",
				Summary:          "Task completed successfully",
				Timeout:          30,
			},
		},
		WorkReportResponse: &agentassistproto.WorkReportResponse{
			ID:       "test-task-456",
			IsError:  false,
			Meta:     map[string]string{"source": "test"},
			Contents: nil,
		},
	}

	// Call the broadcast method
	handler.broadcastWorkReportReply(sender, testMessage)

	// Give some time for message delivery
	time.Sleep(100 * time.Millisecond)

	// Check that sender did not receive the notification
	select {
	case <-sender.SendChan:
		t.Error("sender should not have received the notification")
	default:
		// Expected - sender should not receive the notification
	}

	// Check that receiver received the notification
	select {
	case msg := <-receiver.SendChan:
		if msg.Cmd != "WorkReportReplyNotification" {
			t.Errorf("receiver received wrong message type: %s", msg.Cmd)
		}
		if msg.WorkReportRequest == nil || msg.WorkReportRequest.ID != "test-task-456" {
			t.Error("receiver did not receive correct request data")
		}
	default:
		t.Error("receiver should have received the notification")
	}

	// Clean up
	broadcaster.UnregisterClient(sender)
	broadcaster.UnregisterClient(receiver)
}
