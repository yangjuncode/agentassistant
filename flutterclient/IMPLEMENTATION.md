# Agent Assistant Flutter 客户端实现说明

## 概述

本文档详细说明了 Agent Assistant Flutter 客户端的实现，该客户端完全遵循项目规范，实现了与 agentassistant-srv 服务器的实时通信功能。

## 实现的功能

### 1. 核心功能
- ✅ 用户登录验证（基于 token）
- ✅ 接收 AI Agent 发送的问题（AskQuestion）
- ✅ 接收任务完成通知（WorkReport）
- ✅ 用户回复问题和确认任务
- ✅ 保存并显示历史对话记录
- ✅ 类似 IM 的聊天界面

### 2. 技术特性
- ✅ WebSocket 实时通信
- ✅ Protobuf 消息序列化
- ✅ 自动重连机制
- ✅ 多种内容类型支持（文本、图像、音频、嵌入式资源）
- ✅ Material Design 3 设计规范
- ✅ 响应式布局
- ✅ 本地数据持久化

### 3. 协议兼容性
- ✅ 完全兼容 WebsocketMessage 协议
- ✅ 支持所有定义的命令类型
- ✅ 正确处理 protobuf 消息格式

## 架构设计

### 分层架构

```
┌─────────────────────────────────────┐
│              UI Layer               │
│  (Screens, Widgets, Components)     │
├─────────────────────────────────────┤
│           State Management          │
│         (Provider Pattern)          │
├─────────────────────────────────────┤
│            Service Layer            │
│    (WebSocket, Storage, etc.)       │
├─────────────────────────────────────┤
│             Data Layer              │
│      (Models, Protobuf, etc.)       │
└─────────────────────────────────────┘
```

### 核心组件

1. **ChatProvider**: 状态管理中心
   - 管理 WebSocket 连接
   - 处理消息收发
   - 维护聊天状态

2. **WebSocketService**: WebSocket 通信服务
   - 建立和维护连接
   - 消息序列化/反序列化
   - 自动重连机制

3. **ChatMessage**: 消息数据模型
   - 统一的消息表示
   - 支持多种内容类型
   - 状态管理

## 关键实现细节

### 1. WebSocket 通信

```dart
// 连接建立
await _webSocketService.connect(serverUrl, token);

// 消息处理
_webSocketService.messageStream.listen(_handleWebSocketMessage);

// 发送回复
await _webSocketService.sendAskQuestionReply(originalRequest, response);
```

### 2. 消息状态管理

```dart
enum MessageStatus {
  pending,    // 待处理
  replied,    // 已回复
  confirmed,  // 已确认
  error,      // 错误
}
```

### 3. 内容类型支持

- **文本内容**: 直接显示，支持选择复制
- **图像内容**: Base64 解码显示，支持缩放
- **音频内容**: 内置播放器，支持播放控制
- **嵌入式资源**: 显示链接，支持外部打开

### 4. 自动重连机制

```dart
// 指数退避重连策略
final delay = Duration(
  milliseconds: AppConfig.reconnectDelayMs * _reconnectAttempts,
);
```

## 文件结构说明

### 配置文件
- `lib/config/app_config.dart`: 应用配置常量
- `lib/constants/websocket_commands.dart`: WebSocket 命令常量

### 数据层
- `lib/models/chat_message.dart`: 聊天消息模型
- `lib/proto/`: Protobuf 生成的 Dart 文件

### 服务层
- `lib/services/websocket_service.dart`: WebSocket 通信服务

### 状态管理
- `lib/providers/chat_provider.dart`: 聊天状态管理

### 界面层
- `lib/screens/login_screen.dart`: 登录界面
- `lib/screens/chat_screen.dart`: 聊天界面
- `lib/screens/settings_screen.dart`: 设置界面

### 组件库
- `lib/widgets/message_bubble.dart`: 消息气泡组件
- `lib/widgets/content_display.dart`: 内容显示组件
- `lib/widgets/connection_status_bar.dart`: 连接状态栏
- `lib/widgets/pending_actions_bar.dart`: 待处理操作栏

## 协议实现

### 支持的 WebSocket 命令

1. **UserLogin**: 用户登录验证
2. **AskQuestion**: 接收 AI Agent 问题
3. **AskQuestionReply**: 发送问题回复
4. **WorkReport**: 接收任务完成通知
5. **WorkReportReply**: 发送任务确认
6. **AskQuestionReplyNotification**: 问题回复通知
7. **WorkReportReplyNotification**: 任务确认通知

### 消息流程

```
AI Agent -> agentassistant-mcp -> agentassistant-srv -> Flutter Client
                                                    ↓
User Reply <- agentassistant-mcp <- agentassistant-srv <- Flutter Client
```

## 使用指南

### 1. 环境准备

```bash
# 安装依赖
flutter pub get

# 生成 Protobuf 文件
./generate_proto.sh
```

### 2. 配置服务器

在登录界面配置：
- 访问令牌（必需）
- 服务器地址（可选，默认 ws://localhost:8080/ws）

### 3. 使用流程

1. 启动应用，进入登录界面
2. 输入有效的访问令牌
3. 连接成功后进入聊天界面
4. 接收并回复 AI Agent 的问题
5. 确认任务完成通知

## 测试和调试

### 静态分析

```bash
flutter analyze
```

### 单元测试

```bash
flutter test
```

### 调试模式

```bash
flutter run --debug
```

## 已知限制

1. **网络依赖**: 需要稳定的网络连接
2. **平台限制**: 目前主要针对移动平台优化
3. **音频格式**: 音频播放支持有限的格式

## 未来改进

1. **离线支持**: 实现离线消息缓存
2. **推送通知**: 添加后台推送通知
3. **多语言**: 支持国际化
4. **主题定制**: 支持深色模式和主题切换
5. **性能优化**: 大量消息时的性能优化

## 故障排除

### 常见问题

1. **连接失败**: 检查服务器地址和网络连接
2. **Token 无效**: 确认 token 格式和有效性
3. **消息显示异常**: 重新生成 protobuf 文件

### 日志查看

```bash
# Flutter 日志
flutter logs

# Android 日志
adb logcat | grep flutter
```

## 总结

本 Flutter 客户端完全实现了 Agent Assistant 规范中定义的所有功能，提供了完整的移动端解决方案。代码结构清晰，易于维护和扩展，为用户提供了流畅的 AI Agent 交互体验。
