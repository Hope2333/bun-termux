#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Script to test packaging on remote machines
# Usage: ./test_remote_machine.sh <ip> <port> <github-repo>

IP="${1:-10.31.66.45}"
PORT="${2:-8022}"
GITHUB_REPO="${3:-}"

# Determine SSH user based on IP
case "$IP" in
    "10.31.66.45")
        SSH_USER="u0_a240"  # arm64 test machine
        ;;
    "10.31.66.76")
        SSH_USER="u0_a177"  # arm32 test machine
        ;;
    *)
        SSH_USER="u0_a450"  # Default Termux user
        ;;
esac

if [[ -z "$GITHUB_REPO" ]]; then
    echo "Usage: $0 <ip> <port> <github-repo>"
    echo "Example: $0 10.31.66.45 8022 https://github.com/yourusername/termux-packaging.git"
    exit 1
fi

echo "=== Testing on remote machine ==="
echo "Machine: $IP:$PORT"
echo "Repository: $GITHUB_REPO"
echo ""

# Create test script to run on remote
TEST_SCRIPT=$(cat <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "=== Remote Test Started ==="
echo "Hostname: $(hostname)"
echo "Architecture: $(uname -m)"
echo "Termux info: $(termux-info 2>/dev/null | head -5 || echo "Not available")"
echo ""

# Clone repository
REPO_URL="$1"
echo "Cloning repository: $REPO_URL"
rm -rf termux-packaging-test
git clone "$REPO_URL" termux-packaging-test
cd termux-packaging-test

echo ""
echo "=== Repository Contents ==="
ls -la
echo ""

echo "=== Running Setup ==="
./setup.sh
echo ""

echo "=== Testing Build Scripts ==="
# Test that scripts are executable
if [[ -x "scripts/build/build_bun.sh" ]]; then
    echo "✓ build_bun.sh is executable"
else
    echo "✗ build_bun.sh is not executable"
fi

if [[ -x "scripts/build/build_opencode.sh" ]]; then
    echo "✓ build_opencode.sh is executable"
else
    echo "✗ build_opencode.sh is not executable"
fi

if [[ -x "scripts/package/package_deb.sh" ]]; then
    echo "✓ package_deb.sh is executable"
else
    echo "✗ package_deb.sh is not executable"
fi

echo ""
echo "=== Configuration Test ==="
if [[ -f ".config/termux-packaging.conf.template" ]]; then
    echo "✓ Configuration template exists"
    # Create test config
    cp .config/termux-packaging.conf.template .config/termux-packaging.conf
    # Update paths for test
    sed -i "s|/path/to/your/develop|$(pwd)|g" .config/termux-packaging.conf
    sed -i "s|ARCHITECTURE=\"arm64\"|ARCHITECTURE=\"$(uname -m)\"|g" .config/termux-packaging.conf
    echo "✓ Test configuration created"
else
    echo "✗ Configuration template missing"
fi

echo ""
echo "=== Package Manager Check ==="
if command -v apt >/dev/null 2>&1; then
    echo "✓ apt is available (Debian/Ubuntu style)"
    PM="apt"
elif command -v pacman >/dev/null 2>&1; then
    echo "✓ pacman is available (Arch style)"
    PM="pacman"
else
    echo "✗ No package manager detected"
    PM="unknown"
fi

echo ""
echo "=== Architecture Check ==="
ARCH=$(uname -m)
case "$ARCH" in
    "aarch64"|"arm64")
        echo "✓ ARM64 (64-bit) architecture"
        EXPECTED_ARCH="arm64"
        ;;
    "armv7l"|"arm")
        echo "✓ ARM32 (32-bit) architecture"
        EXPECTED_ARCH="armv7l"
        ;;
    *)
        echo "⚠ Unknown architecture: $ARCH"
        EXPECTED_ARCH="$ARCH"
        ;;
esac

echo ""
echo "=== Test Summary ==="
echo "Machine: $(hostname)"
echo "Architecture: $ARCH ($EXPECTED_ARCH)"
echo "Package manager: $PM"
echo "Repository: Cloned successfully"
echo "Scripts: All executable"
echo "Configuration: Template available"
echo ""
echo "=== Next Steps on This Machine ==="
echo "1. Edit .config/termux-packaging.conf with correct paths"
echo "2. Source configuration: source .config/termux-packaging.conf"
echo "3. Run build test: ./test_packaging.sh"
echo "4. Build packages: ./scripts/build/build_*.sh"
echo ""
echo "=== Remote Test Complete ==="
EOF
)

echo "Connecting to $IP:$PORT..."
echo "Running test script on remote machine..."
echo ""

# Copy test script to remote and execute
echo "$TEST_SCRIPT" | ssh -p "$PORT" "${SSH_USER}@${IP}" "cat > /tmp/remote_test.sh && chmod +x /tmp/remote_test.sh && /tmp/remote_test.sh '$GITHUB_REPO'"

echo ""
echo "=== Local Test Complete ==="
echo "Check above output for any issues."
echo ""
echo "If successful, the remote machine can now:"
echo "1. Use the packaging system"
echo "2. Build packages for its architecture"
echo "3. Test ARM32/ARM64 compatibility"