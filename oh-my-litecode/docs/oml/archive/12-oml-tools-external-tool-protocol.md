# 外置工具层（oml-tools）协议：兼容 Qwen Code discoveryCommand/callCommand

更新时间：2026-02-15

Scope: 本文针对 `oml/omg` 仓库中的 `oml-tools` 组件。术语见 `00-glossary-and-scope.md`。

## 背景

Qwen Code 支持通过 settings 配置：

- `tools.discoveryCommand`
- `tools.callCommand`

其核心行为（从 `ToolRegistry` 可验证）：

1) discoveryCommand 输出 JSON 数组
2) 每项可以是：
   - `{ function_declarations: [...] }`
   - `{ functionDeclarations: [...] }`
   - 或直接是单个 FunctionDeclaration（有 `name`）
3) callCommand 被调用时：
   - 进程参数：`callCommand <toolName>`
   - tool 参数通过 stdin 输入一段 JSON
   - stdout 原样作为 llmContent 返回（Qwen core 不强制解析）

来源：`QwenLM/qwen-code/packages/core/src/tools/tool-registry.ts`

---

## 目标

oml-tools 要成为“跨客户端的大基线”，负责：

- 统一工具发现/调用协议
- 统一日志、脱敏、超时、重试、输出裁剪
- 由适配层（例如 `omgemini`）把各客户端接入 oml-tools

---

## discoveryCommand 输出格式

必须是 JSON 数组：

```json
[
  {
    "function_declarations": [
      {
        "name": "oml.healthcheck",
        "description": "Run OML healthcheck and return JSON summary.",
        "parametersJsonSchema": {
          "type": "object",
          "properties": {
            "mode": {"type": "string", "enum": ["termux", "desktop"]}
          },
          "required": ["mode"]
        }
      }
    ]
  }
]
```

注：Qwen Code 同时接受 `functionDeclarations`（camelCase）。

---

## callCommand 调用约定

Qwen Code 调用：

```bash
<callCommand> <toolName>
```

stdin：JSON 参数（对象）

stdout：返回给模型的文本（建议返回 JSON 字符串）

stderr：一旦非空会被 Qwen core 视为失败（返回错误详情），因此应避免写到 stderr（除致命错误）。

---

## 工具命名规范（与导出包一致）

- 工具名建议采用 namespace：`oml.*`
- 将来按适配层拆分：`omgemini.*` / `omqwen.*` / `omforge.*`

---

## 输出与脱敏规则

任何工具输出必须：

- 不包含 `sk-...` / `ctx7sk-...`
- 不包含真实 baseUrl（可用 `https://api.example.com`）

---

## 最小工具集合（Phase 1 必须）

- `oml.healthcheck`
- `oml.audit_config`
- `oml.sanitize_export`
- `oml.mcp_call`（统一调用 MCP 三件套）

---

## 当前实现状态（2026-02-15）

- `oml.mcp_call` 已支持 `op` 参数：
  - `initialize`
  - `listTools`
  - `call`
  - `closeSession`
- 已实测通过：
  - `websearch`（tools/call）
  - `context7`（tools/call）
  - `grep-app`（tools/list + tools/call）
