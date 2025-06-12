package main

import (
	"encoding/base64"
	"flag"
	"fmt"
	"log"

	"github.com/go-vgo/robotgo"
)

func main() {
	// Define string flags for plaintext and base64 encoded input
	inputPtr := flag.String("input", "", "plaintext string")
	input64Ptr := flag.String("input64", "", "base64 encoded string")

	// Parse the command-line flags
	flag.Parse()

	// Validate flags: exactly one must be provided
	if (*inputPtr == "" && *input64Ptr == "") || (*inputPtr != "" && *input64Ptr != "") {
		log.Fatal("Error: Exactly one of -input or -input64 flags must be provided")
	}

	var stringToType string

	// Process input based on which flag is used
	if *inputPtr != "" {
		stringToType = *inputPtr
		fmt.Println("Using plaintext input.")
	} else {
		// Decode the base64 string from -input64
		decodedBytes, err := base64.StdEncoding.DecodeString(*input64Ptr)
		if err != nil {
			log.Fatalf("Error decoding base64 string from -input64: %v", err)
		}
		stringToType = string(decodedBytes)
		fmt.Println("Using base64 decoded input.")
	}

	// Type the determined string
	robotgo.TypeStr(stringToType)

	fmt.Println("Successfully typed the string.")
}
