# Make GeminiX - OhMyLiteCode 试行计划草案（范围内）

更新时间：2026-02-15

Scope: 本文针对 `oml/gemini`（= `oml/omg`）研究线计划草案。术语见 `00-glossary-and-scope.md`。

## Scope（本 session 生效）

只做：`oml/omg` 下 `omgemini + geminix` 的研究与计划草案。  
不做：`qwenx`、`oml/omq` 构建、`oml/oct`、`oml/omf`、`oml/oma` 子项目实现。

---

## 证据基线（已核验）

1. 本地 `howfixandroid.md` 明确记录了 Termux 下 OpenCode/Bun 的结构性障碍与外部链接（含 `opencode#12515`、`bun#26752/#8685`、`bun-termux-loader`）。
2. Gemini CLI 官方 issue 存在 Termux 安装/运行问题：
   - `google-gemini/gemini-cli#7895`（安装失败，node-pty/ripgrep android 平台问题）
   - `google-gemini/gemini-cli#13784`（运行时 Termux 误判）
3. `oml-tools` 外置协议与最小工具集已在本地落地，并可作为 `omgemini` 复用基线。

---

## 目标

在不引入额外子项目实现的前提下，产出一套可执行、可复现、可迁移的 `omgemini/geminix` 试行方案。

---

## Phase 1：协议与边界冻结（P0）

### 交付
- 命名冻结：`oml/omg`、`oml-tools`、`omgemini`、`geminix`
- 对外协议冻结：discoveryCommand/callCommand + 最小工具集
- XDG 路径规范冻结（bin/config/data/state）

### 验收门禁
- 文档中无旧命名冲突（omqwen/qwenx 语义冲突）
- 协议文档与脚本实现一致

---

## Phase 2：Gemini 试行运行路径设计（P0）

### 交付

两条思路（二选一或并行验证），并明确切换条件：

#### 路线 A：Patch `@google/gemini-cli`（参考 qwen-code 的 fork 思路）

- 目标：让上游 gemini-cli 在 Android/Termux 可安装、可运行。
- 参考证据：Qwen Code README 明确说明其基于 Gemini CLI（Acknowledgments）。
- 风险：维护成本较高（需要跟踪上游依赖变更，例如 node-pty、ripgrep、clipboardy 等）。

#### 路线 B：直接安装 Termux 适配发行 `@mmmbuto/gemini-cli-termux`

- 目标：快速获得 Termux 可用的 gemini 发行包。
- 参考证据：`DioNanos/gemini-cli-termux` README（Termux-first build、ARM64 PTY prebuild、Termux clipboard detection 等）。
- 风险：fork 跟进上游滞后时，需要回退策略/冻结版本。

统一 doctor 检查项：安装、握手、工具调用级验证。

### 验收门禁
- 每条路径都定义可执行验证命令（install/run/tools）。
- 不把 `/mcp/ping` 作为唯一连通标准；以握手头或工具调用级验证为准。
- 明确“路线切换条件”：
  - 若上游 gemini-cli 在 Termux 上出现不可控的 native/postinstall 失败（见 #7895 类问题），主线切到 Termux 适配发行。
  - 若 Termux 适配发行出现长期滞后或关键能力缺失，再回到路线 A patch。

---

## Phase 3：发布与复现规范（P1）

### 交付
- 包命名规范：`oml-gemini-<ver>`（当前 alpha 阶段，先不出版本号）
- 导出包说明：命令名可配置 + 正则校验 + 无敏感信息
- 脱敏流程：本机与手机导出统一标准

### 验收门禁
- 文档示例不含真实 key/私有 URL
- 复现步骤可在新设备执行（至少 dry-run 自检通过）

---

## 风险与回滚

### 风险
1. 上游 gemini-cli 对 Termux 兼容波动（node-pty/ripgrep/clipboardy）
2. 社区 termux fork 跟进延迟
3. issue 状态与实际可用性不同步

### 回滚策略
- 回滚到“oml-tools + 文档协议层”继续推进，不绑定某个发行包
- 保留双路径策略（官方/termux适配）并按 doctor 输出切换

---

## 下一步执行清单（本 session 后）

1. 将 `omgemini-configure-tools.sh` 作为适配层入口脚本纳入规划（仅设计，不实现）。
2. 建立 `issue-watchlist.md`（每周复核 #7895/#13784 及关联依赖 issue）。
3. 形成“试行里程碑看板”：P0/P1 项的完成条件和证据链接。
