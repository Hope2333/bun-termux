# ARM32 (armv7l) Limitations and Dependency Chain

## Executive Summary

**ARM32 Termux builds are NOT currently supported** due to upstream dependency limitations.

## Dependency Chain Analysis

```
OpenCode (1.1.65+)
    └── Requires: Bun runtime
                    └── Official builds: aarch64, x64 ONLY
                    └── NO armv7 builds available
```

## Official Binary Support Matrix

| Software | aarch64 (arm64) | armv7 (arm32) | x64 |
|----------|-----------------|---------------|-----|
| Bun      | ✅ Yes          | ❌ No         | ✅ Yes |
| OpenCode | ✅ Yes          | ❌ No         | ✅ Yes |
| Node.js  | ✅ Yes          | ✅ Yes        | ✅ Yes |

## Why ARM32 is Blocked

1. **Bun has no armv7 builds**
   - Official releases: https://github.com/oven-sh/bun/releases
   - Only aarch64 and x64 binaries provided
   - Building from source requires Zig compiler and significant effort

2. **OpenCode has no armv7 builds**
   - Official releases: https://github.com/anomalyco/opencode/releases
   - Only arm64 and x64 binaries provided
   - OpenCode uses Bun-specific APIs, can't simply switch to Node.js

## Potential Solutions

### Option A: Build Bun from Source for ARM32
- **Complexity**: High
- **Requirements**: Zig compiler, build environment
- **Community Efforts**: Some attempts exist but not production-ready
- **Estimated Effort**: Days to weeks

### Option B: Wait for Upstream Support
- **Complexity**: None (wait)
- **Timeline**: Unknown
- **Recommended**: Watch https://github.com/oven-sh/bun/issues for armv7 requests

### Option C: Use Alternative Architecture
- **Solution**: Use arm64 (aarch64) devices
- **Status**: Fully supported

## Current Support Status

| Platform | Architecture | Package Manager | Status |
|----------|--------------|-----------------|--------|
| Termux   | arm64 (aarch64) | pacman/apt | ✅ Supported |
| Termux   | arm32 (armv7l) | pacman/apt | ❌ Blocked |
| Termux   | x86_64 | pacman/apt | ✅ Theoretical |

## Testing Results

- **Local (arm64/pacman)**: ✅ Build successful
  - bun-termux_1.2.20_aarch64.deb (23MB)
  - opencode-termux_1.1.65_aarch64.deb (36MB)
  
- **ARM32 Test Machine (10.31.66.76)**: ❌ Blocked by dependency chain
  - Architecture: armv7l
  - dpkg-deb: Available
  - bun/opencode binaries: NOT AVAILABLE

## Future Work

1. Monitor Bun for armv7 support
2. Explore cross-compilation options
3. Consider community builds of Bun for armv7
4. Document workarounds if any emerge

---

**Last Updated**: 2026-02-22
**Author**: Termux Packaging Team
