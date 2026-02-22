# OpenCode on Termux (OCT)

Part of Oh-My-Litecode (OML) project.

## Overview

OCT provides OpenCode builds for Termux/Android without proot, featuring:

- **TTY cleanup launcher** - Fixes `setRawMode errno:5` errors
- **Stale lock cleanup** - Prevents hang on restart
- **Broken plugin cache repair** - Auto-heals corrupted `opencode-anthropic-auth`
- **Default plugins disabled** - Avoids EACCES errors during installation

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    OpenCode on Termux                        │
├─────────────────────────────────────────────────────────────┤
│  Launcher Script ($PREFIX/bin/opencode)                      │
│  ├── TTY cleanup (setRawMode fix)                            │
│  ├── Lock cleanup (~/.local/state/opencode/*.lock)           │
│  └── Plugin cache repair                                     │
├─────────────────────────────────────────────────────────────┤
│  Runtime ($PREFIX/lib/opencode/runtime/opencode)             │
│  └── Bun-compiled binary with loader                         │
├─────────────────────────────────────────────────────────────┤
│  Source ($PREFIX/lib/opencode/packages/opencode/)            │
│  └── OpenCode TypeScript source                              │
└─────────────────────────────────────────────────────────────┘
```

## Key Issues Addressed

| Issue | Symptom | Fix |
|-------|---------|-----|
| `anomalyco/opencode#10504` | Linux binary won't run on Android | Use bun-compiled runtime with loader |
| `anomalyco/opencode#12515` | npm install fails | Staged build without postinstall |
| `setRawMode errno:5` | TTY raw mode fails | Launcher binds stdio to /dev/tty |
| EACCES on plugin install | Permission denied | Disable default plugins by default |

## Building

```bash
# Build with Makefile
make build VER=1.1.65 PKGMGR=pacman

# Or directly with makepkg
cd packaging/pacman
makepkg -C -f
```

## Known Limitations

1. **opencode-anthropic-auth** is disabled by default due to EACCES during `bun add`
2. **Web interface** requires `OPENCODE_SERVER_PASSWORD` for security
3. Some LSP servers may need additional setup

## Version History

| Version | Date | Notes |
|---------|------|-------|
| 1.1.65-8 | 2026-02-16 | Added launcher cleanup, disabled default plugins |
| 1.1.65-7 | 2026-02-15 | Fixed runtime stripping issue |
