# PLAN: Make bun and opencode support for android *main of termux* — OhMyLiteCode

更新时间：2026-02-15

Scope: 本文针对 `oml/oct` 研究线（Bun/OpenCode/Termux），不涉及 `oml/omg` 实装细节。术语见 `00-glossary-and-scope.md`。

> 范围：只讨论 **Android/Termux 原生（无 proot）**。目标是让 Bun 与 OpenCode 在 Termux 主环境可用，并可形成可复现的构建/打包/测试流程。
>
> 注意：本计划文档 **不构建** oml/omq（oh-my-litecode/oh-my-qwencode）别名体系，也不在此 session 构建 omgemini/omforge/omaider 等子项目。

---

## 0. 背景与证据输入

### 0.1 本地资料（已存在）

- `termux-opencode/docs/howfixandroid.md`
- `termux.opencode.all/docs/howfixandroid.md`
- `termux.opencode.all/docs/10-bun-build-plan.md`
- `termux.opencode.all/docs/11-opencode-build-plan.md`
- `termux.opencode.all/docs/99-open-issues-and-upstream-sync.md`

### 0.2 上游 issue（关键结论）

#### OpenCode on Termux：官方二进制不可直接运行

- `anomalyco/opencode#10504`：Linux/aarch64 二进制在 Android/Termux 上：
  - program interpreter 错（`/lib/ld-linux-aarch64.so.1` 不存在）
  - 且非 PIE（Android 5+ 拒绝）
  - 结论：**无法通过 patchelf 修补解决，必须重新针对 Android 构建**

#### opencode-ai npm global：postinstall 平台包缺失

- `anomalyco/opencode#12515`：`opencode-ai` 的 `optionalDependencies` 未发布 `opencode-android-arm64`，postinstall 引用却存在 → `npm i -g opencode-ai` 在 Termux 失败。

- `anomalyco/opencode#11689`：社区提出希望提供 Android/Termux aarch64 官方构建；当前仍 open。

#### Bun on Termux：grun 方案对 bun --compile 不可靠

- `oven-sh/bun#8685`：Termux 原生通常依赖 glibc-runner(grun)，但 bun 功能受限且对 node_modules/REPL/bunx 存在边界。
- `oven-sh/bun#26752`（已 closed）：解释了 `/proc/self/exe` 指向 ld.so 时 bun bundled binary 找不到 trailer 的根因；提出 BUN_SELF_EXE 等方案。

### 0.3 第三方关键方案：bun-termux-loader

- `kaan-escober/bun-termux-loader`：用 **userland exec + cache extraction + bunfs shim** 让 `bun build --compile` 的产物在 Termux 原生可跑。
  - userland exec：`mmap(ld.so)` + `jmp`，避免 `execve(ld.so)` 造成 `/proc/self/exe` 指向 ld.so
  - bunfs shim：拦截 `dlopen("/$bunfs/root/*")`，重写到 cache 路径，解决 OpenCode 等 bunfs native libs

---

## 1. 总体策略（两条主线）

### 主线 A：先把 Bun（Termux 可跑的 bun --compile 产物）做稳定

理由：OpenCode 构建/运行链路依赖 Bun + 其 TUI/原生 so 载入路径。

方法：采用 bun-termux-loader 作为**过渡性运行时**（workaround），先跑通“bun compiled artifact → termux self-contained”。

### 主线 B：再把 OpenCode 跑起来（不依赖 npm global postinstall）

理由：`opencode-ai` 在 Termux 直接安装失败（#12515），且官方 Linux 二进制不能跑（#10504）。

方法：

1) staged 构建（首选）：在 Termux 里以源码/预构建产物形式部署 `packages/opencode`，由 bun-termux 能力启动。
2) 包装发布版（备选）：将可运行的 opencode 构建进 bun compiled artifact，再用 loader 包装。

---

## 2. 交付物定义（可复现、可测试、可打包）

### 2.1 Bun 侧交付物

