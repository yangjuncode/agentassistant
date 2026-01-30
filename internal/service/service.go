package service

import (
	"context"
	"fmt"
	"log"
	"time"

	"connectrpc.com/connect"
	"github.com/yangjuncode/agentassistant/agentassistproto"
)

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
	timeout := req.Msg.Request.Timeout
	if timeout <= 0 {
		timeout = 600 // Default 600 seconds
	}

	// Create a context with timeout
	timeoutCtx, cancel := context.WithTimeout(ctx, time.Duration(timeout)*time.Second)
	defer cancel()

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

	// Broadcast to web users with token filtering
	s.broadcaster.BroadcastToToken(websocketMessage, req.Msg.UserToken, responseChan)

	// Wait for response, timeout, or cancellation
	select {
	case response := <-responseChan:
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

	case <-timeoutCtx.Done():
		if timeoutCtx.Err() == context.DeadlineExceeded {
			log.Printf("AskQuestion request timed out after %d seconds", timeout)
			// Cancel the request in broadcaster and notify clients
			s.broadcaster.CancelRequest(requestID, fmt.Sprintf("Request timed out after %d seconds", timeout), "AskQuestion")
			return &connect.Response[agentassistproto.AskQuestionResponse]{
				Msg: &agentassistproto.AskQuestionResponse{
					ID:      requestID,
					IsError: true,
					Meta: map[string]string{
						"error":   "timeout",
						"message": fmt.Sprintf("Request timed out after %d seconds", timeout),
					},
					Contents: nil,
				},
			}, nil
		}
		// Context was cancelled (not timeout)
		log.Printf("AskQuestion request was cancelled: %s", requestID)
		// Cancel the request in broadcaster and notify clients
		s.broadcaster.CancelRequest(requestID, "Request was cancelled by client", "AskQuestion")
		return &connect.Response[agentassistproto.AskQuestionResponse]{
			Msg: &agentassistproto.AskQuestionResponse{
				ID:      requestID,
				IsError: true,
				Meta: map[string]string{
					"error":   "cancelled",
					"message": "Request was cancelled by client",
				},
				Contents: nil,
			},
		}, nil

	case <-ctx.Done():
		// Original context was cancelled
		log.Printf("AskQuestion request was cancelled by original context: %s", requestID)
		// Cancel the request in broadcaster and notify clients
		s.broadcaster.CancelRequest(requestID, "Request was cancelled", "AskQuestion")
		return &connect.Response[agentassistproto.AskQuestionResponse]{
			Msg: &agentassistproto.AskQuestionResponse{
				ID:      requestID,
				IsError: true,
				Meta: map[string]string{
					"error":   "cancelled",
					"message": "Request was cancelled",
				},
				Contents: nil,
			},
		}, nil
	}
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
	timeout := req.Msg.Request.Timeout
	if timeout <= 0 {
		timeout = 600 // Default 600 seconds
	}

	// Create a context with timeout
	timeoutCtx, cancel := context.WithTimeout(ctx, time.Duration(timeout)*time.Second)
	defer cancel()

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

	// Broadcast to web users with token filtering
	s.broadcaster.BroadcastToToken(websocketMessage, req.Msg.UserToken, responseChan)

	// Wait for response, timeout, or cancellation
	select {
	case response := <-responseChan:
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

	case <-timeoutCtx.Done():
		if timeoutCtx.Err() == context.DeadlineExceeded {
			log.Printf("WorkReport request timed out after %d seconds", timeout)
			// Cancel the request in broadcaster and notify clients
			s.broadcaster.CancelRequest(requestID, fmt.Sprintf("Request timed out after %d seconds", timeout), "WorkReport")
			return &connect.Response[agentassistproto.WorkReportResponse]{
				Msg: &agentassistproto.WorkReportResponse{
					ID:      requestID,
					IsError: true,
					Meta: map[string]string{
						"error":   "timeout",
						"message": fmt.Sprintf("Request timed out after %d seconds", timeout),
					},
					Contents: nil,
				},
			}, nil
		}
		// Context was cancelled (not timeout)
		log.Printf("WorkReport request was cancelled: %s", requestID)
		// Cancel the request in broadcaster and notify clients
		s.broadcaster.CancelRequest(requestID, "Request was cancelled by client", "WorkReport")
		return &connect.Response[agentassistproto.WorkReportResponse]{
			Msg: &agentassistproto.WorkReportResponse{
				ID:      requestID,
				IsError: true,
				Meta: map[string]string{
					"error":   "cancelled",
					"message": "Request was cancelled by client",
				},
				Contents: nil,
			},
		}, nil

	case <-ctx.Done():
		// Original context was cancelled
		log.Printf("WorkReport request was cancelled by original context: %s", requestID)
		// Cancel the request in broadcaster and notify clients
		s.broadcaster.CancelRequest(requestID, "Request was cancelled", "WorkReport")
		return &connect.Response[agentassistproto.WorkReportResponse]{
			Msg: &agentassistproto.WorkReportResponse{
				ID:      requestID,
				IsError: true,
				Meta: map[string]string{
					"error":   "cancelled",
					"message": "Request was cancelled",
				},
				Contents: nil,
			},
		}, nil
	}
}

// GetBroadcaster returns the broadcaster instance for web interface integration
func (s *AgentAssistService) GetBroadcaster() *Broadcaster {
	return s.broadcaster
}
