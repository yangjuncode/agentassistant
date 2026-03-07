# agentassistant-mcp

`agentassistant-mcp` 会向 MCP 客户端暴露两个工具：`ask_question` 与 `work_report`。

## 用法

```bash
./agentassistant-mcp
./agentassistant-mcp -disable-workreport
./agentassistant-mcp -disable-ask-question
```

## 工具开关

- `-disable-workreport`：不暴露 `work_report` 工具
- `-disable-ask-question`：不暴露 `ask_question` 工具

如果两个参数同时开启，程序会立即输出错误并以非零状态退出。
