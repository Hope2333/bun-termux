# omqwen-status Extension（替代 Footer UI 的外置状态显示）

更新时间：2026-02-15

Scope: 本文针对 `oml/omg` 的 extension 方案（Qwen 侧）。术语见 `00-glossary-and-scope.md`。

## 目标

你希望在 Qwen Code 底部状态栏显示：

- 当前 agent
- `used%` 后追加：`模型显示名 + 来源信息`

结论：**Extension 目前无法注入/修改 CLI Footer UI 组件**，但可以用 Extension 提供：

- 一个 MCP tool（`oml_status`）输出当前状态
- 一个 slash command（`/oml:status`）一键调用 tool 并总结

达到“外置化、跨设备可复现、无需 patch qwen-code”的效果。

---

## 交付内容

本地模板目录：

`termux-lab/artifacts/omqwen-extension-status`

包含：

- `qwen-extension.json`：extension manifest
- `src/server.ts`：stdio MCP server，提供 `oml_status` tool
- `commands/oml/status.toml`：`/oml:status` 命令
- `QWEN.md`：提示模型使用 tool（无敏感信息）

---

## 安装与链接（本机/Termux 类似）

> 以 Qwen Code 官方 extension 流程为准：`qwen extensions new/link`。

1) 复制模板到你的 extension 开发目录（建议 git 管理）
2) 安装依赖并构建：

```bash
npm install
npm run build
```

3) 链接 extension：

```bash
qwen extensions link .
```

4) 重启 qwen 会话。

---

## 使用

在 qwen 里运行：

`/oml:status`

或让模型直接调用 tool：

`oml_status {"includeEnv": true}`

输出会自动脱敏：

- key 显示为 `ABC…YZ`
- baseUrl 只显示 host

---

## 与 oml-tools/omqwen 的关系

- `oml-tools`：工具大基线（discover/call + mcp gateway）
- `omqwen`：Qwen settings 注入
- `omqwen-status` extension：提供“状态可观测性”能力，替代 Footer UI patch

建议把 `/oml:status` 用作所有验收前的“环境快照”。
