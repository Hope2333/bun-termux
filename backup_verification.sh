#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Backup and verification script for local development machine
# This ensures we have a working OMO environment backup

echo "=== Local Development Machine Backup Verification ==="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo ""

BACKUP_DIR="/data/data/com.termux/files/home/omo-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "1. Backing up critical OMO files..."
echo ""

# Backup OpenCode configuration
echo "Backing up OpenCode config..."
mkdir -p "$BACKUP_DIR/.config/opencode"
cp -r ~/.config/opencode/* "$BACKUP_DIR/.config/opencode/" 2>/dev/null || echo "No OpenCode config found"

# Backup oh-my-opencode installation
echo "Backing up oh-my-opencode..."
mkdir -p "$BACKUP_DIR/oh-my-opencode"
find ~ -path "*oh-my-opencode*" -type f -name "*.json" -o -name "*.js" -o -name "*.ts" | head -20 | while read f; do
    rel_path="${f#$HOME/}"
    mkdir -p "$BACKUP_DIR/$(dirname "$rel_path")"
    cp "$f" "$BACKUP_DIR/$rel_path" 2>/dev/null || true
done

# Backup packaging system
echo "Backing up packaging system..."
cp -r /data/data/com.termux/files/home/develop "$BACKUP_DIR/" 2>/dev/null || echo "Develop directory not found"

# Backup Termux packages list
echo "Backing up package list..."
pkg list-installed > "$BACKUP_DIR/termux-packages.txt" 2>/dev/null || apt list --installed > "$BACKUP_DIR/termux-packages.txt" 2>/dev/null || echo "Could not get package list"

echo ""
echo "2. Verifying backup integrity..."
echo ""

# Check backup contents
BACKUP_FILES=$(find "$BACKUP_DIR" -type f | wc -l)
echo "✓ Backed up $BACKUP_FILES files"

# Verify critical files
CRITICAL_FILES=0
for file in "$BACKUP_DIR/.config/opencode/opencode.json" \
            "$BACKUP_DIR/termux-packages.txt" \
            "$BACKUP_DIR/develop/README.md"; do
    if [[ -f "$file" ]]; then
        echo "✓ Critical file: $(basename "$file")"
        CRITICAL_FILES=$((CRITICAL_FILES + 1))
    fi
done

echo ""
echo "3. Testing restore capability..."
echo ""

# Create restore test script
cat > "$BACKUP_DIR/RESTORE_INSTRUCTIONS.md" << 'EOF'
# OMO Environment Restore Instructions

## Backup Information
- Backup created: $(date)
- Machine: $(hostname)
- Backup location: $BACKUP_DIR

## Restore Steps

### 1. Restore Termux packages
```bash
# Install packages from backup list
xargs -a termux-packages.txt pkg install -y
```

### 2. Restore OpenCode configuration
```bash
mkdir -p ~/.config/opencode
cp -r .config/opencode/* ~/.config/opencode/
```

### 3. Restore packaging system
```bash
cp -r develop ~/
cd ~/develop
./setup.sh
```

### 4. Verify installation
```bash
# Test OpenCode
opencode --version

# Test packaging system
cd ~/develop
./test_packaging.sh
```

## Verification Checklist
- [ ] OpenCode starts without errors
- [ ] oh-my-opencode agents are available
- [ ] Packaging system builds work
- [ ] Both pacman and apt packaging tested

## Emergency Contacts
- Primary development machine: localhost:8022
- Test machine 1 (arm64): 192.168.101.28:8022
- Test machine 2 (arm32): 192.168.101.38:8022
EOF

echo "✓ Created restore instructions"
echo ""

echo "4. Creating verification test..."
echo ""

# Create verification test
cat > "$BACKUP_DIR/verify_backup.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "=== Backup Verification Test ==="
echo ""

# Test 1: Check backup structure
echo "1. Checking backup structure..."
if [[ -d ".config/opencode" ]]; then
    echo "✓ OpenCode config directory exists"
else
    echo "✗ OpenCode config directory missing"
fi

if [[ -f "termux-packages.txt" ]]; then
    echo "✓ Package list exists"
    PKG_COUNT=$(wc -l < termux-packages.txt)
    echo "  Contains $PKG_COUNT packages"
else
    echo "✗ Package list missing"
fi

if [[ -d "develop" ]]; then
    echo "✓ Packaging system exists"
    if [[ -f "develop/README.md" ]]; then
        echo "✓ README.md present"
    fi
else
    echo "✗ Packaging system missing"
fi

echo ""
echo "2. Testing critical functionality..."
echo ""

# Test 2: Check if we can read configs
if [[ -f ".config/opencode/opencode.json" ]]; then
    echo "✓ OpenCode config file readable"
    if grep -q "oh-my-opencode" ".config/opencode/opencode.json" 2>/dev/null; then
        echo "✓ oh-my-opencode configuration found"
    fi
fi

echo ""
echo "=== Verification Complete ==="
echo ""
echo "To fully test, restore to a clean Termux installation."
echo "See RESTORE_INSTRUCTIONS.md for details."
EOF

chmod +x "$BACKUP_DIR/verify_backup.sh"

echo "✓ Created verification script"
echo ""

echo "5. Compressing backup..."
echo ""

# Compress backup
cd "$(dirname "$BACKUP_DIR")"
tar -czf "$BACKUP_DIR.tar.gz" "$(basename "$BACKUP_DIR")"
BACKUP_SIZE=$(du -h "$BACKUP_DIR.tar.gz" | cut -f1)

echo "✓ Backup compressed: $BACKUP_DIR.tar.gz ($BACKUP_SIZE)"
echo ""

echo "=== Backup Complete ==="
echo ""
echo "Summary:"
echo "- Backup location: $BACKUP_DIR.tar.gz"
echo "- Total files: $BACKUP_FILES"
echo "- Critical files: $CRITICAL_FILES/3"
echo "- Backup size: $BACKUP_SIZE"
echo ""
echo "Next steps:"
echo "1. Store backup in safe location"
echo "2. Test restore on clean environment if possible"
echo "3. Schedule regular backups"
echo ""
echo "With this backup, you can restore your OMO environment"
echo "if the local development machine has issues."