package service

import (
	"log"
	"net/http"
	"time"

	"github.com/gorilla/websocket"
	agentassistproto "github.com/yangjuncode/agentassistant/agentassistproto"
)

// WebSocketHandler handles WebSocket connections for the web interface
type WebSocketHandler struct {
	broadcaster *Broadcaster
	upgrader    websocket.Upgrader
}

// NewWebSocketHandler creates a new WebSocket handler
func NewWebSocketHandler(broadcaster *Broadcaster) *WebSocketHandler {
	return &WebSocketHandler{
		broadcaster: broadcaster,
		upgrader: websocket.Upgrader{
			CheckOrigin: func(r *http.Request) bool {
				// Allow all origins for development - in production, you should restrict this
				return true
			},
			ReadBufferSize:  1024,
			WriteBufferSize: 1024,
		},
	}
}

// HandleWebSocket handles WebSocket connections
func (h *WebSocketHandler) HandleWebSocket(w http.ResponseWriter, r *http.Request) {
	// Upgrade HTTP connection to WebSocket
	conn, err := h.upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("Failed to upgrade WebSocket connection: %v", err)
		return
	}
	defer conn.Close()

	// Generate client ID
	clientID := generateClientID()
	log.Printf("New WebSocket connection from client: %s", clientID)

	// Create web client
	client := NewWebClient(clientID)

	// Register client with broadcaster
	h.broadcaster.RegisterClient(client)
	defer h.broadcaster.UnregisterClient(client)

	// Set up ping/pong to keep connection alive
	conn.SetReadDeadline(time.Now().Add(60 * time.Second))
	conn.SetPongHandler(func(string) error {
		conn.SetReadDeadline(time.Now().Add(60 * time.Second))
		return nil
	})

	// Start goroutine to handle outgoing messages
	go h.handleOutgoingMessages(conn, client)

	// Handle incoming messages
	h.handleIncomingMessages(conn, client)
}

// handleOutgoingMessages handles messages sent to the web client
func (h *WebSocketHandler) handleOutgoingMessages(conn *websocket.Conn, client *WebClient) {
	ticker := time.NewTicker(54 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case message, ok := <-client.SendChan:
			if !ok {
				// Channel closed, client is being shut down
				conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			// Send the protobuf WebsocketMessage directly to the client
			conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if err := conn.WriteJSON(message); err != nil {
				log.Printf("Failed to send message to client %s: %v", client.ID, err)
				return
			}

		case <-ticker.C:
			// Send ping to keep connection alive
			conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if err := conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				log.Printf("Failed to send ping to client %s: %v", client.ID, err)
				return
			}
		}
	}
}

// handleIncomingMessages handles messages received from the web client
func (h *WebSocketHandler) handleIncomingMessages(conn *websocket.Conn, client *WebClient) {
	for {
		var message agentassistproto.WebsocketMessage
		err := conn.ReadJSON(&message)
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("WebSocket error for client %s: %v", client.ID, err)
			}
			break
		}

		switch message.Cmd {
		case "UserLogin":
			// Handle user login - store the token
			if message.StrParam != "" {
				client.SetToken(message.StrParam)
				log.Printf("Client %s authenticated with token", client.ID)
			} else {
				log.Printf("Client %s sent empty token for UserLogin", client.ID)
			}
		case "AskQuestionReply":
			h.handleAskQuestionReply(client, &message)
		case "TaskFinishReply":
			h.handleTaskFinishReply(client, &message)
		default:
			log.Printf("Unknown message command from client %s: %s", client.ID, message.Cmd)
		}
	}
}

// handleAskQuestionReply processes an AskQuestionReply from the web client
func (h *WebSocketHandler) handleAskQuestionReply(client *WebClient, message *agentassistproto.WebsocketMessage) {
	// For now, we expect the response data to be in the AskQuestionRequest field
	// This is a workaround until the protobuf generation includes response fields
	if message.AskQuestionRequest == nil {
		log.Printf("Received AskQuestionReply from client %s with no request data", client.ID)
		return
	}

	request := message.AskQuestionRequest

	// Create a simple success response for now
	// In a full implementation, the web client would send actual response data
	webResponse := &WebResponse{
		IsError: false,
		Meta: map[string]string{
			"source":    "web_client",
			"client_id": client.ID,
		},
		Contents: []*agentassistproto.McpResultContent{
			{
				Type: 1, // Text content
				Text: &agentassistproto.TextContent{
					Type: "text",
					Text: "Response received from web client", // Placeholder
				},
			},
		},
	}

	log.Printf("Received AskQuestionReply from client %s for request %s", client.ID, request.ID)

	// Send the response to the broadcaster for proper request matching
	h.broadcaster.HandleResponse(request.ID, webResponse)
}

// handleTaskFinishReply processes a TaskFinishReply from the web client
func (h *WebSocketHandler) handleTaskFinishReply(client *WebClient, message *agentassistproto.WebsocketMessage) {
	// For now, we expect the response data to be in the TaskFinishRequest field
	// This is a workaround until the protobuf generation includes response fields
	if message.TaskFinishRequest == nil {
		log.Printf("Received TaskFinishReply from client %s with no request data", client.ID)
		return
	}

	request := message.TaskFinishRequest

	// Create a simple success response for now
	// In a full implementation, the web client would send actual response data
	webResponse := &WebResponse{
		IsError: false,
		Meta: map[string]string{
			"source":    "web_client",
			"client_id": client.ID,
		},
		Contents: []*agentassistproto.McpResultContent{
			{
				Type: 1, // Text content
				Text: &agentassistproto.TextContent{
					Type: "text",
					Text: "Task completion confirmed by web client", // Placeholder
				},
			},
		},
	}

	log.Printf("Received TaskFinishReply from client %s for request %s", client.ID, request.ID)

	// Send the response to the broadcaster for proper request matching
	h.broadcaster.HandleResponse(request.ID, webResponse)
}

// generateClientID generates a unique client ID
func generateClientID() string {
	return time.Now().Format("20060102150405") + "-" + randomString(6)
}

// generateRequestID generates a unique request ID
func generateRequestID() string {
	return time.Now().Format("20060102150405") + "-" + randomString(8)
}

// randomString generates a random string of specified length
func randomString(length int) string {
	const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	b := make([]byte, length)
	for i := range b {
		b[i] = charset[time.Now().UnixNano()%int64(len(charset))]
	}
	return string(b)
}
