#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/common.sh"

OPENCODE_SRC_DIR="${OPENCODE_SRC_DIR:-$ROOT_DIR/sources/opencode/repo}"
OUT_DIR="${OPENCODE_OUT_DIR:-$ROOT_DIR/artifacts/opencode/staged}"
PREFIX_DIR="${OPENCODE_PREFIX_DIR:-$OUT_DIR/prefix}"
RUNTIME_INPUT="${OPENCODE_RUNTIME_INPUT:-$ROOT_DIR/artifacts/opencode/runtime/opencode-termux}"
RUNTIME_FALLBACK_INPUT="${OPENCODE_RUNTIME_FALLBACK_INPUT:-$ROOT_DIR/artifacts/opencode/runtime/opencode}"

[[ -d "$OPENCODE_SRC_DIR" ]] || fail "未找到 opencode 源码目录: $OPENCODE_SRC_DIR"
ensure_dir "$PREFIX_DIR/lib/opencode"
ensure_dir "$PREFIX_DIR/lib/opencode/runtime"
ensure_dir "$PREFIX_DIR/bin"

if command -v rsync >/dev/null 2>&1; then
	rsync -a --delete --exclude '.git' --exclude 'node_modules' "$OPENCODE_SRC_DIR/" "$PREFIX_DIR/lib/opencode/"
else
	rm -rf "$PREFIX_DIR/lib/opencode"
	ensure_dir "$PREFIX_DIR/lib/opencode"
	ensure_dir "$PREFIX_DIR/lib/opencode/runtime"
	if command -v tar >/dev/null 2>&1; then
		(cd "$OPENCODE_SRC_DIR" && tar --exclude='.git' --exclude='node_modules' -cf - .) | (cd "$PREFIX_DIR/lib/opencode" && tar -xf -)
	else
		cp -a "$OPENCODE_SRC_DIR/." "$PREFIX_DIR/lib/opencode/"
		rm -rf "$PREFIX_DIR/lib/opencode/.git" "$PREFIX_DIR/lib/opencode/node_modules"
	fi
fi

ensure_dir "$PREFIX_DIR/lib/opencode/runtime"

OPENCODE_CLI_JS="$PREFIX_DIR/lib/opencode/packages/opencode/bin/opencode"
[[ -f "$OPENCODE_CLI_JS" ]] || fail "未找到 opencode CLI 入口: $OPENCODE_CLI_JS"

RUNTIME_MODE="source-only"
if [[ -f "$RUNTIME_INPUT" ]]; then
	install -m 755 "$RUNTIME_INPUT" "$PREFIX_DIR/lib/opencode/runtime/opencode"
	RUNTIME_MODE="release-loader"
elif [[ -f "$RUNTIME_FALLBACK_INPUT" ]]; then
	install -m 755 "$RUNTIME_FALLBACK_INPUT" "$PREFIX_DIR/lib/opencode/runtime/opencode"
	RUNTIME_MODE="release-raw"
fi

cat >"$PREFIX_DIR/bin/opencode" <<'LAUNCHER'
#!/usr/bin/env bash
set -euo pipefail
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENCODE_CLI="$SELF_DIR/../lib/opencode/packages/opencode/bin/opencode"
OPENCODE_RUNTIME="$SELF_DIR/../lib/opencode/runtime/opencode"

cleanup_state_locks() {
  local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/opencode"
  if [ -d "$state_dir" ]; then
    if command -v find >/dev/null 2>&1; then
      find "$state_dir" -maxdepth 1 -type f -name '*.lock' -delete 2>/dev/null || true
    else
      rm -f "$state_dir"/*.lock 2>/dev/null || true
    fi
  fi
}

cleanup_broken_cached_modules() {
  local cache_root="${XDG_CACHE_HOME:-$HOME/.cache}/opencode"
  local mod_dir="$cache_root/node_modules/opencode-anthropic-auth"
  if [ -d "$mod_dir" ] && [ ! -f "$mod_dir/package.json" ]; then
    rm -rf "$cache_root/node_modules" 2>/dev/null || true
  fi
}

ensure_stdio_tty() {
  if [ -t 0 ] && [ -t 1 ] && [ -w /dev/tty ]; then
    exec </dev/tty >/dev/tty 2>/dev/tty
  fi
}

cleanup_tty() {
  if [ -t 1 ]; then
    printf '\033[?1049l\033[?25h\033[0m' >/dev/tty 2>/dev/null || true
  fi
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
  rc=$?
  cleanup_tty
  exit $rc
fi

"$OPENCODE_CLI" "$@"
rc=$?
cleanup_tty
exit $rc
LAUNCHER

chmod 755 "$PREFIX_DIR/bin/opencode"

write_build_meta "$ROOT_DIR/artifacts/opencode/build.meta" \
	"component=opencode" \
	"source=$OPENCODE_SRC_DIR" \
	"prefix=$PREFIX_DIR" \
	"runtime_mode=$RUNTIME_MODE" \
	"note=staged-copy-without-npm-global-postinstall"

log "opencode staged 构建完成: $PREFIX_DIR"
