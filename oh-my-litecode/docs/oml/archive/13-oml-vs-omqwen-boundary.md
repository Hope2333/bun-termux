# OML / om<client> 分层边界（必须遵守）

更新时间：2026-02-15

Scope: 本文针对 `oml/omg` 的分层边界（通用：oml-tools + om<client>）。术语见 `00-glossary-and-scope.md`。

## 结论

- **oml-tools**：跨客户端基线（Qwen/Gemini/Forge/Aider）可复用。
- **om<client>**：客户端适配层，只做对应客户端 settings/行为对接。

这满足你的要求：oml-tools 只做基线；适配层按 client 分离。

---

## 分层职责

## 1) oml-tools（跨客户端）

负责：
- 工具 discover/call 协议
- 统一脱敏、审计、健康检查
- 统一输出格式（建议 JSON 文本）
- 会话导出/可复现资产

不负责：
- 某个客户端的 settings 写法细节
- 某个客户端 UI patch

## 2) om<client>（客户端适配）

负责：
- 写入该客户端 settings：`tools.discoveryCommand` / `tools.callCommand`
- fakehome/userhome 安装策略
- 客户端相关环境变量兼容策略

不负责：
- 通用工具逻辑（应下沉到 oml-tools）

---

## 当前脚本映射

- 通用层（oml-tools）
  - `scripts/oml-tools-discover.sh`
  - `scripts/oml-tools-call.sh`
  - `scripts/healthcheck-termux.sh`
  - `scripts/sanitize-export-termux.sh`
  - `scripts/audit-qwenx.sh`
  - `scripts/audit-qwen-settings.sh`

- 示例：Qwen 适配层（omqwen）
  - `scripts/omqwen-configure-tools.sh`

- 示例：Gemini 适配层（omgemini）
  - `scripts/omgemini-configure-tools.sh`（待实现）

---

## 必须路径（~/.qwen 特殊场景）

对于需要直接装到默认配置目录（例如 `~/.gemini`）的用户：

1. 运行 `omgemini-configure-tools.sh --settings ~/.gemini/settings.json ...`
2. 验证 `gemini` 可发现外置工具并执行

该路径必须纳入验收，不得只测 fakehome。
