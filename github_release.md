# GitHub Setup and Release Guide 🚀

This guide will help you push WallyHaze to GitHub and create a professional release.

## 📋 Prerequisites

1. **GitHub Account** - Make sure you have a GitHub account
2. **Git Configured** - Set up your git identity:
   ```bash
   git config user.name "YourGitHubUsername"
   git config user.email "your-email@example.com"
   ```
3. **GitHub CLI (Optional)** - For easier releases:
   ```bash
   # Install GitHub CLI
   sudo dnf install gh  # Fedora
   # or
   sudo apt install gh  # Ubuntu/Debian
   ```

## 🎯 Step 1: Create GitHub Repository

### Option A: Using GitHub Web Interface (Recommended)
1. Go to [GitHub.com](https://github.com)
2. Click the **"+"** button → **"New repository"**
3. Fill in the details:
   - **Repository name:** `WallyHaze`
   - **Description:** `A beautiful, modern wallpaper browser and setter for Linux with infinite scroll capabilities`
   - **Visibility:** Public ✅
   - **Initialize:** ❌ Don't initialize (we have our code ready)
4. Click **"Create repository"**
5. Copy the repository URL (e.g., `https://github.com/YourUsername/WallyHaze.git`)

### Option B: Using GitHub CLI
```bash
gh repo create WallyHaze --public --description "A beautiful, modern wallpaper browser and setter for Linux with infinite scroll capabilities"
```

## 🔗 Step 2: Connect Local Repository to GitHub

```bash
# Add GitHub as remote origin (replace with your actual GitHub URL)
git remote add origin https://github.com/YourUsername/WallyHaze.git

# Push the code to GitHub
git push -u origin main
```

## 📦 Step 3: Upload the AppImage for Release

Since the AppImage is too large for git, we need to handle it specially:

```bash
# First, let's remove the AppImage from git tracking (it's in releases/)
git rm --cached releases/v1.0.0/WallyHaze-1.0.0-x86_64.AppImage
git commit -m "Remove AppImage from git tracking - will be uploaded to GitHub releases"
git push origin main
```

## 🎉 Step 4: Create GitHub Release

### Option A: Using GitHub Web Interface (Recommended)

1. Go to your repository on GitHub
2. Click **"Releases"** → **"Create a new release"**
3. Fill in the release details:
   - **Tag version:** `v1.0.0`
   - **Release title:** `WallyHaze v1.0.0 - Beautiful Wallpaper Browser with New Icon Design`
   - **Description:** Copy the content from `releases/v1.0.0/RELEASE_NOTES.md`
4. **Upload the AppImage:**
   - Drag and drop `releases/v1.0.0/WallyHaze-1.0.0-x86_64.AppImage`
   - This will attach it to the release
5. Click **"Publish release"**

### Option B: Using GitHub CLI

```bash
# Create release with GitHub CLI
gh release create v1.0.0 \
    releases/v1.0.0/WallyHaze-1.0.0-x86_64.AppImage \
    --title "WallyHaze v1.0.0 - Beautiful Wallpaper Browser with New Icon Design" \
    --notes-file releases/v1.0.0/RELEASE_NOTES.md
```

## 📝 Step 5: Update README Links

After creating the GitHub repository, update the README.md badges and links:

```bash
# Edit README.md and replace 'username' with your actual GitHub username
sed -i 's/username/YourActualUsername/g' README.md

# Commit the updated README
git add README.md
git commit -m "Update README with correct GitHub repository links"
git push origin main
```

## 🎯 Complete Release Checklist

- [ ] ✅ Repository created on GitHub
- [ ] ✅ Code pushed to GitHub (`git push origin main`)
- [ ] ✅ AppImage removed from git tracking
- [ ] ✅ Release v1.0.0 created with AppImage attached
- [ ] ✅ README links updated with your username
- [ ] ✅ Release notes published
- [ ] ✅ Download links working

## 📊 Post-Release Tasks

### 1. Update Repository Settings
- Go to **Settings** → **General** → **Features**
- Enable **Issues** ✅
- Enable **Discussions** ✅
- Enable **Wiki** ✅

### 2. Add Topics/Tags
- Go to your repository main page
- Click the **⚙️** gear icon next to "About"
- Add topics: `wallpaper`, `qt6`, `linux`, `appimage`, `desktop`, `c-plus-plus`

### 3. Create Additional Labels
Go to **Issues** → **Labels** and add:
- `enhancement` (new features)
- `bug` (something isn't working)
- `help wanted` (community contributions welcome)
- `good first issue` (good for newcomers)

### 4. Pin the Repository
- Go to your GitHub profile
- Click **"Customize your pins"**
- Select WallyHaze to showcase it

## 📢 Share Your Release

### Social Media
- Share on Twitter/X with hashtags: `#WallyHaze #Linux #Qt6 #Wallpaper #OpenSource`
- Post on Reddit: r/linux, r/unixporn, r/Qt
- Share in Discord communities: Linux, Qt, Desktop customization

### Developer Communities
- Submit to **AppImageHub**: https://github.com/AppImage/appimage.github.io
- List on **AlternativeTo**: https://alternativeto.net/
- Post on **Hacker News**: https://news.ycombinator.com/

## 🔧 Maintenance Commands

### Update Release
```bash
# For future updates:
git tag v1.0.1
git push origin v1.0.1

# Create new release with updated AppImage
gh release create v1.0.1 \
    releases/v1.0.1/WallyHaze-1.0.1-x86_64.AppImage \
    --title "WallyHaze v1.0.1 - Bug fixes and improvements"
```

### Monitor Repository
```bash
# Check repository stats
gh repo view --web

# View releases
gh release list

# Check issues
gh issue list
```

## 🎉 Success!

Your WallyHaze project is now live on GitHub! 🚀

**Repository URL:** `https://github.com/YourUsername/WallyHaze`
**Download Link:** `https://github.com/YourUsername/WallyHaze/releases/latest`

People can now:
- ⭐ Star your repository
- 📥 Download the AppImage
- 🐛 Report issues
- 🤝 Contribute code
- 💬 Start discussions

## 📈 Growing Your Project

1. **Documentation** - Add more guides to the Wiki
2. **Screenshots** - Add beautiful screenshots to README
3. **Video Demo** - Create a demo video
4. **Translations** - Add i18n support for multiple languages
5. **Windows Build** - Implement cross-compilation for Windows users
6. **Package Repositories** - Submit to Flathub, AUR, etc.

---

**Happy releasing! 🎊**

*Your WallyHaze project is now ready to make Linux desktops beautiful worldwide!* ✨