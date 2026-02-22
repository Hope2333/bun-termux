# OMO / OpenCode 非 MCP 能力复刻矩阵（证据版）

更新时间：2026-02-15

Scope: 本文针对 `oml/omg` 体系的 OMO/OpenCode 非 MCP 复刻矩阵。术语见 `00-glossary-and-scope.md`。

> 目标：给 OML 做“除 MCP 以外”的复刻蓝图。只记录已从本地源码快照/官方文档可验证的能力。

## A. OpenCode 核心能力（非 MCP）

| 领域 | 能力 | 证据（文件/符号） | OML 复刻难度 |
|---|---|---|---|
| Agent | 主/子代理模型与权限合并 | `packages/opencode/src/agent/agent.ts` `PermissionNext.merge` | 中 |
| Session | 会话创建、fork、share、unshare、diff、remove | `packages/opencode/src/session/index.ts` | 中 |
| Session Loop | 主循环、resume/cancel、max steps、command/shell/prompt | `packages/opencode/src/session/prompt.ts` | 高 |
| Todo | 会话级 todo 存储与读写 | `packages/opencode/src/session/todo.ts`, `tool/todo.ts` | 低 |
| Task Delegation | `task` 工具启动子会话并可恢复 session_id | `packages/opencode/src/tool/task.ts` | 中 |
| Permission | ask/allow/deny 规则、匹配、回复 | `packages/opencode/src/permission/next.ts`, `config/config.ts` | 中 |
| Plugin Hook | 插件触发点与 event 分发 | `packages/opencode/src/plugin/index.ts`, `session/prompt.ts` `Plugin.trigger(...)` | 高 |
| LSP | LSP server 管理、多语言配置、诊断事件 | `packages/opencode/src/lsp/server.ts`, `lsp/index.ts`, `lsp/client.ts` | 中 |
| File Safety | read/write 时间戳冲突保护 | `packages/opencode/src/file/time.ts` | 低 |
| Compaction | 会话压缩与差异保存 | `packages/opencode/src/session/compaction.ts` | 中 |
| Revert | 会话回滚/恢复 | `packages/opencode/src/session/revert.ts` | 中 |
| TUI/API | session/pty/tui 路由与控制 | `packages/opencode/src/server/routes/{session,tui,pty}.ts` | 中 |
| Bash/Batch | 命令执行、批工具编排 | `packages/opencode/src/tool/bash.ts`, `tool/batch.ts` | 低 |

## B. OMO 增强能力（非 MCP）

| 领域 | 能力 | 证据（文档） | OML 复刻策略 |
|---|---|---|---|
| 多代理编排 | Sisyphus + Oracle/Librarian/Explore + 规划代理 | `docs/features.md` Agents 章节 | 在 Qwen/Gemini 先实现角色模板 + 委派策略 |
| 背景任务 | task + background_output/background_cancel | `docs/features.md` Background Agents | 用“异步子进程 + task_id registry”复刻 |
| 命令体系 | `/ralph-loop` `/ulw-loop` `/refactor` `/start-work` | `docs/features.md` Commands 章节 | 先复刻 `/ralph-loop` + `/refactor` MVP |
| Hook 自动化 | UserPromptSubmit / PreToolUse / PostToolUse / Stop | `docs/features.md` Hooks 章节 | 在 wrapper 前后置脚本 + 事件总线实现 |
| Claude 兼容 | `.claude/commands` `.claude/skills` `.claude/agents` | `docs/features.md` Claude compatibility | 目录加载器 + 映射器 |
| Tmux 可视并行 | 背景代理 pane 可视化 | `docs/features.md` Tmux Integration | Termux 直接复刻（已具备 tmux） |

## C. 当前 OML 状态（与复刻目标差距）

已达成：
- qwenx 基线对话恢复
- context7/websearch/grep-app 三件套连通
- context7/websearch/grep-app 工具调用级验证通过

未完成：
- OMO 级 hooks 自动化链
- 标准化 session/todo/background 协议
- ForgeCode / Aider 的同构实现
