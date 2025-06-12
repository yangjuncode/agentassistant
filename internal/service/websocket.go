package service

import (
	"fmt"
	"log"
	"net/http"
	"time"

	"google.golang.org/protobuf/proto"

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
	defer func() {
		// Broadcast disconnection status before unregistering
		if client.GetToken() != "" {
			h.broadcaster.BroadcastUserConnectionStatus(client, "disconnected")
		}
		h.broadcaster.UnregisterClient(client)
	}()

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
			mb, merr := proto.Marshal(message)
			if merr != nil {
				log.Printf("Failed to marshal message to client %s: %v", client.ID, merr)
				return
			}
			if err := conn.WriteMessage(websocket.BinaryMessage, mb); err != nil {
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
		mtype, mb, merr := conn.ReadMessage()
		if merr != nil {
			if websocket.IsUnexpectedCloseError(merr, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("WebSocket error for client %s: %v", client.ID, merr)
			}
			break
		}
		if mtype != websocket.BinaryMessage {
			continue
		}
		err := proto.Unmarshal(mb, &message)
		log.Printf("Received message from client %s: %s", client.ID, mb)
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("WebSocket error for client %s: %v", client.ID, err)
			}
			break
		}

		switch message.Cmd {
		case "UserLogin":
			// Handle user login - store the token and nickname
			if message.StrParam != "" {
				client.SetToken(message.StrParam)
				log.Printf("Client %s authenticated with token", client.ID)
			} else {
				log.Printf("Client %s sent empty token for UserLogin", client.ID)
			}

			// Set nickname if provided
			if message.Nickname != "" {
				client.SetNickname(message.Nickname)
				log.Printf("Client %s set nickname to: %s", client.ID, message.Nickname)
			} else {
				// Generate default nickname if not provided
				defaultNickname := fmt.Sprintf("User_%s", client.ID[:8])
				client.SetNickname(defaultNickname)
				log.Printf("Client %s assigned default nickname: %s", client.ID, defaultNickname)
			}

			// Send login response with client ID
			loginResponse := &agentassistproto.WebsocketMessage{
				Cmd: "UserLogin",
				UserLoginResponse: &agentassistproto.UserLoginResponse{
					ClientId:     client.ID,
					Success:      true,
					ErrorMessage: "",
				},
			}
			if !client.Send(loginResponse) {
				log.Printf("Failed to send login response to client %s", client.ID)
			} else {
				log.Printf("Sent login response to client %s", client.ID)
			}

			// Broadcast user connection status to other clients with the same token
			h.broadcaster.BroadcastUserConnectionStatus(client, "connected")
		case "AskQuestionReply":
			h.handleAskQuestionReply(client, &message)
			h.broadcastAskQuestionReply(client, &message)
		case "TaskFinishReply":
			h.handleTaskFinishReply(client, &message)
			h.broadcastTaskFinishReply(client, &message)
		case "CheckMessageValidity":
			h.handleCheckMessageValidity(client, &message)
		case "GetPendingMessages":
			h.handleGetPendingMessages(client, &message)
		case "GetOnlineUsers":
			h.handleGetOnlineUsers(client, &message)
		case "SendChatMessage":
			h.handleSendChatMessage(client, &message)

		case "RequestCancelled":
			// This is a notification message, clients don't send this to server
			log.Printf("Client %s sent RequestCancelled message (unexpected)", client.ID)
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
		IsError:  message.AskQuestionResponse.IsError,
		Meta:     message.AskQuestionResponse.Meta,
		Contents: message.AskQuestionResponse.Contents,
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
		IsError:  message.TaskFinishResponse.IsError,
		Meta:     message.TaskFinishResponse.Meta,
		Contents: message.TaskFinishResponse.Contents,
	}

	log.Printf("Received TaskFinishReply from client %s for request %s", client.ID, request.ID)

	// Send the response to the broadcaster for proper request matching
	h.broadcaster.HandleResponse(request.ID, webResponse)
}

// broadcastAskQuestionReply broadcasts an AskQuestionReply to all connected clients except the sender
func (h *WebSocketHandler) broadcastAskQuestionReply(client *WebClient, message *agentassistproto.WebsocketMessage) {
	if message.AskQuestionRequest == nil {
		log.Printf("Cannot broadcast AskQuestionReply: missing AskQuestionRequest data")
		return
	}

	// Create a notification message for other clients
	notificationMessage := &agentassistproto.WebsocketMessage{
		Cmd: "AskQuestionReplyNotification",
		AskQuestionRequest: &agentassistproto.AskQuestionRequest{
			ID:        message.AskQuestionRequest.ID,
			UserToken: message.AskQuestionRequest.UserToken,
			Request:   message.AskQuestionRequest.Request,
		},
		// Include response data if available
		AskQuestionResponse: message.AskQuestionResponse,
		StrParam:            fmt.Sprintf("Response received from %s", client.GetNickname()),
		Nickname:            client.GetNickname(),
	}

	log.Printf("Broadcasting AskQuestionReply notification for request %s from client %s",
		message.AskQuestionRequest.ID, client.ID)

	// Broadcast to all clients except the sender
	h.broadcaster.BroadcastToAllExcept(notificationMessage, client.ID)
}

