# Bun for Termux

[![Build](https://github.com/Hope2333/bun-termux/actions/workflows/build.yml/badge.svg)](https://github.com/Hope2333/bun-termux/actions)

Bun runtime for Termux/Android using glibc-runner.

## Installation

### Prerequisites

```bash
pacman -Syu
pacman -S glibc-runner
```

### Install

```bash
pacman -U bun-1.3.9-1-aarch64.pkg.tar.xz
```

## Usage

```bash
bun --version
bun run script.ts
bun install
```

## How It Works

```
/usr/bin/bun (wrapper)
    └── exec grun /usr/lib/bun-termux/bun "$@"
            └── glibc-runner executes glibc binary
```

## Building

```bash
make build PKGVER=1.3.9 PKGMGR=pacman
```

## Related Projects

- [oh-my-litecode](https://github.com/Hope2333/oh-my-litecode) - Parent project
- [opencode-termux](https://github.com/Hope2333/opencode-termux) - Depends on this
- [bun-termux-loader](https://github.com/kaan-escober/bun-termux-loader) - Loader mechanism

## License

MIT License

## ARMv7 Migration

- Workflow: `.github/workflows/armv7.yml`
- Guide: `docs/armv7-migration.md`
- Cross-first, native-fallback strategy is tracked via status artifacts (`next-build-path.json`).
