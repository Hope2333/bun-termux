# Make GeminiX - OhMyLiteCode（最小同步包）

更新时间：2026-02-15

Scope: 本文用于同步 `oml/gemini`（= `oml/omg`）研究线最小必需信息。术语见 `00-glossary-and-scope.md`。

本文用于把“最小必需信息”同步给 `oml/omg` 下的 Gemini 子项目（omgemini + geminix），用于避免路线分叉。

## 命名（文档统一口径）

- 仓库/项目：`oml/omg`
- 跨客户端基线：`oml-tools`
- Gemini 适配：`omgemini`
- 命令/launcher：`geminix`（命令名可配置）

发布包名（未来）：`oml-gemini-<ver>`

> 当前处 alpha 阶段，不在文档中承诺版本号。

---

## 分层边界（必须遵守）

- `oml-tools`：跨客户端基线，仅做外置工具协议与通用治理。
- `omgemini`：仅做 Gemini CLI 的 settings 注入/启动器包装/路径策略。

---

## 外置工具协议（Gemini 复用关键）

### discoveryCommand

- 输出 JSON array
- 兼容 key：`function_declarations` / `functionDeclarations`
- 每项可包含 FunctionDeclaration（name/description/parametersJsonSchema）

实现：
- `termux-lab/scripts/oml-tools-discover.sh`

### callCommand

- 调用方式：`<callCommand> <toolName>`
- stdin：JSON 参数
- stdout：返回结果（建议 JSON 字符串）
- stderr：尽量不要输出；一旦非空通常被 core 视为失败

实现：
- `termux-lab/scripts/oml-tools-call.sh`

---

## 最小工具集合（已落地，可直接复用）

- `oml.healthcheck`
- `oml.audit_config`
- `oml.sanitize_export`
- `oml.mcp_call`（op=initialize/listTools/call/closeSession）

MCP 网关实现：
- `termux-lab/scripts/oml-mcp-http-gateway.py`

---

## XDG/用户态规范（建议 Gemini 子项目对齐）

- bin：`~/.local/bin/<cmd>`
- config：`~/.config/oml/<client>/profile.json`
- data：`~/.local/share/oml/<client>/...`
- state/backups：`~/.local/state/oml/<client>/backups`

建议 Makefile targets：

- `install` / `uninstall`
- `doctor`
- `package`
- `sha`

---

## 已知坑（必须写入 doctor）

1. Context7 `/mcp/ping` 在部分环境 404：连通性以握手头或工具调用级为准。
2. grep-app 可能输出过大：测试 query 要收敛（避免触发输出上限）。
