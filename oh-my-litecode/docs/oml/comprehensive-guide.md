# Oh-My-Litecode 综合文档

> 最后更新：2026-02-20

---

## 1. 项目概述

### 1.1 OML 是什么？

Oh-My-Litecode (OML) 是一个统一的工具链管理器，专注于 Termux/Android 平台上的 AI 辅助开发环境。

### 1.2 子项目

| 缩写 | 全名 | 仓库 | 状态 |
|------|------|------|------|
| OML | Oh-My-Litecode | Hope2333/oh-my-litecode | 母项目 |
| OCT | OpenCode-Termux | Hope2333/opencode-termux | ✅ 完成 |
| BUN | bun-termux | Hope2333/bun-termux | ✅ 完成 |
| OMG | omgemini | - | 规划中 |
| OMA | omaider | - | 规划中 |

### 1.3 依赖关系

```
bun-termux (独立)
    ↑
    └── opencode-termux (depends: bun)
            ↑
            └── oh-my-litecode (meta/工具集)
```

---

## 2. 包命名规范

详见：[packaging-standards.md](./packaging-standards.md)

### 2.1 Pacman

```
PKGNAME(-SPLITS)-PKGVER-PKGREL<-DISTROVER>-ARCH.pkg.tar.xz
```

示例：
- `opencode-1.1.65-8-aarch64.pkg.tar.xz`
- `bun-1.3.9-1-aarch64.pkg.tar.xz`

### 2.2 DPKG

```
PKGNAME(-SPLITS)_PKGVER<~DISTROVER>-PKGREL-ARCH.deb
```

示例：
- `opencode_1.1.65-8_arm64.deb`
- `bun_1.3.9-1_arm64.deb`

---

## 3. 关键技术问题与解决方案

### 3.1 OpenCode 在 Termux 上的问题

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| Linux 二进制无法运行 | interpreter/PIE 不兼容 | 使用 bun-compiled runtime |
| npm install 失败 | postinstall 引用不存在包 | staged build |
| setRawMode errno:5 | stdio 未绑定 tty | launcher: ensure_stdio_tty |
| EACCES on plugin install | bun add 权限问题 | 禁用默认插件 |
| 二次启动无响应 | lock 文件残留 | launcher: cleanup_state_locks |

### 3.2 Bun 在 Termux 上的问题

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| glibc 二进制无法执行 | Android 使用 bionic | glibc-runner (grun) |
| bun build --compile 问题 | /proc/self/exe 指向 ld.so | bun-termux-loader |

---

## 4. 构建流程

详见：[build-rules.md](./build-rules.md)

### 4.1 构建命令

```bash
# OML 所有子项目
make build

# 单个项目
make build-project PROJECT=opencode PKGVER=1.1.65

# 调试包
make build DEBUG=true
```

### 4.2 发布流程

```bash
# 1. 更新版本
make upgrade PKGVER=1.2.0

# 2. 构建
make package

# 3. 测试
pacman -U dist/*.pkg.tar.xz

# 4. 发布
git tag v1.2.0
git push origin v1.2.0
```

---

## 5. Session 同步

详见：[session-sync-prompts.md](./session-sync-prompts.md)

### 5.1 快速同步

```
继续 OML 项目工作。
项目位于 ~/develop/oh-my-litecode
当前状态：v0.1.0-alpha
现在需要：[具体任务]
```

### 5.2 调试机信息

```
SSH: u0_a450@172.18.0.1 -p 8022 (密码: 0)
备用: u0_a450@192.168.1.164 -p 8022
包管理器: pacman
前缀: /data/data/com.termux/files/usr
```

---

## 6. 文档索引

| 文档 | 内容 |
|------|------|
| [packaging-standards.md](./packaging-standards.md) | 包命名与构建规范 |
| [build-rules.md](./build-rules.md) | 通用构建规则 |
| [session-sync-prompts.md](./session-sync-prompts.md) | Session 同步提示词 |
| [glossary.md](./glossary.md) | 术语表 |
| [opencode/architecture.md](../opencode/architecture.md) | OCT 架构 |
| [opencode/installation.md](../opencode/installation.md) | OCT 安装指南 |
| [bun/architecture.md](../bun/architecture.md) | Bun 架构 |

---

## 7. 开发笔记

### 7.1 已解决的问题

1. **makepkg strip 破坏 runtime**
   - 添加 `options=('!strip' '!debug')`

2. **launcher 脚本格式错误**
   - 使用 here-doc 生成，避免 quote 问题

3. **rsync --delete 删除 runtime 目录**
   - 在 rsync 后重新创建 runtime 目录

### 7.2 待解决的问题

1. **opencode-anthropic-auth 安装失败**
   - 当前方案：禁用默认插件
   - 长期方案：修复 bun add 权限问题

2. **版本更新自动化**
   - 需要自动检测上游版本
   - 需要自动更新 PKGBUILD

---

## 8. 许可证

MIT License - 与上游项目保持一致

- OpenCode: MIT
- Bun: MIT
- bun-termux-loader: MIT
