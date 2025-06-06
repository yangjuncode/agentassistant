package service

import (
	"context"
	"fmt"
	"log"
	"time"

	"connectrpc.com/connect"
	"github.com/yangjuncode/agentassistant"
	"github.com/yangjuncode/agentassistant/agentassistantconnect"
)

// AgentAssistService implements the SrvAgentAssist service
type AgentAssistService struct {
	agentassistantconnect.UnimplementedSrvAgentAssistHandler

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
	req *connect.Request[agentassistant.AskQuestionRequest],
) (*connect.Response[agentassistant.AskQuestionResponse], error) {
	// Check if the nested Request field is nil
	if req.Msg.Request == nil {
		log.Printf("Received AskQuestion request with nil Request field")
		return &connect.Response[agentassistant.AskQuestionResponse]{
			Msg: &agentassistant.AskQuestionResponse{
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

	// Create request for web users
	webRequest := &WebRequest{
		ID:               generateRequestID(),
		Type:             "ask_question",
		ProjectDirectory: req.Msg.Request.ProjectDirectory,
		Question:         req.Msg.Request.Question,
		Summary:          "",
		Timeout:          timeout,
		ResponseChan:     make(chan *WebResponse, 1),
	}

	// Broadcast to web users
	s.broadcaster.Broadcast(webRequest)

	// Wait for response or timeout
	select {
	case response := <-webRequest.ResponseChan:
		if response.IsError {
			return &connect.Response[agentassistant.AskQuestionResponse]{
				Msg: &agentassistant.AskQuestionResponse{
					IsError:  true,
					Meta:     response.Meta,
					Contents: nil,
				},
			}, nil
		}

		return &connect.Response[agentassistant.AskQuestionResponse]{
			Msg: &agentassistant.AskQuestionResponse{
				IsError:  false,
				Meta:     response.Meta,
				Contents: response.Contents,
			},
		}, nil

	case <-timeoutCtx.Done():
		log.Printf("AskQuestion request timed out after %d seconds", timeout)
		return &connect.Response[agentassistant.AskQuestionResponse]{
			Msg: &agentassistant.AskQuestionResponse{
				IsError: true,
				Meta: map[string]string{
					"error":   "timeout",
					"message": fmt.Sprintf("Request timed out after %d seconds", timeout),
				},
				Contents: nil,
			},
		}, nil
	}
}

// TaskFinish implements the TaskFinish RPC method
func (s *AgentAssistService) TaskFinish(
	ctx context.Context,
	req *connect.Request[agentassistant.TaskFinishRequest],
) (*connect.Response[agentassistant.TaskFinishResponse], error) {
	// Check if the nested Request field is nil
	if req.Msg.Request == nil {
		log.Printf("Received TaskFinish request with nil Request field")
		return &connect.Response[agentassistant.TaskFinishResponse]{
			Msg: &agentassistant.TaskFinishResponse{
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

	// Create request for web users
	webRequest := &WebRequest{
		ID:               generateRequestID(),
		Type:             "task_finish",
		ProjectDirectory: req.Msg.Request.ProjectDirectory,
		Question:         "",
		Summary:          req.Msg.Request.Summary,
		Timeout:          timeout,
		ResponseChan:     make(chan *WebResponse, 1),
	}

	// Broadcast to web users
	s.broadcaster.Broadcast(webRequest)

	// Wait for response or timeout
	select {
	case response := <-webRequest.ResponseChan:
		if response.IsError {
			return &connect.Response[agentassistant.TaskFinishResponse]{
				Msg: &agentassistant.TaskFinishResponse{
					IsError:  true,
					Meta:     response.Meta,
					Contents: nil,
				},
			}, nil
		}

		return &connect.Response[agentassistant.TaskFinishResponse]{
			Msg: &agentassistant.TaskFinishResponse{
				IsError:  false,
				Meta:     response.Meta,
				Contents: response.Contents,
			},
		}, nil

	case <-timeoutCtx.Done():
		log.Printf("TaskFinish request timed out after %d seconds", timeout)
		return &connect.Response[agentassistant.TaskFinishResponse]{
			Msg: &agentassistant.TaskFinishResponse{
				IsError: true,
				Meta: map[string]string{
					"error":   "timeout",
					"message": fmt.Sprintf("Request timed out after %d seconds", timeout),
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
