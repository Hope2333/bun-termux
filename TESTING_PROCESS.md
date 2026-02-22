# Testing Process for Termux Packaging System

This document outlines the complete testing process for verifying the packaging system across all environments.

## Test Environments

### 1. Local Development Machine (Primary)
- **Address**: localhost:8022
- **Package Manager**: termux-pacman
- **Architecture**: arm64 (aarch64)
- **Status**: Mature, production environment
- **Risk**: If broken, no mature OMO available

### 2. Test Machine 1 (arm64 apt)
- **Address**: 192.168.101.70:8022
- **Package Manager**: termux-apt
- **Architecture**: arm64 (aarch64)
- **Status**: New environment
- **Purpose**: Test apt-based packaging

### 3. Test Machine 2 (arm32 apt)
- **Address**: 192.168.101.38:8022
- **Package Manager**: termux-apt
- **Architecture**: arm32 (armv7l)
- **Status**: Mature environment
- **Purpose**: Test ARM32 portability

## Test Process

### Phase 1: GitHub Repository Setup
1. **Create GitHub repository** (manually via web interface)
   - Repository name: `termux-packaging`
   - Description: "Packaging system for Bun and OpenCode on Termux"
   - License: MIT
   - Do NOT initialize with README (we have our own)

2. **Push local repository to GitHub**
   ```bash
   cd /data/data/com.termux/files/home/develop
   ./push_to_github.sh https://github.com/yourusername/termux-packaging.git
   ```

### Phase 2: Test Machine 1 (arm64 apt) Verification
```bash
# From local machine, test remote
cd /data/data/com.termux/files/home/develop
./test_remote_machine.sh 192.168.101.70 8022 https://github.com/yourusername/termux-packaging.git
```

**Expected Results:**
- ✓ Repository clones successfully
- ✓ All scripts are executable
- ✓ Configuration template exists
- ✓ Architecture detected as arm64
- ✓ Package manager detected as apt

### Phase 3: Test Machine 2 (arm32 apt) Verification
```bash
# From local machine, test remote
cd /data/data/com.termux/files/home/develop
./test_remote_machine.sh 192.168.101.38 8022 https://github.com/yourusername/termux-packaging.git
```

**Expected Results:**
- ✓ Repository clones successfully
- ✓ All scripts are executable
- ✓ Configuration template exists
- ✓ Architecture detected as armv7l (32-bit)
- ✓ Package manager detected as apt

### Phase 4: Build Verification on Each Machine

#### On Test Machine 1 (arm64):
```bash
# SSH into machine
ssh -p 8022 u0_a240@192.168.101.70

# Clone and test
git clone https://github.com/yourusername/termux-packaging.git
cd termux-packaging
./setup.sh

# Edit configuration
vim .config/termux-packaging.conf
# Set DEVELOP_ROOT to current directory
# Verify ARCHITECTURE="arm64"

# Test build
source .config/termux-packaging.conf
./scripts/build/build_bun.sh
./scripts/build/build_opencode.sh
```

#### On Test Machine 2 (arm32):
```bash
# SSH into machine
ssh -p 8022 u0_a450@192.168.101.38

# Clone and test
git clone https://github.com/yourusername/termux-packaging.git
cd termux-packaging
./setup.sh

# Edit configuration
vim .config/termux-packaging.conf
# Set DEVELOP_ROOT to current directory
# Change ARCHITECTURE="armv7l"

# Test build
source .config/termux-packaging.conf
./scripts/build/build_bun.sh
./scripts/build/build_opencode.sh
```

### Phase 5: Package Creation Test
```bash
# On each test machine, after successful build
./scripts/package/package_deb.sh bun bun-termux $BUN_VERSION $ARCHITECTURE
./scripts/package/package_deb.sh opencode opencode-termux $OPENCODE_VERSION $ARCHITECTURE

# Verify packages were created
ls -la packages/*.deb
```

### Phase 6: Local Machine Backup
```bash
# On local development machine
cd /data/data/com.termux/files/home/develop
./backup_verification.sh

# Verify backup was created
ls -la ~/omo-backup-*.tar.gz
```

## Success Criteria

### Repository Level
- [ ] Repository exists on GitHub
- [ ] All files pushed successfully
- [ ] No sensitive information in repository
- [ ] README.md is comprehensive

### Build System Level
- [ ] Build scripts work on arm64 (apt)
- [ ] Build scripts work on arm32 (apt)
- [ ] Configuration system works on all machines
- [ ] Architecture detection works correctly

### Packaging Level
- [ ] DEB packages created on arm64
- [ ] DEB packages created on arm32
- [ ] Packages have correct architecture in control files
- [ ] Package dependencies resolved correctly

### Safety Level
- [ ] Local machine backup created
- [ ] Backup includes critical OMO files
- [ ] Restore instructions documented
- [ ] Verification script works

## Troubleshooting

### Common Issues

#### 1. GitHub Push Fails
- **Cause**: Repository doesn't exist or authentication failed
- **Solution**: Create repository on GitHub web interface first

#### 2. SSH Connection Fails
- **Cause**: Wrong IP, port, or authentication
- **Solution**: Verify network connectivity and credentials

#### 3. Build Script Fails
- **Cause**: Missing dependencies or wrong paths
- **Solution**: Check configuration file paths and install dependencies

#### 4. Architecture Detection Wrong
- **Cause**: Script doesn't handle all architecture names
- **Solution**: Update architecture detection in scripts

#### 5. Package Creation Fails
- **Cause**: Missing dpkg-deb or wrong paths
- **Solution**: Install dpkg or check staged directory paths

## Rollback Plan

If testing reveals critical issues:

1. **Fix in local repository**
2. **Commit and push fixes**
3. **Re-test on all machines**
4. **Update documentation**

## Long-term Maintenance

1. **Regular backups** of local development machine
2. **Periodic testing** on all environments
3. **Update documentation** as system evolves
4. **Monitor GitHub issues** for community feedback

## Contact Information

- **Primary Developer**: Local development machine
- **Test Coordinator**: Responsible for test execution
- **GitHub Repository**: https://github.com/yourusername/termux-packaging

## Revision History

| Date | Version | Changes | Tested By |
|------|---------|---------|-----------|
| $(date) | 1.0 | Initial testing process | System |
| | | | |