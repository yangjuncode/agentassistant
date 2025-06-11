#!/bin/bash

# Test script to verify window popup functionality when messages are received

echo "Testing Flutter client window popup functionality..."

# Start the server in background
echo "Starting server..."
cd ..
PORT=8081 ./bin/agentassistant-srv > server.log 2>&1 &
SERVER_PID=$!

# Wait for server to start
sleep 3
echo "Server started with PID: $SERVER_PID"

# Start Flutter client in background
echo "Starting Flutter client..."
cd flutterclient
./build/linux/x64/debug/bundle/flutterclient &
FLUTTER_PID=$!

echo "Flutter client started with PID: $FLUTTER_PID"
echo "Please manually:"
echo "1. Connect to the server using token 'test-token'"
echo "2. Minimize or hide the Flutter window behind other windows"
echo "3. Press Enter to send a test message that should bring the window to front"

read -p "Press Enter when ready to test..."

# Send a test message to trigger window popup
echo "Sending test message to trigger window popup..."
curl -X POST http://localhost:8081/agentassistproto.SrvAgentAssist/AskQuestion \
  -H "Content-Type: application/connect+proto" \
  -H "Connect-Protocol-Version: 1" \
  -d '{
    "ID": "test-window-popup",
    "UserToken": "test-token",
    "Request": {
      "ProjectDirectory": "/test",
      "Question": "This is a test question to trigger window popup",
      "Timeout": 30
    }
  }' &

CURL_PID=$!

echo "Test message sent. The Flutter window should now come to the front."
echo "Check if the window appeared on top of other windows."

read -p "Press Enter to send another test message (TaskFinish)..."

# Send a TaskFinish message
curl -X POST http://localhost:8081/agentassistproto.SrvAgentAssist/TaskFinish \
  -H "Content-Type: application/connect+proto" \
  -H "Connect-Protocol-Version: 1" \
  -d '{
    "ID": "test-task-popup",
    "UserToken": "test-token",
    "Request": {
      "ProjectDirectory": "/test",
      "Summary": "This is a test task to trigger window popup"
    }
  }' &

TASK_CURL_PID=$!

echo "TaskFinish message sent. The Flutter window should come to front again."

read -p "Press Enter to cleanup and exit..."

# Cleanup
echo "Cleaning up..."
kill $CURL_PID 2>/dev/null
kill $TASK_CURL_PID 2>/dev/null
kill $FLUTTER_PID 2>/dev/null
kill $SERVER_PID 2>/dev/null

echo "Test completed!"
echo "Expected behavior:"
echo "- When messages are received, the Flutter window should automatically come to front"
echo "- The window should become visible and focused even if it was minimized or hidden"
echo "- On Linux X11, the window should stay on top for 5 seconds to ensure visibility"
echo "- The window should remain focused and not fall back to background immediately"
echo "- This should work reliably on Linux desktop environments"
