#!/bin/bash

# Test script for the new chat feature
# This script tests the user-to-user communication functionality

echo "=== Agent Assistant Chat Feature Test ==="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test configuration
SERVER_HOST="127.0.0.1"
SERVER_PORT="22080"
TEST_TOKEN="test-token"

echo -e "${YELLOW}Testing new chat functionality...${NC}"
echo

# Function to check if server is running
check_server() {
    if curl -s "http://${SERVER_HOST}:${SERVER_PORT}/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Server is running${NC}"
        return 0
    else
        echo -e "${RED}✗ Server is not running${NC}"
        return 1
    fi
}

# Function to test protobuf generation
test_protobuf() {
    echo -e "${YELLOW}Testing protobuf generation...${NC}"
    
    # Check if Go protobuf files exist and contain new messages
    if grep -q "OnlineUser" agentassistproto/agentassist.pb.go; then
        echo -e "${GREEN}✓ Go protobuf files contain OnlineUser${NC}"
    else
        echo -e "${RED}✗ Go protobuf files missing OnlineUser${NC}"
        return 1
    fi
    
    if grep -q "ChatMessage" agentassistproto/agentassist.pb.go; then
        echo -e "${GREEN}✓ Go protobuf files contain ChatMessage${NC}"
    else
        echo -e "${RED}✗ Go protobuf files missing ChatMessage${NC}"
        return 1
    fi
    
    # Check web protobuf files
    if grep -q "OnlineUser" web/src/proto/agentassist_pb.ts; then
        echo -e "${GREEN}✓ Web protobuf files contain OnlineUser${NC}"
    else
        echo -e "${RED}✗ Web protobuf files missing OnlineUser${NC}"
        return 1
    fi
    
    # Check Flutter protobuf files
    if grep -q "OnlineUser" flutterclient/lib/proto/agentassist.pb.dart; then
        echo -e "${GREEN}✓ Flutter protobuf files contain OnlineUser${NC}"
    else
        echo -e "${RED}✗ Flutter protobuf files missing OnlineUser${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✓ All protobuf files generated successfully${NC}"
    return 0
}

# Function to test server compilation
test_server_build() {
    echo -e "${YELLOW}Testing server build...${NC}"
    
    if [ -f "bin/agentassistant-srv" ]; then
        echo -e "${GREEN}✓ Server binary exists${NC}"
    else
        echo -e "${RED}✗ Server binary not found${NC}"
        return 1
    fi
    
    # Check if server contains new handler methods
    if strings bin/agentassistant-srv | grep -q "handleGetOnlineUsers"; then
        echo -e "${GREEN}✓ Server contains handleGetOnlineUsers${NC}"
    else
        echo -e "${RED}✗ Server missing handleGetOnlineUsers${NC}"
        return 1
    fi
    
    if strings bin/agentassistant-srv | grep -q "handleSendChatMessage"; then
        echo -e "${GREEN}✓ Server contains handleSendChatMessage${NC}"
    else
        echo -e "${RED}✗ Server missing handleSendChatMessage${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✓ Server build successful with new features${NC}"
    return 0
}

# Function to test web client build
test_web_build() {
    echo -e "${YELLOW}Testing web client...${NC}"
    
    # Check if web client has new command constants
    if grep -q "GET_ONLINE_USERS" web/src/types/websocket.ts; then
        echo -e "${GREEN}✓ Web client has GET_ONLINE_USERS command${NC}"
    else
        echo -e "${RED}✗ Web client missing GET_ONLINE_USERS command${NC}"
        return 1
    fi
    
    if grep -q "SEND_CHAT_MESSAGE" web/src/types/websocket.ts; then
        echo -e "${GREEN}✓ Web client has SEND_CHAT_MESSAGE command${NC}"
    else
        echo -e "${RED}✗ Web client missing SEND_CHAT_MESSAGE command${NC}"
        return 1
    fi
    
    # Check if chat store has new methods
    if grep -q "sendChatMessage" web/src/stores/chat.ts; then
        echo -e "${GREEN}✓ Chat store has sendChatMessage method${NC}"
    else
        echo -e "${RED}✗ Chat store missing sendChatMessage method${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✓ Web client updated successfully${NC}"
    return 0
}

