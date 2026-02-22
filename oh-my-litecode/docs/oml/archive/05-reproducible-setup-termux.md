# OML 在 Termux 的可复现部署流程（跨设备）

更新时间：2026-02-15

Scope: 本文针对 `oml/omg` 在 Termux 的可复现部署流程。术语见 `00-glossary-and-scope.md`。

目标：在**新设备**上，从 0 复现一个可工作的 OML 基线（qwenx/geminix + MCP 三件套），不依赖任何历史会话。

> 本文档严格不包含敏感信息：不写真实域名、不写真实 key。

---

## 0. 约定与术语

- **REALHOME**：真实 `$HOME`
- **FAKEHOME**：隔离用的假 HOME，例如 `~/.local/home/qwenx`
- **MCP 三件套**：`context7 / websearch / grep-app`
- **remote MCP**：通过 `httpUrl` 连接远程服务
- **stdio MCP**：通过 `command/args` 启动本地进程

---

## 1. 前置条件

### 1.1 Termux 环境

- Termux 安装完成
- 网络可用（至少能访问 `https://mcp.context7.com`、`https://mcp.exa.ai`）

### 1.2 Node.js

- Node.js >= 18（推荐更高，但必须 >= 18）

验证：

```bash
node --version
npm --version
```

---

## 2. 安装 CLI（按需）

### 2.1 Qwen Code

```bash
npm install -g @qwen-code/qwen-code
qwen --version
```

### 2.2 Gemini CLI

```bash
npm install -g @google/gemini-cli
gemini --version
```

---

## 3. 创建隔离目录（FAKEHOME）

```bash
mkdir -p ~/.local/home/qwenx ~/.local/home/geminix
mkdir -p ~/.local/home/qwenx/.qwen ~/.local/home/geminix/.gemini
```

---

## 4. 配置 MCP（三件套，推荐 remote 优先）

### 4.1 Context7（remote HTTP）

Context7 官方示例显示 remote 连接通常使用 header `CONTEXT7_API_KEY`，并建议设置 `Accept: application/json, text/event-stream`。

> API key 的格式一般以 `ctx7sk-` 开头（参考 Context7 Troubleshooting）。

Qwen Code（settings.json）示例：

```json
{
  "mcpServers": {
    "context7": {
      "httpUrl": "https://mcp.context7.com/mcp",
      "headers": {
        "CONTEXT7_API_KEY": "$CONTEXT7_API_KEY",
        "Accept": "application/json, text/event-stream"
      },
      "timeout": 600000,
      "trust": false
    }
  }
}
```

### 4.2 Websearch（remote HTTP，Exa MCP）

```json
{
  "mcpServers": {
    "websearch": {
      "httpUrl": "https://mcp.exa.ai/mcp?tools=web_search_exa",
      "headers": {
        "x-api-key": "$EXA_API_KEY"
      },
      "timeout": 600000,
      "trust": false
    }
  }
}
```

### 4.3 Grep-app（stdio，本地执行）

```json
{
  "mcpServers": {
    "grep-app": {
      "command": "npx",
      "args": ["-y", "@247arjun/mcp-grep"],
      "timeout": 600000,
      "trust": false
    }
  }
}
```

---

## 5. 环境变量注入（唯一允许的敏感信息入口）

示例（仅示意，不要写进配置文件/脚本/文档）：

```bash
export CONTEXT7_API_KEY="***REDACTED***"
export EXA_API_KEY="***REDACTED***"

# 若你用 OpenAI-compat provider
export OPENAI_API_KEY="***REDACTED***"
export OPENAI_BASE_URL="https://api.example.com/v1"

# 若你用 qwenx wrapper（推荐），同时建议提供 QWEN_*（避免 wrapper/客户端策略分叉）
export QWEN_API_KEY="***REDACTED***"
export QWEN_BASE_URL="https://api.example.com/v1"
```

---

## 6. 验收（必须做）

### 6.1 握手级检查

Context7 官方建议：

```bash
curl -sS https://mcp.context7.com/mcp/ping
```

期待：`{"status":"ok","message":"pong"}`（或等价内容）。

### 6.2 Qwen Code MCP 列表

```bash
qwen mcp list
```

### 6.2.1 qwenx wrapper 验收（若使用）

```bash
qwenx -p 'say ONLY OK' --output-format text
qwenx mcp list
```

期待：三件套均为 Connected。

### 6.3 工具调用级检查（需要模型可用）

如果你当前模型 provider 认证没问题（不会 401），在 Qwen 会话内调用：

- `mcp__context7__resolve-library-id`
- `mcp__context7__query-docs`

---

## 7. 常见失败模式（精简版）

1. **Context7 401**：大概率是 key 无效或 header 名不匹配；确认 key 以 `ctx7sk-` 开头；尝试用官方 header `CONTEXT7_API_KEY`。
2. **SSE 长连接 curl 超时**：常见，不代表 MCP 不可用；优先使用 `/mcp/ping`。
3. **模型侧 401**：不是 Context7 失败，是你的主模型 provider token 无效/过期。
