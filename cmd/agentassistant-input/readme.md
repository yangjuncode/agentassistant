# agentassistant-input

agentassistant-input 是一个命令行工具，用于将命令行参数 input/input64(base64 encoded utf8 string) 发送到当前系统中。

## 用法

```bash
agentassistant-input -input <string> -input64 <base64 encoded utf8 string>
```

其中 input 是明文，input64 是 base64 编码的 utf8 字符串.
input和input64不能同时使用，但必须提供一个.

## spec

**write in golang**
**use github.com/go-vgo/robotgo to send key events & text**
