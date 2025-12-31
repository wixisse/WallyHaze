#!/bin/bash

# WallyHaze Windows Build Script
set -e

APP_NAME="WallyHaze"
APP_VERSION="1.0.0"
WINDOWS_BUILD_DIR="$(pwd)/build-windows"
PACKAGE_DIR="$(pwd)/${APP_NAME}-Windows-${APP_VERSION}"

echo "🪟 Building WallyHaze for Windows..."

# Check if MinGW-w64 is installed
if ! command -v x86_64-w64-mingw32-gcc &> /dev/null; then
    echo "❌ MinGW-w64 not found! Please install it first:"
    echo "   Fedora/RHEL: sudo dnf install mingw64-gcc mingw64-gcc-c++ mingw64-qt6-qtbase-devel mingw64-qt6-qttools"
    echo "   Ubuntu/Debian: sudo apt install gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64"
    echo "   Arch: sudo pacman -S mingw-w64-gcc"
    exit 1
fi

# Clean previous builds
rm -rf "$WINDOWS_BUILD_DIR"
rm -rf "$PACKAGE_DIR"

# Create Windows build directory
mkdir -p "$WINDOWS_BUILD_DIR"
cd "$WINDOWS_BUILD_DIR"

echo "🔧 Configuring CMake for Windows cross-compilation..."

# Configure with MinGW toolchain
cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=../toolchain-mingw64.cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$PACKAGE_DIR" \
    -DCMAKE_PREFIX_PATH="/usr/x86_64-w64-mingw32" \
    -DQt6_DIR="/usr/x86_64-w64-mingw32/lib/cmake/Qt6"

echo "🔨 Building WallyHaze for Windows..."
make -j$(nproc)

cd ..

# Create package directory
mkdir -p "$PACKAGE_DIR"

echo "📦 Packaging WallyHaze for Windows..."

# Copy executable
cp "$WINDOWS_BUILD_DIR/WallyHaze.exe" "$PACKAGE_DIR/"

# Copy Qt6 DLLs
echo "📚 Copying Qt6 libraries..."
MINGW_BIN="/usr/x86_64-w64-mingw32/bin"
QT_DLLS=(
    "Qt6Core.dll"
    "Qt6Gui.dll"
    "Qt6Widgets.dll"
    "Qt6Network.dll"
)

for dll in "${QT_DLLS[@]}"; do
    if [ -f "$MINGW_BIN/$dll" ]; then
        cp "$MINGW_BIN/$dll" "$PACKAGE_DIR/"
    fi
done

# Copy MinGW runtime DLLs
MINGW_DLLS=(
    "libgcc_s_seh-1.dll"
    "libstdc++-6.dll"
    "libwinpthread-1.dll"
)

for dll in "${MINGW_DLLS[@]}"; do
    if [ -f "$MINGW_BIN/$dll" ]; then
        cp "$MINGW_BIN/$dll" "$PACKAGE_DIR/"
    fi
done

# Copy Qt plugins
echo "🔌 Copying Qt6 plugins..."
QT_PLUGINS_DIR="/usr/x86_64-w64-mingw32/plugins"
if [ -d "$QT_PLUGINS_DIR" ]; then
    mkdir -p "$PACKAGE_DIR/platforms"
    mkdir -p "$PACKAGE_DIR/imageformats"

    cp "$QT_PLUGINS_DIR/platforms/"*.dll "$PACKAGE_DIR/platforms/" 2>/dev/null || true
    cp "$QT_PLUGINS_DIR/imageformats/"*.dll "$PACKAGE_DIR/imageformats/" 2>/dev/null || true
fi

# Create Windows icon from new wallpaper-style logos
echo "🎨 Creating Windows icon..."

