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

	"github.com/yangjuncode/agentassistant/agentassistantconnect"
	"github.com/yangjuncode/agentassistant/internal/service"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
)

func main() {
	// Create the service instance
	svc := service.NewAgentAssistService()

	// Create HTTP mux
	mux := http.NewServeMux()

	// Register the Connect-Go handler
	path, handler := agentassistantconnect.NewSrvAgentAssistHandler(svc)
	mux.Handle(path, handler)

	// Register WebSocket handler for web interface
	wsHandler := service.NewWebSocketHandler(svc.GetBroadcaster())
	mux.HandleFunc("/ws", wsHandler.HandleWebSocket)

	// Add health check endpoint
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, "OK")
	})

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
