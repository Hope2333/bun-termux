#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Test script for Termux packaging
# Tests the merged packaging system on this machine (debug environment)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

log() {
    echo "=== $* ===" >&2
}

error() {
    echo "ERROR: $*" >&2
    exit 1
}

success() {
    echo "✓ $*" >&2
}

# Load configuration
if [[ -f ".config/termux-packaging.conf" ]]; then
    log "Loading configuration..."
    source ".config/termux-packaging.conf"
    success "Configuration loaded"
else
    log "Using default configuration"
fi

# Test 1: Directory structure
log "Testing directory structure..."
for dir in "bun-termux" "opencode-termux" "oh-my-litecode"; do
    if [[ -d "$dir" ]]; then
        success "Found $dir"
    else
        error "Missing directory: $dir"
    fi
done

# Test 2: Packaging files
log "Testing packaging files..."
for pkg in "bun-termux" "opencode-termux"; do
    if [[ -f "$pkg/packaging/pacman/PKGBUILD" ]]; then
        success "Found PKGBUILD for $pkg"
    else
        error "Missing PKGBUILD for $pkg"
    fi
    
    if [[ -f "$pkg/packaging/deb/DEBIAN/control" ]]; then
        success "Found DEBIAN/control for $pkg"
    else
        error "Missing DEBIAN/control for $pkg"
    fi
done

# Test 3: Build scripts
log "Testing build scripts..."
for script in "scripts/build/build_bun.sh" "scripts/build/build_opencode.sh" "scripts/package/package_deb.sh"; do
    if [[ -f "$script" ]]; then
        success "Found $script"
        if [[ -x "$script" ]]; then
            chmod +x "$script"
            success "$script is executable"
        fi
    else
        error "Missing script: $script"
    fi
done

# Test 4: Sensitive information separation
log "Testing sensitive information separation..."
if [[ -f ".config/termux-packaging.conf" ]]; then
    if grep -q "termux.opencode.all" ".config/termux-packaging.conf"; then
        error "Hardcoded path found in config file"
    else
        success "No hardcoded paths in config"
    fi
    
    if grep -q "^export " ".config/termux-packaging.conf"; then
        success "Configuration uses environment variables"
    fi
else
    log "Warning: No configuration file found"
fi

# Test 5: PKGBUILD structure
log "Testing PKGBUILD structure..."
for pkg in "bun-termux" "opencode-termux"; do
    pkgbuild="$pkg/packaging/pacman/PKGBUILD"
    if grep -q "_rootdir=" "$pkgbuild"; then
        error "Hardcoded _rootdir found in $pkgbuild"
    else
        success "No hardcoded _rootdir in $pkgbuild"
    fi
    
    if grep -q "pkgver=" "$pkgbuild"; then
        version=$(grep "pkgver=" "$pkgbuild" | cut -d= -f2 | tr -d "'")
        if [[ "$version" != "0.0.0" ]]; then
            success "$pkg version: $version"
        else
            error "$pkg has placeholder version 0.0.0"
        fi
    fi
done

# Test 6: Create test build (dry run)
log "Testing build scripts (dry run)..."
mkdir -p test-build
cd test-build

# Test bun build script
log "Testing bun build script..."
if ../scripts/build/build_bun.sh 2>&1 | grep -q "Bun build completed"; then
    success "Bun build script runs successfully"
else
    error "Bun build script failed"
fi

# Test opencode build script  
log "Testing opencode build script..."
if ../scripts/build/build_opencode.sh 2>&1 | grep -q "OpenCode build completed"; then
    success "Opencode build script runs successfully"
else
    error "Opencode build script failed"
fi

# Clean up
cd ..
rm -rf test-build

# Final summary
log "Packaging test completed"
echo ""
echo "Summary:"
echo "1. Directory structure: ✓"
echo "2. Packaging files: ✓" 
echo "3. Build scripts: ✓"
echo "4. Sensitive info separation: ✓"
echo "5. PKGBUILD structure: ✓"
echo "6. Build script execution: ✓"
echo ""
echo "The merged packaging system is ready for use on this debug machine."
echo ""
echo "Next steps:"
echo "1. Source the configuration: source develop/.config/termux-packaging.conf"
echo "2. Build packages: develop/scripts/build/build_*.sh"
echo "3. Create packages: develop/scripts/package/package_deb.sh"
echo ""
echo "Note: This machine is configured as the debug environment."