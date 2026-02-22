# OML 实施计划（OMO 全面复刻 → ForgeCode/Aider 扩展）

更新时间：2026-02-15

Scope: 本文针对 `oml/omg` 的实施计划与验收门禁。术语见 `00-glossary-and-scope.md`。

## 0. 总原则（门禁）

1. 任何“完成度”只以**可执行验收命令**为准。
2. 配置、脚本、文档**不得出现明文密钥**；敏感信息只能通过环境变量注入。
3. 主线先保证：`qwen/qwenx/geminix` 基线对话 + MCP 三件套工具调用级通过。

---

## 1) Phase 1：固化可复现基线（跨设备）

### 交付物

- `05-reproducible-setup-termux.md`（已存在，持续维护）
- `healthcheck-termux.sh`（已存在）
- `audit-qwenx.sh`（检查 wrapper 无强制 auth-type、无 sk-*）
- `audit-qwen-settings.sh`（检查 settings.json 三件套 + 无明文 key）
- `sanitize-export-termux.sh`（生成脱敏导出包）

### 验收

- `qwenx -p 'say ONLY OK'` 返回 OK
- `qwenx` 调用：
  - `mcp__context7__resolve-library-id`
  - `mcp__websearch__web_search_exa`
  - `mcp__grep-app__grep_count`
  均返回预期 marker

---

## 2) Phase 2：复刻 OMO 的“编排层”（非 MCP）到 Qwen/Gemini

### 目标能力

- 代理体系：主代理 + 专家子代理（planner/reviewer/researcher）
- hooks：关键事件点注入（pre/post tool、stop、prompt submit）
- 会话治理：导出/压缩/恢复、todo 强约束
- 工作流命令：`/ralph-loop`、`/refactor` 的最小可用版

### 落地策略

- 用“wrapper + 目录约定 + 事件脚本”先实现 hooks（最可移植）
- 把命令体系落到可分发的 `commands/*.md` 模板 + runner
- 保持与 Claude 生态兼容的目录结构（`.claude/commands`, `.claude/skills`）作为迁移接口

### 验收

- 针对 2 个典型任务（代码修改 / 文档生成）
  - 能自动生成 todo
  - 能执行至少 1 次验证（lsp/命令/工具）
  - 产物可复现（sanitize export 后在另一设备复跑）

---

## 3) Phase 3：ForgeCode 复刻

### 目标

- 复用 Phase 1 的 MCP/安全/导出/健康检查规范
- 让 ForgeCode 具备同样的“编排层”入口（命令 + hooks + 会话导出）

### 验收

- ForgeCode 入口下，MCP 三件套工具调用级通过
- hooks runner 输出与 Qwen/Gemini 一致（同一套脚本/模板）

---

## 4) Phase 4：Aider 复刻

### 现实边界

Aider 更偏 git 工作流与编辑循环，MCP-first 能力通常较弱。

### 复刻重点

- fake HOME 隔离
- 安全规范 + 脱敏导出
- 外接检索（websearch/context7/grep-app）作为前置步骤，而不是深度集成

### 验收

- 能复现同一套“先检索→再改代码→再验证→导出”的流程
