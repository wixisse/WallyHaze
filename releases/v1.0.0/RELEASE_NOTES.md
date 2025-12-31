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
- **Cross-Platform** - Works on all major Linux distributions

## Available Downloads

### Linux AppImage (Recommended)
- **File:** `WallyHaze-1.0.0-x86_64.AppImage`
- **Size:** 14.2 MB
- **SHA256:** `1ea7e30624db1215d316fe48c584263bacb152e88d42634c172724ad4fd4e342`
- **Requirements:** Any Linux distribution with glibc 2.17+ (2012+)

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

## Technical Specifications

- **Framework:** Qt6 (Core, Widgets, Network)
- **Language:** C++17
- **Build System:** CMake 3.16+
- **Dependencies:** All bundled in AppImage
- **Architecture:** x86_64 (Intel/AMD 64-bit)

## Installation

### Method 1: AppImage (Universal Linux)
1. Download `WallyHaze-1.0.0-x86_64.AppImage`
2. Make it executable: `chmod +x WallyHaze-1.0.0-x86_64.AppImage`
3. Run: `./WallyHaze-1.0.0-x86_64.AppImage`

### Method 2: System Integration
The AppImage includes desktop integration files for a native feel:
- Application menu entry
- File associations
- AppStream metadata

## System Requirements

### Minimum Requirements:
- **OS:** Linux with glibc 2.17+ (Ubuntu 14.04+, CentOS 7+, etc.)
- **RAM:** 256 MB available memory
- **Disk:** 50 MB free space
- **Display:** X11 or Wayland compatible

### Recommended:
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

- **Built with:** CMake + Qt6 on Fedora Linux
- **Compiler:** GCC with C++17 standard
- **Packaging:** AppImageTool continuous build
- **Quality:** Production-ready, fully tested build

## Security & Verification

Verify your download integrity:
```bash
sha256sum WallyHaze-1.0.0-x86_64.AppImage
# Should match: 1ea7e30624db1215d316fe48c584263bacb152e88d42634c172724ad4fd4e342
```

## What's Next

Future releases will include:
- Windows builds
- Additional wallpaper sources
- Advanced image filters
- Automatic wallpaper rotation
- Plugin system

---

**Thank you for using WallyHaze!**

*WallyHaze v1.0.0 - Making Linux desktops beautiful, one wallpaper at a time.*

---

**Release Team:** WallyHaze Development Team  
**Build Date:** December 31, 2024  
**License:** Check LICENSE.txt for details