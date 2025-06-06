package main

import (
	"context"
	"log"
	"net/http"
	"time"

	"connectrpc.com/connect"
	"github.com/yangjuncode/agentassistant"
	"github.com/yangjuncode/agentassistant/agentassistantconnect"
)

func main() {
	// Create client
	client := agentassistantconnect.NewSrvAgentAssistClient(
		http.DefaultClient,
		"http://localhost:8080",
	)

	// Test AskQuestion
	log.Println("Testing AskQuestion...")
	askReq := connect.NewRequest(&agentassistant.AskQuestionRequest{
		ID:        "test-ask-123",
		UserToken: "test-user-token",
		Request: &agentassistant.McpAskQuestionRequest{
			ProjectDirectory: "/example/project",
			Question:         "Should I proceed with the implementation?",
			Timeout:          30, // 30 seconds timeout
		},
	})

	ctx, cancel := context.WithTimeout(context.Background(), 35*time.Second)
	defer cancel()

	askResp, err := client.AskQuestion(ctx, askReq)
	if err != nil {
		log.Fatalf("AskQuestion failed: %v", err)
	}

	log.Printf("AskQuestion response: IsError=%t", askResp.Msg.IsError)
	if askResp.Msg.IsError {
		log.Printf("Error: %s", askResp.Msg.Meta["message"])
	} else {
		log.Printf("Received %d content items", len(askResp.Msg.Contents))
		for i, content := range askResp.Msg.Contents {
			switch content.Type {
			case 1: // Text
				log.Printf("Content %d (Text): %s", i, content.Text.Text)
			case 2: // Image
				log.Printf("Content %d (Image): MIME=%s, DataLen=%d", i, content.Image.MimeType, len(content.Image.Data))
			case 3: // Audio
				log.Printf("Content %d (Audio): MIME=%s, DataLen=%d", i, content.Audio.MimeType, len(content.Audio.Data))
			case 4: // Embedded Resource
				log.Printf("Content %d (Resource): URI=%s, MIME=%s", i, content.EmbeddedResource.Uri, content.EmbeddedResource.MimeType)
			}
		}
	}

	// Test TaskFinish
	log.Println("\nTesting TaskFinish...")
	taskReq := connect.NewRequest(&agentassistant.TaskFinishRequest{
		ID:        "test-task-123",
		UserToken: "test-user-token",
		Request: &agentassistant.McpTaskFinishRequest{
			ProjectDirectory: "/example/project",
			Summary:          "Implementation completed successfully. All tests pass.",
			Timeout:          30, // 30 seconds timeout
		},
	})

	taskResp, err := client.TaskFinish(ctx, taskReq)
	if err != nil {
		log.Fatalf("TaskFinish failed: %v", err)
	}

	log.Printf("TaskFinish response: IsError=%t", taskResp.Msg.IsError)
	if taskResp.Msg.IsError {
		log.Printf("Error: %s", taskResp.Msg.Meta["message"])
	} else {
		log.Printf("Received %d content items", len(taskResp.Msg.Contents))
		for i, content := range taskResp.Msg.Contents {
			switch content.Type {
			case 1: // Text
				log.Printf("Content %d (Text): %s", i, content.Text.Text)
			case 2: // Image
				log.Printf("Content %d (Image): MIME=%s, DataLen=%d", i, content.Image.MimeType, len(content.Image.Data))
			case 3: // Audio
				log.Printf("Content %d (Audio): MIME=%s, DataLen=%d", i, content.Audio.MimeType, len(content.Audio.Data))
			case 4: // Embedded Resource
				log.Printf("Content %d (Resource): URI=%s, MIME=%s", i, content.EmbeddedResource.Uri, content.EmbeddedResource.MimeType)
			}
		}
	}

	log.Println("Client test completed")
}
