#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Setup script for Termux Packaging System
# This script helps initialize the development environment

echo "=== Termux Packaging Setup ==="
echo ""

# Check if configuration exists
if [[ -f ".config/termux-packaging.conf" ]]; then
    echo "✓ Configuration already exists at .config/termux-packaging.conf"
    echo "  To reconfigure, remove it and run this script again."
else
    echo "Creating configuration from template..."
    if [[ -f ".config/termux-packaging.conf.template" ]]; then
        cp .config/termux-packaging.conf.template .config/termux-packaging.conf
        echo "✓ Created .config/termux-packaging.conf"
        echo ""
        echo "Please edit .config/termux-packaging.conf with your local paths:"
        echo "  - DEVELOP_ROOT: Path to this repository"
        echo "  - BUN_SOURCE: Path to Bun source code"
        echo "  - OPENCODE_SOURCE: Path to OpenCode source code"
        echo "  - BUN_RUNTIME: Path to pre-built Bun binary"
        echo "  - OPENCODE_RUNTIME: Path to pre-built OpenCode binary"
    else
        echo "✗ Template file not found: .config/termux-packaging.conf.template"
        exit 1
    fi
fi

echo ""
echo "Making scripts executable..."
chmod +x scripts/build/*.sh scripts/package/*.sh test_packaging.sh verify_merge.sh 2>/dev/null || true

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Edit .config/termux-packaging.conf with your paths"
echo "2. Source the configuration: source .config/termux-packaging.conf"
echo "3. Run tests: ./test_packaging.sh"
echo ""
echo "For arm32 (armv7l) testing, change ARCHITECTURE in the config file."