- `bun-termux-loader` 本地镜像（指定 commit/tag）
- `bun-compiled` 输入样本（必须包含 `---- Bun! ----` marker）
- `*-termux` 输出样本（必须包含 `BUNWRAP1` 与 `---- Bun! ----`）
- 回归测试脚本：
  - marker 检测
  - 首次运行缓存写入
  - 二次运行 cache hit

### 2.2 OpenCode 侧交付物

- `opencode-termux` 可运行入口（最少 `--help` / `--version` 成功）
- `deb` / `pkg.tar.xz` 打包产物（可选阶段性）
- 回归测试脚本：
  - 启动
  - 二次启动（规避“二次启动黑屏/崩溃”类问题）
  - 基本功能：打开目录、启动 server/tui（至少一种）

---

## 3. 执行顺序（Fail-Fast 门禁）

### Phase 1：环境基线

验收：

1. `clang --version` 可用
2. `python3 --version` 可用
3. `pkg/pacman` 可安装依赖（本环境已做 pkg→pacman 转译，视为已满足）

### Phase 2：Bun loader build + marker gate

1. 构建 wrapper：`make`
2. 输入门禁：输入二进制必须包含 `---- Bun! ----`
3. 输出门禁：输出必须包含 `BUNWRAP1` 与 `---- Bun! ----`

失败即停：

- 没有 marker → 输入不是 bun --compile 产物
- 输出无 BUNWRAP1 → build.py 未正确拼接

### Phase 3：Bun-termux run gate

验收：

1. 首次运行：cache 目录出现 bun-<hash>，大小接近 bun ELF（~92MB 级别）
2. 二次运行：不重复写入，执行时间明显降低

### Phase 4：OpenCode bring-up（staged）

验收：

- `opencode --help` 或 `opencode --version` 通过其一

失败即停并分流：

- 若报 bunfs dlopen 失败：需要 bunfs shim（bun-termux-loader 支持）
- 若报 ELF/PIE/linker：说明误用了 Linux 二进制（回到 #10504 路径）

### Phase 5：打包与回归

- 先做 `pkg.tar.xz` 或 `deb` 任一
- 再做二次启动回归

---

## 4. 风险与对策

### 风险 1：bun-termux-loader 是 workaround，未来 Bun 上游行为变化

对策：

- 固定 bun 版本/tag 与 loader commit
- 每次升级先跑 marker + cache + 二次启动回归矩阵

### 风险 2：OpenCode 依赖的原生 so / node addons 识别不全

对策：

- 优先走 loader 的 bunfs shim + BUNLIBS1 自动提取
- 若识别失败，补 SIGNATURES 或用“提取未声明 ELF blob”兜底

### 风险 3：Termux 文件系统 noexec / SELinux 限制

对策：

- cache 使用 `$TMPDIR`（Termux 内部路径）
- 避免在 shared storage 下执行

---

## 5. 当前状态（以证据为准）

已具备（来自已有文档与验证）：

- 已建立 bun 与 opencode 的 build plan 文档（10/11/99）
- 已收集上游 issue 并提炼结论（10504/11689/12515/8685/26752）

下一步最短路径：

1) 以 bun-termux-loader 跑通一个最小 bun --compile artifact
2) 再用同机制 bring-up opencode

---

## 6. 本轮实测记录（2026-02-15）

### 6.1 环境基线（Termux 原生）

已确认可用：

- `clang 21.1.8`（aarch64-unknown-linux-android24）
- `python3 3.12.12`
- `make 4.4.1`
- `git 2.53.0`
- `grun` 存在（`$PREFIX/glibc/lib/ld-linux-aarch64.so.1` 可执行）

### 6.2 bun-termux-loader 构建与门禁

- `~/termux-opencode/bun-termux-loader` 中 `make` 成功
- `wrapper` 为 Android linker64 的 PIE 可执行（符合 loader 本体预期）

### 6.3 输入样本门禁（关键）

