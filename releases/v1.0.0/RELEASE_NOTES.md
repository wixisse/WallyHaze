# WallyHaze v1.0.0 Release Notes

**Release Date:** December 31, 2024  
**Version:** 1.0.0  
**Build:** Production Release

## What's New

This is the initial stable release of WallyHaze - a beautiful, modern wallpaper browser and setter with infinite scroll capabilities.

### Key Features

- **Infinite Scroll Browsing** - Seamlessly browse thousands of high-quality wallpapers
- **Advanced Search & Filtering** - Find wallpapers by categories, colors, resolutions, and more
- **Lightning-Fast Performance** - Optimized image loading and caching system
- **Multi-Monitor Support** - Set different wallpapers for multiple displays
- **KDE Lockscreen Integration** - Built-in KDE lockscreen wallpaper support
- **Modern Qt6 Interface** - Clean, responsive user interface
- **Cross-Platform** - Works on all major Linux distributions and Windows
- **Windows Support** - Native Windows build with portable package

## Available Downloads

### Linux AppImage
- **File:** `WallyHaze-1.0.0-x86_64.AppImage`
- **Size:** 15 MB
- **SHA256:** `e2ef8ba0f4845c5e967d1d7b42c4720f7b5a0c2f50d29d035565c94876e0bdaf`
- **Requirements:** Any Linux distribution with glibc 2.17+ (2012+)

### Windows Portable Package
- **File:** `WallyHaze-Windows-1.0.0.zip`
- **Size:** 24 MB
- **SHA256:** `1a98f3b6c5061fcac025db018563e566fb5359b713f6df126d7a3ab8eb7e4b6f`
- **Requirements:** Windows 10/11 (64-bit)

#### How to Use the AppImage:
```bash
# Download and make executable
chmod +x WallyHaze-1.0.0-x86_64.AppImage

# Run directly
./WallyHaze-1.0.0-x86_64.AppImage

# Or integrate with desktop (optional)
./WallyHaze-1.0.0-x86_64.AppImage --appimage-extract
sudo cp squashfs-root/wallyhaze.desktop /usr/share/applications/
```

#### How to Use the Windows Package:
```bash
# Extract the ZIP file
unzip WallyHaze-Windows-1.0.0.zip

# Navigate to the folder
cd WallyHaze-Windows-1.0.0

# Double-click WallyHaze.exe to run
# All required DLLs and dependencies are included
```

## Technical Specifications

- **Framework:** Qt6 (Core, Widgets, Network)
- **Language:** C++17
- **Build System:** CMake 3.16+
- **Dependencies:** All bundled in AppImage
- **Architecture:** x86_64 (Intel/AMD 64-bit)

## Installation

### Linux - Method 1: AppImage (Universal)
1. Download `WallyHaze-1.0.0-x86_64.AppImage`
2. Make it executable: `chmod +x WallyHaze-1.0.0-x86_64.AppImage`
3. Run: `./WallyHaze-1.0.0-x86_64.AppImage`

### Linux - Method 2: System Integration
The AppImage includes desktop integration files for a native feel:
- Application menu entry
- File associations
- AppStream metadata

### Windows - Portable Package
1. Download `WallyHaze-Windows-1.0.0.zip`
2. Extract to any folder (e.g., `C:\Program Files\WallyHaze`)
3. Double-click `WallyHaze.exe` to run
4. No installation required - fully portable!

## System Requirements

### Linux - Minimum Requirements:
- **OS:** Linux with glibc 2.17+ (Ubuntu 14.04+, CentOS 7+, etc.)
- **RAM:** 256 MB available memory
- **Disk:** 50 MB free space
- **Display:** X11 or Wayland compatible

### Windows - Minimum Requirements:
- **OS:** Windows 10 or Windows 11 (64-bit)
- **RAM:** 512 MB available memory
- **Disk:** 100 MB free space

### Recommended (All Platforms):
- **RAM:** 1 GB+ for smooth image caching
- **Internet:** Broadband connection for wallpaper downloads
- **Display:** 1920×1080 or higher resolution

## Known Issues

None at this time. This is a stable release thoroughly tested across multiple distributions.

## Support & Contributing

- **Issues:** Report bugs and feature requests on GitHub
- **Documentation:** See `README.md` for detailed usage instructions
- **KDE Integration:** See `KDE_LOCKSCREEN_SETUP.md` for lockscreen setup

## Build Information

### Linux Build
- **Built with:** CMake + Qt6 on Fedora Linux
- **Compiler:** GCC with C++17 standard
- **Packaging:** AppImageTool continuous build

### Windows Build
- **Built with:** CMake + Qt6 cross-compilation
- **Compiler:** MinGW-w64 GCC 15.2.1 with C++17 standard
- **Packaging:** Portable ZIP with all dependencies included

**Quality:** Production-ready, fully tested builds on both platforms

## Security & Verification

Verify your download integrity:
```bash
# Linux AppImage
sha256sum WallyHaze-1.0.0-x86_64.AppImage
# Should match: e2ef8ba0f4845c5e967d1d7b42c4720f7b5a0c2f50d29d035565c94876e0bdaf

# Windows Package
sha256sum WallyHaze-Windows-1.0.0.zip
# Should match: 1a98f3b6c5061fcac025db018563e566fb5359b713f6df126d7a3ab8eb7e4b6f
```

## What's Next

Future releases will include:
- Additional wallpaper sources
- Advanced image filters
- Automatic wallpaper rotation
- Plugin system
- macOS support
- Flatpak and Snap packages

---

**Thank you for using WallyHaze!**

*WallyHaze v1.0.0 - Making Linux desktops beautiful, one wallpaper at a time.*

---

**Release Team:** WallyHaze Development Team  
**Build Date:** December 31, 2024  
**License:** Check LICENSE.txt for details