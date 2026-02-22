# Oh-My-Litecode CHANGELOG

All notable changes to this project will be documented in this file.

## [0.1.0-alpha] - 2026-02-18

### Added
- Initial project structure
- OML orchestrator script (`oml`)
- Makefile-based build system
- GitHub Actions workflows for CI/CD
- OpenCode for Termux (OCT) sub-project
  - TTY cleanup launcher
  - Stale lock cleanup
  - Plugin cache repair
  - Pacman package support
- Bun for Termux sub-project
  - glibc-runner wrapper
  - Pacman package support

### Documentation
- Architecture docs for opencode and bun
- Installation guide
- Patch documentation

### Based On
- OpenCode v1.1.65 (anomalyco/opencode)
- Bun v1.2.20 (oven-sh/bun)
- bun-termux-loader (kaan-escober/bun-termux-loader)

---

## Sub-project Changelogs

### opencode-termux

| Version | Changes |
|---------|---------|
| 1.1.65-8 | Launcher with TTY cleanup, default plugins disabled |
| 1.1.65-7 | Fixed runtime stripping issue |
| 1.1.65-6 | Initial working build |

### bun-termux

| Version | Changes |
|---------|---------|
| 1.2.20-1 | Initial wrapper with grun |
