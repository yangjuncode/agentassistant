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
	log.Printf("[DEBUG] Process ID: %d", os.Getpid())
	log.Printf("[DEBUG] Args: %v", os.Args)
	log.Printf("[DEBUG] Working directory: %s", getCurrentDir())

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

	// Log before typing
	log.Printf("[DEBUG] About to type string, length: %d, first 100 chars: '%s'", len(stringToType), truncateForLog(stringToType))
	log.Printf("[DEBUG] String contains %d runes", len([]rune(stringToType)))

	// Add a small delay to ensure the target window is ready
	log.Printf("[DEBUG] Waiting 100ms before typing...")
	time.Sleep(100 * time.Millisecond)

	// Type the determined string
	log.Printf("[DEBUG] Calling robotgo.TypeStr()...")
	startTime := time.Now()
	robotgo.TypeStr(stringToType)
	elapsed := time.Since(startTime)
	log.Printf("[DEBUG] robotgo.TypeStr() completed in %v", elapsed)

	fmt.Println("Successfully typed the string.")
	log.Printf("[DEBUG] agentassistant-input completed successfully")
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
