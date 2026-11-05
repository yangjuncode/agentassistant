package service

import (
	"context"
	"fmt"
	"log"
	"time"

	"connectrpc.com/connect"
	"github.com/yangjuncode/agentassistant/agentassistproto"
)

const (
	// defaultAskQuestionTimeout is used when the caller does not specify one
	defaultAskQuestionTimeout = 600
	// defaultWorkReportTimeout is used when the caller does not specify one
	defaultWorkReportTimeout = 300
)

// Tunables expressed as package variables so tests can shrink them instead of
// sleeping for seconds.
var (
	// requestTimeoutUnit multiplies the timeout carried in the request to get
	// the inactivity window. Production uses seconds; tests shrink it so that
	// "timeout=4" means 400ms rather than 4s.
	requestTimeoutUnit = time.Second

	// requestAbsoluteLifetime caps how long a pending request may live, counted
	// from its creation, even if the user keeps resetting the inactivity timer.
	// Without this ceiling a client that (buggily or maliciously) keeps sending
	// activity would pin a request - and its goroutine and pending-entry - for
	// ever. Resets extend the inactivity timer, never this deadline.
	requestAbsoluteLifetime = 2 * time.Hour
)

// waitFailure describes why a pending request stopped waiting.
type waitFailure struct {
	// ErrorCode is the value put in the response Meta["error"].
	ErrorCode string
	// Message is the human-readable reason.
	Message string
}

// pendingRequest bundles everything needed to wait for one reply.
type pendingRequest struct {
	id           string
	messageType  string // "AskQuestion" or "WorkReport"
	timeout      int    // inactivity timeout, in requestTimeoutUnit units
	responseChan chan *WebResponse
	resetChan    chan struct{}
}

// awaitPendingReply blocks until the user replies, the inactivity timer fires,
// the absolute lifetime is exceeded, or ctx is cancelled.
//
// Returns (response, nil) on a reply and (nil, failure) otherwise. The failure
// has already been propagated to web clients via CancelRequest.
func (s *AgentAssistService) awaitPendingReply(ctx context.Context, p pendingRequest) (*WebResponse, *waitFailure) {
	inactivity := time.Duration(p.timeout) * requestTimeoutUnit
	timeoutMessage := fmt.Sprintf("Request timed out after %d seconds of inactivity", p.timeout)

	timer := time.NewTimer(inactivity)
	defer timer.Stop()

	deadline := time.NewTimer(requestAbsoluteLifetime)
	defer deadline.Stop()

	for {
		select {
		case response := <-p.responseChan:
			return response, nil

		case <-p.resetChan:
			// The user is working on this request: restart the inactivity
			// window with the FULL timeout (not the remaining part), and leave
			// the absolute deadline untouched.
			log.Printf("%s request %s: user activity, restarting inactivity timer (%ds)",
				p.messageType, p.id, p.timeout)
			if !timer.Stop() {
				// Drain a value that already fired so Reset starts cleanly.
				select {
				case <-timer.C:
				default:
				}
			}
			timer.Reset(inactivity)

		case <-timer.C:
			log.Printf("%s request %s timed out after %d seconds of inactivity",
				p.messageType, p.id, p.timeout)
			s.broadcaster.CancelRequest(p.id, timeoutMessage, p.messageType, CancelReasonTimeout)
			return nil, &waitFailure{ErrorCode: "timeout", Message: timeoutMessage}

		case <-deadline.C:
			// Activity kept the request alive, but a request must not live for
			// ever: bound the total lifetime.
			message := fmt.Sprintf("Request expired: maximum lifetime of %s exceeded despite user activity",
				requestAbsoluteLifetime)
			log.Printf("%s request %s hit the absolute lifetime cap (%s)",
				p.messageType, p.id, requestAbsoluteLifetime)
			s.broadcaster.CancelRequest(p.id, message, p.messageType, CancelReasonTimeout)
			return nil, &waitFailure{ErrorCode: "expired", Message: message}

		case <-ctx.Done():
			// The RPC caller went away (MCP process exited or gave up).
			log.Printf("%s request %s was cancelled: caller disconnected", p.messageType, p.id)
			s.broadcaster.CancelRequest(p.id, "Request was cancelled", p.messageType, CancelReasonInitiatorDisconnected)
			return nil, &waitFailure{ErrorCode: "cancelled", Message: "Request was cancelled"}
		}
	}
}

