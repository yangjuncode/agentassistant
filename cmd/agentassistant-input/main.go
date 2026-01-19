package main

import (
	"encoding/base64"
	"flag"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/go-vgo/robotgo"
)

func main() {
	// Log startup
	log.Printf("[DEBUG] agentassistant-input started")
	log.Printf("[DEBUG] Args: %v", os.Args)

	// Define string flags for plaintext and base64 encoded input
	inputPtr := flag.String("input", "", "plaintext string")
	input64Ptr := flag.String("input64", "", "base64 encoded string")

	// Parse the command-line flags
	flag.Parse()

	log.Printf("[DEBUG] Parsed flags - input: '%s' (len=%d), input64: '%s' (len=%d)",
		truncateForLog(*inputPtr), len(*inputPtr),
		truncateForLog(*input64Ptr), len(*input64Ptr))

	// Validate flags: exactly one must be provided
	if (*inputPtr == "" && *input64Ptr == "") || (*inputPtr != "" && *input64Ptr != "") {
		log.Fatal("Error: Exactly one of -input or -input64 flags must be provided")
	}

	var stringToType string

	// Process input based on which flag is used
	if *inputPtr != "" {
		stringToType = *inputPtr
		log.Printf("[DEBUG] Using plaintext input, length: %d", len(stringToType))
		fmt.Println("Using plaintext input.")
	} else {
		log.Printf("[DEBUG] Decoding base64 input...")
		// Decode the base64 string from -input64
		decodedBytes, err := base64.StdEncoding.DecodeString(*input64Ptr)
		if err != nil {
			log.Fatalf("Error decoding base64 string from -input64: %v", err)
		}
		stringToType = string(decodedBytes)
		log.Printf("[DEBUG] Decoded base64 input, length: %d, content: '%s'", len(stringToType), truncateForLog(stringToType))
		fmt.Println("Using base64 decoded input.")
	}

	// Type the determined string with newline handling
	log.Printf("[DEBUG] Calling typeWithNewlines()...")
	startTime := time.Now()
	typeWithNewlines(stringToType)
	elapsed := time.Since(startTime)
	log.Printf("[DEBUG] typeWithNewlines() completed in %v", elapsed)

	fmt.Println("Successfully typed the string.")
	log.Printf("[DEBUG] agentassistant-input completed successfully")
}

// typeWithNewlines types a string, handling newline characters by pressing Enter
func typeWithNewlines(s string) {
	segments := splitByNewlines(s)
	for i, segment := range segments {
		if segment.isNewline {
			// Press Enter key for newline
			robotgo.KeyTap("enter")
		} else if segment.text != "" {
			// Type the text segment
			robotgo.TypeStr(segment.text)
		}
		if i < len(segments)-1 {
			// Small delay between segments to ensure proper input order
			time.Sleep(10 * time.Millisecond)
		}
	}
}

// textSegment represents a segment of text (either text or a newline marker)
type textSegment struct {
	text      string
	isNewline bool
}

// splitByNewlines splits a string into segments, separating text from newlines
func splitByNewlines(s string) []textSegment {
	var segments []textSegment
	currentText := ""

	for _, r := range s {
		if r == '\n' {
			// Flush current text segment if any
			if currentText != "" {
				segments = append(segments, textSegment{text: currentText, isNewline: false})
				currentText = ""
			}
			// Add newline segment
			segments = append(segments, textSegment{isNewline: true})
		} else if r == '\r' {
			// Skip carriage return (Windows line endings)
			continue
		} else {
			currentText += string(r)
		}
	}

	// Flush remaining text
	if currentText != "" {
		segments = append(segments, textSegment{text: currentText, isNewline: false})
	}

	return segments
}

// truncateForLog truncates a string for logging, showing first 100 characters
func truncateForLog(s string) string {
	if len(s) > 100 {
		return s[:100] + "..."
	}
	return s
}

// getCurrentDir returns the current working directory
func getCurrentDir() string {
	dir, err := os.Getwd()
	if err != nil {
		return "<error: " + err.Error() + ">"
	}
	return dir
}
