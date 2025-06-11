# Nickname功能测试指南

## 🎯 测试目标

验证Web客户端和Flutter客户端的nickname功能是否正常工作，包括：
- 昵称设置界面
- 昵称在回复中的显示
- 昵称的持久化存储

## 🚀 快速测试步骤

### 1. 启动服务端
```bash
cd /home/yj/github.com/yangjuncode/agentassistant
PORT=8081 ./bin/agentassistant-srv
```

### 2. 启动Web客户端
```bash
cd web
pnpm run dev
# 或者使用构建版本
pnpm run serve
```
然后访问：`http://localhost:9000/chat?token=test-token`

### 3. 启动Flutter客户端
```bash
cd flutterclient
flutter run -d linux
```
在登录界面输入：
- Server URL: `ws://localhost:8081/ws`
- Token: `test-token`

## 🔧 测试步骤详解

### 步骤1：设置昵称

#### Web客户端
1. 打开聊天页面
2. 点击右上角的**设置按钮**（齿轮图标）
3. 在弹出的设置对话框中找到**昵称设置**部分
4. 输入昵称，例如："Alice"
5. 点击**保存**

#### Flutter客户端
1. 连接成功后，点击右上角的**菜单按钮**
2. 选择**设置**
3. 在**用户设置**部分找到**昵称设置**
4. 输入昵称，例如："Bob"
5. 点击**保存**

### 步骤2：测试昵称显示

#### 发送测试消息
使用curl发送测试消息：

```bash
# 发送问题消息
curl -X POST http://localhost:8081/agentassistproto.SrvAgentAssist/AskQuestion \
  -H "Content-Type: application/connect+proto" \
  -H "Connect-Protocol-Version: 1" \
  -d '{
    "ID": "test-nickname-question",
    "UserToken": "test-token",
    "Request": {
      "ProjectDirectory": "/test",
      "Question": "应该使用哪种部署策略？",
      "Timeout": 300
    }
  }'
```

#### 验证昵称显示
1. 两个客户端都应该收到问题消息
2. 在**Alice**（Web客户端）中回复问题
3. 在**Bob**（Flutter客户端）中应该看到："Alice的回复"
4. 在**Alice**（Web客户端）中应该看到："您的回复"

### 步骤3：测试昵称实时更新 🆕

#### 测试昵称动态更新
1. 在**Alice**（Web客户端）中，将昵称从"Alice"改为"Alice_Updated"
2. 保存昵称（系统会自动向服务器发送更新）
3. 发送另一个测试消息：

```bash
# 发送第二个问题消息
curl -X POST http://localhost:8081/agentassistproto.SrvAgentAssist/AskQuestion \
  -H "Content-Type: application/connect+proto" \
  -H "Connect-Protocol-Version: 1" \
  -d '{
    "ID": "test-nickname-question-2",
    "UserToken": "test-token",
    "Request": {
      "ProjectDirectory": "/test",
      "Question": "如何优化数据库性能？",
      "Timeout": 300
    }
  }'
```

4. 在**Alice**（Web客户端）中回复第二个问题
5. 在**Bob**（Flutter客户端）中应该看到："Alice_Updated的回复"（新昵称）

#### 验证实时更新效果
- ✅ 昵称更改后立即生效，无需重连
- ✅ 其他用户看到的是更新后的昵称
- ✅ 服务端日志显示昵称更新信息

## ✅ 预期结果

### 昵称设置
- ✅ Web客户端有设置按钮和昵称设置界面
- ✅ Flutter客户端在设置页面有昵称设置部分
- ✅ 昵称输入验证（2-20字符）
- ✅ 昵称保存到本地存储
- ✅ 默认昵称自动生成

### 昵称显示
- ✅ 自己的回复显示："您的回复/您的确认"
- ✅ 他人的回复显示："[昵称]的回复/[昵称]的确认"
- ✅ 未设置昵称时显示默认昵称
- ✅ 昵称在重连后保持

### 服务端处理
- ✅ 服务端接收并存储客户端昵称
- ✅ 广播通知包含回复者昵称
- ✅ 服务端日志显示昵称信息

## 🐛 故障排除

### 问题1：找不到设置按钮
**Web客户端**：检查ChatPage右上角是否有齿轮图标
**Flutter客户端**：检查聊天页面右上角是否有菜单按钮

### 问题2：昵称设置界面不显示
检查组件导入和路由配置是否正确

### 问题3：昵称不显示在回复中
1. 检查服务端日志是否收到昵称
2. 检查广播消息是否包含Nickname字段
3. 检查客户端是否正确解析昵称

### 问题4：昵称不持久化
检查本地存储权限和SharedPreferences/localStorage功能

## 📝 测试检查清单

### Web客户端
- [ ] 设置按钮可见
- [ ] 昵称设置对话框打开
- [ ] 昵称输入和验证工作
- [ ] 昵称保存成功
- [ ] 回复显示正确昵称
- [ ] 重新加载后昵称保持

### Flutter客户端
- [ ] 设置页面有昵称设置
- [ ] 昵称输入和验证工作
- [ ] 昵称保存成功
- [ ] 回复显示正确昵称
- [ ] 重启应用后昵称保持

### 跨客户端测试
- [ ] Web客户端回复在Flutter中显示昵称
- [ ] Flutter客户端回复在Web中显示昵称
- [ ] 多个客户端同时连接时昵称正确区分

## 🔍 调试信息

### 服务端日志关键词
```
grep -E "(nickname|Nickname)" server.log
```

### 浏览器开发者工具
检查WebSocket消息中的Nickname字段

### Flutter调试
查看控制台输出中的昵称相关日志

## 📞 如果遇到问题

如果测试过程中遇到任何问题，请检查：

1. **构建是否成功**：确保所有客户端都重新构建
2. **服务端版本**：确保使用最新的服务端代码
3. **网络连接**：确保WebSocket连接正常
4. **浏览器缓存**：清除浏览器缓存和本地存储
5. **权限问题**：确保应用有本地存储权限

测试完成后，nickname功能应该让多用户协作更加人性化和易于识别！
