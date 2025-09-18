# Agent Assistant Flutter 客户端

Agent Assistant 的移动客户端应用，使用 Flutter 框架开发，提供与 AI Agent 的实时通信功能。

## 功能特性

- **实时通信**: 通过 WebSocket 与 agentassistant-srv 服务器建立实时连接
- **用户认证**: 基于 token 的用户登录验证
- **消息处理**: 接收和回复 AI Agent 的问题（AskQuestion）
- **任务管理**: 接收和确认任务完成通知（WorkReport）
- **多媒体支持**: 支持文本、图像、音频和嵌入式资源的显示
- **聊天界面**: 类似 IM 的聊天界面，保存历史对话记录
- **自动重连**: 网络断开时自动重连机制
- **Material Design**: 遵循 Material Design 设计规范
- **响应式布局**: 适配不同尺寸的移动设备

## 技术栈

- **Flutter**: 跨平台移动应用开发框架
- **Dart**: 编程语言
- **Provider**: 状态管理
- **WebSocket**: 实时通信
- **Protobuf**: 数据序列化
- **Material Design 3**: UI 设计系统

## 项目结构

```text
lib/
├── config/           # 应用配置
├── constants/        # 常量定义
├── models/          # 数据模型
├── providers/       # 状态管理
├── proto/           # Protobuf 生成的文件
├── screens/         # 页面组件
├── services/        # 服务层
├── widgets/         # 可复用组件
└── main.dart        # 应用入口
```

## 开始使用

### 前置要求

- Flutter SDK (>= 3.5.0)
- Dart SDK
- Android Studio / VS Code
- 运行中的 agentassistant-srv 服务器

### 安装依赖

```bash
cd flutterclient
flutter pub get
```

### 生成 Protobuf 文件

```bash
# 安装 protoc-gen-dart
dart pub global activate protoc_plugin

# 生成 Dart protobuf 文件
./generate_proto.sh
```

### 运行应用

```bash
# 开发模式运行
flutter run

# 构建 APK
flutter build apk

# 构建 iOS
flutter build ios

# 构建 Linux
flutter build linux --release
```

## 配置说明

### 服务器连接

应用启动时需要配置以下信息：

- **访问令牌**: 用于身份验证的 token
- **服务器地址**: agentassistant-srv 的 WebSocket 地址
  - 格式: `ws://host:port/ws` 或 `wss://host:port/ws`
  - 默认: `ws://localhost:8080/ws`

### 应用配置

主要配置项在 `lib/config/app_config.dart` 中：

```dart
class AppConfig {
  // WebSocket 配置
  static const String defaultWebSocketHost = 'localhost';
  static const int defaultWebSocketPort = 8080;

  // 连接设置
  static const int maxReconnectAttempts = 5;
  static const int reconnectDelayMs = 1000;

  // UI 设置
  static const int maxMessageLength = 10000;
  static const int messageHistoryLimit = 1000;
}
```

## 使用说明

### 1. 登录

1. 启动应用后进入登录界面
2. 输入访问令牌（从系统管理员获取）
3. 可选：配置服务器地址（高级设置）
4. 点击"连接"按钮

### 2. 聊天界面

- **接收问题**: AI Agent 发送的问题会显示在聊天界面
- **回复问题**: 点击"回复"按钮输入回答
- **任务通知**: 接收任务完成通知
- **确认任务**: 点击"确认"按钮确认任务完成

### 3. 设置

- **连接状态**: 查看当前连接状态
- **消息统计**: 查看消息数量和待处理项目
- **清除消息**: 删除所有聊天记录
- **应用信息**: 查看版本信息

## 开发指南

### 添加新功能

1. **数据模型**: 在 `lib/models/` 中定义数据结构
2. **服务层**: 在 `lib/services/` 中实现业务逻辑
3. **状态管理**: 在 `lib/providers/` 中管理应用状态
4. **UI 组件**: 在 `lib/widgets/` 或 `lib/screens/` 中创建界面

### 调试

```bash
# 启用调试模式
flutter run --debug

# 查看日志
flutter logs

# 分析代码
flutter analyze
```

### 测试

```bash
# 运行单元测试
flutter test

# 运行集成测试
flutter drive --target=test_driver/app.dart
```

## 故障排除

### 常见问题

1. **连接失败**
   - 检查服务器地址是否正确
   - 确认 agentassistant-srv 服务正在运行
   - 验证网络连接

2. **Token 无效**
   - 联系系统管理员获取有效 token
   - 确认 token 格式正确（至少10个字符）

3. **消息显示异常**
   - 检查 protobuf 文件是否最新
   - 重新生成 protobuf 文件

### 日志查看

应用使用 `logger` 包记录日志，可以通过以下方式查看：

```bash
# Flutter 控制台日志
flutter logs

# Android 设备日志
adb logcat | grep flutter
```

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证。详见 LICENSE 文件。
