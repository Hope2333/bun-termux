# Bun on Termux

Part of Oh-My-Litecode (OML) project.

## Overview

Bun runtime for Termux using glibc-runner (grun) wrapper.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Bun on Termux                             │
├─────────────────────────────────────────────────────────────┤
│  Wrapper ($PREFIX/bin/bun)                                  │
│  └── exec grun $PREFIX/lib/bun-termux/bun "$@"              │
├─────────────────────────────────────────────────────────────┤
│  Runtime ($PREFIX/lib/bun-termux/bun)                       │
│  └── glibc-compiled Bun binary                              │
├─────────────────────────────────────────────────────────────┤
│  Dependencies                                                │
│  └── glibc-runner (grun)                                    │
└─────────────────────────────────────────────────────────────┘
```

## How It Works

1. **glibc-runner (grun)** provides glibc execution environment
2. **Wrapper script** invokes grun with the Bun binary
3. **Bun binary** is the standard Linux/aarch64 build

## Known Issues

| Issue | Description | Workaround |
|-------|-------------|------------|
| `oven-sh/bun#8685` | `/proc/self/exe` points to ld.so | Use bun-termux-loader for compiled artifacts |
| `oven-sh/bun#26752` | bunfs path issues | Loader handles bunfs shim |

## bun-termux-loader

For `bun build --compile` artifacts, use [bun-termux-loader](https://github.com/kaan-escober/bun-termux-loader):

- Userland exec to preserve `/proc/self/exe`
- bunfs shim for native libraries
- Cache extraction for embedded assets

## Building

```bash
make build VER=1.2.20 PKGMGR=pacman
```
