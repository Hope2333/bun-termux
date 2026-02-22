#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Package script for DEB packages on Termux
# Uses environment variables for configuration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVELOP_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Configuration
PACKAGE_TYPE="${1:-}"
PACKAGE_NAME="${2:-}"
VERSION="${3:-1.0.0}"
ARCHITECTURE="${4:-${ARCHITECTURE:-arm64}}"  # Use environment variable or default

if [[ -z "$PACKAGE_TYPE" ]] || [[ -z "$PACKAGE_NAME" ]]; then
    echo "Usage: $0 <package_type> <package_name> [version] [architecture]"
    echo "  package_type: bun or opencode"
    echo "  package_name: output package name"
    echo "  version: package version (default: 1.0.0)"
    echo "  architecture: architecture from env or arm64 (default)"
    echo "               Set ARCHITECTURE environment variable for different arch"
    exit 1
fi

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

error() {
    echo "ERROR: $*" >&2
    exit 1
}

need_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        error "Required command '$1' not found"
    fi
}

need_cmd bash
need_cmd mkdir
need_cmd cp
need_cmd find
need_cmd dpkg-deb || log "Warning: dpkg-deb not found, creating package structure only"

# Set up directories
PACKAGE_DIR="$DEVELOP_DIR/packages/$PACKAGE_NAME"
STAGED_DIR=""
CONTROL_FILE=""

case "$PACKAGE_TYPE" in
    bun)
        STAGED_DIR="${BUN_STAGED:-$DEVELOP_DIR/bun-termux/artifacts/staged/prefix}"
        CONTROL_FILE="$DEVELOP_DIR/bun-termux/packaging/deb/DEBIAN/control"
        ;;
    opencode)
        STAGED_DIR="${OPENCODE_STAGED:-$DEVELOP_DIR/opencode-termux/artifacts/staged/prefix}"
        CONTROL_FILE="$DEVELOP_DIR/opencode-termux/packaging/deb/DEBIAN/control"
        ;;
    *)
        error "Unknown package type: $PACKAGE_TYPE. Use 'bun' or 'opencode'"
        ;;
esac

if [[ ! -d "$STAGED_DIR" ]]; then
    error "Staged directory not found: $STAGED_DIR"
    log "Run build script first: develop/scripts/build/build_${PACKAGE_TYPE}.sh"
    exit 1
fi

if [[ ! -f "$CONTROL_FILE" ]]; then
    error "Control file not found: $CONTROL_FILE"
    exit 1
fi

# Create package directory
log "Creating DEB package: $PACKAGE_NAME"
log "Type: $PACKAGE_TYPE"
log "Version: $VERSION"
log "Architecture: $ARCHITECTURE"
log "Staged dir: $STAGED_DIR"

rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR/DEBIAN"
chmod 755 "$PACKAGE_DIR/DEBIAN"

# Copy staged files
log "Copying staged files..."
cp -a "$STAGED_DIR/." "$PACKAGE_DIR/"

# Update control file with version and architecture
log "Creating control file..."
cp "$CONTROL_FILE" "$PACKAGE_DIR/DEBIAN/"

# Replace variables in control file
sed -i "s/\${BUN_VERSION}/$VERSION/g" "$PACKAGE_DIR/DEBIAN/control"
sed -i "s/\${OPENCODE_VERSION}/$VERSION/g" "$PACKAGE_DIR/DEBIAN/control"
sed -i "s/\${ARCHITECTURE}/$ARCHITECTURE/g" "$PACKAGE_DIR/DEBIAN/control"

# Fallback for hardcoded versions (if variables not used)
sed -i "s/Version: .*/Version: $VERSION/" "$PACKAGE_DIR/DEBIAN/control"
sed -i "s/Architecture: .*/Architecture: $ARCHITECTURE/" "$PACKAGE_DIR/DEBIAN/control"

# Calculate installed size
log "Calculating installed size..."
INSTALLED_SIZE=$(find "$PACKAGE_DIR" -type f -exec ls -l {} \; 2>/dev/null | awk '{sum += $5} END {print int(sum/1024)}')
sed -i "/^Installed-Size:/d" "$PACKAGE_DIR/DEBIAN/control"
echo "Installed-Size: $INSTALLED_SIZE" >> "$PACKAGE_DIR/DEBIAN/control"

# Create postinst script if needed
if [[ ! -f "$PACKAGE_DIR/DEBIAN/postinst" ]]; then
    cat > "$PACKAGE_DIR/DEBIAN/postinst" <<'POSTINST'
#!/usr/bin/env bash
set -euo pipefail

echo ""
echo "Package installed successfully!"
echo ""
POSTINST
    chmod 755 "$PACKAGE_DIR/DEBIAN/postinst"
fi

# Build the package
if command -v dpkg-deb >/dev/null 2>&1; then
    log "Building DEB package..."
    dpkg-deb --build "$PACKAGE_DIR" "$DEVELOP_DIR/packages/${PACKAGE_NAME}_${VERSION}_${ARCHITECTURE}.deb"
    log "Package created: $DEVELOP_DIR/packages/${PACKAGE_NAME}_${VERSION}_${ARCHITECTURE}.deb"
else
    log "dpkg-deb not available. Package structure created at: $PACKAGE_DIR"
    log "To build DEB package, install dpkg and run:"
    log "  dpkg-deb --build $PACKAGE_DIR"
fi

# Create package metadata
cat > "$DEVELOP_DIR/packages/${PACKAGE_NAME}.meta" <<EOF
package_name=$PACKAGE_NAME
package_type=$PACKAGE_TYPE
version=$VERSION
architecture=$ARCHITECTURE
build_time=$(date -Iseconds)
staged_dir=$STAGED_DIR
control_file=$CONTROL_FILE
installed_size=${INSTALLED_SIZE}KB
EOF

log "Packaging completed"