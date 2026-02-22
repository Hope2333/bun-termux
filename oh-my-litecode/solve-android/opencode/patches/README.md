# OpenCode Patches

This directory contains patches applied to OpenCode for Termux compatibility.

## Active Patches

### 001-launcher-tty-cleanup

**File:** `launcher-tty-cleanup.patch`
**Applies to:** `packages/opencode/bin/opencode`
**Purpose:** Add TTY cleanup, lock cleanup, and plugin cache repair

Changes:
- `ensure_stdio_tty()` - Bind stdio to /dev/tty
- `cleanup_state_locks()` - Remove stale lock files
- `cleanup_broken_cached_modules()` - Repair corrupted plugin cache
- Set `OPENCODE_DISABLE_DEFAULT_PLUGINS=1` by default

### 002-disable-default-plugins

**File:** None (environment variable)
**Applies to:** Launcher
**Purpose:** Disable builtin plugin installation

Reason: `opencode-anthropic-auth` installation fails with EACCES on Termux.

## Applying Patches

Patches are embedded in the PKGBUILD during build. No manual application needed.

## Creating New Patches

1. Make changes to source in `sources/opencode/`
2. Generate patch: `git diff > patches/NNN-name.patch`
3. Add patch info to this README
