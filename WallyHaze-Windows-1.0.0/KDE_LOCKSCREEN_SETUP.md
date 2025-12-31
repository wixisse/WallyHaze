# KDE Lock Screen Wallpaper Setup Guide

This guide helps you manually set lock screen wallpapers in KDE Plasma when WallyHaze's automatic method doesn't work.

## Automatic Method (Preferred)

WallyHaze includes an automatic KDE lock screen wallpaper setter. When you click "Set as Desktop & Lock Screen" in the wallpaper dialog, it will:

1. Set your desktop wallpaper using KDE's plasma shell
2. Configure the lock screen wallpaper using kwriteconfig
3. Restart necessary services to apply changes

## Manual Method (If Automatic Fails)

### Step 1: Open System Settings
- Click on the Application Menu (Start Menu)
- Search for "System Settings" and open it
- Or press `Alt + Space` and type "system settings"

### Step 2: Navigate to Screen Locking
- In System Settings, find and click **"Screen Locking"**
- Or use the search box at the top and search for "screen locking"

### Step 3: Configure Lock Screen Appearance
1. In the Screen Locking settings, click on the **"Appearance"** tab
2. Under "Wallpaper Type", select **"Image"**
3. Click **"Browse"** or the folder icon
4. Navigate to your WallyHaze wallpapers directory: `~/Pictures/WallyHaze/`
5. Select your desired wallpaper
6. Click **"Apply"** at the bottom

### Step 4: Test the Lock Screen
- Lock your screen using `Ctrl + Alt + L`
- Or click the lock icon in the system tray
- Your new wallpaper should appear on the lock screen

## Alternative Quick Method

### Using KDE's Built-in Tools

1. **Open a terminal** (`Ctrl + Alt + T`)

2. **Set lock screen wallpaper directly**:
   ```bash
   kwriteconfig6 --file kscreenlockerrc --group Greeter --key WallpaperPlugin "org.kde.image"
   kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "file:///home/YOUR_USERNAME/Pictures/WallyHaze/wallpaper_name.jpg"
   ```

3. **Replace** `YOUR_USERNAME` and `wallpaper_name.jpg` with actual values

4. **Restart lock screen service**:
   ```bash
   systemctl --user restart plasma-kscreen_backend
   ```

## Troubleshooting

### Lock Screen Wallpaper Not Changing?

1. **Check file permissions**: Make sure the wallpaper file is readable
   ```bash
   chmod 644 ~/Pictures/WallyHaze/*.jpg
   chmod 644 ~/Pictures/WallyHaze/*.png
   ```

2. **Verify config file**: Check if the setting was applied
   ```bash
   cat ~/.config/kscreenlockerrc
   ```

3. **Use absolute paths**: Ensure you're using full file paths starting with `/home/`

4. **Restart KDE session**: Log out and log back in

5. **Check KDE version**: Some settings differ between KDE 5 and KDE 6
   ```bash
   plasmashell --version
   ```

### Still Not Working?

1. **Desktop wallpaper but not lock screen**: This is common - desktop and lock screen use different settings in KDE

2. **Try the KDE Wallpaper Engine**: Some themes override lock screen settings

3. **Check for theme conflicts**: Disable any custom lock screen themes temporarily

4. **Reset lock screen settings**:
   ```bash
   rm ~/.config/kscreenlockerrc
   # Then reconfigure through System Settings
   ```

## File Locations

- **Wallpapers saved by WallyHaze**: `~/Pictures/WallyHaze/`
- **KDE lock screen config**: `~/.config/kscreenlockerrc`
- **Desktop wallpaper config**: `~/.config/plasma-org.kde.plasma.desktop-appletsrc`

## Supported Formats

KDE supports these image formats for lock screen wallpapers:
- JPEG (.jpg, .jpeg)
- PNG (.png)
- WEBP (.webp)
- BMP (.bmp)
- GIF (.gif) - static only

## Tips

- **Higher resolution is better**: Use wallpapers that match or exceed your screen resolution
- **Aspect ratio matters**: Choose wallpapers that match your screen's aspect ratio to avoid stretching
- **File size**: Large files (>10MB) may cause slower lock screen loading
- **Multiple monitors**: You may need to set wallpapers for each monitor separately

---

## Quick Reference Commands

```bash
# Check KDE version
plasmashell --version

# Set lock screen wallpaper (KDE 6)
kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "file:///path/to/wallpaper.jpg"

# Set lock screen wallpaper (KDE 5)
kwriteconfig5 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "file:///path/to/wallpaper.jpg"

# Test lock screen
loginctl lock-session

# View current lock screen config
cat ~/.config/kscreenlockerrc | grep Image
```

---

If you continue to have issues, check the WallyHaze console output when setting wallpapers, or file an issue on the project repository.