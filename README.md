# Termux Packaging System

This repository contains packaging scripts and configurations for building Bun and OpenCode on Termux (Android).

## Project Structure

```
develop/
├── .config/
│   └── termux-packaging.conf.template  # Configuration template
├── bun-termux/                         # Bun packaging for Termux
│   ├── packaging/
│   │   ├── pacman/PKGBUILD            # Pacman packaging (Arch Linux style)
│   │   └── deb/DEBIAN/control         # Debian packaging
├── opencode-termux/                    # OpenCode packaging for Termux
│   ├── packaging/
│   │   ├── pacman/PKGBUILD
│   │   └── deb/DEBIAN/control
│   └── scripts/launcher.sh            # OpenCode launcher with TTY cleanup
├── oh-my-litecode/                     # Lightweight launcher
├── scripts/                            # Shared build scripts
│   ├── build/build_bun.sh
│   ├── build/build_opencode.sh
│   └── package/package_deb.sh
└── test_packaging.sh                   # Test script
```

## Quick Start

1. **Clone this repository**:
   ```bash
   git clone https://github.com/Hope2333/bun-termux.git
   cd bun-termux
   ```

2. **Setup configuration**:
   ```bash
   cp .config/termux-packaging.conf.template .config/termux-packaging.conf
   # Edit .config/termux-packaging.conf with your local paths
   ```

3. **Build packages**:
   ```bash
   # Load configuration
   source .config/termux-packaging.conf
   
   # Build Bun
   ./scripts/build/build_bun.sh
   
   # Build OpenCode
   ./scripts/build/build_opencode.sh
   
   # Create DEB packages
   ./scripts/package/package_deb.sh bun bun-termux $BUN_VERSION $ARCHITECTURE
   ./scripts/package/package_deb.sh opencode opencode-termux $OPENCODE_VERSION $ARCHITECTURE
   ```

## Features

- **Dual packaging support**: Both Pacman (`.pkg.tar.*`) and Debian (`.deb`) formats
- **Architecture aware**: Supports arm64 and arm32 (armv7l)
- **Sensitive info separation**: Configuration via environment variables
- **Termux optimized**: Proper shebang paths and Android compatibility
- **TTY cleanup**: OpenCode launcher includes proper terminal cleanup

## Supported Architectures

- **arm64** (aarch64): Primary target for modern Android devices
- **arm32** (armv7l): For older Android devices (32-bit ARM)

## Testing

Run the test script to verify your setup:
```bash
./test_packaging.sh
```

## License

MIT License
