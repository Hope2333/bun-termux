#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Build script for OpenCode on Termux
# Uses environment variables for configuration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVELOP_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Configuration (can be overridden by environment)
OPENCODE_SOURCE="${OPENCODE_SOURCE:-$DEVELOP_DIR/opencode-termux/sources/opencode}"
OPENCODE_RUNTIME="${OPENCODE_RUNTIME:-$DEVELOP_DIR/opencode-termux/runtime/opencode}"
BUILD_DIR="${BUILD_DIR:-$DEVELOP_DIR/opencode-termux/build}"
ARTIFACTS_DIR="${ARTIFACTS_DIR:-$DEVELOP_DIR/opencode-termux/artifacts}"

# Create directories
mkdir -p "$BUILD_DIR" "$ARTIFACTS_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

error() {
    echo "ERROR: $*" >&2
    exit 1
}

# Check for required commands
need_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        error "Required command '$1' not found"
    fi
}

need_cmd bash
need_cmd mkdir
need_cmd cp
need_cmd rsync || need_cmd cp  # rsync preferred, but cp is okay

log "Starting OpenCode build for Termux"
log "Source: ${OPENCODE_SOURCE}"
log "Build dir: ${BUILD_DIR}"
log "Artifacts: ${ARTIFACTS_DIR}"

# Check source directory
if [[ ! -d "$OPENCODE_SOURCE" ]]; then
    log "Warning: OpenCode source not found at $OPENCODE_SOURCE"
    log "Will create minimal package structure"
else
    # Copy source to build directory (excluding git and node_modules)
    log "Copying OpenCode source..."
    if command -v rsync >/dev/null 2>&1; then
        rsync -a --exclude='.git' --exclude='node_modules' \
            "$OPENCODE_SOURCE/" "$BUILD_DIR/source/" 2>/dev/null || \
        cp -a "$OPENCODE_SOURCE/." "$BUILD_DIR/source/"
    else
        cp -a "$OPENCODE_SOURCE/." "$BUILD_DIR/source/"
        # Clean up unwanted directories
        rm -rf "$BUILD_DIR/source/.git" 2>/dev/null || true
        rm -rf "$BUILD_DIR/source/node_modules" 2>/dev/null || true
    fi
fi

# Handle runtime
if [[ -f "$OPENCODE_RUNTIME" ]]; then
    log "Using existing runtime: $OPENCODE_RUNTIME"
    cp "$OPENCODE_RUNTIME" "$ARTIFACTS_DIR/opencode"
    chmod 755 "$ARTIFACTS_DIR/opencode"
else
    log "No pre-built runtime found at $OPENCODE_RUNTIME"
    log "Creating placeholder runtime for packaging"
    
    # Create a simple wrapper
    cat > "$ARTIFACTS_DIR/opencode" <<'PLACEHOLDER'
#!/usr/bin/env bash
# Placeholder OpenCode runtime for Termux

echo "OpenCode runtime not built." >&2
echo "Please build OpenCode runtime and place at: $(dirname "$0")/../runtime/opencode" >&2
echo ""
echo "For development, you can use the source version:" >&2
echo "  cd /path/to/opencode/source" >&2
echo "  bun run cli" >&2
exit 1
PLACEHOLDER
    chmod 755 "$ARTIFACTS_DIR/opencode"
fi

# Create staged prefix structure for packaging
log "Creating staged prefix structure..."
PREFIX="$ARTIFACTS_DIR/staged/prefix"
mkdir -p "$PREFIX/lib/opencode"
mkdir -p "$PREFIX/lib/opencode/runtime"
mkdir -p "$PREFIX/bin"

# Copy source if available
if [[ -d "$BUILD_DIR/source" ]]; then
    log "Copying source to staged prefix..."
    if command -v rsync >/dev/null 2>&1; then
        rsync -a --exclude='.git' --exclude='node_modules' \
            "$BUILD_DIR/source/" "$PREFIX/lib/opencode/" 2>/dev/null || \
        cp -a "$BUILD_DIR/source/." "$PREFIX/lib/opencode/"
    else
        cp -a "$BUILD_DIR/source/." "$PREFIX/lib/opencode/"
    fi
fi

# Install runtime
cp "$ARTIFACTS_DIR/opencode" "$PREFIX/lib/opencode/runtime/opencode"

# Create launcher script
cat > "$PREFIX/bin/opencode" <<'LAUNCHER'
#!/usr/bin/env bash
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENCODE_CLI="$SELF_DIR/../lib/opencode/packages/opencode/bin/opencode"
OPENCODE_RUNTIME="$SELF_DIR/../lib/opencode/runtime/opencode"

cleanup_state_locks() {
    local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/opencode"
    [[ -d "$state_dir" ]] && find "$state_dir" -maxdepth 1 -type f -name '*.lock' -delete 2>/dev/null || true
}

cleanup_broken_cached_modules() {
    local cache_root="${XDG_CACHE_HOME:-$HOME/.cache}/opencode"
    local mod_dir="$cache_root/node_modules/opencode-anthropic-auth"
    [[ -d "$mod_dir" ]] && [[ ! -f "$mod_dir/package.json" ]] && rm -rf "$cache_root/node_modules" 2>/dev/null || true
}

ensure_stdio_tty() {
    [[ -t 0 ]] && [[ -t 1 ]] && [[ -w /dev/tty ]] && exec </dev/tty >/dev/tty 2>/dev/tty || true
}

cleanup_tty() {
    [[ -t 1 ]] && printf '\033[?1049l\033[?25h\033[0m' >/dev/tty 2>/dev/null || true
    command -v stty >/dev/null 2>&1 && stty sane 2>/dev/null || true
    command -v tput >/dev/null 2>&1 && tput rmcup >/dev/null 2>&1 || true
}

trap cleanup_tty EXIT INT TERM HUP QUIT

ensure_stdio_tty
cleanup_state_locks
cleanup_broken_cached_modules

: "${OPENCODE_DISABLE_DEFAULT_PLUGINS:=1}"
export OPENCODE_DISABLE_DEFAULT_PLUGINS

if [[ -x "$OPENCODE_RUNTIME" ]]; then
    "$OPENCODE_RUNTIME" "$@"
    exit $?
fi

"$OPENCODE_CLI" "$@"
LAUNCHER
chmod 755 "$PREFIX/bin/opencode"

# Create build metadata
cat > "$ARTIFACTS_DIR/build.meta" <<EOF
build_time=$(date -Iseconds)
build_host=$(hostname)
opencode_source=${OPENCODE_SOURCE}
opencode_runtime=${OPENCODE_RUNTIME}
artifacts_dir=${ARTIFACTS_DIR}
build_dir=${BUILD_DIR}
staged_prefix=${PREFIX}
has_source=$([[ -d "$OPENCODE_SOURCE" ]] && echo "true" || echo "false")
has_runtime=$([[ -f "$OPENCODE_RUNTIME" ]] && echo "true" || echo "false")
EOF

log "OpenCode build completed"
log "Staged prefix: $PREFIX"
log "Runtime: $ARTIFACTS_DIR/opencode"
log "Metadata: $ARTIFACTS_DIR/build.meta"