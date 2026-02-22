# howfixandroid.md → 计划草案（证据整合版）

更新时间：2026-02-15

Scope: 本文针对 `oml/oct`（opencode-on-termux）研究线的计划草案。术语见 `00-glossary-and-scope.md`。

## 范围声明

本草案基于以下来源“抽取证据→形成计划”，不直接开始实现：

- 本地资料：`termux.opencode.all/docs/howfixandroid.md`（脱敏副本）
- 本地资料：`termux.opencode.all/docs/99-open-issues-and-upstream-sync.md`
- 先前会话实测结论（Termux 上 qwen/qwenx/geminix + MCP 三件套工具调用级通过）
- 最新联网 issue 追踪（Gemini CLI Termux install / clipboardy 误判等）

> 注意：历史完成度/进度报告存在“幻觉风险”，不作为验收依据。

---

## 1) howfixandroid.md 的关键证据摘要

### 1.1 Termux 包管理与系统约束

howfixandroid.md 记录：

- 当前 Termux 环境已把 pkg/apt 转译到 pacman。
- 可用 `grun` 跑部分 glibc 软件，但 bun 的 bundled executable 受 `/proc/self/exe` 语义影响。

影响：

- “依赖 bun 的 postinstall / 打包发布”在 Android/Termux 有结构性边界，需要绕过或引入 loader。

### 1.2 OpenCode 在 Termux 上的关键阻塞：平台包缺失

引用 issue：`anomalyco/opencode#12515`

核心报错：

- `postinstall.mjs` 需要 `opencode-android-arm64` 但 npm optionalDependencies 未发布。

结论：

- 现阶段不应把“原生 npm -g 安装 opencode-ai”作为 Termux 主线。

### 1.3 bun-termux-loader 方案与争议

howfixandroid.md 引用：`kaan-escober/bun-termux-loader`

方案摘要：

- 通过用户态 exec（不走 execve）保持 `/proc/self/exe` 指向 wrapper binary，从而让 bun compiled binary 能找到内嵌 JS trailer。
- Opencode 还涉及 `$bunfs` 与 `opentui` 的 dlopen 拦截。

风险：

- 该方案对输入二进制形态非常敏感（“提取到的 bun-* 竟是 ld-linux-aarch64.so.1”类错误），需要严格 marker 检查。

---

## 2) 最新联网问题追踪（对计划的影响）

### 2.1 Gemini CLI 在 Termux 的安装问题

`google-gemini/gemini-cli#7895` 显示：

- node-pty 构建依赖与 android 平台变量（ndk path）问题
- ripgrep postinstall 无 android target，报 `Unknown platform: android`

影响：

- 原生 `npm install -g @google/gemini-cli` 在 Termux 并不稳。

### 2.2 Gemini CLI 在 Termux 的运行误判

`google-gemini/gemini-cli#13784`：

- clipboardy 误判“需要安装 Termux”，即使已在 Termux 中运行。

影响：

- 需要 Termux 特供发行或补丁（类似 `*-termux` 的分发策略）。

---

## 3) 计划草案（按优先级）

### Phase 0：证据化基线（必做）

目标：保证所有后续动作可复现。

- 统一导出与脱敏：使用 `sanitize-export-termux.sh`（手机）与 `make-opencode-sanitized-local.sh`（本机）
- 统一健康检查：使用 `healthcheck-termux.sh`

验收：

- 任意设备上，导入配置后可复现：
  - 基础对话 OK
  - MCP 三件套工具调用级 OK

### Phase 1：在 Termux 上优先“可用路径”，不依赖 opencode/bun

目标：绕开 opencode/bun 的平台包与 runtime 边界，保证移动端长期可用。

- 以“Gemini/Qwen CLI + OML(轻量编排)”为主线
- gemini-cli 若不稳，优先使用 Termux 适配发行（社区维护的 `*-termux`）

验收：

- CLI 安装不依赖 NDK/编译重模块（或已有替代包）
- `mcp list` + tool-call 级通过

### Phase 2：opencode-termux（实验线）

目标：仅作为实验线跟踪，不绑定主线交付。

依赖退出条件（来自 99-open-issues-and-upstream-sync）：

- 上游发布并验证 Android arm64 平台包可直接安装
- bun 在 Termux 的 /proc/self/exe 语义问题有稳定上游方案

验收：

- staged build/package/run 回归矩阵连续通过

---

## 4) 下一步信息缺口（需要进一步搜索/核验）

1. `bun-termux-loader` 的维护状态、适配版本区间、以及与 opencode 版本的匹配矩阵
2. gemini-cli/qwen-code 的 Termux 发行策略：哪些版本开始引入了 node-pty/ripgrep 变更导致 Termux 失败
3. 对 `ripgrep` / `node-pty` 的替代策略（预编译包/可选依赖/feature flag）
