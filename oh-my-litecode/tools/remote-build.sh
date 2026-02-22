#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Remote build script for Termux packaging
# Uses environment variables for configuration

HOST="${1:-192.168.1.164}"
PORT="${2:-8022}"
USER="${3:-u0_a450}"

# Remote base directory (can be overridden)
REMOTE_BASE="${REMOTE_BASE:-/data/data/com.termux/files/home/develop}"

# Local artifacts directory (can be overridden)
LOCAL_OCT_DIR="${LOCAL_OCT_DIR:-/home/miao/termux-lab/artifacts/oct-files}"

echo "[oct] target: ${USER}@${HOST}:${PORT}"

ssh -p "$PORT" "${USER}@${HOST}" "mkdir -p '$REMOTE_BASE/scripts/build' '$REMOTE_BASE/packaging/pacman/bun' '$REMOTE_BASE/packaging/pacman/opencode'"

scp -P "$PORT" "$LOCAL_OCT_DIR/build_opencode.sh" "${USER}@${HOST}:$REMOTE_BASE/scripts/build/build_opencode.sh"
scp -P "$PORT" "$LOCAL_OCT_DIR/PKGBUILD.bun" "${USER}@${HOST}:$REMOTE_BASE/packaging/pacman/bun/PKGBUILD"
scp -P "$PORT" "$LOCAL_OCT_DIR/PKGBUILD.opencode" "${USER}@${HOST}:$REMOTE_BASE/packaging/pacman/opencode/PKGBUILD"

ssh -p "$PORT" "${USER}@${HOST}" "chmod 755 '$REMOTE_BASE/scripts/build/build_opencode.sh'"

ssh -p "$PORT" "${USER}@${HOST}" "set -e; cd '$REMOTE_BASE/packaging/pacman/bun'; makepkg -C -f --noconfirm; cd '$REMOTE_BASE/packaging/pacman/opencode'; makepkg -C -f --noconfirm"

ssh -p "$PORT" "${USER}@${HOST}" "set -e; cd '$REMOTE_BASE/packaging/pacman/bun'; bun_pkg=\$(command ls -1t bun-termux-*.pkg.tar.* | head -n 1); pacman -U --noconfirm ./\$bun_pkg; cd '$REMOTE_BASE/packaging/pacman/opencode'; opc_pkg=\$(command ls -1t opencode-termux-*.pkg.tar.* | head -n 1); pacman -U --noconfirm ./\$opc_pkg"

ssh -p "$PORT" "${USER}@${HOST}" "set -e; bun --version; opencode --version; opencode --help >/dev/null; rt='/data/data/com.termux/files/usr/lib/opencode/runtime/opencode'; wc -c \"\$rt\"; strings -n 8 \"\$rt\" | grep -F -- '---- Bun! ----' | head -n 1"

ssh -p "$PORT" "${USER}@${HOST}" "set -e; mkdir -p ~/.local/share/opencode/log; timeout 12s script -q -c 'opencode' ~/.local/share/opencode/log/oct-run1.txt >/dev/null 2>&1 || true; timeout 12s script -q -c 'opencode' ~/.local/share/opencode/log/oct-run2.txt >/dev/null 2>&1 || true; command ls -1t ~/.local/share/opencode/log | sed -n '1,12p'"

echo "[oct] completed"
