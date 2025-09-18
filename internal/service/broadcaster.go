package service

import (
	"fmt"
	"log"
	"sync"
	"time"

	agentassistproto "github.com/yangjuncode/agentassistant/agentassistproto"
)

// WebsocketRequest represents a request with response channel for internal use
type WebsocketRequest struct {
	Message      *agentassistproto.WebsocketMessage
	ResponseChan chan *WebResponse
	UserToken    string // Token of the user who should receive this message
}

// WebResponse represents a response from web users
type WebResponse struct {
	IsError  bool                                 `json:"is_error"`
	Meta     map[string]string                    `json:"meta"`
	Contents []*agentassistproto.McpResultContent `json:"contents"`
}

// WebClient represents a connected web client
type WebClient struct {
	ID          string
	Token       string
	Nickname    string
	ConnectedAt int64
	SendChan    chan *agentassistproto.WebsocketMessage
	mu          sync.RWMutex
	active      bool
}

// NewWebClient creates a new web client
func NewWebClient(id string) *WebClient {
	return &WebClient{
		ID:          id,
		ConnectedAt: time.Now().Unix(),
		SendChan:    make(chan *agentassistproto.WebsocketMessage, 10), // Buffered channel
		active:      true,
	}
}

// SetToken sets the authentication token for the client
func (c *WebClient) SetToken(token string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.Token = token
}

// GetToken returns the client's authentication token
func (c *WebClient) GetToken() string {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.Token
}

// SetNickname sets the nickname for the client
func (c *WebClient) SetNickname(nickname string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.Nickname = nickname
}

// GetNickname returns the client's nickname
func (c *WebClient) GetNickname() string {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.Nickname
}

// IsActive returns whether the client is active
func (c *WebClient) IsActive() bool {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.active
}

// Close marks the client as inactive and closes the send channel
func (c *WebClient) Close() {
	c.mu.Lock()
	defer c.mu.Unlock()
	if c.active {
		c.active = false
		close(c.SendChan)
	}
}

// Send sends a websocket message to the client if it's active
func (c *WebClient) Send(msg *agentassistproto.WebsocketMessage) bool {
	c.mu.RLock()
	defer c.mu.RUnlock()

	if !c.active {
		return false
	}

	select {
	case c.SendChan <- msg:
		return true
	default:
		// Channel is full, client might be unresponsive
		log.Printf("Failed to send message to client %s: channel full", c.ID)
		return false
	}
}

// Broadcaster manages broadcasting requests to web clients
type Broadcaster struct {
	clients          map[string]*WebClient
	pendingRequests  map[string]*WebsocketRequest // Map request ID to WebsocketRequest
	register         chan *WebClient
	unregister       chan *WebClient
	broadcast        chan *WebsocketRequest
	responseReceived chan *ResponseWithID
	mu               sync.RWMutex
}

// ResponseWithID represents a response with its associated request ID
type ResponseWithID struct {
	RequestID string
	Response  *WebResponse
}

// NewBroadcaster creates a new broadcaster
func NewBroadcaster() *Broadcaster {
	b := &Broadcaster{
		clients:          make(map[string]*WebClient),
		pendingRequests:  make(map[string]*WebsocketRequest),
		register:         make(chan *WebClient),
		unregister:       make(chan *WebClient),
		broadcast:        make(chan *WebsocketRequest),
		responseReceived: make(chan *ResponseWithID),
	}

	// Start the broadcaster goroutine
	go b.run()

	return b
}

