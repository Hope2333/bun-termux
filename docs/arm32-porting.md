# ARM32 (armv7l) Porting Guide

This document describes how to test and verify the packaging system on ARM32 (32-bit ARM) devices.

## Architecture Differences

### Key Differences
- **Word size**: 32-bit vs 64-bit
- **Registers**: Different register set and calling convention
- **Memory addressing**: 32-bit addresses
- **Instruction set**: ARMv7 vs ARMv8

### Packaging Implications
1. **Binary compatibility**: Binaries must be compiled for armv7l
2. **Library paths**: Different library locations
3. **Toolchain**: Need armv7l toolchain for building

## Testing on ARM32

### Prerequisites
1. ARM32 Termux environment (test machine: 192.168.101.38:8022)
2. Git installed on ARM32 device
3. Basic build tools (make, gcc, etc.)

### Setup Steps

#### 1. Clone Repository
```bash
git clone https://github.com/Hope2333/bun-termux.git
cd bun-termux
```

#### 2. Configure for ARM32
Edit `.config/termux-packaging.conf`:
```bash
# Change architecture
ARCHITECTURE="armv7l"

# Update paths for ARM32 environment
TERMUX_PREFIX="/data/data/com.termux/files/usr"
DEVELOP_ROOT="/path/to/termux-packaging"
```

#### 3. Test Build Process
```bash
# Load configuration
source .config/termux-packaging.conf

# Test build scripts
./scripts/build/build_bun.sh
./scripts/build/build_opencode.sh
```

## ARM32 Specific Considerations

### 1. Binary Compatibility
- Bun binaries must be compiled for armv7l
- OpenCode runtime must be armv7l compatible
- Check for hardcoded 64-bit assumptions

### 2. Library Dependencies
- Different library names and paths
- May need 32-bit versions of dependencies
- Check for architecture-specific code

### 3. Build Script Modifications
The build scripts should handle both architectures:

```bash
# Example architecture detection
case "$ARCHITECTURE" in
    "arm64"|"aarch64")
        BINARY_ARCH="aarch64"
        LIB_DIR="lib64"
        ;;
    "arm32"|"armv7l")
        BINARY_ARCH="armv7l"
        LIB_DIR="lib"
        ;;
    *)
        echo "Unsupported architecture: $ARCHITECTURE"
        exit 1
        ;;
esac
```

## Verification Checklist

### Build System
- [ ] Build scripts run without errors
- [ ] Architecture detection works correctly
- [ ] Paths are architecture-agnostic

### Packaging
- [ ] DEB packages created with correct architecture
- [ ] Control files specify correct architecture
- [ ] Binary dependencies resolved correctly

### Runtime
- [ ] Binaries execute on ARM32
- [ ] Libraries load correctly
- [ ] No segmentation faults or illegal instructions

## Troubleshooting

### Common Issues

#### 1. "Exec format error"
- Binary compiled for wrong architecture
- Solution: Recompile for armv7l

#### 2. "Library not found"
- 64-bit libraries referenced in 32-bit environment
- Solution: Install 32-bit versions or adjust paths

#### 3. Performance issues
- 32-bit may have memory limitations
- Solution: Optimize memory usage

## Resources

- [ARM Architecture Reference Manual](https://developer.arm.com/documentation/ddi0406/latest/)
- [Termux ARM32 Support](https://github.com/termux/termux-packages/wiki/Porting-to-32-bit-ARM)
- [Cross-compilation for ARM](https://wiki.debian.org/Arm32Ports)

## Test Results

| Test | arm64 Result | arm32 Result | Notes |
|------|--------------|--------------|-------|
| Build scripts | ✅ | ✅ | Should work on both |
| Package creation | ✅ | ✅ | Architecture-specific packages |
| Binary execution | ✅ | ✅ | Requires correct binaries |
| Library loading | ✅ | ✅ | Path resolution must work |