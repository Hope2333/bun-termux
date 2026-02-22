# Bun for Termux

Sub-project of Oh-My-Litecode (OML)

## Overview

Bun runtime for Termux using glibc-runner (grun) wrapper.

## Installation

### From Pacman Package

```bash
pacman -U bun-termux-1.2.20-1-aarch64.pkg.tar.xz
```

### Dependencies

- `glibc-runner` - Required for running glibc binaries

## Usage

```bash
bun --version
bun run script.ts
bun install
```

## How It Works

The wrapper script uses `grun` to execute the glibc-compiled Bun binary:

```bash
exec grun "$PREFIX/lib/bun-termux/bun" "$@"
```

## Versioning

Package naming: `bun-{ver}-{relfix}.{pkgmgr}`

## Upstream

- [bun-termux-loader](https://github.com/kaan-escober/bun-termux-loader) - MIT License
- [Bun](https://github.com/oven-sh/bun) - MIT License
