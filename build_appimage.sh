#!/bin/bash

# WallyHaze AppImage Build Script
set -e

APP_NAME="WallyHaze"
APP_VERSION="1.0.0"
BUILD_DIR="$(pwd)/build"
APPDIR="$(pwd)/${APP_NAME}.AppDir"

echo "🚀 Building WallyHaze AppImage..."

# Clean previous builds
rm -rf "$APPDIR"
rm -f "${APP_NAME}-${APP_VERSION}-x86_64.AppImage"

# Create AppDir structure
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/lib"
mkdir -p "$APPDIR/usr/share/applications"
mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$APPDIR/usr/share/metainfo"

# Copy binary
echo "📦 Copying WallyHaze binary..."
cp "$BUILD_DIR/WallyHaze" "$APPDIR/usr/bin/"

# Make binary executable
chmod +x "$APPDIR/usr/bin/WallyHaze"

# Copy Qt libraries
echo "📚 Copying Qt6 libraries..."
QT_LIBS=(
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
    "libQt6Network.so.6"
    "libQt6DBus.so.6"
)

for lib in "${QT_LIBS[@]}"; do
    if [ -f "/lib64/$lib" ]; then
        cp "/lib64/$lib" "$APPDIR/usr/lib/"
    elif [ -f "/usr/lib64/$lib" ]; then
        cp "/usr/lib64/$lib" "$APPDIR/usr/lib/"
    elif [ -f "/usr/lib/x86_64-linux-gnu/$lib" ]; then
        cp "/usr/lib/x86_64-linux-gnu/$lib" "$APPDIR/usr/lib/"
    fi
done

# Copy Qt plugins
echo "🔌 Copying Qt6 plugins..."
QT_PLUGIN_DIR=""
if [ -d "/usr/lib64/qt6/plugins" ]; then
    QT_PLUGIN_DIR="/usr/lib64/qt6/plugins"
elif [ -d "/usr/lib/x86_64-linux-gnu/qt6/plugins" ]; then
    QT_PLUGIN_DIR="/usr/lib/x86_64-linux-gnu/qt6/plugins"
elif [ -d "/usr/lib/qt6/plugins" ]; then
    QT_PLUGIN_DIR="/usr/lib/qt6/plugins"
fi

if [ -n "$QT_PLUGIN_DIR" ]; then
    mkdir -p "$APPDIR/usr/plugins"
    cp -r "$QT_PLUGIN_DIR/platforms" "$APPDIR/usr/plugins/"
    cp -r "$QT_PLUGIN_DIR/imageformats" "$APPDIR/usr/plugins/"
    cp -r "$QT_PLUGIN_DIR/iconengines" "$APPDIR/usr/plugins/" 2>/dev/null || true
    cp -r "$QT_PLUGIN_DIR/platformthemes" "$APPDIR/usr/plugins/" 2>/dev/null || true
fi

# Create desktop file
echo "🖥️  Creating desktop file..."
cat > "$APPDIR/usr/share/applications/wallyhaze.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=WallyHaze
GenericName=Wallpaper Browser
Comment=Beautiful wallpaper browser and setter with infinite scroll
Exec=WallyHaze
Icon=wallyhaze
Terminal=false
StartupNotify=true
Categories=Graphics;Photography;Utility;
Keywords=wallpaper;background;desktop;image;lockscreen;
StartupWMClass=WallyHaze
EOF

# Create icon using the new wallpaper-style logos
echo "🎨 Creating application icon..."

