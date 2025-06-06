.PHONY: build test clean run-srv run-client generate proto-gen help

# Default target
help:
	@echo "Available targets:"
	@echo "  build      - Build all binaries"
	@echo "  test       - Run all tests"
	@echo "  clean      - Clean build artifacts"
	@echo "  run-srv    - Run the agent assistant server"
	@echo "  run-client - Run the example client"
	@echo "  generate   - Generate protobuf code"
	@echo "  proto-gen  - Alias for generate"
	@echo "  help       - Show this help message"

# Build all binaries
build:
	@echo "Building agent assistant server..."
	go build -o bin/agentassistant-srv ./cmd/agentassistant-srv
	@echo "Building agent assistant MCP..."
	go build -o bin/agentassistant-mcp ./cmd/agentassistant-mcp
	@echo "Building example client..."
	go build -o bin/example-client ./examples/client
	@echo "Build complete!"

# Run tests
test:
	@echo "Running tests..."
	go test -v ./internal/service
	go test -v ./...

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf bin/
	go clean

# Run the server
run-srv:
	@echo "Starting Agent Assistant server..."
	go run ./cmd/agentassistant-srv

# Run the example client
run-client:
	@echo "Running example client..."
	go run ./examples/client

# Generate protobuf code
generate: proto-gen

proto-gen:
	@echo "Generating protobuf code..."
	buf generate
	@echo "Protobuf generation complete!"

# Install dependencies
deps:
	@echo "Installing dependencies..."
	go mod tidy
	go mod download

# Format code
fmt:
	@echo "Formatting code..."
	go fmt ./...

# Lint code
lint:
	@echo "Linting code..."
	golangci-lint run

# Run server in development mode with auto-restart
dev:
	@echo "Starting development server..."
	@which air > /dev/null || (echo "Installing air..." && go install github.com/cosmtrek/air@latest)
	air -c .air.toml

# Create directories
dirs:
	mkdir -p bin/

# Full build pipeline
all: clean deps generate fmt test build
	@echo "Full build pipeline complete!"