// run handles the broadcaster's main loop
func (b *Broadcaster) run() {
	for {
		select {
		case client := <-b.register:
			b.mu.Lock()
			b.clients[client.ID] = client
			b.mu.Unlock()
			log.Printf("Web client %s registered. Total clients: %d", client.ID, len(b.clients))

		case client := <-b.unregister:
			b.mu.Lock()
			if _, exists := b.clients[client.ID]; exists {
				delete(b.clients, client.ID)
				client.Close()
			}
			b.mu.Unlock()
			log.Printf("Web client %s unregistered. Total clients: %d", client.ID, len(b.clients))

		case request := <-b.broadcast:
			// Get request ID from the message
			var requestID string
			if request.Message.AskQuestionRequest != nil {
				requestID = request.Message.AskQuestionRequest.ID
			} else if request.Message.WorkReportRequest != nil {
				requestID = request.Message.WorkReportRequest.ID
			} else {
				log.Printf("Invalid request: no ID found")
				continue
			}

			// Filter clients by token if specified
			var targetClients []*WebClient
			b.mu.RLock()
			if request.UserToken != "" {
				// Send only to clients with matching token
				for _, client := range b.clients {
					if client.IsActive() && client.GetToken() == request.UserToken {
						targetClients = append(targetClients, client)
					}
				}
			} else {
				// Send to all active clients
				for _, client := range b.clients {
					if client.IsActive() {
						targetClients = append(targetClients, client)
					}
				}
			}
			b.mu.RUnlock()

			if len(targetClients) == 0 {
				log.Printf("No web clients available to handle request %s", requestID)
				// Send error response
				go func() {
					select {
					case request.ResponseChan <- &WebResponse{
						IsError: true,
						Meta: map[string]string{
							"error":   "no_clients",
							"message": "No web clients available to handle the request",
						},
						Contents: nil,
					}:
					default:
					}
				}()
				continue
			}

			log.Printf("Broadcasting request %s to %d web clients", requestID, len(targetClients))

			// Store the request for response matching
			b.mu.Lock()
			b.pendingRequests[requestID] = request
			b.mu.Unlock()

			// Send to target clients
			for _, client := range targetClients {
				go func(c *WebClient) {
					if !c.Send(request.Message) {
						// Client failed to receive, unregister it
						b.unregister <- c
					}
				}(client)
			}

		case responseWithID := <-b.responseReceived:
			// Handle response from web client
			b.mu.Lock()
			if request, exists := b.pendingRequests[responseWithID.RequestID]; exists {
				delete(b.pendingRequests, responseWithID.RequestID)
				b.mu.Unlock()

				// Send response to the waiting RPC call
				go func() {
					select {
					case request.ResponseChan <- responseWithID.Response:
					default:
						log.Printf("Failed to send response for request %s: channel not available", responseWithID.RequestID)
					}
				}()
			} else {
				b.mu.Unlock()
				log.Printf("Received response for unknown request ID: %s", responseWithID.RequestID)
			}
		}
	}
}

// RegisterClient registers a new web client
func (b *Broadcaster) RegisterClient(client *WebClient) {
	b.register <- client
}

// UnregisterClient unregisters a web client
func (b *Broadcaster) UnregisterClient(client *WebClient) {
	b.unregister <- client
}

// BroadcastToToken sends a request to web clients with a specific token
func (b *Broadcaster) BroadcastToToken(message *agentassistproto.WebsocketMessage, userToken string, responseChan chan *WebResponse) {
	request := &WebsocketRequest{
		Message:      message,
		ResponseChan: responseChan,
		UserToken:    userToken,
	}
	b.broadcast <- request
}

// BroadcastToAllExcept sends a message to all connected clients except the specified client
func (b *Broadcaster) BroadcastToAllExcept(message *agentassistproto.WebsocketMessage, excludeClientID string) {
	b.mu.RLock()
	defer b.mu.RUnlock()

	log.Printf("Broadcasting message to all clients except %s", excludeClientID)

	sentCount := 0
	for _, client := range b.clients {
		if client.IsActive() && client.ID != excludeClientID {
			go func(c *WebClient) {
				if !c.Send(message) {
					// Client failed to receive, unregister it
					b.unregister <- c
				}
			}(client)
			sentCount++
		}
	}

	log.Printf("Broadcasted message to %d clients (excluding %s)", sentCount, excludeClientID)
}

