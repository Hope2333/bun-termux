# OCT 可复现发布规范 + 脱敏导出规范（可复用，不含 OMQ/qwenx）

更新时间：2026-02-15

Scope: 本文针对 `oml/oct` 的可复现发布与脱敏导出规范。术语见 `00-glossary-and-scope.md`。

## 1) 发布/目录规范（建议）

```
oct/
  docs/
    plan.md
    upstream-issues.md
    howfixandroid.md
    repro.md
    release.md
    sanitize.md
  scripts/
    healthcheck.sh
    sanitize-export.sh
    verify-markers.sh
  packaging/
    deb/
    pacman/
  artifacts/
    logs/
    releases/
```

说明：

- `docs/` 只收 OCT 范围内容（兼容性/构建线/证据链）
- `scripts/` 是复现入口，必须可在 Termux 执行
- `packaging/` 仅与 bun/opencode 打包有关

---

## 2) XDG 约定

尽量用 XDG 路径约定，便于跨设备复现：

- `XDG_CACHE_HOME`（默认 `~/.cache`）放大文件 cache（如 bun-termux-cache 可映射）
- `XDG_CONFIG_HOME`（默认 `~/.config`）放配置
- `XDG_STATE_HOME`（默认 `~/.local/state`）放运行状态

Termux 下若不完全遵循 XDG，可在文档里给出“实际路径=Termux 默认”的等价映射。

---

## 3) 脱敏导出规范（强制）

### 3.1 不允许导出内容

- 任意 `sk-...` / `ctx7sk-...` / token 形式 key
- OAuth refresh/access token
- 私有域名、私有 IP

### 3.2 必须支持的导出内容

- `docs/` 全部
- `scripts/` 全部
- 构建日志（去掉敏感信息）
- 版本信息（Termux/Android/arch/node/python/clang）

### 3.3 验收门禁

- 任何导出包中不得匹配：
  - `sk-[A-Za-z0-9]{20,}`
  - `ctx7sk-[A-Za-z0-9_-]{10,}`

---

## 4) 复现报告模板（最小）

每次报告必须提供：

1. `uname -a`
2. `node -v` / `python3 -V` / `clang --version`
3. 目标二进制 marker 检测输出（见 verify-markers.sh）
4. 首次运行与二次运行的关键日志片段（不含敏感信息）

---

## 5) pacman 优先的打包/安装/回滚流程（OCT）

> 说明：以下流程针对 Termux + pacman 环境，默认不使用 proot。

### 5.1 构建前检查

```bash
command -v makepkg
command -v pacman
command -v grun
```

确保 PKGBUILD 至少满足：

- `options=('!strip' '!debug')`（避免破坏 bun trailer）
- `package()` 只写 `$pkgdir$prefix`（不要写 `/`）
- `prefix="${PREFIX:-/data/data/com.termux/files/usr}"`

### 5.2 构建

```bash
# bun-termux
cd /data/data/com.termux/files/home/termux.opencode.all/packaging/pacman/bun
makepkg -C -f --noconfirm

# opencode-termux
cd /data/data/com.termux/files/home/termux.opencode.all/packaging/pacman/opencode
makepkg -C -f --noconfirm
```

### 5.3 安装

```bash
cd /data/data/com.termux/files/home/termux.opencode.all/packaging/pacman/bun
pacman -U --noconfirm ./bun-termux-<ver>-aarch64.pkg.tar.xz

cd /data/data/com.termux/files/home/termux.opencode.all/packaging/pacman/opencode
pacman -U --noconfirm ./opencode-termux-<ver>-aarch64.pkg.tar.xz
```

### 5.4 回归验收（最小）

```bash
bun --version
opencode --version
opencode --help >/dev/null

rt=/data/data/com.termux/files/usr/lib/opencode/runtime/opencode
wc -c "$rt"
strings -n 8 "$rt" | grep -F -- '---- Bun! ----'
```

### 5.5 回滚

```bash
# 查看缓存中旧包
ls /data/data/com.termux/files/var/cache/pacman/pkg | grep -E '^(bun-termux|opencode-termux)-'

# 安装指定旧版本
pacman -U --noconfirm /data/data/com.termux/files/var/cache/pacman/pkg/opencode-termux-<old>.pkg.tar.xz
pacman -U --noconfirm /data/data/com.termux/files/var/cache/pacman/pkg/bun-termux-<old>.pkg.tar.xz
```

### 5.6 黑屏/无响应排障（最小破坏原则）

1. 先仅清 lock：

```bash
find "${XDG_STATE_HOME:-$HOME/.local/state}/opencode" -maxdepth 1 -type f -name '*.lock' -delete
```

2. 不默认删除 DB / storage（避免破坏会话）。

3. 收集日志：

```bash
command ls -1t "$HOME/.local/share/opencode/log" | head
```

并记录是否出现：

- `setRawMode failed with errno: 5`
- `Cannot find module ... opencode-anthropic-auth ...`
