# Hope2333 项目包命名与构建规范

> 适用于所有 Hope2333 GitHub 用户下的项目输出

---

## 1. 包文件名格式

### 1.1 Pacman 包 (.pkg.tar.xz)

```
PKGNAME(-SPLITS)-PKGVER-PKGREL<-DISTROVER>-ARCH.pkg.tar.xz
```

**示例：**
```
opencode-1.1.65-8-aarch64.pkg.tar.xz
opencode-debug-1.1.65-8-aarch64.pkg.tar.xz
bun-1.3.9-2-termux-aarch64.pkg.tar.xz
tank-0.1.0-1-bullseye-x86_64.pkg.tar.xz
```

**字段说明：**
| 字段 | 必填 | 说明 |
|------|------|------|
| PKGNAME | ✅ | 包名，不含发行版后缀 |
| SPLITS | ❌ | 子包/变体，如 `debug`、`dev`、`doc` |
| PKGVER | ✅ | 上游版本号 |
| PKGREL | ✅ | 打包修订号 |
| DISTROVER | ❌ | 发行版标识：`termux`、`bionic`、`bullseye` 等 |
| ARCH | ✅ | 架构：`aarch64`、`x86_64`、`arm64` 等 |

### 1.2 DPKG 包 (.deb)

```
PKGNAME(-SPLITS)_PKGVER<~DISTROVER>-PKGREL-ARCH.deb
```

**示例：**
```
opencode_1.1.65-8_arm64.deb
opencode_1.1.65~termux-8_arm64.deb
bun_1.3.9-2_arm64.deb
tank_0.1.0~bullseye-1_amd64.deb
```

---

## 2. 包内部细节

### 2.1 DISTROVER 规则

| 目标平台 | DISTROVER | 示例 |
|----------|-----------|------|
| Termux | `termux` | `bun-1.3.9-1-termux-aarch64.pkg.tar.xz` |
| Ubuntu Bionic | `bionic` | `tank_0.1.0~bionic-1_amd64.deb` |
| Debian Bullseye | `bullseye` | `tank_0.1.0~bullseye-1_amd64.deb` |
| 通用 Linux | (省略) | `bun-1.3.9-1-aarch64.pkg.tar.xz` |

### 2.2 ARCH 规则

| 包管理器 | 架构名称 | 说明 |
|----------|----------|------|
| pacman | `aarch64` | ARM64 |
| pacman | `x86_64` | AMD64 |
| pacman | `armv7h` | ARM32 hard float |
| dpkg | `arm64` | ARM64 |
| dpkg | `amd64` | AMD64 |
| dpkg | `armhf` | ARM32 hard float |

### 2.3 包名规范

**正确：**
- `opencode` ✅
- `bun` ✅
- `tank` ✅

**错误：**
- `opencode-termux` ❌
- `bun-android` ❌
- `tank-termux` ❌

> 包名不应包含发行版后缀，发行版信息通过 DISTROVER 字段表达。

---

## 3. 依赖分类

### 3.1 依赖类型定义

| 类型 | pacman | dpkg | 说明 |
|------|--------|------|------|
| 构建依赖 | `makedepends` | `Build-Depends` | 编译时需要，运行时不需要 |
| 安装依赖 | `depends` | `Depends` | 安装和运行时必需 |
| 功能性依赖 | `optdepends` | `Recommends/Suggests` | 可选功能，缺失不影响基本运行 |

### 3.2 示例

**PKGBUILD：**
```bash
# 构建依赖：编译时需要
makedepends=('git' 'bun' 'clang')

# 安装依赖：运行时必需
depends=('bash' 'ncurses' 'glibc')

# 功能性依赖：可选功能
optdepends=(
    'ripgrep: faster search'
    'wl-clipboard: Wayland clipboard support'
)
```

**control (dpkg)：**
```
Build-Depends: git, bun, clang
Depends: ${shlibs:Depends}, bash, ncurses
Recommends: ripgrep, wl-clipboard
Suggests: xclip
```

### 3.3 依赖原则

1. **最小化原则**：不添加不必要的依赖
2. **精确原则**：明确区分构建依赖和运行依赖
3. **可选原则**：功能性依赖标记为可选
4. **继承原则**：子项目继承母项目的必要依赖

---

## 4. 打包流程

### 4.1 Pacman 打包

```bash
# 1. 创建源码包
tar -cvf package.tar src/

# 2. 最高压缩
xz -9 -e package.tar

# 3. 或使用 makepkg
makepkg -c -f
```

**压缩级别说明：**
- `-9`：最高压缩比
- `-e`：极致压缩（更耗时）
- 默认 makepkg 使用 `-z`（中等压缩）

### 4.2 DPKG 打包

```bash
# 使用 dpkg-deb
dpkg-deb -Zxz -z9 --build package-dir/

# 或使用 debuild
debuild -us -uc
```

---

## 5. 项目结构规范

### 5.1 母子项目关系

```
oh-my-litecode/              # 母项目 (OML)
├── docs/                    # 共享文档
├── tools/                   # 共享工具
└── solve-android/           # 子项目集合
    ├── opencode/            # 子项目：OCT
    └── bun/                 # 子项目：bun-termux

opencode-termux/             # 独立仓库（OCT）
├── packaging/
├── scripts/
└── README.md

bun-termux/                  # 独立仓库
├── packaging/
├── scripts/
└── README.md
```

### 5.2 依赖关系

```
bun-termux (独立) ←─ opencode-termux (depends)
                    ↑
                    └── oh-my-litecode (meta/可选)
```

---

## 6. 版本号规则

### 6.1 上游版本 (PKGVER)

- 遵循上游项目的版本号
- 示例：`1.1.65`、`1.3.9`

### 6.2 打包修订号 (PKGREL)

- 从 `1` 开始
- 每次打包修改递增
- 不改变上游版本时递增

### 6.3 子项目版本独立性

- 子项目版本号独立于母项目
- OML v0.1.0-alpha 与 OCT v1.1.65-8 无数字关联
- 各自的开发进度独立

---

## 7. 文档规范

### 7.1 必需文档

| 文档 | 位置 | 内容 |
|------|------|------|
| README.md | 项目根目录 | 项目介绍、快速开始 |
| CHANGELOG.md | 项目根目录 | 版本变更记录 |
| LICENSE | 项目根目录 | 许可证 |
| architecture.md | docs/ | 架构设计 |
| installation.md | docs/ | 安装指南 |

### 7.2 双向同步

- 母项目文档包含子项目概述和链接
- 子项目文档独立完整
- 共享规范通过母项目同步

---

## 8. 特殊情况处理

### 8.1 调试包

```
PKGNAME-debug-PKGVER-PKGREL-ARCH.pkg.tar.xz
```

包含：
- 编译符号
- 源代码
- 开发文档

### 8.2 多架构

同一 PKGBUILD 支持多架构：

```bash
arch=('aarch64' 'x86_64' 'armv7h')
```

### 8.3 平台特定补丁

```
patches/
├── 001-common.patch
├── 002-termux.patch
└── 003-android.patch
```

---

## 9. 检查清单

打包前确认：

- [ ] 包名不含发行版后缀
- [ ] DISTROVER 正确填写
- [ ] ARCH 与包管理器匹配
- [ ] 依赖分类正确
- [ ] 压缩级别最优
- [ ] 文档完整
- [ ] 许可证文件存在
