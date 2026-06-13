package main

import (
	"bufio"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"os"
	"os/signal"
	"strings"
	"sync"
	"sync/atomic"
	"syscall"

	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"
)

type concurrentStdioSession struct {
	notifications chan mcp.JSONRPCNotification
	initialized   atomic.Bool
	loggingLevel  atomic.Value
	clientInfo    atomic.Value
}

func newConcurrentStdioSession() *concurrentStdioSession {
	session := &concurrentStdioSession{
		notifications: make(chan mcp.JSONRPCNotification, 100),
	}
	session.loggingLevel.Store(mcp.LoggingLevelError)
	return session
}

func (s *concurrentStdioSession) SessionID() string {
	return "stdio"
}

func (s *concurrentStdioSession) NotificationChannel() chan<- mcp.JSONRPCNotification {
	return s.notifications
}

func (s *concurrentStdioSession) Initialize() {
	s.loggingLevel.Store(mcp.LoggingLevelError)
	s.initialized.Store(true)
}

func (s *concurrentStdioSession) Initialized() bool {
	return s.initialized.Load()
}

func (s *concurrentStdioSession) GetClientInfo() mcp.Implementation {
	value := s.clientInfo.Load()
	if value == nil {
		return mcp.Implementation{}
	}
	clientInfo, ok := value.(mcp.Implementation)
	if !ok {
		return mcp.Implementation{}
	}
	return clientInfo
}

func (s *concurrentStdioSession) SetClientInfo(clientInfo mcp.Implementation) {
	s.clientInfo.Store(clientInfo)
}

func (s *concurrentStdioSession) SetLogLevel(level mcp.LoggingLevel) {
	s.loggingLevel.Store(level)
}

func (s *concurrentStdioSession) GetLogLevel() mcp.LoggingLevel {
	value := s.loggingLevel.Load()
	if value == nil {
		return mcp.LoggingLevelError
	}
	level, ok := value.(mcp.LoggingLevel)
	if !ok {
		return mcp.LoggingLevelError
	}
	return level
}

var (
	_ server.ClientSession         = (*concurrentStdioSession)(nil)
	_ server.SessionWithLogging    = (*concurrentStdioSession)(nil)
	_ server.SessionWithClientInfo = (*concurrentStdioSession)(nil)
)

type concurrentStdioServer struct {
	server    *server.MCPServer
	errLogger *log.Logger
	writeMu   sync.Mutex
}

func serveConcurrentStdio(mcpServer *server.MCPServer) error {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGTERM, syscall.SIGINT)
	defer signal.Stop(sigChan)

	go func() {
		select {
		case <-sigChan:
			cancel()
		case <-ctx.Done():
		}
	}()

	return listenConcurrentStdio(ctx, os.Stdin, os.Stdout, mcpServer)
}

func listenConcurrentStdio(
	ctx context.Context,
	stdin io.Reader,
	stdout io.Writer,
	mcpServer *server.MCPServer,
) error {
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	session := newConcurrentStdioSession()
	if err := mcpServer.RegisterSession(ctx, session); err != nil {
		return fmt.Errorf("register session: %w", err)
	}
	defer mcpServer.UnregisterSession(ctx, session.SessionID())

	ctx = mcpServer.WithContext(ctx, session)
	stdioServer := &concurrentStdioServer{
		server:    mcpServer,
		errLogger: log.New(os.Stderr, "", log.LstdFlags),
	}

	go stdioServer.handleNotifications(ctx, session, stdout)
	return stdioServer.processInputStream(ctx, bufio.NewReader(stdin), stdout)
}

func (s *concurrentStdioServer) handleNotifications(
	ctx context.Context,
	session *concurrentStdioSession,
	stdout io.Writer,
) {
	for {
		select {
		case notification := <-session.notifications:
			if err := s.writeResponse(notification, stdout); err != nil {
				s.errLogger.Printf("Error writing notification: %v", err)
			}
		case <-ctx.Done():
			return
		}
	}
}

func (s *concurrentStdioServer) processInputStream(
	ctx context.Context,
	reader *bufio.Reader,
	stdout io.Writer,
) error {
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	var wg sync.WaitGroup
	errCh := make(chan error, 1)

	for {
		if err := ctx.Err(); err != nil {
			return err
		}
		select {
		case err := <-errCh:
			return err
		default:
		}

		line, err := readNextStdioLine(ctx, reader)
		if err != nil {
			if err == io.EOF {
				return waitForConcurrentStdioHandlers(ctx, &wg)
			}
			return err
		}

		if isToolCallRequest(line) {
			wg.Add(1)
			go func(line string) {
				defer wg.Done()
				if err := s.processMessage(ctx, line, stdout); err != nil {
					select {
					case errCh <- err:
						cancel()
					default:
					}
				}
			}(line)
			continue
		}

		if err := s.processMessage(ctx, line, stdout); err != nil {
			if err == io.EOF {
				return waitForConcurrentStdioHandlers(ctx, &wg)
			}
			return err
		}
	}
}

func readNextStdioLine(ctx context.Context, reader *bufio.Reader) (string, error) {
	type result struct {
		line string
		err  error
	}

	resultCh := make(chan result, 1)
	go func() {
		line, err := reader.ReadString('\n')
		resultCh <- result{line: line, err: err}
	}()

	select {
	case <-ctx.Done():
		return "", ctx.Err()
	case res := <-resultCh:
		return res.line, res.err
	}
}

func isToolCallRequest(line string) bool {
	var envelope struct {
		Method mcp.MCPMethod   `json:"method"`
		ID     json.RawMessage `json:"id"`
	}
	if err := json.Unmarshal([]byte(line), &envelope); err != nil {
		return false
	}

	id := strings.TrimSpace(string(envelope.ID))
	return envelope.Method == mcp.MethodToolsCall && id != "" && id != "null"
}

func waitForConcurrentStdioHandlers(ctx context.Context, wg *sync.WaitGroup) error {
	done := make(chan struct{})
	go func() {
		wg.Wait()
		close(done)
	}()

	select {
	case <-ctx.Done():
		return ctx.Err()
	case <-done:
		return nil
	}
}

func (s *concurrentStdioServer) processMessage(
	ctx context.Context,
	line string,
	stdout io.Writer,
) error {
	var rawMessage json.RawMessage
	if err := json.Unmarshal([]byte(line), &rawMessage); err != nil {
		response := mcp.NewJSONRPCError(mcp.NewRequestId(nil), mcp.PARSE_ERROR, "Parse error", nil)
		return s.writeResponse(response, stdout)
	}

	response := s.server.HandleMessage(ctx, rawMessage)
	if response == nil {
		return nil
	}
	if err := s.writeResponse(response, stdout); err != nil {
		return fmt.Errorf("failed to write response: %w", err)
	}
	return nil
}

func (s *concurrentStdioServer) writeResponse(response mcp.JSONRPCMessage, writer io.Writer) error {
	responseBytes, err := json.Marshal(response)
	if err != nil {
		return err
	}

	s.writeMu.Lock()
	defer s.writeMu.Unlock()

	_, err = fmt.Fprintf(writer, "%s\n", responseBytes)
	return err
}
