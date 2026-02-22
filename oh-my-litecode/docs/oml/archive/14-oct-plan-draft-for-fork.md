# OCT Fork Plan Draft（可直接同步到 opencode-on-termux）

更新时间：2026-02-15

Scope: 本文针对 `oml/oct` fork 的计划草案。术语见 `00-glossary-and-scope.md`。

> 项目名：`OCT`（OpenCode(-on)-Termux）
>
> 目标：只做 OpenCode 在 Android/Termux 无 proot 的兼容与构建线；不混入 OMQ/qwenx 实现。

---

## 0. 范围声明

### In Scope

- OpenCode 原生 Termux 兼容性
- Bun 运行时与 bun compiled artifact 在 Termux 的可执行路径
- 打包与可复现（pkg/deb，可选）
- 上游 issue 同步与证据链维护

### Out of Scope

- OMQ/qwenx/geminix wrapper 细节
- 其他 OML 子项目实现

---

## 1. 现实约束（证据）

1. `opencode-ai` npm global 在 Termux 可能 postinstall 失败：
   - 缺少 `opencode-android-arm64` 平台包（见 `anomalyco/opencode#12515`）
2. 官方 Linux/aarch64 OpenCode 二进制在 Android/Termux 原生不可直接运行：
   - interpreter 路径与 PIE 要求不满足（见 `anomalyco/opencode#10504`）
3. Bun 在 Termux 的 grun 路径对 `bun build --compile` 存在 `/proc/self/exe` 语义问题：
   - 见 `oven-sh/bun#26752` 与 `#8685`

---

## 2. 技术路线（OCT）

## Route A（主线）：bun-termux-loader 过渡运行时

- 先将 bun compiled binary 封装为 termux self-contained 产物
- 通过 userland exec + bunfs shim 解决：
  - `/proc/self/exe` 指向错误
  - `/$bunfs/root/*` 的 dlopen 问题

## Route B（并行）：上游可移除 workaround 的观察线

- 监控 OpenCode/Bun 上游是否提供 Android/Termux 原生支持
- 一旦上游可用，逐步淘汰 Route A workaround

---

## 3. 执行阶段

### Phase 1 — Bun 输入/输出门禁

验收：

- 输入包含 `---- Bun! ----`
- 输出包含 `BUNWRAP1` + `---- Bun! ----`

### Phase 2 — Bun Termux 运行门禁

验收：

- 首次运行：生成 cache（`$TMPDIR/bun-termux-cache/`）
- 二次运行：cache hit，启动耗时明显下降

### Phase 3 — OpenCode bring-up（staged）

验收：

- `opencode --help` 或 `opencode --version` 至少一项成功

### Phase 4 — 回归与可复现

验收：

- 二次启动稳定（覆盖“首次能跑、再次黑屏/崩溃”）
- 导出包可在另一设备复现

---

## 4. 风险与分流

### R1: loader/workaround 漂移

- 对策：固定版本矩阵 + 每周 issue 同步

### R2: native so 识别不全

- 对策：优先 bunfs shim；必要时补签名或增加兜底检测

### R3: Android/SELinux/noexec

- 对策：仅在 Termux 内部路径执行；避免 shared storage 执行位问题

---

## 5. OCT 对外同步建议（fork README 首屏）

建议在 `opencode-on-termux` 首屏明确：

1. 这是 **Termux 原生兼容线**（无 proot）
2. 当前依赖 workaround，目标是随上游演进逐步移除
3. 只接受可复现实测报告（命令 + 输出 + 版本）
