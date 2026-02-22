# OpenCode for Termux (OCT)

Sub-project of Oh-My-Litecode (OML)

## Overview

This project provides OpenCode builds for Termux/Android with:

- TTY cleanup launcher (fixes setRawMode errors)
- Stale lock cleanup on startup
- Broken plugin cache auto-repair
- Default plugins disabled (avoids EACCES errors)

## Installation

### From Pacman Package

```bash
pacman -U opencode-termux-1.1.65-1-aarch64.pkg.tar.xz
```

### From Source

```bash
make build VER=1.1.65 PKGMGR=pacman
```

## Configuration

The launcher sets these defaults:

- `OPENCODE_DISABLE_DEFAULT_PLUGINS=1` - Disables opencode-anthropic-auth
- Lock cleanup in `~/.local/state/opencode/*.lock`
- Plugin cache repair in `~/.cache/opencode/node_modules`

## Versioning

Package naming: `opencode-{ver}-{relfix}.{pkgmgr}`

Examples:
- `opencode-1.1.65-1.pacman.tar.xz`
- `opencode-debug-1.1.65-1.pacman.tar.xz` (includes sources)

## Upstream

- [OpenCode](https://github.com/anomalyco/opencode) - MIT License