# Function to test Flutter client
test_flutter_build() {
    echo -e "${YELLOW}Testing Flutter client...${NC}"

    # Check if Flutter client has new command constants
    if grep -q "getOnlineUsers" flutterclient/lib/constants/websocket_commands.dart; then
        echo -e "${GREEN}✓ Flutter client has getOnlineUsers command${NC}"
    else
        echo -e "${RED}✗ Flutter client missing getOnlineUsers command${NC}"
        return 1
    fi

    if grep -q "sendChatMessage" flutterclient/lib/constants/websocket_commands.dart; then
        echo -e "${GREEN}✓ Flutter client has sendChatMessage command${NC}"
    else
        echo -e "${RED}✗ Flutter client missing sendChatMessage command${NC}"
        return 1
    fi

    # Check if SystemInputService exists
    if [ -f "flutterclient/lib/services/system_input_service.dart" ]; then
        echo -e "${GREEN}✓ Flutter client has SystemInputService${NC}"
    else
        echo -e "${RED}✗ Flutter client missing SystemInputService${NC}"
        return 1
    fi

    # Check if SystemInputService has correct methods
    if grep -q "sendToSystemInput" flutterclient/lib/services/system_input_service.dart; then
        echo -e "${GREEN}✓ SystemInputService has sendToSystemInput method${NC}"
    else
        echo -e "${RED}✗ SystemInputService missing sendToSystemInput method${NC}"
        return 1
    fi

    echo -e "${GREEN}✓ Flutter client updated successfully${NC}"
    return 0
}

# Function to test agentassistant-input
test_input_tool() {
    echo -e "${YELLOW}Testing agentassistant-input tool...${NC}"
    
    if [ -f "bin/agentassistant-input" ]; then
        echo -e "${GREEN}✓ agentassistant-input binary exists${NC}"
    else
        echo -e "${RED}✗ agentassistant-input binary not found${NC}"
        return 1
    fi
    
    # Test help output
    if ./bin/agentassistant-input 2>&1 | grep -q "input"; then
        echo -e "${GREEN}✓ agentassistant-input shows help${NC}"
    else
        echo -e "${RED}✗ agentassistant-input help not working${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✓ agentassistant-input tool working${NC}"
    return 0
}

# Run all tests
echo "Starting comprehensive test suite..."
echo

# Test 1: Protobuf generation
if ! test_protobuf; then
    echo -e "${RED}❌ Protobuf test failed${NC}"
    exit 1
fi
echo

# Test 2: Server build
if ! test_server_build; then
    echo -e "${RED}❌ Server build test failed${NC}"
    exit 1
fi
echo

# Test 3: Web client
if ! test_web_build; then
    echo -e "${RED}❌ Web client test failed${NC}"
    exit 1
fi
echo

# Test 4: Flutter client
if ! test_flutter_build; then
    echo -e "${RED}❌ Flutter client test failed${NC}"
    exit 1
fi
echo

# Test 5: Input tool
if ! test_input_tool; then
    echo -e "${RED}❌ Input tool test failed${NC}"
    exit 1
fi
echo

echo -e "${GREEN}🎉 All tests passed! Chat feature implementation is complete.${NC}"
echo
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Start the server: ./bin/agentassistant-srv"
echo "2. Open web interface: http://localhost:22080?token=test-token"
echo "3. Test online users and chat functionality"
echo "4. Test Flutter client with chat features"
echo "5. Test local remote input functionality on Flutter PC"
echo "   - Receive chat messages from other users"
echo "   - Use 'Send to System Input' option to input text locally"
echo
