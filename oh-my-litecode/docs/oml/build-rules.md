# OML 构建规则通用文档

> 适用于 Oh-My-Litecode 及其子项目的通用构建规则

---

## 1. 构建环境

### 1.1 Termux 环境

```bash
# 必需工具
pacman -S make git rsync

# 构建工具
pacman -S clang python3

# 打包工具
pacman -S pacman-contrib
```

### 1.2 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `PREFIX` | `/data/data/com.termux/files/usr` | 安装前缀 |
| `PKGVER` | (从 PKGBUILD) | 版本号 |
| `PKGREL` | `1` | 打包修订号 |
| `DEBUG` | `false` | 是否构建调试包 |
| `PKGMGR` | `pacman` | 包管理器类型 |

---

## 2. Makefile 模板

### 2.1 基础模板

```makefile
SHELL := /bin/bash
.DEFAULT_GOAL := help

PKGVER ?= 1.0.0
PKGREL ?= 1
DEBUG ?= false
PKGMGR ?= pacman
ARCH ?= aarch64
DISTROVER ?= termux

PROJECT_DIR := $(shell pwd)
BUILD_DIR := $(PROJECT_DIR)/.build
DIST_DIR := $(PROJECT_DIR)/dist

ifeq ($(DEBUG),true)
    SUFFIX := -debug
else
    SUFFIX :=
endif

ifeq ($(PKGMGR),pacman)
    PKG_EXT := .pkg.tar.xz
    ARCH_NAME := $(ARCH)
else
    PKG_EXT := .deb
    ARCH_NAME := $(subst aarch64,arm64,$(ARCH))
endif

PKG_NAME := $(PROJECT)-$(PKGVER)-$(PKGREL)-$(ARCH_NAME)$(PKG_EXT)

.PHONY: help build clean package

help:
	@echo "Usage: make [target] [VARIABLE=value]"
	@echo ""
	@echo "Targets: build clean package"
	@echo "Variables: PKGVER=$(PKGVER) PKGREL=$(PKGREL)"

build:
	@echo "Building $(PROJECT) v$(PKGVER)..."
	@mkdir -p $(BUILD_DIR)
	# Add build steps here

package: build
	@echo "Creating package..."
	@mkdir -p $(DIST_DIR)
	# Add packaging steps here

clean:
	@rm -rf $(BUILD_DIR) $(DIST_DIR)
	@echo "Clean complete."
```

---

## 3. PKGBUILD 模板

### 3.1 标准 PKGBUILD

```bash
pkgname=PROJECT
pkgver=1.0.0
pkgrel=1
pkgdesc='Description'
arch=('aarch64')
url='https://github.com/user/project'
license=('MIT')
options=('!strip' '!debug')

# 构建依赖
makedepends=('git' 'clang')

# 安装依赖
depends=('bash' 'glibc')

# 功能性依赖
optdepends=(
    'ripgrep: faster search'
)

source=("$pkgname-$pkgver.tar.gz::https://github.com/user/project/archive/v$pkgver.tar.gz")
sha256sums=('SKIP')

build() {
    cd "$pkgname-$pkgver"
    # Build steps
}

package() {
    cd "$pkgname-$pkgver"
    # Package steps
    
    # 安装到正确的位置
    local prefix="${PREFIX:-/data/data/com.termux/files/usr}"
    install -Dm755 binary "$pkgdir$prefix/bin/binary"
}
```

### 3.2 Termux 特殊配置

```bash
# 禁用 strip（保护 bun runtime）
options=('!strip' '!debug')

# 使用正确的安装前缀
local prefix="${PREFIX:-/data/data/com.termux/files/usr}"

# 避免 npm global postinstall
# 使用 staged build 替代
```

---

## 4. 打包命令

### 4.1 Pacman

```bash
# 构建
makepkg -C -f

# 安装
pacman -U package.pkg.tar.xz

# 验证
pacman -Qi package
```

### 4.2 DPKG

```bash
# 构建
dpkg-deb -Zxz -z9 --build package-dir/

# 安装
dpkg -i package.deb

# 验证
dpkg -s package
```

---

## 5. 子项目构建规则

### 5.1 bun-termux

```makefile
build:
	# 下载或复制预编译的 bun 二进制
	# 创建 grun wrapper

package:
	# 安装二进制到 $PREFIX/lib/bun-termux/
	# 安装 wrapper 到 $PREFIX/bin/bun
```

**依赖：**
- makedepends: (无，使用预编译二进制)
- depends: `glibc-runner` `bash`

### 5.2 opencode-termux

```makefile
build:
	# 复制 OpenCode 源码
	# 安装 bun-compiled runtime
	# 创建 launcher 脚本

package:
	# 安装到 $PREFIX/lib/opencode/
	# 安装 launcher 到 $PREFIX/bin/opencode
```

**依赖：**
- makedepends: (无，使用预编译 runtime)
- depends: `bash` `ncurses` `bun-termux`

---

## 6. 调试包构建

```bash
# 构建调试包
make build DEBUG=true

# 调试包包含：
# - 源代码
# - 编译符号
# - 开发文档
# - 测试用例
```

---

## 7. 版本更新流程

```bash
# 1. 更新版本号
make upgrade PKGVER=1.2.0

# 2. 重新构建
make clean build package

# 3. 测试安装
pacman -U dist/package.pkg.tar.xz

# 4. 发布
git tag v1.2.0
git push origin v1.2.0
```

---

## 8. 常见问题

### 8.1 runtime 被 strip 破坏

**问题：** bun compiled binary 被默认 strip 后无法运行

**解决：**
```bash
options=('!strip' '!debug')
```

### 8.2 安装路径错误

**问题：** 安装到错误的前缀

**解决：**
```bash
local prefix="${PREFIX:-/data/data/com.termux/files/usr}"
install -Dm755 binary "$pkgdir$prefix/bin/binary"
```

### 8.3 依赖未正确声明

**问题：** 运行时报错缺少依赖

**解决：** 使用 `ldd` 检查动态链接依赖
```bash
ldd binary | grep "not found"
```
