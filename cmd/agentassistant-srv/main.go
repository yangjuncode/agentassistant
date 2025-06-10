package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/yangjuncode/agentassistant/agentassistproto"
	"github.com/yangjuncode/agentassistant/internal/service"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
)

func main() {
	// Create the service instance
	svc := service.NewAgentAssistService()

	// Create HTTP mux
	mux := http.NewServeMux()

	// Register the Connect-Go handlers
	path, handler := agentassistproto.NewSrvAgentAssistHandler(svc)
	mux.Handle(path, handler)

	// Register WebSocket handler for web interface
	wsHandler := service.NewWebSocketHandler(svc.GetBroadcaster())
	mux.HandleFunc("/ws", wsHandler.HandleWebSocket)

	// Add health check endpoint
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, "OK")
	})

	// Serve static files from web/dist directory
	webDir := "www/dist"
	if _, err := os.Stat(webDir); err == nil {
		fileServer := http.FileServer(http.Dir(webDir))
		mux.Handle("/", fileServer)
	} else {
		// Fallback to examples/webclient if web/dist doesn't exist
		exampleDir := "examples/webclient"
		if _, err := os.Stat(exampleDir); err == nil {
			fileServer := http.FileServer(http.Dir(exampleDir))
			mux.Handle("/", fileServer)
		} else {
			// Serve a simple message if no web files are found
			mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
				w.Header().Set("Content-Type", "text/html")
				w.WriteHeader(http.StatusOK)
				w.Write([]byte(`
<!DOCTYPE html>
<html>
<head>
    <title>Agent Assistant Server</title>
</head>
<body>
    <h1>Agent Assistant Server</h1>
    <p>Server is running on port 8080</p>
    <p>WebSocket endpoint: /ws</p>
    <p>RPC endpoints:</p>
    <ul>
        <li>/agentassistproto.SrvAgentAssist/AskQuestion</li>
        <li>/agentassistproto.SrvAgentAssist/TaskFinish</li>
    </ul>
</body>
</html>
				`))
			})
		}
	}

	// Add CORS middleware for web interface
	corsHandler := addCORS(mux)

	// Create HTTP server with HTTP/2 support
	server := &http.Server{
		Addr:    ":8080",
		Handler: h2c.NewHandler(corsHandler, &http2.Server{}),
	}

	// Start server in a goroutine
	go func() {
		log.Printf("Starting Agent Assistant server on :8080")
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed to start: %v", err)
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("Shutting down server...")

	// Create a deadline to wait for
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Attempt graceful shutdown
	if err := server.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

	log.Println("Server exited")
}

// addCORS adds CORS headers to allow web interface access
func addCORS(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, Connect-Protocol-Version, Connect-Timeout-Ms")
		w.Header().Set("Access-Control-Expose-Headers", "Connect-Protocol-Version")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		h.ServeHTTP(w, r)
	})
}
