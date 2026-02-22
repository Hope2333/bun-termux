# 本机 OpenCode/OMO 与 Termux OML 差异（脱敏基线）

更新时间：2026-02-15

Scope: 本文针对 `oml/omg` 的本机与 Termux 差异对比。术语见 `00-glossary-and-scope.md`。

## 数据来源

- 本机：`~/.config/opencode`（已生成脱敏副本：`termux-lab/artifacts/local-opencode-sanitized`）
- 手机：Termux qwen/qwenx/geminix 配置与实测输出

> 后续分析统一基于脱敏副本，避免泄露。

---

## 主要差异

## 1) 运行时与能力层

- 本机 OpenCode + OMO：
  - 完整 agent 编排、hook、commands、skills、categories、plugin 链
  - 适合“调度型”工作流
- Termux OML：
  - 目前以 qwenx/geminix wrapper + MCP 三件套为主
  - 非 MCP 能力在逐步复刻中（已出路线图）

## 2) 配置体系

- 本机：`opencode.json` + `oh-my-opencode.json`（内容丰富、含 provider/agent/category）
- Termux：`~/.qwen/settings.json` + fake HOME 下 qwenx/geminix 专用配置

## 3) MCP 部署形态

- 本机 OMO：内建 MCP + 插件合并注入（含 skill-embedded MCP）
- Termux：当前主线采用“remote + stdio 混合”
  - context7: remote http
  - websearch: remote http
  - grep-app: stdio

## 4) 鉴权策略

- 本机 OpenCode provider 可直接绑定各 provider key（配置能力强）
- Termux qwenx 目前建议以 `QWEN_*` 为主，同时导出包保证 `OPENAI_*` 兼容

---

## 当前可复刻优先级

P0：
- 三件套 MCP 工具调用级可用（已达成）
- 导出包可复现（命令名正则 + env 双栈 + fakehome/userhome）

P1：
- hooks 事件化与工作流命令复刻（/ralph-loop /refactor 最小版）
- model alias 自动更新机制（sync + 静态回退）

P2：
- ForgeCode 与 Aider 的同构迁移