# Copy all icon sizes
echo "📋 Copying icon files..."
if [ -d "icons" ]; then
    mkdir -p "$APPDIR/usr/share/icons/hicolor/16x16/apps"
    mkdir -p "$APPDIR/usr/share/icons/hicolor/32x32/apps"
    mkdir -p "$APPDIR/usr/share/icons/hicolor/48x48/apps"
    mkdir -p "$APPDIR/usr/share/icons/hicolor/64x64/apps"
    mkdir -p "$APPDIR/usr/share/icons/hicolor/128x128/apps"
    mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"
    mkdir -p "$APPDIR/usr/share/icons/hicolor/scalable/apps"

    # Convert SVG icons to PNG for different sizes
    if command -v rsvg-convert >/dev/null 2>&1; then
        rsvg-convert -w 16 -h 16 "icons/wallyhaze-16.svg" > "$APPDIR/usr/share/icons/hicolor/16x16/apps/wallyhaze.png"
        rsvg-convert -w 32 -h 32 "icons/wallyhaze-32.svg" > "$APPDIR/usr/share/icons/hicolor/32x32/apps/wallyhaze.png"
        rsvg-convert -w 48 -h 48 "wallyhaze-logo.svg" > "$APPDIR/usr/share/icons/hicolor/48x48/apps/wallyhaze.png"
        rsvg-convert -w 64 -h 64 "icons/wallyhaze-64.svg" > "$APPDIR/usr/share/icons/hicolor/64x64/apps/wallyhaze.png"
        rsvg-convert -w 128 -h 128 "wallyhaze-logo.svg" > "$APPDIR/usr/share/icons/hicolor/128x128/apps/wallyhaze.png"
        rsvg-convert -w 256 -h 256 "icons/wallyhaze-256.svg" > "$APPDIR/usr/share/icons/hicolor/256x256/apps/wallyhaze.png"
        echo "✅ Converted all icon sizes using rsvg-convert"
    elif command -v convert >/dev/null 2>&1; then
        convert -size 16x16 "icons/wallyhaze-16.svg" "$APPDIR/usr/share/icons/hicolor/16x16/apps/wallyhaze.png"
        convert -size 32x32 "icons/wallyhaze-32.svg" "$APPDIR/usr/share/icons/hicolor/32x32/apps/wallyhaze.png"
        convert -size 48x48 "wallyhaze-logo.svg" "$APPDIR/usr/share/icons/hicolor/48x48/apps/wallyhaze.png"
        convert -size 64x64 "icons/wallyhaze-64.svg" "$APPDIR/usr/share/icons/hicolor/64x64/apps/wallyhaze.png"
        convert -size 128x128 "wallyhaze-logo.svg" "$APPDIR/usr/share/icons/hicolor/128x128/apps/wallyhaze.png"
        convert -size 256x256 "icons/wallyhaze-256.svg" "$APPDIR/usr/share/icons/hicolor/256x256/apps/wallyhaze.png"
        echo "✅ Converted all icon sizes using ImageMagick"
    else
        # Use existing PNG files if available
        [ -f "icons/wallyhaze-48.png" ] && cp "icons/wallyhaze-48.png" "$APPDIR/usr/share/icons/hicolor/48x48/apps/wallyhaze.png"
        [ -f "icons/wallyhaze-96.png" ] && cp "icons/wallyhaze-96.png" "$APPDIR/usr/share/icons/hicolor/128x128/apps/wallyhaze.png"
        [ -f "icons/wallyhaze-100.png" ] && cp "icons/wallyhaze-100.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/wallyhaze.png"
        echo "⚠️  Using PNG files directly (no SVG converter found)"
    fi

    # Copy scalable versions
    cp "icons/wallyhaze.svg" "$APPDIR/usr/share/icons/hicolor/scalable/apps/"
    cp "wallyhaze-logo.svg" "$APPDIR/usr/share/icons/hicolor/scalable/apps/wallyhaze.svg"

elif [ -f "wallyhaze-logo.svg" ]; then
    echo "✅ Using main project logo: wallyhaze-logo.svg"

    # Try to convert SVG to PNG with different tools
    if command -v rsvg-convert >/dev/null 2>&1; then
        rsvg-convert -w 256 -h 256 "wallyhaze-logo.svg" > "$APPDIR/usr/share/icons/hicolor/256x256/apps/wallyhaze.png"
        echo "✅ Converted logo using rsvg-convert"
    elif command -v convert >/dev/null 2>&1; then
        convert -size 256x256 "wallyhaze-logo.svg" "$APPDIR/usr/share/icons/hicolor/256x256/apps/wallyhaze.png"
        echo "✅ Converted logo using ImageMagick"
    else
        # Copy SVG directly as fallback
        cp "wallyhaze-logo.svg" "$APPDIR/usr/share/icons/hicolor/256x256/apps/wallyhaze.png"
        echo "⚠️  Using SVG directly (no converter found)"
    fi
