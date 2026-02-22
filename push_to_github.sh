#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Script to push to GitHub repository
# Usage: ./push_to_github.sh <github-repo-url>

GITHUB_REPO="${1:-}"

if [[ -z "$GITHUB_REPO" ]]; then
    echo "Usage: $0 <github-repo-url>"
    echo "Example: $0 https://github.com/yourusername/termux-packaging.git"
    exit 1
fi

echo "=== Pushing to GitHub ==="
echo "Repository: $GITHUB_REPO"
echo ""

# Check if remote already exists
if git remote | grep -q origin; then
    echo "Updating existing remote..."
    git remote set-url origin "$GITHUB_REPO"
else
    echo "Adding remote..."
    git remote add origin "$GITHUB_REPO"
fi

echo ""
echo "Pushing to GitHub..."
echo "Note: You may need to authenticate with GitHub"
echo ""

# Try to push
if git push -u origin master; then
    echo ""
    echo "✓ Successfully pushed to GitHub!"
    echo "Repository URL: ${GITHUB_REPO%.git}"
else
    echo ""
    echo "✗ Push failed. Possible reasons:"
    echo "1. Repository doesn't exist on GitHub"
    echo "2. Authentication failed"
    echo "3. Network issues"
    echo ""
    echo "To create the repository on GitHub:"
    echo "1. Go to https://github.com/new"
    echo "2. Create repository 'termux-packaging'"
    echo "3. Don't initialize with README (we already have one)"
    echo "4. Then run this script again"
    exit 1
fi

echo ""
echo "=== Next Steps ==="
echo "1. Test on arm64 apt machine (10.31.66.45):"
echo "   git clone $GITHUB_REPO"
echo "   cd termux-packaging"
echo "   ./setup.sh"
echo ""
echo "2. Test on arm32 apt machine (10.31.66.76):"
echo "   Same steps, but change ARCHITECTURE to 'armv7l' in config"
echo ""
echo "3. Verify builds work on both architectures"