#### 样本 A：`termux.opencode.all/buno`

- 运行：`grun ./buno --version` → `1.2.20`（可运行）
- 用它编译最小入口：
  - `grun ./buno build --compile ./entry.js --outfile ./entry-buno`
  - 生成成功（`entry-buno`）
- marker 检查：`entry-buno` 含 `---- Bun! ----`，不含 `BUNWRAP1`（符合“输入样本”角色）

#### 样本 B：`termux.opencode.all/buno` 本体

- 虽能 `strings` 命中 `---- Bun! ----` 文本片段，但 `build.py` 认定其不是有效 bun bundled input（marker/布局校验失败）
- 结论：不能把 `buno` 本体直接当作 `build.py` 输入

### 6.4 包装最小样本（loader 路径）

- 执行：
  - `python3 build.py entry-buno entry-buno-termux`
  - 产物含 `BUNWRAP1` + `---- Bun! ----`
- 运行：`./entry-buno-termux --version`
- 错误：`ld-linux-aarch64.so.1: loader cannot load itself`

这说明：

- **输入样本门禁已通过**（不是“假输入”问题）
- 当前 blocker 已转为 **wrapper/loader 自身运行路径问题**（与 howfixandroid.md 的已知问题一致）

### 6.5 OpenCode 输入提取验证

从 `opencode-with-bun-1.1.60-1-aarch64.pkg.tar.xz` 解包后：

- `.../usr/bin/opencode` 大小 ~1KB（launcher script）
- `.../packages/opencode/bin/opencode` 大小 ~2KB（non-bundled stub）
- 二者均不含 `---- Bun! ----` / `BUNWRAP1`

结论：

- 现有包内 **没有可直接喂给 build.py 的 OpenCode bun bundled binary**
- 需先获得“真正的 bun build --compile 产物”再谈 OpenCode 包装

### 6.6 当前阶段结论

1. 构建环境 OK，loader 源码可构建。  
2. 已获得有效最小输入样本并完成包装。  
3. 主要 blocker：`entry-buno-termux` 运行时 `loader cannot load itself`。  
4. OpenCode 线目前缺“可包装输入二进制”，无法进入 bring-up 成功态。

### 6.7 OpenCode 运行态验证（基于已有 runtime 产物）

在 `termux.opencode.all` 中存在已有 runtime：

- `artifacts/opencode/runtime/opencode`（Linux glibc 解释器路径）
- `artifacts/opencode/runtime/opencode-termux`（Android linker64, PIE）

实测：

- `./artifacts/opencode/runtime/opencode-termux --version` 返回 `1.1.65`
- `./scripts/build/build_opencode.sh` + `./scripts/verify/verify_opencode.sh` 通过
- `artifacts/opencode/staged/prefix/bin/opencode` 启动脚本优先调用 runtime，并成功输出帮助/版本

因此可确认：

- **OCT 在 Termux 原生启动 OpenCode 已可达成（基于已有 termux runtime 产物）**。
- 当前未完成的是“从头重新生成同等稳定 opencode-termux runtime”的全流程闭环；该闭环仍受 loader 分支问题影响，需要继续在 Bun 路线上收敛。

---

## 7. 本轮追加实测记录（2026-02-16，pacman/makepkg 线）

> 目标：补齐 **pacman(makepkg) 可复现打包/安装/验证** 闭环，并修复此前“makepkg strip 破坏 runtime / launcher 脚本损坏”的问题。

### 7.1 关键修复点（以证据为准）

1) **PKGBUILD 禁止 strip**

- 问题：makepkg 的 strip/optipng 等 tidy 步骤可能破坏 bun compiled artifact 的 trailer；此前在 `$PREFIX/lib/opencode/runtime/opencode` 观察到安装后 runtime 仅 ~12KB 且缺 `---- Bun! ----`。
- 修复：在 `bun-termux` 与 `opencode-termux` 的 PKGBUILD 增加：

```bash
options=('!strip' '!debug')
```

