#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Build script for Bun on Termux
# Uses environment variables for configuration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVELOP_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Configuration (can be overridden by environment)
BUN_SOURCE="${BUN_SOURCE:-$DEVELOP_DIR/bun-termux/sources/bun}"
BUN_RUNTIME="${BUN_RUNTIME:-$DEVELOP_DIR/bun-termux/runtime/bun}"
BUILD_DIR="${BUILD_DIR:-$DEVELOP_DIR/bun-termux/build}"
ARTIFACTS_DIR="${ARTIFACTS_DIR:-$DEVELOP_DIR/bun-termux/artifacts}"

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

log "Starting Bun build for Termux"
log "Source: ${BUN_SOURCE}"
log "Build dir: ${BUILD_DIR}"
log "Artifacts: ${ARTIFACTS_DIR}"

# Check if we have a pre-built runtime
if [[ -f "$BUN_RUNTIME" ]]; then
    log "Using existing runtime: $BUN_RUNTIME"
    cp "$BUN_RUNTIME" "$ARTIFACTS_DIR/bun"
    chmod 755 "$ARTIFACTS_DIR/bun"
else
    log "No pre-built runtime found at $BUN_RUNTIME"
    log "Creating placeholder runtime for packaging"
    
    # Create a simple wrapper that will work with glibc-runner
    cat > "$ARTIFACTS_DIR/bun" <<'PLACEHOLDER'
#!/usr/bin/env bash
# Placeholder Bun runtime for Termux
# This should be replaced with actual Bun binary built with --compile

if [[ "$1" == "--version" ]]; then
    echo "bun placeholder 1.3.9"
    echo "Note: This is a placeholder. Build actual Bun with: bun build --compile"
    exit 0
fi

echo "Bun runtime not built. Please build Bun with: bun build --compile" >&2
echo "Then place the binary at: $(dirname "$0")/../runtime/bun" >&2
exit 1
PLACEHOLDER
    chmod 755 "$ARTIFACTS_DIR/bun"
fi

# Create build metadata
cat > "$ARTIFACTS_DIR/build.meta" <<EOF
build_time=$(date -Iseconds)
build_host=$(hostname)
bun_source=${BUN_SOURCE}
bun_runtime=${BUN_RUNTIME}
artifacts_dir=${ARTIFACTS_DIR}
build_dir=${BUILD_DIR}
placeholder=$([[ ! -f "$BUN_RUNTIME" ]] && echo "true" || echo "false")
EOF

log "Bun build completed"
log "Artifact: $ARTIFACTS_DIR/bun"
log "Metadata: $ARTIFACTS_DIR/build.meta"