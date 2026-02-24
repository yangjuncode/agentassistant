package main

import (
	"encoding/base64"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
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
	windowIDPtr := flag.String("window-id", "", "target window id for directed input")
	listWindowsPtr := flag.Bool("list-windows", false, "list forwardable system windows as JSON")

	// Parse the command-line flags
	flag.Parse()

	log.Printf("[DEBUG] Parsed flags - input: '%s' (len=%d), input64: '%s' (len=%d)",
		truncateForLog(*inputPtr), len(*inputPtr),
		truncateForLog(*input64Ptr), len(*input64Ptr))

	if *listWindowsPtr {
		if *inputPtr != "" || *input64Ptr != "" {
			log.Fatal("Error: -list-windows cannot be used with -input or -input64")
		}

		if err := outputWindowListAsJSON(); err != nil {
			log.Fatalf("Error listing windows: %v", err)
		}
		return
	}

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
	if *windowIDPtr != "" {
		if err := activateWindow(*windowIDPtr); err != nil {
			if errors.Is(err, errWindowNotFound) {
				fmt.Fprintln(os.Stderr, "ERR_WINDOW_NOT_FOUND")
				os.Exit(3)
			}
			log.Fatalf("Error activating target window: %v", err)
		}
	}
	typeWithNewlines(stringToType)
	elapsed := time.Since(startTime)
	log.Printf("[DEBUG] typeWithNewlines() completed in %v", elapsed)

	fmt.Println("Successfully typed the string.")
	log.Printf("[DEBUG] agentassistant-input completed successfully")
}

var errWindowNotFound = errors.New("window not found")

type windowInfo struct {
	WindowID string `json:"window_id"`
	Title    string `json:"title"`
}

func outputWindowListAsJSON() error {
	windows, err := listWindows()
	if err != nil {
		return err
	}

	b, err := json.Marshal(windows)
	if err != nil {
		return err
	}

	fmt.Println(string(b))
	return nil
}

func listWindows() ([]windowInfo, error) {
	out, err := exec.Command("xdotool", "search", "--onlyvisible", "--name", ".").Output()
	if err != nil {
		return nil, fmt.Errorf("xdotool search failed: %w", err)
	}

	lines := strings.Split(strings.TrimSpace(string(out)), "\n")
	windows := make([]windowInfo, 0, len(lines))
	seen := map[string]struct{}{}
	for _, line := range lines {
		id := strings.TrimSpace(line)
		if id == "" {
			continue
		}
		if _, ok := seen[id]; ok {
			continue
		}
		seen[id] = struct{}{}

		titleOut, titleErr := exec.Command("xdotool", "getwindowname", id).Output()
		title := strings.TrimSpace(string(titleOut))
		if titleErr != nil {
			continue
		}
		windows = append(windows, windowInfo{WindowID: id, Title: title})
	}

	return windows, nil
}

func activateWindow(windowID string) error {
	windowID = strings.TrimSpace(windowID)
	if windowID == "" {
		return errWindowNotFound
	}

	if err := exec.Command("xdotool", "getwindowname", windowID).Run(); err != nil {
		return errWindowNotFound
	}

	if err := exec.Command("xdotool", "windowactivate", "--sync", windowID).Run(); err != nil {
		return fmt.Errorf("xdotool windowactivate failed: %w", err)
	}

	// small delay to ensure target window is ready to receive input
	time.Sleep(60 * time.Millisecond)
	return nil
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