// AgentAssistService implements the SrvAgentAssist service
type AgentAssistService struct {
	agentassistproto.UnimplementedSrvAgentAssistHandler

	// Broadcast manager for web users
	broadcaster *Broadcaster
}

// SendMcpClientInfo handles the initial MCP client info RPC.
func (s *AgentAssistService) SendMcpClientInfo(
	ctx context.Context,
	req *connect.Request[agentassistproto.McpClientInfoRequest],
) (*connect.Response[agentassistproto.McpClientInfoResponse], error) {
	if req.Msg.Request == nil {
		log.Printf("Received McpClientInfo request with nil payload")
		return connect.NewResponse(&agentassistproto.McpClientInfoResponse{Success: false}), nil
	}

	info := req.Msg.Request
	log.Printf(
		"MCP client initialized: protocol=%s, client=%s (%s), capabilities=%s",
		info.ProtocolVersion,
		info.ClientName,
		info.ClientVersion,
		info.CapabilitiesJson,
	)

	return connect.NewResponse(&agentassistproto.McpClientInfoResponse{Success: true}), nil
}

// NewAgentAssistService creates a new instance of the service
func NewAgentAssistService() *AgentAssistService {
	return &AgentAssistService{
		broadcaster: NewBroadcaster(),
	}
}

// AskQuestion implements the AskQuestion RPC method
func (s *AgentAssistService) AskQuestion(
	ctx context.Context,
	req *connect.Request[agentassistproto.AskQuestionRequest],
) (*connect.Response[agentassistproto.AskQuestionResponse], error) {
	// Check if the nested Request field is nil
	if req.Msg.Request == nil {
		log.Printf("Received AskQuestion request with nil Request field")
		return &connect.Response[agentassistproto.AskQuestionResponse]{
			Msg: &agentassistproto.AskQuestionResponse{
				IsError: true,
				Meta: map[string]string{
					"error":   "invalid_request",
					"message": "Request field is required",
				},
				Contents: nil,
			},
		}, nil
	}

	log.Printf("Received AskQuestion request: ProjectDirectory=%s, Questions=%d, Timeout=%d",
		req.Msg.Request.ProjectDirectory, len(req.Msg.Request.Questions), req.Msg.Request.Timeout)

	// Set default timeout if not provided
	timeout := int(req.Msg.Request.Timeout)
	if timeout <= 0 {
		timeout = defaultAskQuestionTimeout
	}

	// Create WebsocketMessage for web users
	requestID := req.Msg.ID

	// Set timestamp
	req.Msg.Timestamp = time.Now().UnixMilli()

	websocketMessage := &agentassistproto.WebsocketMessage{
		Cmd:                "AskQuestion",
		AskQuestionRequest: req.Msg,
	}

	// Create response channel
	responseChan := make(chan *WebResponse, 1)

	// Broadcast to web users with token filtering and get reset channel
	resetChan := s.broadcaster.BroadcastToToken(websocketMessage, req.Msg.UserToken, responseChan)

	response, failure := s.awaitPendingReply(ctx, pendingRequest{
		id:           requestID,
		messageType:  "AskQuestion",
		timeout:      timeout,
		responseChan: responseChan,
		resetChan:    resetChan,
	})
	if failure != nil {
		return &connect.Response[agentassistproto.AskQuestionResponse]{
			Msg: &agentassistproto.AskQuestionResponse{
				ID:      requestID,
				IsError: true,
				Meta: map[string]string{
					"error":   failure.ErrorCode,
					"message": failure.Message,
				},
				Contents: nil,
			},
		}, nil
	}

	if response.IsError {
		return &connect.Response[agentassistproto.AskQuestionResponse]{
			Msg: &agentassistproto.AskQuestionResponse{
				ID:       requestID,
				IsError:  true,
				Meta:     response.Meta,
				Contents: nil,
			},
		}, nil
	}

	return &connect.Response[agentassistproto.AskQuestionResponse]{
		Msg: &agentassistproto.AskQuestionResponse{
			ID:       requestID,
			IsError:  false,
			Meta:     response.Meta,
			Contents: response.Contents,
		},
	}, nil
}

