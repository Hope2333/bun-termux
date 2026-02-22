# OpenCode Installation Guide

## Prerequisites

- Termux (latest version)
- glibc-runner installed

## Quick Install

```bash
pacman -Syu
pacman -S glibc-runner
pacman -U opencode-termux-1.1.65-1-aarch64.pkg.tar.xz
```

## First Run

```bash
opencode
```

## Configuration

OpenCode stores data in:

- `~/.local/share/opencode/` - Data and logs
- `~/.local/state/opencode/` - State and locks
- `~/.cache/opencode/` - Cache
- `~/.config/opencode/` - Configuration

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OPENCODE_DISABLE_DEFAULT_PLUGINS` | `1` | Disable builtin plugins |
| `OPENCODE_SERVER_PASSWORD` | (unset) | Web interface password |

## Troubleshooting

### setRawMode Errors

If you see `setRawMode failed with errno: 5`:

1. Ensure running in a real terminal (not script/pexpect)
2. Check `opencode` launcher version

### Plugin Installation Failures

The launcher disables builtin plugins by default to avoid EACCES errors on Termux.

### Lock Files

If OpenCode hangs, clean locks:

```bash
rm -f ~/.local/state/opencode/*.lock
```
