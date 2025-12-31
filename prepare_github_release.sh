#!/bin/bash

# WallyHaze GitHub Release Preparation Script
# This script helps prepare the repository for GitHub release

set -e

echo "🚀 WallyHaze GitHub Release Preparation"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "CMakeLists.txt" ] || [ ! -f "wallyhaze-logo.svg" ]; then
    echo -e "${RED}❌ Error: Please run this script from the WallyHaze project root directory${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Checking repository status...${NC}"

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Error: Git repository not initialized. Run 'git init' first.${NC}"
    exit 1
fi

# Check if we have commits
if ! git rev-parse HEAD >/dev/null 2>&1; then
    echo -e "${RED}❌ Error: No commits found. Make sure you've committed your code first.${NC}"
    exit 1
fi

# Check if user has configured git
if ! git config user.name >/dev/null || ! git config user.email >/dev/null; then
    echo -e "${YELLOW}⚠️  Git user not configured. Please set up your identity:${NC}"
    echo "git config user.name 'Your GitHub Username'"
    echo "git config user.email 'your-email@example.com'"
    exit 1
fi

echo -e "${GREEN}✅ Git repository is properly configured${NC}"

# Check if AppImage exists
APPIMAGE_PATH="releases/v1.0.0/WallyHaze-1.0.0-x86_64.AppImage"
if [ ! -f "$APPIMAGE_PATH" ]; then
    echo -e "${RED}❌ Error: AppImage not found at $APPIMAGE_PATH${NC}"
    echo "Please build the AppImage first using: ./build_appimage.sh"
    exit 1
fi

echo -e "${GREEN}✅ AppImage found: $(du -h "$APPIMAGE_PATH" | cut -f1)${NC}"

# Check AppImage size (GitHub has a 100MB limit for regular uploads)
APPIMAGE_SIZE=$(stat --printf="%s" "$APPIMAGE_PATH")
if [ $APPIMAGE_SIZE -gt 104857600 ]; then # 100MB in bytes
    echo -e "${YELLOW}⚠️  Warning: AppImage is larger than 100MB. Consider using Git LFS or release assets.${NC}"
fi

# Function to remove AppImage from git if it's tracked
remove_appimage_from_git() {
    if git ls-files --error-unmatch "$APPIMAGE_PATH" >/dev/null 2>&1; then
        echo -e "${YELLOW}📦 Removing AppImage from git tracking (will be uploaded to GitHub releases)...${NC}"
        git rm --cached "$APPIMAGE_PATH"

        # Add to .gitignore if not already there
        if ! grep -q "*.AppImage" .gitignore; then
            echo "" >> .gitignore
            echo "# AppImage files (keep releases)" >> .gitignore
            echo "*.AppImage" >> .gitignore
            echo "!releases/**/*.AppImage" >> .gitignore
        fi

        git add .gitignore
        git commit -m "Remove AppImage from git tracking - will be uploaded to GitHub releases

The AppImage will be available as a release asset on GitHub instead of being tracked in git."

        echo -e "${GREEN}✅ AppImage removed from git tracking${NC}"
    else
        echo -e "${GREEN}✅ AppImage is not tracked in git${NC}"
    fi
}

# Check if remote origin exists
if git remote get-url origin >/dev/null 2>&1; then
    ORIGIN_URL=$(git remote get-url origin)
    echo -e "${GREEN}✅ Remote origin configured: $ORIGIN_URL${NC}"

    # Extract GitHub username from URL
    if [[ $ORIGIN_URL =~ github\.com[:/]([^/]+)/WallyHaze ]]; then
        GITHUB_USERNAME="${BASH_REMATCH[1]}"
        echo -e "${BLUE}📝 GitHub username detected: $GITHUB_USERNAME${NC}"

        # Update README.md with actual username
        if grep -q "username/WallyHaze" README.md; then
            echo -e "${YELLOW}📝 Updating README.md with your GitHub username...${NC}"
            sed -i "s/username\/WallyHaze/$GITHUB_USERNAME\/WallyHaze/g" README.md
            git add README.md
            git commit -m "Update README with correct GitHub repository links" || echo "No changes to commit in README"
            echo -e "${GREEN}✅ README.md updated with your GitHub username${NC}"
        fi
    fi
else
    echo -e "${YELLOW}⚠️  No remote origin configured. You'll need to add it manually:${NC}"
    echo "git remote add origin https://github.com/YourUsername/WallyHaze.git"
fi

# Check if GitHub CLI is available
if command -v gh >/dev/null 2>&1; then
    echo -e "${GREEN}✅ GitHub CLI is available${NC}"
    GH_CLI_AVAILABLE=true

    # Check if user is logged in to GitHub CLI
    if gh auth status >/dev/null 2>&1; then
        echo -e "${GREEN}✅ GitHub CLI is authenticated${NC}"
    else
        echo -e "${YELLOW}⚠️  GitHub CLI is not authenticated. Run: gh auth login${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  GitHub CLI not found. Install it for easier releases: sudo dnf install gh${NC}"
    GH_CLI_AVAILABLE=false
fi

# Prepare release
echo -e "\n${BLUE}🎯 Preparing for release...${NC}"

# Remove AppImage from git if needed
remove_appimage_from_git

echo -e "\n${GREEN}🎉 Repository is ready for GitHub!${NC}"
echo -e "${BLUE}📋 Next steps:${NC}"

if git remote get-url origin >/dev/null 2>&1; then
    echo "1. Push to GitHub: git push -u origin main"

    if [ "$GH_CLI_AVAILABLE" = true ]; then
        echo -e "\n${BLUE}🚀 Quick release with GitHub CLI:${NC}"
        echo "gh release create v1.0.0 \\"
        echo "    \"$APPIMAGE_PATH\" \\"
        echo "    --title \"WallyHaze v1.0.0 - Beautiful Wallpaper Browser with New Icon Design\" \\"
        echo "    --notes-file releases/v1.0.0/RELEASE_NOTES.md"
    else
        echo "2. Go to your GitHub repository"
        echo "3. Click 'Releases' → 'Create a new release'"
        echo "4. Tag: v1.0.0"
        echo "5. Upload: $APPIMAGE_PATH"
        echo "6. Use release notes from: releases/v1.0.0/RELEASE_NOTES.md"
    fi
else
    echo "1. Create repository on GitHub"
    echo "2. Add remote: git remote add origin https://github.com/YourUsername/WallyHaze.git"
    echo "3. Push: git push -u origin main"
    echo "4. Create release and upload: $APPIMAGE_PATH"
fi

echo -e "\n${YELLOW}📖 For detailed instructions, see: github_release.md${NC}"

# Generate release summary
echo -e "\n${BLUE}📊 Release Summary:${NC}"
echo "Repository: WallyHaze v1.0.0"
echo "AppImage: $(basename "$APPIMAGE_PATH") ($(du -h "$APPIMAGE_PATH" | cut -f1))"
echo "SHA256: $(cat releases/v1.0.0/checksums.sha256 | cut -d' ' -f1)"
echo "Commits: $(git rev-list --count HEAD)"
echo "Files: $(git ls-files | wc -l)"

echo -e "\n${GREEN}✨ Ready to make Linux desktops beautiful! 🖼️${NC}"
