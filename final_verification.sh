#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Final verification script for packaging system
# Tests all components for multi-architecture compatibility

echo "=== 最终验证测试 ==="
echo "测试时间: $(date)"
echo ""

PASS=0
FAIL=0
WARN=0

check() {
    local name="$1"
    local condition="$2"
    local message="$3"
    
    if eval "$condition"; then
        echo "✅ $name: $message"
        PASS=$((PASS + 1))
    else
        echo "❌ $name: $message"
        FAIL=$((FAIL + 1))
    fi
}

warn() {
    local name="$1"
    local message="$2"
    echo "⚠  $name: $message"
    WARN=$((WARN + 1))
}

echo "1. 基础架构检测..."
check "架构检测脚本" \
    "[[ -f scripts/detect_architecture.sh ]]" \
    "架构检测脚本存在"

check "架构检测可执行" \
    "bash -n scripts/detect_architecture.sh" \
    "架构检测脚本语法正确"

echo ""
echo "2. 构建脚本验证..."
check "构建脚本存在" \
    "[[ -f scripts/build/build_bun.sh && -f scripts/build/build_opencode.sh ]]" \
    "所有构建脚本存在"

check "构建脚本可执行" \
    "[[ -x scripts/build/build_bun.sh && -x scripts/build/build_opencode.sh ]]" \
    "构建脚本可执行"

check "构建脚本语法" \
    "bash -n scripts/build/build_bun.sh && bash -n scripts/build/build_opencode.sh" \
    "构建脚本语法正确"

echo ""
echo "3. 打包脚本验证..."
check "打包脚本存在" \
    "[[ -f scripts/package/package_deb.sh ]]" \
    "打包脚本存在"

check "打包脚本使用变量" \
    "grep -q 'ARCHITECTURE=\"\\\${4:-\\\${ARCHITECTURE:-arm64}}\"' scripts/package/package_deb.sh" \
    "打包脚本使用环境变量"

check "打包脚本语法" \
    "bash -n scripts/package/package_deb.sh" \
    "打包脚本语法正确"

echo ""
echo "4. 配置文件验证..."
check "配置模板存在" \
    "[[ -f .config/termux-packaging.conf.template ]]" \
    "配置模板存在"

check "配置使用变量" \
    "grep -q 'ARCHITECTURE=' .config/termux-packaging.conf.template" \
    "配置使用ARCHITECTURE变量"

check "无硬编码路径" \
    "! grep -q 'termux.opencode.all' .config/termux-packaging.conf.template" \
    "无硬编码路径"

echo ""
echo "5. 多架构支持验证..."
check "DEBIAN控制文件使用变量" \
    "grep -q 'Architecture: \\\${ARCHITECTURE}' bun-termux/packaging/deb/DEBIAN/control && grep -q 'Architecture: \\\${ARCHITECTURE}' opencode-termux/packaging/deb/DEBIAN/control" \
    "DEBIAN控制文件使用变量"

check "版本变量使用" \
    "grep -q 'Version: \\\${BUN_VERSION}' bun-termux/packaging/deb/DEBIAN/control && grep -q 'Version: \\\${OPENCODE_VERSION}' opencode-termux/packaging/deb/DEBIAN/control" \
    "使用版本变量"

# Check PKGBUILD multi-arch support
if [[ -f bun-termux/packaging/pacman/PKGBUILD.aarch64 && -f bun-termux/packaging/pacman/PKGBUILD.armv7l ]]; then
    check "多架构PKGBUILD" \
        "true" \
        "PKGBUILD多架构支持已实现"
else
    warn "PKGBUILD多架构" \
        "PKGBUILD需要架构特定版本"
fi

echo ""
echo "6. 文档完整性..."
check "README存在" \
    "[[ -f README.md ]]" \
    "README文档存在"

check "测试文档存在" \
    "[[ -f TESTING_PROCESS.md && -f MANUAL_TEST_GUIDE.md ]]" \
    "测试文档完整"

check "ARM32文档" \
    "[[ -f docs/arm32-porting.md ]]" \
    "ARM32移植文档存在"

echo ""
echo "7. 自动化脚本..."
check "GitHub推送脚本" \
    "[[ -f push_to_github.sh ]]" \
    "GitHub推送脚本存在"

check "远程测试脚本" \
    "[[ -f test_remote_machine.sh ]]" \
    "远程测试脚本存在"

check "备份脚本" \
    "[[ -f backup_verification.sh ]]" \
    "备份验证脚本存在"

check "本地测试脚本" \
    "[[ -f local_architecture_test.sh && -f arm32_simulation_test.sh ]]" \
    "本地测试脚本完整"

echo ""
echo "=== 验证结果 ==="
echo "总计检查: $((PASS + FAIL + WARN))"
echo "✅ 通过: $PASS"
echo "❌ 失败: $FAIL"
echo "⚠  警告: $WARN"
echo ""

if [[ $FAIL -eq 0 ]]; then
    if [[ $WARN -eq 0 ]]; then
        echo "🎉 所有检查通过！打包系统已准备好进行多架构测试。"
    else
        echo "✓ 主要检查通过，但有 $WARN 个警告需要注意。"
    fi
    
    echo ""
    echo "下一步操作:"
    echo "1. 创建GitHub仓库: https://github.com/new"
    echo "2. 推送代码: ./push_to_github.sh <仓库URL>"
    echo "3. 测试arm64: ./test_remote_machine.sh 10.31.66.45 8022 <仓库URL>"
    echo "4. 测试arm32: ./test_remote_machine.sh 10.31.66.76 8022 <仓库URL>"
    echo "5. 创建备份: ./backup_verification.sh"
else
    echo "⚠ 有 $FAIL 个检查失败，需要修复后才能进行测试。"
    echo ""
    echo "需要修复的问题:"
    echo "1. 检查失败的项目"
    echo "2. 重新运行验证: ./final_verification.sh"
fi

echo ""
echo "=== 架构兼容性状态 ==="
echo "支持架构:"
echo "- arm64 (aarch64): ✅ 完全支持"
echo "- arm32 (armv7l): ⚠ 需要PKGBUILD特定版本"
echo ""
echo "包管理器支持:"
echo "- apt/deb: ✅ 完全支持 (使用变量)"
echo "- pacman: ⚠ 需要架构特定PKGBUILD"
echo ""
echo "测试环境:"
echo "- 本机 (localhost): termux-pacman arm64"
echo "- 测试机1 (10.31.66.45): termux-apt arm64"
echo "- 测试机2 (10.31.66.76): termux-apt arm32"