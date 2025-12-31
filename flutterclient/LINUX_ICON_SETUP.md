# Linux Desktop Icon Setup

## 概述

本文档说明如何为 Agent Assistant Flutter Linux 桌面版本设置应用图标。

## 已完成的修改

### 1. 图标文件

- 从 Android 版本的图标创建了 128x128 的 PNG 图标
- 位置：`linux/agent-assistant-icon.png`
- 构建脚本会自动从 Android 图标生成（如果不存在）

### 2. 窗口图标设置

- 修改了 `linux/runner/my_application.cc`
- 在窗口创建时加载并设置图标
- **智能路径查找**：
  1. 首先尝试从当前工作目录加载图标
  2. 如果失败，则从可执行文件所在目录加载
  3. 这确保了无论从哪里启动应用，图标都能正确显示
- 图标会显示在窗口标题栏和任务栏中

### 3. 桌面集成

- 创建了 `.desktop` 文件：`linux/agentassistant-flutter.desktop`
- 更新了 `linux/CMakeLists.txt` 以安装图标和 .desktop 文件
- 创建了安装脚本：`install-linux.sh`

## 构建和安装

### 1. 构建应用

```bash
./build-linux.sh
```

### 2. 安装到系统（可选）

```bash
./install-linux.sh
```

这将：

- 将 .desktop 文件安装到 `~/.local/share/applications/`
- 更新 .desktop 文件中的路径为绝对路径
- 使应用出现在应用程序菜单中

### 3. 直接运行

```bash
./build/linux/x64/release/bundle/agentassistant-flutter
```

## 图标显示位置

设置完成后，图标将显示在：

1. **窗口标题栏** - 应用窗口左上角
2. **任务栏** - 当应用运行时
3. **应用程序菜单** - 如果运行了 install-linux.sh

## 自定义图标

如果需要更换图标：

1. 替换 `linux/agent-assistant-icon.png` 文件（建议 128x128 PNG 格式）
2. 重新运行 `./build-linux.sh`
3. 如果已安装，重新运行 `./install-linux.sh`

## 技术细节

- 图标使用 GdkPixbuf 加载
- 支持 PNG 格式
- 推荐尺寸：128x128 像素
- 图标文件在编译时被复制到 bundle 目录
- .desktop 文件遵循 freedesktop.org 标准

## 故障排除

### 图标未显示

1. 确认 `linux/agent-assistant-icon.png` 文件存在
2. 检查编译输出是否有错误
3. 确认图标文件已复制到 bundle 目录：

   ```bash
   ls -l build/linux/x64/release/bundle/agent-assistant-icon.png
   ```

### 应用菜单中未显示

1. 确认已运行 `./install-linux.sh`
2. 检查 .desktop 文件：

   ```bash
   cat ~/.local/share/applications/agentassistant-flutter.desktop
   ```

3. 更新桌面数据库（某些桌面环境需要）：

   ```bash
   update-desktop-database ~/.local/share/applications/
   ```
