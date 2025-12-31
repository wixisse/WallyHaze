# WallyHaze 🖼️

**A beautiful, modern wallpaper browser and setter for Linux with infinite scroll capabilities**

![WallyHaze Logo](wallyhaze-logo.svg)

[![Latest Release](https://img.shields.io/github/v/release/wixisse/WallyHaze)](https://github.com/wixisse/WallyHaze/releases)
[![Downloads](https://img.shields.io/github/downloads/wixisse/WallyHaze/total)](https://github.com/wixisse/WallyHaze/releases)
[![License](https://img.shields.io/github/license/wixisse/WallyHaze)](LICENSE.txt)

## ✨ Features

- **🌊 Infinite Scroll Browsing** - Seamlessly browse thousands of high-quality wallpapers
- **🔍 Advanced Search & Filtering** - Find wallpapers by categories, colors, resolutions, and more
- **⚡ Lightning-Fast Performance** - Optimized image loading and caching system
- **🖥️ Multi-Monitor Support** - Set different wallpapers for multiple displays
- **🔒 KDE Lockscreen Integration** - Built-in KDE lockscreen wallpaper support
- **🎨 Modern Qt6 Interface** - Clean, responsive user interface
- **📱 Cross-Platform** - Works on all major Linux distributions
- **🚀 AppImage Distribution** - No installation required, runs everywhere

## 📸 Screenshots

*Coming soon - Screenshots will be added to showcase the beautiful interface*

## 📥 Download & Installation

### Quick Start (Recommended)

1. **Download the latest AppImage** from the [Releases](https://github.com/wixisse/WallyHaze/releases) page
2. **Make it executable:**
   ```bash
   chmod +x WallyHaze-1.0.0-x86_64.AppImage
   ```
3. **Run it:**
   ```bash
   ./WallyHaze-1.0.0-x86_64.AppImage
   ```

That's it! No installation required.

### System Integration (Optional)

For desktop integration (application menu, file associations, etc.):

```bash
# Extract AppImage contents
./WallyHaze-1.0.0-x86_64.AppImage --appimage-extract

# Copy desktop file and icons
sudo cp squashfs-root/wallyhaze.desktop /usr/share/applications/
sudo cp -r squashfs-root/usr/share/icons/* /usr/share/icons/
```

## 🛠️ System Requirements

### Minimum Requirements
- **OS:** Linux with glibc 2.17+ (Ubuntu 14.04+, CentOS 7+, etc.)
- **RAM:** 256 MB available memory
- **Disk:** 50 MB free space
- **Display:** X11 or Wayland compatible

### Recommended
- **RAM:** 1 GB+ for smooth image caching
- **Internet:** Broadband connection for wallpaper downloads
- **Display:** 1920×1080 or higher resolution

## 🚀 Usage

### Basic Usage
1. Launch WallyHaze
2. Browse the infinite scroll gallery of wallpapers
3. Click on any wallpaper to preview it full-size
4. Right-click to set as wallpaper or lockscreen background

### Advanced Features
- **Search:** Use the search bar to find specific types of wallpapers
- **Categories:** Filter by categories like Nature, Abstract, Photography, etc.
- **Resolution Filtering:** Find wallpapers that match your screen resolution
- **Multi-Monitor:** Set different wallpapers for each monitor
- **KDE Integration:** Automatic lockscreen wallpaper setting (see KDE setup below)

### KDE Lockscreen Integration

WallyHaze includes special integration for KDE Plasma users. See [KDE_LOCKSCREEN_SETUP.md](KDE_LOCKSCREEN_SETUP.md) for detailed setup instructions.

## 🏗️ Building from Source

### Prerequisites
- Qt6 (Core, Widgets, Network)
- CMake 3.16+
- C++17 compatible compiler
- Linux development environment

### Build Steps
```bash
# Clone the repository
git clone https://github.com/wixisse/WallyHaze.git
cd WallyHaze

# Create build directory
mkdir build && cd build

# Configure with CMake
cmake .. -DCMAKE_BUILD_TYPE=Release

# Build
make -j$(nproc)

# Run
./WallyHaze
```

### Building AppImage
```bash
# Build the application first (see above)
cd ..

# Create AppImage (requires appimagetool)
./build_appimage.sh
```

### Cross-compilation for Windows
```bash
# Install MinGW-w64 cross-compiler and Qt6 for Windows
# See BUILD_WINDOWS.md for detailed instructions

cmake -B build-windows -DCMAKE_TOOLCHAIN_FILE=toolchain-mingw64.cmake
cmake --build build-windows --config Release
./build_windows.sh
```

## 🎨 Icon Design

WallyHaze features a beautiful, modern icon with:
- **Blue gradient theme** - Professional and eye-catching
- **Image gallery representation** - Perfect for a wallpaper application
- **Scalable vector graphics** - Crystal clear at any size
- **Consistent across all platforms** - From system tray to desktop shortcuts

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Reporting Issues
- Use the [Issues](https://github.com/wixisse/WallyHaze/issues) tab to report bugs
- Include your Linux distribution, version, and steps to reproduce
- Attach screenshots if applicable

### Feature Requests
- Check existing [Issues](https://github.com/wixisse/WallyHaze/issues) first
- Describe the feature and why it would be useful
- Consider contributing code if you're able!

### Code Contributions
1. Fork the repository
2. Create a feature branch: `git checkout -b amazing-feature`
3. Make your changes and test thoroughly
4. Commit: `git commit -m 'Add amazing feature'`
5. Push: `git push origin amazing-feature`
6. Open a Pull Request

### Development Setup
```bash
# Install development dependencies
sudo dnf install qt6-qtbase-devel cmake gcc-c++  # Fedora
# sudo apt install qt6-base-dev cmake build-essential  # Ubuntu/Debian

# Clone and build
git clone https://github.com/wixisse/WallyHaze.git
cd WallyHaze
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug
make -j$(nproc)
```

## 📋 Roadmap

- [ ] **Windows Support** - Native Windows build
- [ ] **Additional Wallpaper Sources** - Support for more wallpaper APIs
- [ ] **Advanced Filters** - More sophisticated filtering options
- [ ] **Automatic Rotation** - Scheduled wallpaper changes
- [ ] **Plugin System** - Extensible architecture for custom features
- [ ] **Favorites System** - Save and organize favorite wallpapers
- [ ] **Custom Collections** - Create personal wallpaper collections
- [ ] **Social Features** - Share wallpapers with friends

## 📄 License

This project is licensed under the [MIT License](LICENSE.txt) - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Qt Framework** - For the excellent cross-platform GUI framework
- **Wallhaven API** - For providing access to high-quality wallpapers
- **AppImage Project** - For making Linux application distribution simple
- **Icons8** - For inspiration in modern icon design
- **Contributors** - Everyone who helps make WallyHaze better

## 📞 Support

- **GitHub Issues:** [Report bugs and request features](https://github.com/wixisse/WallyHaze/issues)
- **Documentation:** Check the [Wiki](https://github.com/wixisse/WallyHaze/wiki) for detailed guides
- **Discussions:** Join conversations in [Discussions](https://github.com/wixisse/WallyHaze/discussions)

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=wixisse/WallyHaze&type=Date)](https://star-history.com/#wixisse/WallyHaze&Date)

---

**Made with ❤️ for the Linux community**

*WallyHaze v1.0.0 - Making Linux desktops beautiful, one wallpaper at a time.* ✨