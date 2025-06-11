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

	log.Printf("Received AskQuestion request: ProjectDirectory=%s, Question=%s, Timeout=%d",
		req.Msg.Request.ProjectDirectory, req.Msg.Request.Question, req.Msg.Request.Timeout)

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

// TaskFinish implements the TaskFinish RPC method
func (s *AgentAssistService) TaskFinish(
	ctx context.Context,
	req *connect.Request[agentassistproto.TaskFinishRequest],
) (*connect.Response[agentassistproto.TaskFinishResponse], error) {
	// Check if the nested Request field is nil
	if req.Msg.Request == nil {
		log.Printf("Received TaskFinish request with nil Request field")
		return &connect.Response[agentassistproto.TaskFinishResponse]{
			Msg: &agentassistproto.TaskFinishResponse{
				IsError: true,
				Meta: map[string]string{
					"error":   "invalid_request",
					"message": "Request field is required",
				},
				Contents: nil,
			},
		}, nil
	}

	log.Printf("Received TaskFinish request: ProjectDirectory=%s, Summary=%s, Timeout=%d",
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
	websocketMessage := &agentassistproto.WebsocketMessage{
		Cmd:               "TaskFinish",
		TaskFinishRequest: req.Msg,
	}

	// Create response channel
	responseChan := make(chan *WebResponse, 1)

	// Broadcast to web users with token filtering
	s.broadcaster.BroadcastToToken(websocketMessage, req.Msg.UserToken, responseChan)

	// Wait for response, timeout, or cancellation
	select {
	case response := <-responseChan:
		if response.IsError {
			return &connect.Response[agentassistproto.TaskFinishResponse]{
				Msg: &agentassistproto.TaskFinishResponse{
					ID:       requestID,
					IsError:  true,
					Meta:     response.Meta,
					Contents: nil,
				},
			}, nil
		}

		return &connect.Response[agentassistproto.TaskFinishResponse]{
			Msg: &agentassistproto.TaskFinishResponse{
				ID:       requestID,
				IsError:  false,
				Meta:     response.Meta,
				Contents: response.Contents,
			},
		}, nil

	case <-timeoutCtx.Done():
		if timeoutCtx.Err() == context.DeadlineExceeded {
			log.Printf("TaskFinish request timed out after %d seconds", timeout)
			// Cancel the request in broadcaster and notify clients
			s.broadcaster.CancelRequest(requestID, fmt.Sprintf("Request timed out after %d seconds", timeout), "TaskFinish")
			return &connect.Response[agentassistproto.TaskFinishResponse]{
				Msg: &agentassistproto.TaskFinishResponse{
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
		log.Printf("TaskFinish request was cancelled: %s", requestID)
		// Cancel the request in broadcaster and notify clients
		s.broadcaster.CancelRequest(requestID, "Request was cancelled by client", "TaskFinish")
		return &connect.Response[agentassistproto.TaskFinishResponse]{
			Msg: &agentassistproto.TaskFinishResponse{
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
		log.Printf("TaskFinish request was cancelled by original context: %s", requestID)
		// Cancel the request in broadcaster and notify clients
		s.broadcaster.CancelRequest(requestID, "Request was cancelled", "TaskFinish")
		return &connect.Response[agentassistproto.TaskFinishResponse]{
			Msg: &agentassistproto.TaskFinishResponse{
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
