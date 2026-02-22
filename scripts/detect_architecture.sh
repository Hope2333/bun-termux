#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Architecture detection script
# Returns standardized architecture names for packaging

detect_architecture() {
    local raw_arch=$(uname -m)
    
    case "$raw_arch" in
        "aarch64"|"arm64")
            echo "aarch64"
            ;;
        "armv7l"|"arm")
            echo "armv7l"
            ;;
        "x86_64"|"amd64")
            echo "x86_64"
            ;;
        "i686"|"i386")
            echo "i686"
            ;;
        *)
            echo "$raw_arch"
            ;;
    esac
}

# Package manager specific architecture names
detect_package_manager_arch() {
    local package_manager="${1:-}"
    local arch=$(detect_architecture)
    
    case "$package_manager" in
        "apt"|"dpkg")
            # Debian/Ubuntu architecture names
            case "$arch" in
                "aarch64") echo "arm64" ;;
                "armv7l") echo "armhf" ;;
                "x86_64") echo "amd64" ;;
                "i686") echo "i386" ;;
                *) echo "$arch" ;;
            esac
            ;;
        "pacman")
            # Arch Linux architecture names
            echo "$arch"
            ;;
        *)
            echo "$arch"
            ;;
    esac
}

# Main execution
if [[ "${1:-}" == "--package-manager" ]]; then
    detect_package_manager_arch "${2:-}"
else
    detect_architecture
fi