#!/bin/bash

# Test script to verify nickname real-time update functionality

echo "=== Nickname实时更新功能测试 ==="
echo ""

# Start the server in background
echo "启动服务器..."
PORT=8081 ./bin/agentassistant-srv > server.log 2>&1 &
SERVER_PID=$!

# Wait for server to start
sleep 3
echo "服务器已启动 (PID: $SERVER_PID)"
echo ""

echo "📋 测试步骤："
echo "1. 启动两个客户端并设置不同昵称"
echo "2. 发送测试消息并回复"
echo "3. 修改其中一个客户端的昵称"
echo "4. 发送新消息验证昵称实时更新"
echo ""

read -p "按Enter键开始发送第一个测试消息..."

# Send first test message
echo "=== 发送第一个测试消息 ==="
curl -X POST http://localhost:8081/agentassistproto.SrvAgentAssist/AskQuestion \
  -H "Content-Type: application/connect+proto" \
  -H "Connect-Protocol-Version: 1" \
  -d '{
    "ID": "test-nickname-1",
    "UserToken": "test-token",
    "Request": {
      "ProjectDirectory": "/test",
      "Question": "应该使用哪种部署策略？",
      "Timeout": 300
    }
  }' &

echo "第一个测试消息已发送"
echo "请在其中一个客户端回复此消息，然后按Enter继续..."
read

echo ""
echo "=== 现在请修改昵称 ==="
echo "1. 在刚才回复的客户端中修改昵称"
echo "2. 保存新昵称（系统会自动向服务器发送更新）"
echo "3. 修改完成后按Enter继续..."
read

echo ""
echo "=== 发送第二个测试消息验证昵称更新 ==="
curl -X POST http://localhost:8081/agentassistproto.SrvAgentAssist/AskQuestion \
  -H "Content-Type: application/connect+proto" \
  -H "Connect-Protocol-Version: 1" \
  -d '{
    "ID": "test-nickname-2",
    "UserToken": "test-token",
    "Request": {
      "ProjectDirectory": "/test",
      "Question": "如何优化数据库性能？",
      "Timeout": 300
    }
  }' &

echo "第二个测试消息已发送"
echo "请在修改昵称的客户端回复此消息"
echo ""

echo "=== 验证结果 ==="
echo "在另一个客户端中，您应该看到："
echo "• 第一个回复：显示旧昵称"
echo "• 第二个回复：显示新昵称"
echo ""

read -p "测试完成后按Enter查看服务器日志..."

echo "=== 服务器日志中的昵称信息 ==="
echo "查找昵称相关的日志："
grep -E "(nickname|Nickname)" server.log | tail -20 || echo "未找到昵称相关日志"

echo ""
echo "=== 预期行为 ==="
echo "✅ 昵称修改后立即向服务器发送UserLogin消息"
echo "✅ 服务器更新客户端昵称信息"
echo "✅ 后续回复显示新昵称，无需重连"
echo "✅ 其他客户端看到更新后的昵称"

# Cleanup
echo ""
echo "=== 清理 ==="
kill $SERVER_PID 2>/dev/null
echo "服务器已停止"

echo ""
echo "🎉 测试完成！"
echo ""
echo "如果功能正常，您应该观察到："
echo "1. 昵称设置界面可以正常使用"
echo "2. 昵称修改后立即生效，无需重连"
echo "3. 其他用户看到的是更新后的昵称"
echo "4. 服务器日志显示昵称更新信息"