2) **PKGBUILD 必须使用 $pkgdir + $prefix**

- 问题：直接 `cp -a ... /.`, 或 `install -d /bin` 会把文件写入构建机根目录，且会造成 `$pkgdir` 中混入奇怪目录名（如 `opencode-termux${PREFIX:-`）。
- 修复：统一使用：

```bash
prefix="${PREFIX:-/data/data/com.termux/files/usr}"
install -d "$pkgdir$prefix"
cp -a <staged-prefix>/. "$pkgdir$prefix/"
```

3) **build_opencode.sh 修复：rsync --delete 会删 runtime 目录**

- 问题：`rsync -a --delete ... -> $PREFIX_DIR/lib/opencode/` 会删除 `runtime/` 子目录（因为源仓库不含该目录），导致后续 `install ... runtime/opencode` 报：

```
install: cannot create regular file .../runtime/opencode: No such file or directory
```

- 修复：rsync/copy 完成后 **重新 ensure_dir**：

```bash
ensure_dir "$PREFIX_DIR/lib/opencode/runtime"
```

4) **bun-termux 以 grun wrapper 方式提供 bun 命令**

在 `$prefix/bin/bun` 安装一个小脚本：

```bash
exec grun "$PREFIX/lib/bun-termux/bun" "$@"
```

### 7.2 构建/安装验证（关键结果）

在 Termux（pacman 环境）中：

1) `makepkg` 产物：

- `bun-termux-1.2.20-7-aarch64.pkg.tar.xz`（约 23MB）
- `opencode-termux-1.1.65-8-aarch64.pkg.tar.xz`（约 110MB）

2) `pacman -U` 安装后：

- `bun --version` 输出：`1.2.20`
- `opencode --version` 输出：`1.1.65`
- `$PREFIX/lib/opencode/runtime/opencode` 大小约：`154,577,842 bytes`
- marker 检查：
  - `---- Bun! ----` **存在**
  - `BUNWRAP1` 可能不存在（视 runtime 类型：loader 包装 vs direct）；本轮为 direct runtime 形态。

3) `opencode --help` 可成功输出（非 TUI）。

### 7.3 已知问题（仍需继续定位）

TUI 仍可能在某些启动场景下失败，日志中出现：

- `setRawMode failed with errno: 5`
- `Cannot find module ... opencode-anthropic-auth ... from /$bunfs/root/.../worker.js`

这些错误与“二次启动黑屏/无响应”存在相关性，但尚未收敛为最小复现与最小清理集。

#### 7.3.1 启动失败的两个假设与对应最小修复（launcher 层）

> 注：这两个修复都遵守“最小破坏原则”：不删 DB、不删 storage；仅清理 lock 或“损坏缓存模块”。

1) `setRawMode errno: 5`

- 假设：stdin/stdout 没绑定到真实 TTY（比如被脚本、服务、某些 wrapper 启动），Bun/Node 的 `stdin.setRawMode(true)` 会失败。
- 对策（launcher）：若检测到交互环境，则强制将 stdio 绑定到 `/dev/tty`：

```bash
exec </dev/tty >/dev/tty 2>/dev/tty
```

2) `Cannot find module ... opencode-anthropic-auth ...`

- 事实：OpenCode 默认插件列表包含 `opencode-anthropic-auth@0.0.13`（见 `packages/opencode/src/plugin/index.ts` 的 BUILTIN）。
- 假设：`~/.cache/opencode/node_modules/opencode-anthropic-auth` 目录存在但内容不完整（升级中断/缓存损坏），导致 worker import 失败。
- 对策（launcher）：仅在 **目录存在但缺少 `package.json`** 时，删除该模块目录，允许 OpenCode 在下次启动重新安装/修复：

```bash
dir="$XDG_CACHE_HOME/opencode/node_modules/opencode-anthropic-auth"
[ -d "$dir" ] && [ ! -f "$dir/package.json" ] && rm -rf "$dir"
```
