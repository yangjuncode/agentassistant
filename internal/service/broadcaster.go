package service

import (
	"log"
	"sync"

	"github.com/yangjuncode/agentassistant"
)

// WebRequest represents a request to be sent to web users
type WebRequest struct {
	ID               string            `json:"id"`                 // Unique request ID
	Type             string            `json:"type"`               // "ask_question" or "task_finish"
	ProjectDirectory string            `json:"project_directory"`  // Current project directory
	Question         string            `json:"question,omitempty"` // Question for ask_question type
	Summary          string            `json:"summary,omitempty"`  // Summary for task_finish type
	Timeout          int32             `json:"timeout"`            // Timeout in seconds
	ResponseChan     chan *WebResponse `json:"-"`                  // Channel to receive response (not serialized)
}

// WebResponse represents a response from web users
type WebResponse struct {
	IsError  bool                               `json:"is_error"`
	Meta     map[string]string                  `json:"meta"`
	Contents []*agentassistant.McpResultContent `json:"contents"`
}

// WebClient represents a connected web client
type WebClient struct {
	ID       string
	SendChan chan *WebRequest
	mu       sync.RWMutex
	active   bool
}

// NewWebClient creates a new web client
func NewWebClient(id string) *WebClient {
	return &WebClient{
		ID:       id,
		SendChan: make(chan *WebRequest, 10), // Buffered channel
		active:   true,
	}
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

// Send sends a request to the client if it's active
func (c *WebClient) Send(req *WebRequest) bool {
	c.mu.RLock()
	defer c.mu.RUnlock()

	if !c.active {
		return false
	}

	select {
	case c.SendChan <- req:
		return true
	default:
		// Channel is full, client might be unresponsive
		log.Printf("Failed to send request to client %s: channel full", c.ID)
		return false
	}
}

// Broadcaster manages broadcasting requests to web clients
type Broadcaster struct {
	clients          map[string]*WebClient
	pendingRequests  map[string]*WebRequest // Map request ID to WebRequest
	register         chan *WebClient
	unregister       chan *WebClient
	broadcast        chan *WebRequest
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
		pendingRequests:  make(map[string]*WebRequest),
		register:         make(chan *WebClient),
		unregister:       make(chan *WebClient),
		broadcast:        make(chan *WebRequest),
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
			b.mu.RLock()
			clientCount := len(b.clients)
			b.mu.RUnlock()

			if clientCount == 0 {
				log.Printf("No web clients available to handle request")
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

			log.Printf("Broadcasting request %s to %d web clients", request.ID, clientCount)

			// Store the request for response matching
			b.mu.Lock()
			b.pendingRequests[request.ID] = request
			b.mu.Unlock()

			// Send to all active clients
			b.mu.RLock()
			for _, client := range b.clients {
				if client.IsActive() {
					go func(c *WebClient) {
						if !c.Send(request) {
							// Client failed to receive, unregister it
							b.unregister <- c
						}
					}(client)
				}
			}
			b.mu.RUnlock()

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

// Broadcast sends a request to all connected web clients
func (b *Broadcaster) Broadcast(request *WebRequest) {
	b.broadcast <- request
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