// broadcastTaskFinishReply broadcasts a TaskFinishReply to all connected clients except the sender
func (h *WebSocketHandler) broadcastTaskFinishReply(client *WebClient, message *agentassistproto.WebsocketMessage) {
	if message.TaskFinishRequest == nil {
		log.Printf("Cannot broadcast TaskFinishReply: missing TaskFinishRequest data")
		return
	}

	// Create a notification message for other clients
	notificationMessage := &agentassistproto.WebsocketMessage{
		Cmd: "TaskFinishReplyNotification",
		TaskFinishRequest: &agentassistproto.TaskFinishRequest{
			ID:        message.TaskFinishRequest.ID,
			UserToken: message.TaskFinishRequest.UserToken,
			Request:   message.TaskFinishRequest.Request,
		},
		// Include response data if available
		TaskFinishResponse: message.TaskFinishResponse,
		StrParam:           fmt.Sprintf("Task completion confirmed by %s", client.GetNickname()),
		Nickname:           client.GetNickname(),
	}

	log.Printf("Broadcasting TaskFinishReply notification for request %s from client %s",
		message.TaskFinishRequest.ID, client.ID)

	// Broadcast to all clients except the sender
	h.broadcaster.BroadcastToAllExcept(notificationMessage, client.ID)
}

// handleCheckMessageValidity handles message validity check requests
func (h *WebSocketHandler) handleCheckMessageValidity(client *WebClient, message *agentassistproto.WebsocketMessage) {
	if message.CheckMessageValidityRequest == nil {
		log.Printf("Invalid CheckMessageValidity message from client %s: missing request", client.ID)
		return
	}

	log.Printf("Client %s checking validity for %d request IDs", client.ID, len(message.CheckMessageValidityRequest.RequestIds))

	// Check validity using broadcaster
	validity := h.broadcaster.CheckMessageValidity(message.CheckMessageValidityRequest.RequestIds)

	// Create response message
	response := &agentassistproto.WebsocketMessage{
		Cmd: "CheckMessageValidity",
		CheckMessageValidityResponse: &agentassistproto.CheckMessageValidityResponse{
			Validity: validity,
		},
	}

	// Send response back to the requesting client
	if !client.Send(response) {
		log.Printf("Failed to send CheckMessageValidity response to client %s", client.ID)
	} else {
		log.Printf("Sent CheckMessageValidity response to client %s", client.ID)
	}
}

// handleGetPendingMessages handles get pending messages requests
func (h *WebSocketHandler) handleGetPendingMessages(client *WebClient, message *agentassistproto.WebsocketMessage) {
	log.Printf("Client %s requesting pending messages", client.ID)

	// Get client token for filtering
	userToken := client.GetToken()
	if userToken == "" {
		log.Printf("Client %s has no token, cannot get pending messages", client.ID)
		// Send empty response
		response := &agentassistproto.WebsocketMessage{
			Cmd: "GetPendingMessages",
			GetPendingMessagesResponse: &agentassistproto.GetPendingMessagesResponse{
				PendingMessages: []*agentassistproto.PendingMessage{},
				TotalCount:      0,
			},
		}
		client.Send(response)
		return
	}

	// Get pending messages from broadcaster
	pendingMessages := h.broadcaster.GetPendingMessages(userToken)

	log.Printf("Found %d pending messages for client %s", len(pendingMessages), client.ID)

	// Create response message
	response := &agentassistproto.WebsocketMessage{
		Cmd: "GetPendingMessages",
		GetPendingMessagesResponse: &agentassistproto.GetPendingMessagesResponse{
			PendingMessages: pendingMessages,
			TotalCount:      int32(len(pendingMessages)),
		},
	}

	// Send response back to the requesting client
	if !client.Send(response) {
		log.Printf("Failed to send GetPendingMessages response to client %s", client.ID)
	} else {
		log.Printf("Sent GetPendingMessages response to client %s with %d messages", client.ID, len(pendingMessages))
	}
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

// handleGetOnlineUsers handles get online users requests
func (h *WebSocketHandler) handleGetOnlineUsers(client *WebClient, message *agentassistproto.WebsocketMessage) {
	log.Printf("Client %s requesting online users", client.ID)

	// Get client token for filtering
	clientToken := client.GetToken()
	if clientToken == "" {
		log.Printf("Client %s has no token, cannot get online users", client.ID)
		return
	}

	// Get online users from broadcaster (excluding the requester)
	onlineUsers := h.broadcaster.GetOnlineUsers(clientToken, client.ID)

	// Create response message
	response := &agentassistproto.WebsocketMessage{
		Cmd: "GetOnlineUsers",
		GetOnlineUsersResponse: &agentassistproto.GetOnlineUsersResponse{
			OnlineUsers: onlineUsers,
			TotalCount:  int32(len(onlineUsers)),
		},
	}

	// Send response back to the requesting client
	if !client.Send(response) {
		log.Printf("Failed to send GetOnlineUsers response to client %s", client.ID)
	} else {
		log.Printf("Sent %d online users to client %s", len(onlineUsers), client.ID)
	}
}

// handleSendChatMessage handles send chat message requests
func (h *WebSocketHandler) handleSendChatMessage(client *WebClient, message *agentassistproto.WebsocketMessage) {
	log.Printf("Client %s sending chat message", client.ID)

	if message.SendChatMessageRequest == nil {
		log.Printf("Client %s sent SendChatMessage with nil request", client.ID)
		return
	}

	request := message.SendChatMessageRequest
	if request.ReceiverClientId == "" || request.Content == "" {
		log.Printf("Client %s sent invalid chat message request", client.ID)
		return
	}

	// Send chat message through broadcaster
	err := h.broadcaster.SendChatMessage(client.ID, request.ReceiverClientId, request.Content)
	if err != nil {
		log.Printf("Failed to send chat message from client %s: %v", client.ID, err)
	}
}
