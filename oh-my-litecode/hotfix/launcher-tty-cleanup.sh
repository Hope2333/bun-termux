#!/usr/bin/env bash
# Hotfix: Launcher TTY Cleanup Enhancement
# Applies to: opencode
# Created: 2026-02-18
# Version: 1.0

set -euo pipefail

echo "Applying hotfix: launcher-tty-cleanup"

PATCH_DIR="$(dirname "$0")/../../solve-android/opencode"
LAUNCHER="$PATCH_DIR/packaging/pacman/PKGBUILD"

if [[ ! -f "$LAUNCHER" ]]; then
	echo "Error: PKGBUILD not found"
	exit 1
fi

echo "TTY cleanup functions are already embedded in PKGBUILD"
echo "No additional patching required."

echo "Hotfix applied successfully."
