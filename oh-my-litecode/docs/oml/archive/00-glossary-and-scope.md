# 术语表与作用域（必读）

更新时间：2026-02-15

本文用于解决同义/混用命名带来的歧义。后续所有文档与脚本均以此为准。

---

## 1) 项目与仓库

| 名称 | 含义 | 备注 |
|---|---|---|
| OML | alpha 大项目 | 总体规划、跨客户端标准 |
| oml/omg | 仓库/项目 | 与 `oml/gemini` 等同（同一条线，命名别名） |
| oml/gemini | 仓库/项目别名 | 适配层：omgemini；命令：geminix；发布包：oml-gemini-<ver> |
| oml/qwen | Qwen 子项目 | 适配层：omqwen；命令：qwenx；发布包：oml-qwen-<ver> |
| oml/oct | OpenCode-on-Termux 子项目 | 别名：opencode(-on)-termux(oct) |

### 规划中的子项目（先统一口径）

> 以下子项目可能尚未启动或尚未定稿；这里先统一命名与文档口径，避免后续扩展时反复改名。

| 子项目 | 适配层（建议） | 命令/launcher（建议） | 发布包名（建议） |
|---|---|---|---|
| oml/oma | omaider | aiderx | alpha（未定） |
| oml/omf | omforge | forgex | oml-forge-<ver> |
| oml/omcx (codex) | omcodex | codexx | oml-codex-<ver> |
| oml/omk (kimi) | omkimi | kimix | oml-kimi-<ver> |
| oml/omch (crush) | omcrush | crushx | oml-crush-<ver> |
| oml/omgr (grok) | omgrok | grokx | oml-grok-<ver> |
| oml/omr (roo) | omroo | roox | oml-roo-<ver> |
| oml/omcr (cursor) | omcursor | cursorx | oml-cursor-<ver> |

---

## 2) 组件分层（本仓库）

| 名称 | 含义 | 职责边界 |
|---|---|---|
| oml-tools | 跨客户端基线 | 外置工具 discover/call、脱敏、审计、导出、MCP gateway |
| om<client> | 客户端适配层 | 只做该客户端的 settings 注入、启动器包装、路径策略 |
| <client>x | 命令/launcher | 可配置命令名；默认指向对应适配层 wrapper |
| <client> | 上游客户端 CLI | 不属于本仓库实现；本仓库对其进行适配 |

---

## 3) 版本号归属

| 版本号 | 归属 | 例子 |
|---|---|---|
| alpha | OML 总项目 | 不固定、用于整体阶段 |
| x.y.z | 子项目 | 发布包名：`oml-<client>-<ver>`（例：`oml-qwen-0.1.0`） |

版本策略补充：

- 子项目可以处于 alpha 阶段（无版本号）；只有达到“0.1.0 标准”后才开始发布 x.y.z。
- 当前：`oml/qwen` 已达到 0.1.0；`oml/oma`（aider）仍处 alpha。

结论：OML 总项目使用 alpha 阶段；具体版本号由各子项目自行维护。

---

## 4) 文档作用域声明（模板）

建议每篇文档开头加：

> Scope: 本文针对 `oml/omg` 仓库中的 `<component>`。术语见 `00-glossary-and-scope.md`。

---

## 5) 口径冻结（当前）

- `oml/gemini` 与 `oml/omg` 等同（同一条线的命名别名）。
- `oma` = Aider 线（`omaider` / `aiderx` / `oml-aider-<ver>`）。
- `omf` = Forge(Code) 线（`omforge` / `forgex` / `oml-forge-<ver>`）。
