package main

import (
	"bufio"
	"bytes"
	"context"
	"encoding/json"
	"strings"
	"testing"
	"time"

	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"
)

func TestConcurrentStdioProcessesToolCallsConcurrently(t *testing.T) {
	started := make(chan struct{}, 2)
	release := make(chan struct{})

	mcpServer := server.NewMCPServer("test", "1.0.0", server.WithToolCapabilities(false))
	mcpServer.AddTool(mcp.NewTool("blocking_tool"), func(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
		started <- struct{}{}
		select {
		case <-release:
			return mcp.NewToolResultText("done"), nil
		case <-ctx.Done():
			return nil, ctx.Err()
		}
	})

	input := strings.Join([]string{
		mustMarshalJSONLine(t, map[string]any{
			"jsonrpc": "2.0",
			"id":      1,
			"method":  "initialize",
			"params": map[string]any{
				"protocolVersion": "2024-11-05",
				"clientInfo": map[string]any{
					"name":    "test-client",
					"version": "1.0.0",
				},
			},
		}),
		mustMarshalJSONLine(t, map[string]any{
			"jsonrpc": "2.0",
			"id":      2,
			"method":  "tools/call",
			"params": map[string]any{
				"name": "blocking_tool",
			},
		}),
		mustMarshalJSONLine(t, map[string]any{
			"jsonrpc": "2.0",
			"id":      3,
			"method":  "tools/call",
			"params": map[string]any{
				"name": "blocking_tool",
			},
		}),
		"",
	}, "\n")

	var stdout bytes.Buffer
	errCh := make(chan error, 1)
	go func() {
		errCh <- listenConcurrentStdio(context.Background(), strings.NewReader(input), &stdout, mcpServer)
	}()

	waitForToolStart(t, started)
	waitForToolStart(t, started)

	close(release)

	select {
	case err := <-errCh:
		if err != nil {
			t.Fatalf("listenConcurrentStdio returned error: %v", err)
		}
	case <-time.After(time.Second):
		t.Fatal("stdio server did not finish after releasing tool handlers")
	}

	responseIDs := readResponseIDs(t, stdout.String())
	for _, want := range []float64{1, 2, 3} {
		if !containsResponseID(responseIDs, want) {
			t.Fatalf("missing response id %v in %v", want, responseIDs)
		}
	}
}

func mustMarshalJSONLine(t *testing.T, value any) string {
	t.Helper()

	data, err := json.Marshal(value)
	if err != nil {
		t.Fatalf("json.Marshal failed: %v", err)
	}
	return string(data)
}

func waitForToolStart(t *testing.T, started <-chan struct{}) {
	t.Helper()

	select {
	case <-started:
	case <-time.After(250 * time.Millisecond):
		t.Fatal("timed out waiting for concurrent tool handler to start")
	}
}

func readResponseIDs(t *testing.T, output string) []float64 {
	t.Helper()

	var ids []float64
	scanner := bufio.NewScanner(strings.NewReader(output))
	for scanner.Scan() {
		var response map[string]any
		if err := json.Unmarshal(scanner.Bytes(), &response); err != nil {
			t.Fatalf("invalid JSON-RPC response line %q: %v", scanner.Text(), err)
		}
		id, ok := response["id"].(float64)
		if !ok {
			t.Fatalf("response line is missing numeric id: %s", scanner.Text())
		}
		ids = append(ids, id)
	}
	if err := scanner.Err(); err != nil {
		t.Fatalf("failed to scan responses: %v", err)
	}
	return ids
}

func containsResponseID(ids []float64, want float64) bool {
	for _, id := range ids {
		if id == want {
			return true
		}
	}
	return false
}
