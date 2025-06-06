package service

import (
	"encoding/json"
	"log"
	"net/http"
	"time"

	"github.com/gorilla/websocket"
	"github.com/yangjuncode/agentassistant"
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

// WebSocketMessage represents a message sent over WebSocket
type WebSocketMessage struct {
	Type    string      `json:"type"`
	Payload interface{} `json:"payload"`
}

// WebSocketRequest represents a request sent to the web client
type WebSocketRequest struct {
	ID               string `json:"id"`
	Type             string `json:"type"`               // "ask_question" or "task_finish"
	ProjectDirectory string `json:"project_directory"`  // Current project directory
	Question         string `json:"question,omitempty"` // Question for ask_question type
	Summary          string `json:"summary,omitempty"`  // Summary for task_finish type
	Timeout          int32  `json:"timeout"`            // Timeout in seconds
}

// WebSocketResponse represents a response from the web client
type WebSocketResponse struct {
	ID       string                             `json:"id"`
	IsError  bool                               `json:"is_error"`
	Meta     map[string]string                  `json:"meta"`
	Contents []*agentassistant.McpResultContent `json:"contents"`
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
		case request, ok := <-client.SendChan:
			if !ok {
				// Channel closed, client is being shut down
				conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			// Convert WebRequest to WebSocketRequest
			wsRequest := &WebSocketRequest{
				ID:               request.ID, // Use the request ID from the WebRequest
				Type:             request.Type,
				ProjectDirectory: request.ProjectDirectory,
				Question:         request.Question,
				Summary:          request.Summary,
				Timeout:          request.Timeout,
			}

			// Send request to web client
			message := &WebSocketMessage{
				Type:    "request",
				Payload: wsRequest,
			}

			conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if err := conn.WriteJSON(message); err != nil {
				log.Printf("Failed to send message to client %s: %v", client.ID, err)
				return
			}

			// Store the request for response matching
			// In a production system, you'd want to store this with the request ID
			// For now, we'll use a simple approach

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
		var message WebSocketMessage
		err := conn.ReadJSON(&message)
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("WebSocket error for client %s: %v", client.ID, err)
			}
			break
		}

		switch message.Type {
		case "response":
			h.handleResponse(client, message.Payload)
		case "ping":
			// Respond to ping with pong
			pongMessage := &WebSocketMessage{
				Type:    "pong",
				Payload: nil,
			}
			conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			conn.WriteJSON(pongMessage)
		default:
			log.Printf("Unknown message type from client %s: %s", client.ID, message.Type)
		}
	}
}

// handleResponse processes a response from the web client
func (h *WebSocketHandler) handleResponse(client *WebClient, payload interface{}) {
	// Convert payload to WebSocketResponse
	responseData, err := json.Marshal(payload)
	if err != nil {
		log.Printf("Failed to marshal response payload from client %s: %v", client.ID, err)
		return
	}

	var response WebSocketResponse
	if err := json.Unmarshal(responseData, &response); err != nil {
		log.Printf("Failed to unmarshal response from client %s: %v", client.ID, err)
		return
	}

	// Validate content if provided
	if !response.IsError && response.Contents != nil {
		for _, content := range response.Contents {
			if err := ValidateContent(content); err != nil {
				log.Printf("Invalid content in response from client %s: %v", client.ID, err)
				// Convert to error response
				response.IsError = true
				response.Meta = map[string]string{
					"error":   "invalid_content",
					"message": err.Error(),
				}
				response.Contents = nil
				break
			}
		}
	}

	// Create WebResponse
	webResponse := &WebResponse{
		IsError:  response.IsError,
		Meta:     response.Meta,
		Contents: response.Contents,
	}

	log.Printf("Received response from client %s for request %s: IsError=%t", client.ID, response.ID, response.IsError)

	// Send the response to the broadcaster for proper request matching
	h.broadcaster.HandleResponse(response.ID, webResponse)
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
