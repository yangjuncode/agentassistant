package service

import (
	"encoding/base64"
	"fmt"
	"strings"

	"github.com/yangjuncode/agentassistant"
)

// Content type constants
const (
	ContentTypeText             = 1
	ContentTypeImage            = 2
	ContentTypeAudio            = 3
	ContentTypeEmbeddedResource = 4
)

// CreateTextContent creates a McpResultContent with text content
func CreateTextContent(text string) *agentassistant.McpResultContent {
	return &agentassistant.McpResultContent{
		Type: ContentTypeText,
		Text: &agentassistant.TextContent{
			Type: "text",
			Text: text,
		},
	}
}

// CreateImageContent creates a McpResultContent with image content
func CreateImageContent(data, mimeType string) (*agentassistant.McpResultContent, error) {
	// Validate base64 data
	if _, err := base64.StdEncoding.DecodeString(data); err != nil {
		return nil, fmt.Errorf("invalid base64 image data: %w", err)
	}

	// Validate MIME type
	if !isValidImageMimeType(mimeType) {
		return nil, fmt.Errorf("invalid image MIME type: %s", mimeType)
	}

	return &agentassistant.McpResultContent{
		Type: ContentTypeImage,
		Image: &agentassistant.ImageContent{
			Type:     "image",
			Data:     data,
			MimeType: mimeType,
		},
	}, nil
}

// CreateAudioContent creates a McpResultContent with audio content
func CreateAudioContent(data, mimeType string) (*agentassistant.McpResultContent, error) {
	// Validate base64 data
	if _, err := base64.StdEncoding.DecodeString(data); err != nil {
		return nil, fmt.Errorf("invalid base64 audio data: %w", err)
	}

	// Validate MIME type
	if !isValidAudioMimeType(mimeType) {
		return nil, fmt.Errorf("invalid audio MIME type: %s", mimeType)
	}

	return &agentassistant.McpResultContent{
		Type: ContentTypeAudio,
		Audio: &agentassistant.AudioContent{
			Type:     "audio",
			Data:     data,
			MimeType: mimeType,
		},
	}, nil
}

// CreateEmbeddedResourceContent creates a McpResultContent with embedded resource content
func CreateEmbeddedResourceContent(uri, mimeType string, data []byte) (*agentassistant.McpResultContent, error) {
	if uri == "" {
		return nil, fmt.Errorf("URI cannot be empty for embedded resource")
	}

	return &agentassistant.McpResultContent{
		Type: ContentTypeEmbeddedResource,
		EmbeddedResource: &agentassistant.EmbeddedResource{
			Type:     "embedded_resource",
			Uri:      uri,
			MimeType: mimeType,
			Data:     data,
		},
	}, nil
}

// ValidateContent validates a McpResultContent
func ValidateContent(content *agentassistant.McpResultContent) error {
	if content == nil {
		return fmt.Errorf("content cannot be nil")
	}

	switch content.Type {
	case ContentTypeText:
		if content.Text == nil {
			return fmt.Errorf("text content cannot be nil for type %d", content.Type)
		}
		if content.Text.Type != "text" {
			return fmt.Errorf("text content type must be 'text', got '%s'", content.Text.Type)
		}

	case ContentTypeImage:
		if content.Image == nil {
			return fmt.Errorf("image content cannot be nil for type %d", content.Type)
		}
		if content.Image.Type != "image" {
			return fmt.Errorf("image content type must be 'image', got '%s'", content.Image.Type)
		}
		if !isValidImageMimeType(content.Image.MimeType) {
			return fmt.Errorf("invalid image MIME type: %s", content.Image.MimeType)
		}

	case ContentTypeAudio:
		if content.Audio == nil {
			return fmt.Errorf("audio content cannot be nil for type %d", content.Type)
		}
		if content.Audio.Type != "audio" {
			return fmt.Errorf("audio content type must be 'audio', got '%s'", content.Audio.Type)
		}
		if !isValidAudioMimeType(content.Audio.MimeType) {
			return fmt.Errorf("invalid audio MIME type: %s", content.Audio.MimeType)
		}

	case ContentTypeEmbeddedResource:
		if content.EmbeddedResource == nil {
			return fmt.Errorf("embedded resource content cannot be nil for type %d", content.Type)
		}
		if content.EmbeddedResource.Type != "embedded_resource" {
			return fmt.Errorf("embedded resource content type must be 'embedded_resource', got '%s'", content.EmbeddedResource.Type)
		}
		if content.EmbeddedResource.Uri == "" {
			return fmt.Errorf("embedded resource URI cannot be empty")
		}

	default:
		return fmt.Errorf("invalid content type: %d", content.Type)
	}

	return nil
}

// isValidImageMimeType checks if the MIME type is valid for images
func isValidImageMimeType(mimeType string) bool {
	validTypes := []string{
		"image/jpeg",
		"image/jpg",
		"image/png",
		"image/gif",
		"image/webp",
		"image/bmp",
		"image/svg+xml",
		"image/tiff",
	}

	mimeType = strings.ToLower(mimeType)
	for _, validType := range validTypes {
		if mimeType == validType {
			return true
		}
	}
	return false
}

// isValidAudioMimeType checks if the MIME type is valid for audio
func isValidAudioMimeType(mimeType string) bool {
	validTypes := []string{
		"audio/mpeg",
		"audio/mp3",
		"audio/wav",
		"audio/wave",
		"audio/x-wav",
		"audio/ogg",
		"audio/webm",
		"audio/flac",
		"audio/aac",
		"audio/m4a",
		"audio/mp4",
	}

	mimeType = strings.ToLower(mimeType)
	for _, validType := range validTypes {
		if mimeType == validType {
			return true
		}
	}
	return false
}