// WorkReport implements the WorkReport RPC method
func (s *AgentAssistService) WorkReport(
	ctx context.Context,
	req *connect.Request[agentassistproto.WorkReportRequest],
) (*connect.Response[agentassistproto.WorkReportResponse], error) {
	// Check if the nested Request field is nil
	if req.Msg.Request == nil {
		log.Printf("Received WorkReport request with nil Request field")
		return &connect.Response[agentassistproto.WorkReportResponse]{
			Msg: &agentassistproto.WorkReportResponse{
				IsError: true,
				Meta: map[string]string{
					"error":   "invalid_request",
					"message": "Request field is required",
				},
				Contents: nil,
			},
		}, nil
	}

	log.Printf("Received WorkReport request: ProjectDirectory=%s, Summary=%s, Timeout=%d",
		req.Msg.Request.ProjectDirectory, req.Msg.Request.Summary, req.Msg.Request.Timeout)

	// Set default timeout if not provided
	timeout := int(req.Msg.Request.Timeout)
	if timeout <= 0 {
		timeout = defaultWorkReportTimeout
	}

	// Create WebsocketMessage for web users
	requestID := req.Msg.ID

	// Set timestamp
	req.Msg.Timestamp = time.Now().UnixMilli()

	websocketMessage := &agentassistproto.WebsocketMessage{
		Cmd:               "WorkReport",
		WorkReportRequest: req.Msg,
	}

	// Create response channel
	responseChan := make(chan *WebResponse, 1)

	// Broadcast to web users with token filtering and get reset channel
	resetChan := s.broadcaster.BroadcastToToken(websocketMessage, req.Msg.UserToken, responseChan)

	response, failure := s.awaitPendingReply(ctx, pendingRequest{
		id:           requestID,
		messageType:  "WorkReport",
		timeout:      timeout,
		responseChan: responseChan,
		resetChan:    resetChan,
	})
	if failure != nil {
		return &connect.Response[agentassistproto.WorkReportResponse]{
			Msg: &agentassistproto.WorkReportResponse{
				ID:      requestID,
				IsError: true,
				Meta: map[string]string{
					"error":   failure.ErrorCode,
					"message": failure.Message,
				},
				Contents: nil,
			},
		}, nil
	}

	if response.IsError {
		return &connect.Response[agentassistproto.WorkReportResponse]{
			Msg: &agentassistproto.WorkReportResponse{
				ID:       requestID,
				IsError:  true,
				Meta:     response.Meta,
				Contents: nil,
			},
		}, nil
	}

	return &connect.Response[agentassistproto.WorkReportResponse]{
		Msg: &agentassistproto.WorkReportResponse{
			ID:       requestID,
			IsError:  false,
			Meta:     response.Meta,
			Contents: response.Contents,
		},
	}, nil
}

// Heartbeat implements the Heartbeat RPC method. MCP initiator processes call
// this periodically to keep their pending requests alive; requests whose
// session stops heartbeating are expired by the broadcaster sweeper.
func (s *AgentAssistService) Heartbeat(
	ctx context.Context,
	req *connect.Request[agentassistproto.McpHeartbeatRequest],
) (*connect.Response[agentassistproto.McpHeartbeatResponse], error) {
	sessionID := req.Msg.SessionId
	if sessionID == "" {
		log.Printf("Received Heartbeat request with empty session id")
		return connect.NewResponse(&agentassistproto.McpHeartbeatResponse{Success: false}), nil
	}

	s.broadcaster.ReportSessionActivity(sessionID)
	return connect.NewResponse(&agentassistproto.McpHeartbeatResponse{Success: true}), nil
}

// GetRequestStatus implements the GetRequestStatus RPC method. An MCP initiator
// polls this while it waits for a reply so that a wedged connection cannot leave
// the tool call hanging: if the server no longer knows the request, the caller
// stops waiting and reports a clean error instead of blocking forever.
func (s *AgentAssistService) GetRequestStatus(
	ctx context.Context,
	req *connect.Request[agentassistproto.RequestStatusRequest],
) (*connect.Response[agentassistproto.RequestStatusResponse], error) {
	requestID := req.Msg.RequestId
	if requestID == "" {
		return connect.NewResponse(&agentassistproto.RequestStatusResponse{
			RequestId: "",
			Pending:   false,
		}), nil
	}

	pending := s.broadcaster.IsRequestPending(requestID)
	return connect.NewResponse(&agentassistproto.RequestStatusResponse{
		RequestId: requestID,
		Pending:   pending,
	}), nil
}

// GetBroadcaster returns the broadcaster instance for web interface integration
func (s *AgentAssistService) GetBroadcaster() *Broadcaster {
	return s.broadcaster
}
