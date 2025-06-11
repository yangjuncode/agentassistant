package service

import (
	"log"
	"sync"

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
	ID       string
	Token    string
	SendChan chan *agentassistproto.WebsocketMessage
	mu       sync.RWMutex
	active   bool
}

// NewWebClient creates a new web client
func NewWebClient(id string) *WebClient {
	return &WebClient{
		ID:       id,
		SendChan: make(chan *agentassistproto.WebsocketMessage, 10), // Buffered channel
		active:   true,
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
			} else if request.Message.TaskFinishRequest != nil {
				requestID = request.Message.TaskFinishRequest.ID
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
