#!/bin/bash

# KDE Lock Screen Wallpaper Setter for WallyHaze
# Usage: ./set_kde_lockscreen.sh /path/to/wallpaper.jpg

if [ $# -eq 0 ]; then
    echo "Usage: $0 <wallpaper_path>"
    exit 1
fi

WALLPAPER_PATH="$1"

if [ ! -f "$WALLPAPER_PATH" ]; then
    echo "Error: Wallpaper file does not exist: $WALLPAPER_PATH"
    exit 1
fi

echo "Setting KDE lock screen wallpaper to: $WALLPAPER_PATH"

# Determine which kwriteconfig to use
KWRITECONFIG=""
if command -v kwriteconfig6 >/dev/null 2>&1; then
    KWRITECONFIG="kwriteconfig6"
elif command -v kwriteconfig5 >/dev/null 2>&1; then
    KWRITECONFIG="kwriteconfig5"
else
    echo "Error: Neither kwriteconfig6 nor kwriteconfig5 found"
    exit 1
fi

echo "Using $KWRITECONFIG"

# Create config directory if it doesn't exist
mkdir -p ~/.config

# Set lock screen wallpaper plugin to image
$KWRITECONFIG --file kscreenlockerrc --group Greeter --key WallpaperPlugin "org.kde.image"

# Set the wallpaper image path
$KWRITECONFIG --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "file://$WALLPAPER_PATH"

# Alternative method - set theme
$KWRITECONFIG --file kscreenlockerrc --group Greeter --key Theme "$WALLPAPER_PATH"

# Set background mode to scaled
$KWRITECONFIG --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key FillMode "2"

# Restart KDE lock screen service if running
if systemctl --user is-active --quiet plasma-kscreen_backend; then
    echo "Restarting plasma-kscreen_backend service..."
    systemctl --user restart plasma-kscreen_backend
fi

# Try to restart screenlocker if it's running
if pgrep -x "kscreenlocker" > /dev/null; then
    echo "Restarting kscreenlocker..."
    pkill -x kscreenlocker
fi

# Force reload of KDE configuration
if command -v kquitapp5 >/dev/null 2>&1; then
    kquitapp5 kscreenlocker 2>/dev/null
elif command -v kquitapp6 >/dev/null 2>&1; then
    kquitapp6 kscreenlocker 2>/dev/null
fi

echo "KDE lock screen wallpaper has been set!"
echo ""
echo "To see the changes:"
echo "1. Lock your screen (Ctrl+Alt+L)"
echo "2. Or go to System Settings > Screen Locking to verify"
echo ""
echo "If the wallpaper doesn't appear:"
echo "• Go to System Settings > Screen Locking > Appearance"
echo "• Select 'Image' as wallpaper type"
echo "• Browse and select: $WALLPAPER_PATH"