# Copy icon files to package
if [ -d "icons" ]; then
    mkdir -p "$PACKAGE_DIR/icons"
    cp -r icons/* "$PACKAGE_DIR/icons/"
    echo "✅ Copied icon files to package"
fi

# Create ICO file using the best available icons
if command -v rsvg-convert >/dev/null 2>&1 && command -v convert >/dev/null 2>&1; then
    echo "Creating multi-resolution ICO file..."

    # Use specialized icons when available, fallback to main logo
    if [ -f "icons/wallyhaze-16.svg" ]; then
        rsvg-convert -w 16 -h 16 "icons/wallyhaze-16.svg" > "/tmp/wallyhaze-16.png"
    else
        rsvg-convert -w 16 -h 16 "wallyhaze-logo.svg" > "/tmp/wallyhaze-16.png"
    fi

    if [ -f "icons/wallyhaze-32.svg" ]; then
        rsvg-convert -w 32 -h 32 "icons/wallyhaze-32.svg" > "/tmp/wallyhaze-32.png"
    else
        rsvg-convert -w 32 -h 32 "wallyhaze-logo.svg" > "/tmp/wallyhaze-32.png"
    fi

    # Use existing PNG or convert from SVG
    if [ -f "icons/wallyhaze-48.png" ]; then
        cp "icons/wallyhaze-48.png" "/tmp/wallyhaze-48.png"
    elif [ -f "icons/wallyhaze-64.svg" ]; then
        rsvg-convert -w 48 -h 48 "icons/wallyhaze-64.svg" > "/tmp/wallyhaze-48.png"
    else
        rsvg-convert -w 48 -h 48 "wallyhaze-logo.svg" > "/tmp/wallyhaze-48.png"
    fi

    if [ -f "icons/wallyhaze-96.png" ]; then
        cp "icons/wallyhaze-96.png" "/tmp/wallyhaze-64.png"
    elif [ -f "icons/wallyhaze-64.svg" ]; then
        rsvg-convert -w 64 -h 64 "icons/wallyhaze-64.svg" > "/tmp/wallyhaze-64.png"
    else
        rsvg-convert -w 64 -h 64 "wallyhaze-logo.svg" > "/tmp/wallyhaze-64.png"
    fi

    if [ -f "icons/wallyhaze-100.png" ]; then
        convert "icons/wallyhaze-100.png" -resize 256x256 "/tmp/wallyhaze-256.png"
    elif [ -f "icons/wallyhaze-256.svg" ]; then
        rsvg-convert -w 256 -h 256 "icons/wallyhaze-256.svg" > "/tmp/wallyhaze-256.png"
    else
        rsvg-convert -w 256 -h 256 "wallyhaze-logo.svg" > "/tmp/wallyhaze-256.png"
    fi

    # Combine all sizes into ICO file
    convert "/tmp/wallyhaze-16.png" "/tmp/wallyhaze-32.png" "/tmp/wallyhaze-48.png" \
            "/tmp/wallyhaze-64.png" "/tmp/wallyhaze-256.png" "$PACKAGE_DIR/wallyhaze.ico"

    # Clean up temporary files
    rm -f /tmp/wallyhaze-*.png
    echo "✅ Created wallyhaze.ico with wallpaper design"
elif [ -f "wallyhaze-logo.svg" ]; then
    echo "⚠️  Limited tools available, creating basic ICO"
    if command -v rsvg-convert >/dev/null 2>&1; then
        rsvg-convert -w 256 -h 256 "wallyhaze-logo.svg" > "$PACKAGE_DIR/wallyhaze.png"
        echo "✅ Created PNG icon (ICO conversion requires ImageMagick)"
    fi
elif [ -f "icons/wallyhaze-100.png" ]; then
    echo "Using PNG icon files..."
    cp "icons/wallyhaze-100.png" "$PACKAGE_DIR/wallyhaze.png"
    echo "✅ Created PNG icon from wallpaper design"
else
    echo "⚠️  No icon files found, skipping ICO creation"
fi

# Create Windows batch launcher
echo "📝 Creating Windows launcher..."
cat > "$PACKAGE_DIR/WallyHaze.bat" << 'EOF'
@echo off
cd /d "%~dp0"
start "" "WallyHaze.exe"
EOF

# Create qt.conf for proper plugin loading
cat > "$PACKAGE_DIR/qt.conf" << 'EOF'
[Paths]
Plugins = .
EOF

# Copy documentation
echo "📄 Copying documentation..."
cp "KDE_LOCKSCREEN_SETUP.md" "$PACKAGE_DIR/" 2>/dev/null || true

# Create Windows-specific README
cat > "$PACKAGE_DIR/README-Windows.txt" << EOF
WallyHaze v${APP_VERSION} for Windows
====================================

Thank you for downloading WallyHaze! 🎉

INSTALLATION:
1. Extract this folder to your desired location (e.g., C:\Program Files\WallyHaze)
2. Double-click WallyHaze.exe to run the application
3. Or use WallyHaze.bat for alternative launching

FEATURES:
• Browse beautiful wallpapers from Wallhaven
• Infinite scroll with automatic page loading
• Set wallpapers for both desktop and lock screen
• High-quality image preview without stretching
• Download wallpapers in full resolution
• Keyboard shortcuts (Ctrl+D to download, Ctrl+W to set wallpaper)

SYSTEM REQUIREMENTS:
• Windows 10 or later (64-bit)
• Internet connection for browsing wallpapers
• At least 100MB free disk space

WALLPAPER STORAGE:
Downloaded wallpapers are saved to:
%USERPROFILE%\Pictures\WallyHaze\

SETTING WALLPAPERS:
• Desktop wallpaper: Set automatically when you click "Set as Desktop & Lock Screen"
• Lock screen: Windows may require manual setting through Settings > Personalization > Lock screen

TROUBLESHOOTING:
• If the app doesn't start, make sure you have Visual C++ Redistributable installed
• For lock screen issues on Windows 11, use Settings > Personalization > Lock screen
• Check Windows Defender if wallpaper downloads are blocked

SUPPORT:
If you encounter issues, check the console output or contact support.

Enjoy browsing beautiful wallpapers! 🌟
EOF

# Create installer script (NSIS)
echo "🎯 Creating Windows installer script..."
cat > "$PACKAGE_DIR/../wallyhaze-installer.nsi" << EOF
!include "MUI2.nsh"

Name "WallyHaze"
OutFile "WallyHaze-${APP_VERSION}-Setup.exe"
InstallDir "\$PROGRAMFILES64\\WallyHaze"
InstallDirRegKey HKCU "Software\\WallyHaze" ""
RequestExecutionLevel admin

!define MUI_ABORTWARNING
!define MUI_ICON "${PACKAGE_DIR}\\wallyhaze.ico"
!define MUI_UNICON "${PACKAGE_DIR}\\wallyhaze.ico"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

Section "WallyHaze" SecMain
    SetOutPath "\$INSTDIR"
    File /r "${PACKAGE_DIR}\\*.*"

    WriteRegStr HKCU "Software\\WallyHaze" "" \$INSTDIR
    WriteUninstaller "\$INSTDIR\\Uninstall.exe"

    CreateDirectory "\$SMPROGRAMS\\WallyHaze"
    CreateShortCut "\$SMPROGRAMS\\WallyHaze\\WallyHaze.lnk" "\$INSTDIR\\WallyHaze.exe"
    CreateShortCut "\$SMPROGRAMS\\WallyHaze\\Uninstall.lnk" "\$INSTDIR\\Uninstall.exe"
    CreateShortCut "\$DESKTOP\\WallyHaze.lnk" "\$INSTDIR\\WallyHaze.exe"
SectionEnd

Section "Uninstall"
    Delete "\$INSTDIR\\*.*"
    RMDir /r "\$INSTDIR"
    Delete "\$SMPROGRAMS\\WallyHaze\\*.*"
    RMDir "\$SMPROGRAMS\\WallyHaze"
    Delete "\$DESKTOP\\WallyHaze.lnk"
    DeleteRegKey HKCU "Software\\WallyHaze"
SectionEnd
EOF

# Create ZIP package
echo "📁 Creating ZIP package..."
cd "$(dirname "$PACKAGE_DIR")"
zip -r "${APP_NAME}-Windows-${APP_VERSION}.zip" "$(basename "$PACKAGE_DIR")"

echo ""
echo "✅ Windows build completed successfully!"
echo ""
echo "📦 Package created: $PACKAGE_DIR"
echo "📁 ZIP file: ${APP_NAME}-Windows-${APP_VERSION}.zip"
echo ""
echo "🚀 Distribution files:"
echo "   • Windows executable: $(basename "$PACKAGE_DIR")/WallyHaze.exe"
echo "   • ZIP package: ${APP_NAME}-Windows-${APP_VERSION}.zip"
echo "   • NSIS installer script: wallyhaze-installer.nsi"
echo ""
echo "🎯 To create an installer:"
echo "   1. Install NSIS (Nullsoft Scriptable Install System)"
echo "   2. Run: makensis wallyhaze-installer.nsi"
echo ""
echo "📏 Package size: $(du -h "${APP_NAME}-Windows-${APP_VERSION}.zip" | cut -f1)"
