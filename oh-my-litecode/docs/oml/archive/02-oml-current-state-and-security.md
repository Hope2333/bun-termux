# OML 当前真实状态（以实测为准）与安全规范

更新时间：2026-02-15

Scope: 本文针对 `oml/omg` 当前实测状态与安全规范。术语见 `00-glossary-and-scope.md`。

## 1. 真实状态（以命令输出为准）

### 1.1 Termux 环境

- Termux 前缀：`/data/data/com.termux/files/usr`
- Node.js / npm 已可用（用于安装 stdio MCP）

### 1.2 可用的核心 MCP（三件套）

当前主线已收敛并验证：

- `context7`（stdio：`npx -y @upstash/context7-mcp`）
- `grep-app`（stdio：`npx -y @247arjun/mcp-grep`）
- `websearch`（remote http：Exa MCP endpoint）

验收标准：在 `qwen / qwenx / geminix` 三个入口执行 `mcp list` 显示 **Connected**。

### 1.3 未实装占位项

`localhost:8080/8081/8082` 相关三组服务（playwright/rag/code-analyzer）目前是占位配置，不计入完成度。

---

## 2. 安全规范（强制执行）

### 2.1 严禁写入任何敏感信息

严禁出现：

- API Key / Token（例如 `sk-...`）
- 真实私有 API Base URL
- OAuth refresh token / session

### 2.2 推荐做法：只用环境变量注入

示例（仅示意，值必须由用户在自己的 shell 注入）：

```bash
export EXA_API_KEY="***REDACTED***"
export CONTEXT7_API_KEY="***REDACTED***"
export OPENAI_API_KEY="***REDACTED***"
```

### 2.3 文档与代码的脱敏规则

必须在提交/同步/分享前做脱敏：

- `sk-[A-Za-z0-9]{20,}` → `sk-***REDACTED***`
- `*_API_KEY=...` → `*_API_KEY=***REDACTED***`
- `https://<private-domain>/...` → `https://api.example.com/...`

### 2.4 本机脱敏数据集

本机已生成：

- 脱敏副本：`termux-lab/artifacts/.../sanitized/...`
- 泄露报告：`termux-lab/reports/secret-leak-report-YYYYMMDD.json`

后续分析与协作以脱敏副本为准。
