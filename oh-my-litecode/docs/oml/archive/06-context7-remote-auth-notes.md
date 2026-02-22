# Context7 remote MCP：API Key / OAuth 行为与客户端兼容性笔记

更新时间：2026-02-15

Scope: 本文针对 `oml/omg` 体系中 Context7 remote MCP 的鉴权与兼容性。术语见 `00-glossary-and-scope.md`。

## 1) 官方证据摘要

### 1.1 API key 格式

Context7 官方文档明确：API key 形如 `ctx7sk-...`，且创建后只展示一次。

来源：
- https://context7.com/docs/howto/api-keys

### 1.2 remote MCP 推荐 header

Context7 “All MCP Clients” 示例对多客户端给出的 remote 连接 header 名称是：

- `CONTEXT7_API_KEY: YOUR_API_KEY`

并且对 Gemini CLI/Qwen Code 示例里建议加：

- `Accept: application/json, text/event-stream`

来源：
- https://context7.com/docs/resources/all-clients

### 1.3 `/mcp/ping` 连通性检测

Context7 Troubleshooting 建议用：

`curl https://mcp.context7.com/mcp/ping`

来源：
- https://context7.com/docs/resources/troubleshooting

### 1.4 OAuth endpoint

Context7 OAuth 文档说明：

- OAuth 仅适用于 remote HTTP
- 若要 OAuth，把 endpoint 从 `/mcp` 改为 `/mcp/oauth`
- 客户端必须实现 MCP OAuth spec

来源：
- https://context7.com/docs/howto/oauth

---

## 2) 你设备上观察到的现象与解释

### 2.1 现象：curl 握手可达，但响应含 `www-authenticate: Bearer ... oauth-protected-resource`

这说明服务端可能对资源做了 OAuth 保护资源元数据提示。

但：这不等于必须 OAuth 才能用；官方示例仍支持 API key header。

### 2.2 现象：Qwen Code 里出现 `401 无效的令牌`

需要区分两类 401：

1. **Context7 MCP 401**（由 context7 工具调用返回）
2. **主模型 provider 401**（Qwen Code 调用模型 API 失败）

排查优先级：

- 先确认 `qwenx -p "say hello"` 是否会 401。
  - 若会：这是模型 provider token 问题，不要把锅扣到 context7。
- 若模型 OK，但调用 `mcp__context7__*` 报 401：再看 Context7 的 key/header。

---

## 3) 推荐配置（最稳、跨客户端通用）

优先用：

- `httpUrl: https://mcp.context7.com/mcp`
- header: `CONTEXT7_API_KEY: $CONTEXT7_API_KEY`
- header: `Accept: application/json, text/event-stream`

避免：

- 把真实 key 写进 settings.json
- 在脚本/文档里出现任何 `ctx7sk-...`
