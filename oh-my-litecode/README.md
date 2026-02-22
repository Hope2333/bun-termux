# Oh-My-Litecode (OML)

**Version: 0.1.0-alpha**

A unified toolchain manager for cross-platform AI-assisted development environments on Termux/Android.

## Overview

OML serves as an orchestrator for multiple sub-projects, providing:
- Unified hotfix and patch management
- Cross-platform package building (pacman/dpkg)
- Version migration and upgrade automation
- Documentation hub for all sub-projects

## Sub-Projects

| Project | Description | Status |
|---------|-------------|--------|
| `solve-android/opencode` | OpenCode for Termux with TTY/lock cleanup | Active |
| `solve-android/bun` | Bun runtime for Termux (glibc-runner) | Active |

## Quick Start

```bash
# Show available commands
./oml --help

# Build packages for Termux
./oml build --ver 1.1.65 --pkgmgr pacman

# Apply hotfixes
./oml hotfix apply <fix-name>

# View documentation
./oml doc <project> <topic>
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Upstream Projects

- [OpenCode](https://github.com/anomalyco/opencode) - MIT License
- [Bun](https://github.com/oven-sh/bun) - MIT License
- [bun-termux-loader](https://github.com/kaan-escober/bun-termux-loader) - MIT License
