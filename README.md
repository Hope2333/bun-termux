# Bun for Termux

Native Android Bun runtime packaged for Termux. No glibc, no wrapper, no grun.

Starting from Bun v1.3.14, official Android builds are available as
Bionic-linked PIE executables that run directly on Termux via
`/system/bin/linker64` — zero extra dependencies.

## Installation

```bash
# pacman
pacman -U bun-1.3.14-1-aarch64.pkg.tar.xz

# apt/deb  
dpkg -i bun_1.3.14_aarch64.deb
```

## Usage

```bash
bun --version
bun run script.ts
bun install
```

## Architecture

```
/usr/bin/bun → Android-native Bun binary (Bionic-linked)
               interpreter: /system/bin/linker64
               No glibc, no grun, no wrapper
```

Supported architectures: `aarch64`, `x86_64`

## Building

```bash
make PKGVER=1.3.14 PKGMGR=pacman
```

## How it works

Bun v1.3.14+ ships official Android builds. This repo downloads the
appropriate zip from GitHub releases, extracts the binary, and packages
it for Termux's package managers.

## Related

- [opencode-termux](https://github.com/Hope2333/opencode-termux) — OpenCode for Termux
- [oven-sh/bun](https://github.com/oven-sh/bun) — Upstream Bun

## License

<<<<<<< HEAD
MIT License

## ARMv7 Migration

- Workflow: `.github/workflows/armv7.yml`
- Guide: `docs/armv7-migration.md`
- Native runner setup: `docs/armv7-native-runner-setup.md`
- Cross-first, native-fallback strategy is tracked via status artifacts (`next-build-path.json`).
=======
MIT
>>>>>>> 7c854a8 (docs: update for native Android Bun (v1.3.14+))