// CancelRequest cancels a pending request and notifies all clients
func (b *Broadcaster) CancelRequest(requestID string, reason string, messageType string) {
	b.mu.Lock()
	defer b.mu.Unlock()

	// Check if the request exists
	request, exists := b.pendingRequests[requestID]
	if !exists {
		log.Printf("Request %s not found for cancellation", requestID)
		return
	}

	log.Printf("Cancelling request %s with reason: %s", requestID, reason)

	// Remove the request from pending requests
	delete(b.pendingRequests, requestID)

	// Send error response to the original requester
	go func() {
		select {
		case request.ResponseChan <- &WebResponse{
			IsError: true,
			Meta: map[string]string{
				"error":   "cancelled",
				"message": reason,
			},
			Contents: nil,
		}:
		default:
		}
	}()

	// Create cancellation notification message
	cancelMessage := &agentassistproto.WebsocketMessage{
		Cmd: "RequestCancelled",
		RequestCancelledNotification: &agentassistproto.RequestCancelledNotification{
			RequestId:   requestID,
			Reason:      reason,
			MessageType: messageType,
		},
	}

	// Broadcast cancellation to all clients
	b.mu.Unlock() // Unlock before broadcasting to avoid deadlock
	b.BroadcastToAllExcept(cancelMessage, "")
	b.mu.Lock() // Re-lock for defer unlock
}

// GetClientCount returns the number of connected clients
func (b *Broadcaster) GetClientCount() int {
	b.mu.RLock()
	defer b.mu.RUnlock()
	return len(b.clients)
}

// HandleResponse processes a response from a web client
func (b *Broadcaster) HandleResponse(requestID string, response *WebResponse) {
	log.Printf("Handling response for request ID: %s", requestID)

	responseWithID := &ResponseWithID{
		RequestID: requestID,
		Response:  response,
	}

	// Send the response to the broadcaster
	select {
	case b.responseReceived <- responseWithID:
		log.Printf("Response for request %s queued for processing", requestID)
	default:
		log.Printf("Failed to queue response for request %s: channel full", requestID)
	}
}

// GetOnlineUsers returns a list of online users with the same token, excluding the requester
func (b *Broadcaster) GetOnlineUsers(token string, excludeClientID string) []*agentassistproto.OnlineUser {
	b.mu.RLock()
	defer b.mu.RUnlock()

	var onlineUsers []*agentassistproto.OnlineUser
	for _, client := range b.clients {
		if client.IsActive() && client.GetToken() == token && client.ID != excludeClientID {
			onlineUsers = append(onlineUsers, &agentassistproto.OnlineUser{
				ClientId:    client.ID,
				Nickname:    client.GetNickname(),
				ConnectedAt: client.ConnectedAt,
			})
		}
	}

	return onlineUsers
}

// SendChatMessage sends a chat message from one client to another
func (b *Broadcaster) SendChatMessage(senderClientID, receiverClientID, content string) error {
	b.mu.RLock()
	defer b.mu.RUnlock()

	// Find sender and receiver clients
	var senderClient, receiverClient *WebClient
	for _, client := range b.clients {
		if client.IsActive() {
			if client.ID == senderClientID {
				senderClient = client
			}
			if client.ID == receiverClientID {
				receiverClient = client
			}
		}
	}

	if senderClient == nil {
		return fmt.Errorf("sender client not found: %s", senderClientID)
	}
	if receiverClient == nil {
		return fmt.Errorf("receiver client not found: %s", receiverClientID)
	}

	// Verify both clients have the same token
	if senderClient.GetToken() != receiverClient.GetToken() {
		return fmt.Errorf("clients do not have the same token")
	}

	// Create chat message
	chatMessage := &agentassistproto.ChatMessage{
		MessageId:        generateChatMessageID(),
		SenderClientId:   senderClientID,
		SenderNickname:   senderClient.GetNickname(),
		ReceiverClientId: receiverClientID,
		ReceiverNickname: receiverClient.GetNickname(),
		Content:          content,
		SentAt:           time.Now().Unix(),
	}

	// Create notification message
	notification := &agentassistproto.WebsocketMessage{
		Cmd: "ChatMessageNotification",
		ChatMessageNotification: &agentassistproto.ChatMessageNotification{
			ChatMessage: chatMessage,
		},
	}

	// Send to receiver
	if !receiverClient.Send(notification) {
		return fmt.Errorf("failed to send message to receiver")
	}

	log.Printf("Chat message sent from %s (%s) to %s (%s): %s",
		senderClient.GetNickname(), senderClientID,
		receiverClient.GetNickname(), receiverClientID,
		content)

	return nil
}

