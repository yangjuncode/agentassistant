#!/bin/bash

# Test script to verify nickname functionality

echo "Testing nickname functionality..."

# Start the server in background
echo "Starting server..."
PORT=8081 ./bin/agentassistant-srv > server.log 2>&1 &
SERVER_PID=$!

# Wait for server to start
sleep 3
echo "Server started with PID: $SERVER_PID"

echo "=== Nickname Feature Test ==="
echo ""
echo "Please follow these steps to test the nickname functionality:"
echo ""
echo "1. Start TWO clients (Flutter + Web or two Flutter clients)"
echo "2. Set different nicknames for each client:"
echo "   - Client 1: Set nickname to 'Alice'"
echo "   - Client 2: Set nickname to 'Bob'"
echo "3. Connect both clients to the server using token 'test-token'"
echo "4. Press Enter to send test messages"

read -p "Press Enter when both clients are connected with nicknames set..."

# Send a test AskQuestion message
echo "=== Test 1: AskQuestion with Nickname Display ==="
echo "Sending AskQuestion message..."
curl -X POST http://localhost:8081/agentassistproto.SrvAgentAssist/AskQuestion \
  -H "Content-Type: application/connect+proto" \
  -H "Connect-Protocol-Version: 1" \
  -d '{
    "ID": "test-nickname-question",
    "UserToken": "test-token",
    "Request": {
      "ProjectDirectory": "/test",
      "Question": "Which deployment strategy should we use?",
      "Timeout": 300
    }
  }' &

CURL_PID1=$!

echo "AskQuestion message sent. Both clients should see the question."
echo "Now reply to the question from ONE client (Alice or Bob)."
echo "The OTHER client should see: '[Nickname]的回复' instead of '其他用户的回复'."

read -p "Press Enter after testing question reply with nickname display..."

# Send a TaskFinish message
echo "=== Test 2: TaskFinish with Nickname Display ==="
echo "Sending TaskFinish message..."
curl -X POST http://localhost:8081/agentassistproto.SrvAgentAssist/TaskFinish \
  -H "Content-Type: application/connect+proto" \
  -H "Connect-Protocol-Version: 1" \
  -d '{
    "ID": "test-nickname-task",
    "UserToken": "test-token",
    "Request": {
      "ProjectDirectory": "/test",
      "Summary": "Code review completed for feature branch"
    }
  }' &

TASK_CURL_PID=$!

echo "TaskFinish message sent. Both clients should see the task."
echo "Now confirm the task from ONE client (Alice or Bob)."
echo "The OTHER client should see: '[Nickname]的确认' instead of '其他用户的确认'."

read -p "Press Enter after testing task confirmation with nickname display..."

echo "=== Expected Behavior ==="
echo "✅ Both clients can set custom nicknames"
echo "✅ Nicknames are sent during login"
echo "✅ Server stores and broadcasts nicknames"
echo "✅ Reply notifications show actual nicknames:"
echo "   - 'Alice的回复' instead of '其他用户的回复'"
echo "   - 'Bob的确认' instead of '其他用户的确认'"
echo "✅ Current user's own replies show '您的回复/您的确认'"
echo "✅ Nicknames persist across sessions"

echo "=== Additional Tests ==="
echo "You can also test:"
echo "• Default nickname generation when none is set"
echo "• Nickname validation (2-20 characters)"
echo "• Nickname settings UI in both clients"
echo "• Nickname persistence after reconnection"

echo "=== Server Logs ==="
echo "Checking server logs for nickname information..."
cat server.log | grep -E "(nickname|Nickname)" | tail -10 || echo "No nickname logs found"

# Cleanup
echo "=== Cleanup ==="
kill $CURL_PID1 2>/dev/null
kill $TASK_CURL_PID 2>/dev/null
kill $SERVER_PID 2>/dev/null

echo "Test completed!"
echo ""
echo "If the nickname functionality is working correctly, you should have observed:"
echo "1. Ability to set custom nicknames in both clients"
echo "2. Nicknames displayed in reply notifications"
echo "3. Proper distinction between own replies and others' replies"
echo "4. Nickname persistence and proper server handling"