else
    echo "⚠️  Logo files not found, creating wallpaper-style fallback icon..."
    # Fallback: create wallpaper-style icon
    cat > "$APPDIR/wallyhaze-fallback.svg" << 'SVGEOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="256" height="256" viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#E3F2FD;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#BBDEFB;stop-opacity:1" />
    </linearGradient>
    <linearGradient id="frame" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#2196F3;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#1976D2;stop-opacity:1" />
    </linearGradient>
    <linearGradient id="content" x1="0%" y1="100%" x2="0%" y2="0%">
      <stop offset="0%" style="stop-color:#81C784;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#E8F5E8;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="256" height="256" rx="32" fill="url(#bg)"/>
  <rect x="32" y="32" width="192" height="192" rx="16" fill="url(#frame)"/>
  <rect x="48" y="48" width="160" height="160" rx="8" fill="url(#content)"/>
  <polygon points="48,160 100,120 150,140 190,130 208,150 208,208 48,208" fill="#2E7D32"/>
  <circle cx="160" cy="88" r="16" fill="#FFC107"/>
</svg>
SVGEOF

    if command -v rsvg-convert >/dev/null 2>&1; then
        rsvg-convert -w 256 -h 256 "$APPDIR/wallyhaze-fallback.svg" > "$APPDIR/usr/share/icons/hicolor/256x256/apps/wallyhaze.png"
        rm "$APPDIR/wallyhaze-fallback.svg"
    else
        cp "$APPDIR/wallyhaze-fallback.svg" "$APPDIR/usr/share/icons/hicolor/256x256/apps/wallyhaze.png"
        rm "$APPDIR/wallyhaze-fallback.svg"
    fi
fi

# Copy icon to AppDir root
cp "$APPDIR/usr/share/icons/hicolor/256x256/apps/wallyhaze.png" "$APPDIR/wallyhaze.png"

# Copy desktop file to AppDir root
cp "$APPDIR/usr/share/applications/wallyhaze.desktop" "$APPDIR/wallyhaze.desktop"

# Copy AppStream metadata
echo "📄 Copying AppStream metadata..."
if [ -f "wallyhaze.appdata.xml" ]; then
    cp "wallyhaze.appdata.xml" "$APPDIR/usr/share/metainfo/"
    echo "✅ Added AppStream metadata"
else
    echo "⚠️  AppStream metadata not found, skipping"
fi

# Create AppRun script
echo "📝 Creating AppRun script..."
cat > "$APPDIR/AppRun" << 'EOF'
#!/bin/bash

# Get the directory of this script
HERE=$(dirname "$(readlink -f "${0}")")

# Set up environment
export LD_LIBRARY_PATH="${HERE}/usr/lib:${LD_LIBRARY_PATH}"
export QT_PLUGIN_PATH="${HERE}/usr/plugins:${QT_PLUGIN_PATH}"
export QML2_IMPORT_PATH="${HERE}/usr/qml:${QML2_IMPORT_PATH}"

# Set Qt platform theme
export QT_QPA_PLATFORM_PLUGIN_PATH="${HERE}/usr/plugins/platforms"

# Ensure we can find the platform plugins
export QT_QPA_PLATFORM="xcb"

# Set application paths
export PATH="${HERE}/usr/bin:${PATH}"

# Run the application
cd "${HERE}" || exit 1
exec "${HERE}/usr/bin/WallyHaze" "$@"
EOF

chmod +x "$APPDIR/AppRun"

# Copy additional files
echo "📄 Copying additional files..."
cp "set_kde_lockscreen.sh" "$APPDIR/usr/bin/" 2>/dev/null || true
cp "KDE_LOCKSCREEN_SETUP.md" "$APPDIR/usr/share/" 2>/dev/null || true

# Download appimagetool if not present
APPIMAGETOOL="appimagetool-x86_64.AppImage"
if [ ! -f "$APPIMAGETOOL" ]; then
    echo "⬇️  Downloading appimagetool..."
    wget -q "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    chmod +x "$APPIMAGETOOL"
fi

# Build AppImage
echo "🔨 Building AppImage..."
ARCH=x86_64 ./"$APPIMAGETOOL" --no-appstream "$APPDIR" "${APP_NAME}-${APP_VERSION}-x86_64.AppImage"

# Clean up
rm -rf "$APPDIR"

echo "✅ AppImage created successfully: ${APP_NAME}-${APP_VERSION}-x86_64.AppImage"
echo ""
echo "🚀 You can now distribute this AppImage file!"
echo "   Users can run it with: ./${APP_NAME}-${APP_VERSION}-x86_64.AppImage"
echo ""
echo "📦 File size: $(du -h "${APP_NAME}-${APP_VERSION}-x86_64.AppImage" | cut -f1)"
