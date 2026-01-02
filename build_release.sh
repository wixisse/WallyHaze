#!/bin/bash

# WallyHaze Release Build Script
# Builds both AppImage (Linux) and Windows executable packages
set -e

APP_NAME="WallyHaze"
APP_VERSION="1.0.0"
RELEASE_DIR="$(pwd)/releases"

echo " WallyHaze Release Builder v${APP_VERSION}"
echo "=============================================="

# Create releases directory
mkdir -p "$RELEASE_DIR"

# Function to print section headers
print_header() {
    echo ""
    echo "$(tput setaf 6)$1$(tput sgr0)"
    echo "$(printf '=%.0s' $(seq 1 ${#1}))"
}

# Function to check dependencies
check_dependencies() {
    print_header "🔍 Checking Dependencies"

    local missing_deps=()

    # Essential build tools
    if ! command -v cmake >/dev/null 2>&1; then
        missing_deps+=("cmake")
    fi

    if ! command -v make >/dev/null 2>&1; then
        missing_deps+=("make")
    fi

    if ! command -v g++ >/dev/null 2>&1; then
        missing_deps+=("g++")
    fi

    # Qt6 development packages
    if ! pkg-config --exists Qt6Core Qt6Widgets Qt6Network 2>/dev/null; then
        missing_deps+=("Qt6 development packages")
    fi

    # Optional: Windows cross-compilation
    if command -v x86_64-w64-mingw32-gcc >/dev/null 2>&1; then
        echo "MinGW-w64 found - Windows builds enabled"
        WINDOWS_BUILD_AVAILABLE=true
    else
        echo "  MinGW-w64 not found - Windows builds disabled"
        WINDOWS_BUILD_AVAILABLE=false
    fi

    # Optional: AppImage tools
    if command -v wget >/dev/null 2>&1 && [ -f "./build_appimage.sh" ]; then
        echo "AppImage tools found - AppImage builds enabled"
        APPIMAGE_BUILD_AVAILABLE=true
    else
        echo " AppImage tools not found - AppImage builds disabled"
        APPIMAGE_BUILD_AVAILABLE=false
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Missing required dependencies:"
        for dep in "${missing_deps[@]}"; do
            echo "   - $dep"
        done
        echo ""
        echo "Please install missing dependencies and run again."
        exit 1
    fi

    echo " All required dependencies found!"
}

# Function to build native Linux version
build_native_linux() {
    print_header " Building Native Linux Version"

    # Clean and create build directory
    rm -rf build
    mkdir -p build
    cd build

    # Configure
    echo "Configuring CMake..."
    cmake .. -DCMAKE_BUILD_TYPE=Release

    # Build
    echo "Building WallyHaze..."
    make -j$(nproc)

    echo " Native Linux build completed!"
    cd ..
}

# Function to create AppImage
create_appimage() {
    if [ "$APPIMAGE_BUILD_AVAILABLE" = false ]; then
        echo "Skipping AppImage build - dependencies not met"
        return
    fi

    print_header " Creating AppImage"

    # Run AppImage build script
    ./build_appimage.sh

    # Move to releases directory with version folder
    local VERSION_DIR="$RELEASE_DIR/v${APP_VERSION}"
    mkdir -p "$VERSION_DIR"

    if [ -f "${APP_NAME}-${APP_VERSION}-x86_64.AppImage" ]; then
        mv "${APP_NAME}-${APP_VERSION}-x86_64.AppImage" "$VERSION_DIR/"
        echo " AppImage created: $VERSION_DIR/${APP_NAME}-${APP_VERSION}-x86_64.AppImage"
    else
        echo " AppImage build failed!"
        return 1
    fi
}

# Function to build Windows version
build_windows() {
    if [ "$WINDOWS_BUILD_AVAILABLE" = false ]; then
        echo "  Skipping Windows build - MinGW-w64 not available"
        return
    fi

    print_header "Building Windows Version"

    # Run Windows build script
    ./build_windows.sh

    # Move to releases directory with version folder
    local VERSION_DIR="$RELEASE_DIR/v${APP_VERSION}"
    mkdir -p "$VERSION_DIR"

    if [ -f "${APP_NAME}-Windows-${APP_VERSION}.zip" ]; then
        mv "${APP_NAME}-Windows-${APP_VERSION}.zip" "$VERSION_DIR/"
        echo " Windows package created: $VERSION_DIR/${APP_NAME}-Windows-${APP_VERSION}.zip"
    else
        echo " Windows build failed!"
        return 1
    fi

    # Also move the installer script if it exists
    if [ -f "wallyhaze-installer.nsi" ]; then
        mv "wallyhaze-installer.nsi" "$VERSION_DIR/"
    fi
}

# Function to create source package
create_source_package() {
    print_header " Creating Source Package"

    # Create source tarball in version directory
    local VERSION_DIR="$RELEASE_DIR/v${APP_VERSION}"
    mkdir -p "$VERSION_DIR"
    SOURCE_PACKAGE="$VERSION_DIR/${APP_NAME}-${APP_VERSION}-source.tar.gz"

    # List of files to include in source package
    tar -czf "$SOURCE_PACKAGE" \
        --exclude='build*' \
        --exclude='releases' \
        --exclude='.git*' \
        --exclude='*.AppImage' \
        --exclude='*.zip' \
        --exclude='*.exe' \
        --exclude='*.AppDir' \
        --exclude='appimagetool*' \
        --exclude='icons8-*' \
        src/ \
        icons/ \
        CMakeLists.txt \
        wallyhaze-logo.svg \
        *.sh \
        *.cmake \
        *.md \
        *.desktop \
        *.appdata.xml 2>/dev/null || true

    echo " Source package created: $SOURCE_PACKAGE"
}