// Broadcast to all clients with the same token, excluding the user themselves
func (b *Broadcaster) BroadcastUserConnectionStatus(user *WebClient, status string) {
	userToken := user.GetToken()
	if userToken == "" {
		return
	}

	// Create notification message
	notification := &agentassistproto.WebsocketMessage{
		Cmd: "UserConnectionStatusNotification",
		UserConnectionStatusNotification: &agentassistproto.UserConnectionStatusNotification{
			User: &agentassistproto.OnlineUser{
				ClientId:    user.ID,
				Nickname:    user.GetNickname(),
				ConnectedAt: user.ConnectedAt,
			},
			Status:    status,
			Timestamp: time.Now().Unix(),
		},
	}

	// snapshot under read-lock
	b.mu.RLock()
	targets := make([]*WebClient, 0, len(b.clients))
	for _, c := range b.clients {
		if c.IsActive() && c.GetToken() == userToken && c.ID != user.ID {
			targets = append(targets, c)
		}
	}
	b.mu.RUnlock()

	// fan-out without holding the lock
	for _, c := range targets {
		go func(cl *WebClient) {
			if !cl.Send(notification) {
				b.unregister <- cl
			}
		}(c)
	}

	log.Printf("Broadcasted user %s (%s) status: %s to %d clients with token %s",
		user.GetNickname(), user.ID, status, len(targets), userToken)
}

// generateChatMessageID generates a unique chat message ID
func generateChatMessageID() string {
	return fmt.Sprintf("chat_%d_%s", time.Now().UnixNano(), randomString(6))
}

// CheckMessageValidity checks if the given request IDs are still valid (pending)
func (b *Broadcaster) CheckMessageValidity(requestIDs []string) map[string]bool {
	b.mu.RLock()
	defer b.mu.RUnlock()

	validity := make(map[string]bool)
	for _, requestID := range requestIDs {
		_, exists := b.pendingRequests[requestID]
		validity[requestID] = exists
	}

	log.Printf("Checked validity for %d request IDs", len(requestIDs))
	return validity
}

// GetPendingMessages returns all pending messages for a specific user token
func (b *Broadcaster) GetPendingMessages(userToken string) []*agentassistproto.PendingMessage {
	b.mu.RLock()
	defer b.mu.RUnlock()

	var pendingMessages []*agentassistproto.PendingMessage

	for requestID, request := range b.pendingRequests {
		// Filter by user token if specified
		if userToken != "" && request.UserToken != userToken {
			continue
		}

		// Convert WebsocketRequest to PendingMessage
		pendingMessage := &agentassistproto.PendingMessage{
			CreatedAt: 0,   // We don't have timestamp info in current structure
			Timeout:   600, // Default timeout
		}

		if request.Message.AskQuestionRequest != nil {
			pendingMessage.MessageType = "AskQuestion"
			pendingMessage.AskQuestionRequest = request.Message.AskQuestionRequest
			if request.Message.AskQuestionRequest.Request != nil {
				pendingMessage.Timeout = request.Message.AskQuestionRequest.Request.Timeout
			}
		} else if request.Message.WorkReportRequest != nil {
			pendingMessage.MessageType = "WorkReport"
			pendingMessage.WorkReportRequest = request.Message.WorkReportRequest
			if request.Message.WorkReportRequest.Request != nil {
				pendingMessage.Timeout = request.Message.WorkReportRequest.Request.Timeout
			}
		} else {
			// Skip unknown message types
			log.Printf("Skipping unknown message type for request ID: %s", requestID)
			continue
		}

		pendingMessages = append(pendingMessages, pendingMessage)
	}

	log.Printf("Found %d pending messages for user token: %s", len(pendingMessages), userToken)
	return pendingMessages
}
