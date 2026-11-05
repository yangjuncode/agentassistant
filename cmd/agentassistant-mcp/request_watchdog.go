package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"time"

	"connectrpc.com/connect"
	"github.com/yangjuncode/agentassistant/agentassistproto"
)

// The server owns the inactivity timeout of a pending request: it restarts the
// timer whenever the user is active, and it enforces an absolute lifetime cap.
// The MCP side therefore does NOT need a wall clock of its own — imposing one
// would end the wait while the user is still typing. Instead it acts as a
// watchdog: it periodically asks the server whether the request is still
// pending, which detects a wedged connection (or a server that forgot the
// request) within a minute or two instead of hanging the tool call forever.
//
// Expressed as variables so tests can shrink them.
var (
	// how often the initiator asks the server whether the request is pending
	requestWatchPollInterval = 1 * time.Minute
	// deadline for one such query; a hung query counts as a failure
	requestWatchPollTimeout = 15 * time.Second
	// consecutive failed queries tolerated before giving up. A single failure
	// is normal (transient reconnect), a run of them means we cannot confirm
	// the request is alive.
	requestWatchMaxPollFailures = 3
	// how long to wait for the in-flight RPC to deliver its result after the
	// server reported that the request is no longer pending
	requestWatchReplyGrace = 10 * time.Second
)

// errRequestGone is returned when the server no longer waits for the request
// but the RPC produced no result — i.e. the request expired, was cancelled, or
// was answered on a connection we can no longer reach.
var errRequestGone = errors.New("the Agent Assistant server is no longer waiting for a reply to this request")

// rpcResult carries the outcome of the blocking RPC.
type rpcResult[T any] struct {
	resp *connect.Response[T]
	err  error
}

// watchRequestStatus asks the server whether requestID is still pending.
func watchRequestStatus(ctx context.Context, requestID string, timeout time.Duration) (bool, error) {
	pollCtx, cancel := context.WithTimeout(ctx, timeout)
	defer cancel()

	resp, err := client.GetRequestStatus(pollCtx, connect.NewRequest(&agentassistproto.RequestStatusRequest{
		RequestId: requestID,
	}))
	if err != nil {
		return false, err
	}
	return resp.Msg.Pending, nil
}

// callWithWatchdog runs call (a blocking RPC that waits for the user) and, in
// the meantime, polls the server so a dead connection cannot hang the caller.
//
// It returns as soon as the RPC completes. If pollInterval is zero the watchdog
// is disabled and this degrades to a plain blocking call.
func callWithWatchdog[T any](
	ctx context.Context,
	requestID string,
	call func(context.Context) (*connect.Response[T], error),
) (*connect.Response[T], error) {
	rpcCtx, rpcCancel := context.WithCancel(ctx)
	defer rpcCancel()

	results := make(chan rpcResult[T], 1)
	go func() {
		resp, err := call(rpcCtx)
		results <- rpcResult[T]{resp: resp, err: err}
	}()

	if requestWatchPollInterval <= 0 {
		select {
		case res := <-results:
			return res.resp, res.err
		case <-ctx.Done():
			return nil, ctx.Err()
		}
	}

	ticker := time.NewTicker(requestWatchPollInterval)
	defer ticker.Stop()

	failures := 0
	for {
		select {
		case res := <-results:
			return res.resp, res.err

		case <-ticker.C:
			pending, err := watchRequestStatus(ctx, requestID, requestWatchPollTimeout)
			if err != nil {
				failures++
				log.Printf("Request status poll for %s failed (%d/%d): %v",
					requestID, failures, requestWatchMaxPollFailures, err)
				if failures < requestWatchMaxPollFailures {
					continue
				}
				rpcCancel()
				return nil, fmt.Errorf(
					"lost contact with the Agent Assistant server while waiting for a reply to request %s (%d consecutive status polls failed): %w",
					requestID, failures, err)
			}

			failures = 0
			if pending {
				continue
			}

			// The server is no longer waiting: either the reply just landed
			// (its response may still be in flight) or the request expired.
			select {
			case res := <-results:
				return res.resp, res.err
			case <-time.After(requestWatchReplyGrace):
			}

			log.Printf("Request %s is no longer pending on the server but the RPC produced no result", requestID)
			rpcCancel()
			return nil, errRequestGone

		case <-ctx.Done():
			rpcCancel()
			return nil, ctx.Err()
		}
	}
}
