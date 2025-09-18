#!/bin/bash

# Test script to verify AskQuestionReply and WorkReportReply broadcast handling

echo "Testing Flutter client AskQuestionReply broadcast handling..."

# Start the server in background
echo "Starting server..."
PORT=8081 ./bin/agentassistant-srv > server.log 2>&1 &
SERVER_PID=$!

# Wait for server to start
sleep 3
echo "Server started with PID: $SERVER_PID"

echo "Please manually:"
echo "1. Start TWO Flutter clients (or one Flutter + one Web client)"
echo "2. Connect both clients to the server using token 'test-token'"
echo "3. Press Enter to send test messages"

read -p "Press Enter when both clients are connected..."

# Send a test AskQuestion message
echo "=== Test 1: AskQuestion Broadcast ==="
echo "Sending AskQuestion message..."
curl -X POST http://localhost:8081/agentassistproto.SrvAgentAssist/AskQuestion \
  -H "Content-Type: application/connect+proto" \
  -H "Connect-Protocol-Version: 1" \
  -d '{
    "ID": "test-broadcast-question",
    "UserToken": "test-token",
    "Request": {
      "ProjectDirectory": "/test",
      "Question": "Should we deploy the new feature to production?",
      "Timeout": 300
    }
  }' &

CURL_PID1=$!

echo "AskQuestion message sent. Both clients should see the question."
echo "Now reply to the question from ONE client (using OK, Continue, or custom text)."
echo "The OTHER client should automatically update to show 'already replied'."

read -p "Press Enter after testing question reply broadcast..."

# Send a work_report message
echo "=== Test 2: WorkReport Broadcast ==="
echo "Sending WorkReport message..."
curl -X POST http://localhost:8081/agentassistproto.SrvAgentAssist/WorkReport \
  -H "Content-Type: application/connect+proto" \
  -H "Connect-Protocol-Version: 1" \
  -d '{
    "ID": "test-broadcast-task",
    "UserToken": "test-token",
    "Request": {
      "ProjectDirectory": "/test",
      "Summary": "Code review completed for PR #123"
    }
  }' &

WORK_REPORT_CURL_PID=$!

echo "WorkReport message sent. Both clients should see the task."
echo "Now confirm the task from ONE client (using OK, Continue, or custom text)."
echo "The OTHER client should automatically update to show 'already confirmed'."

read -p "Press Enter after testing task confirmation broadcast..."

echo "=== Expected Behavior ==="
echo "✅ Both clients receive the same messages"
echo "✅ When one client replies/confirms, the other client sees status update"
echo "✅ Message status changes from '待处理' to '已回复' or '已确认'"
echo "✅ No duplicate replies are possible"
echo "✅ Real-time synchronization between clients"

echo "=== Server Logs ==="
echo "Checking server logs for broadcast messages..."
cat server.log | grep -E "(broadcast|notification|reply)" | tail -10 || echo "No broadcast messages found"

# Cleanup
echo "=== Cleanup ==="
kill $CURL_PID1 2>/dev/null
kill $WORK_REPORT_CURL_PID 2>/dev/null
kill $SERVER_PID 2>/dev/null

echo "Test completed!"
echo ""
echo "If the broadcast handling is working correctly, you should have observed:"
echo "1. Messages appearing in both clients simultaneously"
echo "2. Status updates propagating from one client to another"
echo "3. Prevention of duplicate replies/confirmations"
echo "4. Real-time collaboration between multiple users"
