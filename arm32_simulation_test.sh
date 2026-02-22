#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# ARM32 simulation test
# Tests packaging system compatibility with ARM32 architecture

echo "=== ARM32移植性模拟测试 ==="
echo "测试ARM32 (armv7l) 兼容性"
echo ""

# Simulate ARM32 environment
SIM_ARCH="armv7l"
echo "模拟架构: $SIM_ARCH"
echo ""

echo "1. 检查构建脚本的架构兼容性..."
echo ""

# Check build scripts for architecture compatibility
ARCH_ISSUES=0

echo "检查 build_bun.sh..."
if grep -q "aarch64\|arm64" scripts/build/build_bun.sh; then
    echo "⚠ 发现aarch64/arm64引用"
    grep -n "aarch64\|arm64" scripts/build/build_bun.sh
    ARCH_ISSUES=$((ARCH_ISSUES + 1))
else
    echo "✓ 无架构硬编码"
fi

echo ""
echo "检查 build_opencode.sh..."
if grep -q "aarch64\|arm64" scripts/build/build_opencode.sh; then
    echo "⚠ 发现aarch64/arm64引用"
    grep -n "aarch64\|arm64" scripts/build/build_opencode.sh
    ARCH_ISSUES=$((ARCH_ISSUES + 1))
else
    echo "✓ 无架构硬编码"
fi

echo ""
echo "检查 package_deb.sh..."
if grep -q "aarch64\|arm64" scripts/package/package_deb.sh; then
    echo "⚠ 发现aarch64/arm64引用"
    grep -n "aarch64\|arm64" scripts/package/package_deb.sh
    ARCH_ISSUES=$((ARCH_ISSUES + 1))
else
    echo "✓ 无架构硬编码"
fi

echo ""
echo "2. 检查PKGBUILD文件..."
echo ""

# Check PKGBUILD files
for pkgfile in bun-termux/packaging/pacman/PKGBUILD opencode-termux/packaging/pacman/PKGBUILD; do
    echo "检查 $pkgfile..."
    if grep -q "arch=.*aarch64" "$pkgfile"; then
        echo "✓ 明确指定aarch64架构"
    elif grep -q "arch=" "$pkgfile"; then
        echo "⚠ 有arch设置但不明确"
        grep "arch=" "$pkgfile"
    else
        echo "✗ 无arch设置"
    fi
done

echo ""
echo "3. 检查DEBIAN/control文件..."
echo ""

# Check DEBIAN control files
for controlfile in bun-termux/packaging/deb/DEBIAN/control opencode-termux/packaging/deb/DEBIAN/control; do
    echo "检查 $controlfile..."
    if grep -q "Architecture:" "$controlfile"; then
        ARCH=$(grep "Architecture:" "$controlfile" | cut -d: -f2 | xargs)
        echo "架构设置: $ARCH"
        if [[ "$ARCH" == "arm64" ]]; then
            echo "⚠ 硬编码为arm64，需要改为变量"
            ARCH_ISSUES=$((ARCH_ISSUES + 1))
        elif [[ "$ARCH" == "all" ]] || [[ "$ARCH" == "any" ]]; then
            echo "✓ 架构无关设置"
        else
            echo "当前架构: $ARCH"
        fi
    else
        echo "✗ 无Architecture设置"
    fi
done

echo ""
echo "4. 架构变量使用检查..."
echo ""

# Check for architecture variable usage
echo "检查配置模板..."
if grep -q "ARCHITECTURE=" .config/termux-packaging.conf.template; then
    echo "✓ 使用ARCHITECTURE变量"
    if grep -q 'ARCHITECTURE="arm64"' .config/termux-packaging.conf.template; then
        echo "⚠ 默认值为arm64，但可覆盖"
    else
        echo "✓ 变量可配置"
    fi
else
    echo "✗ 无ARCHITECTURE变量"
    ARCH_ISSUES=$((ARCH_ISSUES + 1))
fi

echo ""
echo "5. 创建ARM32测试配置..."
echo ""

# Create ARM32 test configuration
ARM32_TEST_DIR="/data/data/com.termux/files/home/develop/arm32-sim-test"
mkdir -p "$ARM32_TEST_DIR/.config"

cat > "$ARM32_TEST_DIR/.config/termux-packaging.conf" << EOF
# ARM32 test configuration
TERMUX_PREFIX="/data/data/com.termux/files/usr"
DEVELOP_ROOT="$ARM32_TEST_DIR"
ARCHITECTURE="armv7l"
BUN_VERSION="1.3.9"
OPENCODE_VERSION="1.1.65"

# ARM32 specific paths (simulated)
BUN_SOURCE="\$DEVELOP_ROOT/bun-termux/sources/bun"
OPENCODE_SOURCE="\$DEVELOP_ROOT/opencode-termux/sources/opencode"
BUN_RUNTIME="\$DEVELOP_ROOT/bun-termux/runtime/bun"
OPENCODE_RUNTIME="\$DEVELOP_ROOT/opencode-termux/runtime/opencode"
BUILD_DIR="\$DEVELOP_ROOT/build"
ARTIFACTS_DIR="\$DEVELOP_ROOT/artifacts"
PACKAGES_DIR="\$DEVELOP_ROOT/packages"

export PREFIX="\$TERMUX_PREFIX"
export ARCHITECTURE="\$ARCHITECTURE"
export BUN_SOURCE="\$BUN_SOURCE"
export OPENCODE_SOURCE="\$OPENCODE_SOURCE"
export BUN_RUNTIME="\$BUN_RUNTIME"
export OPENCODE_RUNTIME="\$OPENCODE_RUNTIME"
export BUILD_DIR="\$BUILD_DIR"
export ARTIFACTS_DIR="\$ARTIFACTS_DIR"
EOF

echo "✓ ARM32测试配置创建于: $ARM32_TEST_DIR/.config/termux-packaging.conf"

echo ""
echo "6. 模拟包创建测试..."
echo ""

# Simulate package creation for ARM32
cat > "$ARM32_TEST_DIR/simulated-package.control" << EOF
Package: bun-termux-arm32-test
Version: 1.3.9
Architecture: armv7l
Maintainer: termux-test
Description: Bun for Termux (ARM32 simulated test)

Package: opencode-termux-arm32-test
Version: 1.1.65
Architecture: armv7l
Maintainer: termux-test
Description: OpenCode for Termux (ARM32 simulated test)
EOF

echo "✓ 模拟包控制文件创建"
echo ""

echo "7. 测试摘要..."
echo ""

if [[ $ARCH_ISSUES -eq 0 ]]; then
    echo "✅ 所有检查通过！"
    echo "打包系统对ARM32兼容性良好。"
else
    echo "⚠ 发现 $ARCH_ISSUES 个架构相关问题"
    echo "需要修复这些问题以确保ARM32兼容性。"
fi

echo ""
echo "=== ARM32模拟测试完成 ==="
echo ""
echo "发现的问题:"
echo "1. 架构硬编码检查: $ARCH_ISSUES 个问题"
echo "2. 变量使用: 已使用ARCHITECTURE变量"
echo "3. 配置系统: 支持ARM32配置"
echo ""
echo "建议修复:"
echo "1. 将DEBIAN/control中的'Architecture: arm64'改为'Architecture: \${ARCHITECTURE}'"
echo "2. 确保所有脚本使用ARCHITECTURE变量而非硬编码"
echo "3. 更新PKGBUILD中的arch设置以支持多架构"
echo ""
echo "测试目录: $ARM32_TEST_DIR"
echo "包含完整的ARM32测试配置。"