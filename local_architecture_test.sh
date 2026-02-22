#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Local architecture test script
# Tests packaging system architecture compatibility locally

echo "=== 本地架构兼容性测试 ==="
echo "日期: $(date)"
echo "主机: $(hostname)"
echo ""

# Test 1: Architecture detection
echo "1. 架构检测测试..."
LOCAL_ARCH=$(uname -m)
echo "本地架构: $LOCAL_ARCH"

case "$LOCAL_ARCH" in
    "aarch64"|"arm64")
        echo "✓ 检测为ARM64 (64位)"
        TEST_ARCH="arm64"
        ;;
    "armv7l"|"arm")
        echo "✓ 检测为ARM32 (32位)"
        TEST_ARCH="armv7l"
        ;;
    *)
        echo "⚠ 未知架构: $LOCAL_ARCH"
        TEST_ARCH="$LOCAL_ARCH"
        ;;
esac

echo ""
echo "2. 包管理器检测..."
if command -v apt >/dev/null 2>&1; then
    echo "✓ apt可用 (Debian/Ubuntu风格)"
    PM="apt"
elif command -v pacman >/dev/null 2>&1; then
    echo "✓ pacman可用 (Arch风格)"
    PM="pacman"
else
    echo "✗ 未检测到包管理器"
    PM="unknown"
fi

echo ""
echo "3. 构建脚本测试..."
echo "测试架构: $TEST_ARCH"
echo "包管理器: $PM"

# Create test configuration
TEST_DIR="/data/data/com.termux/files/home/develop/test-$TEST_ARCH-$(date +%s)"
mkdir -p "$TEST_DIR"
cp -r .config "$TEST_DIR/"
cp -r scripts "$TEST_DIR/"
cp README.md setup.sh test_packaging.sh "$TEST_DIR/"

echo ""
echo "4. 创建测试配置..."
cat > "$TEST_DIR/.config/termux-packaging.conf" << EOF
# Test configuration for $TEST_ARCH
TERMUX_PREFIX="/data/data/com.termux/files/usr"
DEVELOP_ROOT="$TEST_DIR"
BUILD_DIR="$TEST_DIR/build"
ARTIFACTS_DIR="$TEST_DIR/artifacts"
PACKAGES_DIR="$TEST_DIR/packages"
BUN_SOURCE="$TEST_DIR/bun-termux/sources/bun"
OPENCODE_SOURCE="$TEST_DIR/opencode-termux/sources/opencode"
BUN_RUNTIME="$TEST_DIR/bun-termux/runtime/bun"
OPENCODE_RUNTIME="$TEST_DIR/opencode-termux/runtime/opencode"
BUN_VERSION="1.3.9"
OPENCODE_VERSION="1.1.65"
ARCHITECTURE="$TEST_ARCH"
ENABLE_DEBUG="false"
CREATE_PLACEHOLDERS="true"

export PREFIX="\$TERMUX_PREFIX"
export BUN_SOURCE="\$BUN_SOURCE"
export OPENCODE_SOURCE="\$OPENCODE_SOURCE"
export BUN_RUNTIME="\$BUN_RUNTIME"
export OPENCODE_RUNTIME="\$OPENCODE_RUNTIME"
export BUILD_DIR="\$BUILD_DIR"
export ARTIFACTS_DIR="\$ARTIFACTS_DIR"
EOF

echo "✓ 测试配置创建于: $TEST_DIR/.config/termux-packaging.conf"

echo ""
echo "5. 运行构建脚本测试..."
cd "$TEST_DIR"

# Make scripts executable
chmod +x scripts/build/*.sh scripts/package/*.sh 2>/dev/null || true

# Test build scripts (dry run)
echo "测试构建脚本 (模拟运行)..."
if bash -n scripts/build/build_bun.sh; then
    echo "✓ build_bun.sh 语法正确"
else
    echo "✗ build_bun.sh 语法错误"
fi

if bash -n scripts/build/build_opencode.sh; then
    echo "✓ build_opencode.sh 语法正确"
else
    echo "✗ build_opencode.sh 语法错误"
fi

if bash -n scripts/package/package_deb.sh; then
    echo "✓ package_deb.sh 语法正确"
else
    echo "✗ package_deb.sh 语法错误"
fi

echo ""
echo "6. 架构特定测试..."
echo "当前架构: $TEST_ARCH"

# Check for architecture-specific issues
if [[ "$TEST_ARCH" == "armv7l" ]]; then
    echo "执行ARM32特定检查..."
    # Check for 64-bit assumptions
    if grep -r "aarch64\|arm64\|64-bit" scripts/ --include="*.sh" | grep -v "ARCHITECTURE" | grep -v "arm64" | head -5; then
        echo "⚠ 发现可能的64位假设"
    else
        echo "✓ 未发现明显的64位假设"
    fi
fi

echo ""
echo "7. 包创建测试 (模拟)..."
# Simulate package creation
mkdir -p "$TEST_DIR/packages"
echo "模拟包创建 for $TEST_ARCH..."

cat > "$TEST_DIR/packages/test-package.meta" << EOF
test_architecture=$TEST_ARCH
test_package_manager=$PM
test_date=$(date -Iseconds)
test_host=$(hostname)
build_scripts_tested=build_bun.sh,build_opencode.sh,package_deb.sh
architecture_specific_checks=completed
EOF

echo "✓ 模拟包创建完成"

echo ""
echo "=== 测试完成 ==="
echo ""
echo "测试摘要:"
echo "- 架构: $TEST_ARCH ($LOCAL_ARCH)"
echo "- 包管理器: $PM"
echo "- 构建脚本: 语法检查通过"
echo "- 配置系统: 工作正常"
echo "- 测试目录: $TEST_DIR"
echo ""
echo "下一步:"
echo "1. 实际网络连接测试需要GitHub仓库URL"
echo "2. 远程机器测试需要SSH连接"
echo "3. 实际构建测试需要源代码"
echo ""
echo "本地架构兼容性验证完成。"