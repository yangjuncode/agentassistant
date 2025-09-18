# Flutter客户端窗口弹出功能

## 功能概述

当Flutter桌面客户端在后台运行或被其他窗口遮挡时，如果收到新的消息（AskQuestion或WorkReport），窗口会自动弹出到前台并获得焦点，确保用户能够及时看到新消息。

## 实现细节

### 1. 依赖添加

在`pubspec.yaml`中添加了`window_manager`依赖：

```yaml
dependencies:
  # Desktop Window Management
  window_manager: ^0.3.9
```

### 2. 窗口服务 (WindowService)

创建了`lib/services/window_service.dart`，提供以下功能：

- **初始化窗口管理器**：设置窗口大小、位置等基本属性
- **窗口弹出**：`bringToFront()` - 将窗口带到前台并获得焦点
- **窗口闪烁**：`flashWindow()` - 在任务栏中闪烁窗口图标（Windows）
- **状态检查**：检查窗口是否聚焦、是否可见等

#### 关键方法

```dart
// 将窗口带到前台
Future<void> bringToFront() async {
  // 如果窗口被最小化，先恢复
  if (await windowManager.isMinimized()) {
    await windowManager.restore();
  }
  
  // 如果窗口不可见，显示窗口
  if (!await windowManager.isVisible()) {
    await windowManager.show();
  }
  
  // 获得焦点并临时置顶
  await windowManager.show
  await windowManager.focus();
  await windowManager.setAlwaysOnTop(true);
  
  <!-- // 500ms后取消置顶，避免过于干扰用户
  Future.delayed(Duration(milliseconds: 500), () {
    windowManager.setAlwaysOnTop(false);
  }); -->
}
```

### 3. 主应用初始化

在`main.dart`中初始化窗口服务：

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化桌面窗口服务
  await WindowService().initialize();
  
  runApp(const AgentAssistantApp());
}
```

### 4. 消息处理集成

在`ChatProvider`中集成窗口弹出功能：

```dart
// 处理AskQuestion消息时
void _handleAskQuestionMessage(AskQuestionRequest request) {
  final chatMessage = ChatMessage.fromAskQuestionRequest(request);
  _addMessage(chatMessage);
  _logger.i('Received question: ${request.request.question}');
  
  // 收到新消息时弹出窗口
  _bringWindowToFrontIfNeeded();
}

// 处理WorkReport消息时
void _handleWorkReportMessage(WorkReportRequest request) {
  final chatMessage = ChatMessage.fromWorkReportRequest(request);
  _addMessage(chatMessage);
  _logger.i('Received task report: ${request.request.summary}');
  
  // 收到新消息时弹出窗口
  _bringWindowToFrontIfNeeded();
}

// 智能窗口弹出逻辑
Future<void> _bringWindowToFrontIfNeeded() async {
  final windowService = WindowService();
  
  // 只在桌面平台执行
  if (!windowService.isDesktop) return;
  
  try {
    // 检查窗口当前状态
    final isFocused = await windowService.isFocused();
    final isVisible = await windowService.isVisible();
    
    // 只有在窗口未聚焦或不可见时才弹出
    if (!isFocused || !isVisible) {
      _logger.i('Window not focused or visible, bringing to front');
      await windowService.bringToFront();
    }
  } catch (error) {
    _logger.e('Failed to bring window to front: $error');
  }
}
```

## 平台支持

- ✅ **Windows**：完全支持，包括任务栏闪烁
- ✅ **Linux X11**：特殊优化支持，窗口保持前台5秒确保可见性
- ✅ **macOS**：支持窗口弹出和焦点获取
- ❌ **移动平台**：自动跳过，不执行窗口操作

### Linux X11 特殊处理

由于Linux X11窗口管理器的特殊性，窗口可能会弹出后立即回到后台。为了解决这个问题，实现了以下特殊处理：

1. **多次聚焦**：连续3次调用focus()确保窗口获得焦点
2. **延长置顶时间**：窗口保持always-on-top状态5秒（而不是500ms）
3. **分步操作**：每个窗口操作之间添加延迟，确保X11有时间处理
4. **强制显示**：先restore、再show、再focus的完整流程

## 用户体验设计

### 智能弹出策略

1. **条件检查**：只有在窗口确实需要用户注意时才弹出
   - 窗口未聚焦
   - 窗口不可见或被最小化

2. **温和提醒**：
   - 临时置顶500ms后自动取消，避免过度干扰
   - 在Windows上使用任务栏闪烁作为补充提醒

3. **错误处理**：
   - 所有窗口操作都有异常处理
   - 在非桌面平台自动跳过

## 测试方法

使用提供的测试脚本：

```bash
./test_window_popup.sh
```

### 手动测试步骤

1. 启动Flutter客户端并连接到服务器
2. 将Flutter窗口最小化或用其他窗口遮挡
3. 发送测试消息（通过脚本或其他客户端）
4. 观察Flutter窗口是否自动弹出到前台

### 预期行为

- 收到新消息时，窗口应该自动显示并获得焦点
- 窗口应该出现在所有其他窗口的前面
- 用户可以立即看到新消息并进行回复

## 配置选项

可以通过`WindowService`的配置方法来调整Linux X11行为：

```dart
// 配置Linux X11特殊行为
WindowService().configureLinuxBehavior(
  alwaysOnTopDuration: Duration(seconds: 3), // 调整置顶时间
  useAggressiveMode: true,                   // 是否使用强制模式
);

// 调整窗口初始大小
const windowOptions = WindowOptions(
  size: Size(1200, 800),
  minimumSize: Size(800, 600),
  center: true,
);
```

### 可配置参数

- **alwaysOnTopDuration**: 窗口保持置顶的时间（默认5秒）
- **useAggressiveMode**: 是否在Linux上使用强制弹出模式（默认true）

## 注意事项

1. **权限要求**：某些Linux桌面环境可能需要额外权限来操作窗口
2. **性能影响**：窗口操作是异步的，不会阻塞消息处理
3. **用户偏好**：未来可以添加设置选项让用户控制是否启用此功能
