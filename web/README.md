# Agent Assistant Web 界面

Agent Assistant 的现代化 Web 用户界面，基于 Vue.js 3 + Quasar + TypeScript 构建。

## 功能特性

- 🚀 **实时通信**: 通过 WebSocket 与 Agent Assistant 服务器实时通信
- 💬 **聊天界面**: 类似 IM 的对话界面，支持问题回复和任务确认
- 🔄 **自动重连**: 网络断开时自动重连机制
- 📱 **响应式设计**: 支持桌面和移动设备
- 🎨 **Material Design**: 基于 Quasar 的精美 UI 组件
- 🔔 **智能通知**: 实时消息通知和状态提醒
- 🛡️ **类型安全**: 完整的 TypeScript 支持

## 技术栈

- **Vue.js 3**: 现代化的 JavaScript 框架
- **Quasar**: Vue.js 的 Material Design 组件库
- **TypeScript**: 类型安全的 JavaScript 超集
- **Vite**: 快速的前端构建工具
- **Pinia**: Vue.js 的状态管理库
- **protobuf-es**: Protocol Buffers 的 JavaScript 实现

## 安装依赖

```bash
pnpm install
# 或者
npm install
# 或者
yarn install
```

## 开发模式

```bash
pnpm dev
# 或者
npm run dev
```

## 构建生产版本

```bash
pnpm build
# 或者
npm run build
```

## 代码检查和格式化

```bash
# 代码检查
pnpm lint

# 代码格式化
pnpm format
```

## 使用方法

1. 启动 `agentassistant-srv` 服务器
2. 在浏览器中访问: `http://localhost:9000?token=your-token`
3. 界面将自动连接到服务器并开始接收 AI Agent 的消息

## 项目结构

```text
web/src/
├── components/          # Vue 组件
│   ├── chat/           # 聊天相关组件
│   └── LoadingSpinner.vue
├── config/             # 配置文件
├── pages/              # 页面组件
├── proto/              # 生成的 protobuf 文件
├── services/           # 服务层
│   ├── websocket.ts    # WebSocket 服务
│   └── notification.ts # 通知服务
├── stores/             # Pinia 状态管理
├── types/              # TypeScript 类型定义
└── utils/              # 工具函数
```

## 配置说明

应用配置位于 `src/config/app.ts`，包含：

- WebSocket 连接配置
- UI 交互配置
- 超时设置
- 应用元数据

## WebSocket 通信

界面通过 WebSocket 与服务器通信，支持以下消息类型：

- `UserLogin`: 用户登录验证
- `AskQuestion`: 接收 AI Agent 的问题
- `TaskFinish`: 接收任务完成通知
- `AskQuestionReply`: 发送问题回复
- `TaskFinishReply`: 发送任务确认
- 各种通知消息

## 自定义配置

参考 [Quasar 配置文档](https://v2.quasar.dev/quasar-cli-vite/quasar-config-file) 了解更多配置选项。
