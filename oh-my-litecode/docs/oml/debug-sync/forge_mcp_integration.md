# Forge CLI 配置与 MCP 集成详解

## 概述

Forge CLI 是一个功能强大的命令行工具，支持多种 AI 模型提供商，并具备 MCP（Model Context Protocol）集成能力。Forge 可以通过环境变量或 `.env` 文件进行配置，并支持通过 MCP 服务器扩展功能。

## 配置方法

### 1. 环境变量配置

Forge 支持通过环境变量进行配置，主要的 API 密钥变量包括：

- `FORGE_KEY` - Antinomy 提供商 (OpenAI 兼容)
- `OPENROUTER_API_KEY` - Open Router (聚合多个模型)
- `OPENAI_API_KEY` - 官方 OpenAI
- `ANTHROPIC_API_KEY` - 官方 Anthropic

### 2. .env 文件配置

推荐在主目录创建 `.env` 文件进行配置：

```bash
# 对于 Open Router（推荐，可访问多个模型）
OPENROUTER_API_KEY=your_openrouter_key_here

# 或对于官方 OpenAI
# OPENAI_API_KEY=your_openai_key_here

# 自定义 API 端点（如果使用自托管模型）
# OPENAI_URL=https://your-custom-provider.com/v1
```

## MCP (Model Context Protocol) 集成

### 1. MCP 服务器配置

Forge 提供了几个 CLI 命令来管理 MCP 服务器：

#### `forge mcp import`
从 JSON 导入 MCP 服务器配置：

```bash
forge mcp import '{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    },
    "websearch": {
      "command": "npx",
      "args": ["@iflow-mcp/open-websearch"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "env": {
        "CONTEXT7_API_KEY": "your_context7_api_key"
      }
    }
  }
}'
```

#### `forge mcp list`
显示所有当前配置的 MCP 服务器。

#### `forge mcp remove`
从设置中删除 MCP 服务器配置。

#### `forge mcp show`
显示特定 MCP 服务器的详细配置。

#### `forge mcp reload`
重新加载 MCP 服务器并重建缓存。

### 2. 手动配置

您也可以通过创建或编辑 `.mcp.json` 文件来手动配置 MCP 服务器：

```json
{
  "mcpServers": {
    "browser_automation": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-browser"],
      "env": {
        "BROWSER_EXECUTABLE": "/usr/bin/chromium-browser"
      }
    },
    "api_service": {
      "command": "python",
      "args": ["-m", "mcp_server", "--port", "3001"],
      "env": {
        "API_KEY": "your_api_key_here",
        "DEBUG": "true"
      }
    },
    "webhook_server": {
      "url": "http://localhost:3000/events"
    }
  }
}
```

### 3. 配置结构

MCP 服务器配置有两种格式：

**基于命令的服务器：**
```json
{
  "server_name": {
    "command": "command_to_execute",
    "args": ["arg1", "arg2", "arg3"],
    "env": {
      "ENV_VAR": "value"
    }
  }
}
```

**基于 URL 的服务器：**
```json
{
  "server_name": {
    "url": "http://localhost:3000/events"
  }
}
```

## 高级配置选项

### 重试配置
- `FORGE_RETRY_INITIAL_BACKOFF_MS` - 重试前的初始退避时间（默认 1000ms）
- `FORGE_RETRY_BACKOFF_FACTOR` - 退避时间乘数（默认 2）
- `FORGE_RETRY_MAX_ATTEMPTS` - 最大重试次数（默认 3）
- `FORGE_RETRY_STATUS_CODES` - 要重试的 HTTP 状态码（默认 429,500,502,503,504）

### HTTP 配置
- `FORGE_HTTP_CONNECT_TIMEOUT` - 连接超时（秒，默认 30）
- `FORGE_HTTP_READ_TIMEOUT` - 读取超时（秒，默认 900）
- `FORGE_HTTP_KEEP_ALIVE_INTERVAL` - 保持活动间隔（秒，默认 60）
- `FORGE_HTTP_KEEP_ALIVE_TIMEOUT` - 保持活动超时（秒，默认 10）

### 工具配置
- `FORGE_TOOL_TIMEOUT` - 工具执行超时（秒，默认 300）
- `FORGE_DUMP_AUTO_OPEN` - 自动打开转储文件（默认 false）

## 在 Termux 中使用

在 Termux 环境中，Forge 可以像其他工具一样使用假 HOME 目录方法来实现完全隔离：

1. 创建隔离目录：`~/.local/home/forge`
2. 设置环境变量指向该目录
3. 配置 API 密钥
4. 使用 MCP 命令管理外部工具集成

## 最佳实践

1. **安全考虑**：将敏感信息如 API 密钥存储在环境变量中而不是配置文件中
2. **权限管理**：限制 MCP 服务器权限仅限必要权限
3. **网络连接**：对基于 URL 的服务器使用安全连接（HTTPS）
4. **定期更新**：定期轮换 API 密钥和令牌