# Function to generate checksums
generate_checksums() {
    print_header "Generating Checksums"

    local VERSION_DIR="$RELEASE_DIR/v${APP_VERSION}"
    cd "$VERSION_DIR"

    # Generate SHA256 checksums
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum *.AppImage *.zip *.tar.gz 2>/dev/null > checksums.sha256 || true
        echo "SHA256 checksums generated"
    fi

    # Generate MD5 checksums
    if command -v md5sum >/dev/null 2>&1; then
        md5sum *.AppImage *.zip *.tar.gz 2>/dev/null > checksums.md5 || true
        echo "MD5 checksums generated"
    fi

    cd ../..
}

# Function to create release notes
create_release_notes() {
    print_header "📝 Creating Release Notes"

    local VERSION_DIR="$RELEASE_DIR/v${APP_VERSION}"
    mkdir -p "$VERSION_DIR"

    cat > "$VERSION_DIR/RELEASE_NOTES.md" << EOF
# WallyHaze v${APP_VERSION} Release Notes

##  Features

- **Infinite Scroll Wallpaper Browser**: Smooth, automatic loading of wallpapers sorted by date added
- **Perfect Image Scaling**: Preview wallpapers without stretching or distortion
- **One-Click Wallpaper Setting**: Set both desktop and lock screen wallpapers instantly
- **Cross-Platform Support**: Native builds for Linux and Windows
- **High-Quality Downloads**: Download wallpapers in full resolution
- **Professional Wallpaper-Style Icons**: New icon design featuring wallpaper frame theme
- **Multiple Icon Sizes**: From 16×16 to 256×256 for perfect scaling
- **Keyboard Shortcuts**:
  - \`Ctrl+D\` to download wallpaper
  - \`Ctrl+W\` to set as wallpaper
  - \`Escape\` to close dialogs

##  Installation

### Linux (AppImage)
1. Download: \`${APP_NAME}-${APP_VERSION}-x86_64.AppImage\`
2. Make executable: \`chmod +x ${APP_NAME}-${APP_VERSION}-x86_64.AppImage\`
3. Run: \`./${APP_NAME}-${APP_VERSION}-x86_64.AppImage\`

### Windows
1. Download: \`${APP_NAME}-Windows-${APP_VERSION}.zip\`
2. Extract to desired location
3. Run: \`WallyHaze.exe\`

### From Source
1. Download: \`${APP_NAME}-${APP_VERSION}-source.tar.gz\`
2. Extract and build with CMake:
   \`\`\`bash
   tar -xzf ${APP_NAME}-${APP_VERSION}-source.tar.gz
   cd ${APP_NAME}-${APP_VERSION}
   mkdir build && cd build
   cmake .. && make
   ./WallyHaze
   \`\`\`

## 🔧 System Requirements

### Linux
- Qt6 runtime libraries
- Internet connection
- Modern Linux distribution (Ubuntu 20.04+, Fedora 35+, etc.)

### Windows
- Windows 10 or later (64-bit)
- Internet connection
- Visual C++ Redistributable (included in package)

##  Known Issues

- KDE lock screen wallpaper may require manual setting in some configurations
- First wallpaper load may take a few seconds
- Large wallpapers (>50MB) may take longer to download

##  File Locations

- **Linux**: Wallpapers saved to \`~/Pictures/WallyHaze/\`
- **Windows**: Wallpapers saved to \`%USERPROFILE%\\Pictures\\WallyHaze\\\`

##  Support

For issues or questions, please check the included documentation or file a bug report.

---

**Build Date**: $(date '+%Y-%m-%d %H:%M:%S %Z')
**Build Platform**: $(uname -s) $(uname -r)
EOF

    echo " Release notes created: $VERSION_DIR/RELEASE_NOTES.md"
}

# Function to display build summary
show_summary() {
    print_header "📊 Build Summary"

    local VERSION_DIR="$RELEASE_DIR/v${APP_VERSION}"
    echo "Release directory: $VERSION_DIR"
    echo ""
    echo "Generated files:"

    if [ -d "$VERSION_DIR" ]; then
        find "$VERSION_DIR" -type f | sort | while read -r file; do
            size=$(du -h "$file" | cut -f1)
            basename_file=$(basename "$file")
            echo "  📄 $basename_file ($size)"
        done
    fi

    echo ""
    echo "🎉 Release build completed successfully!"
    echo ""
    echo "🚀 Ready for distribution:"
    echo "   • Upload files from the '$VERSION_DIR' directory"
    echo "   • Include RELEASE_NOTES.md for users"
    echo "   • Verify checksums before publishing"
    echo "   • Test the AppImage and Windows builds"
}

# Main execution
main() {
    # Parse command line arguments
    BUILD_LINUX=true
    BUILD_WINDOWS=true
    BUILD_APPIMAGE=true

    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-linux)
                BUILD_LINUX=false
                shift
                ;;
            --no-windows)
                BUILD_WINDOWS=false
                shift
                ;;
            --no-appimage)
                BUILD_APPIMAGE=false
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --no-linux     Skip Linux native build"
                echo "  --no-windows   Skip Windows build"
                echo "  --no-appimage  Skip AppImage creation"
                echo "  --help, -h     Show this help"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use --help for available options"
                exit 1
                ;;
        esac
    done

    # Execute build steps
    check_dependencies

    if [ "$BUILD_LINUX" = true ]; then
        build_native_linux
    fi

    if [ "$BUILD_APPIMAGE" = true ]; then
        create_appimage
    fi

    if [ "$BUILD_WINDOWS" = true ]; then
        build_windows
    fi

    create_source_package
    generate_checksums
    create_release_notes
    show_summary
}

# Run main function with all arguments
main "$@"
