# Building WallyHaze for Windows

This guide explains how to build WallyHaze for Windows using cross-compilation or native Windows builds.

## Method 1: Cross-Compilation on Linux (Recommended)

### Prerequisites

#### Fedora/RHEL/CentOS
```bash
sudo dnf install mingw64-gcc mingw64-gcc-c++ mingw64-qt6-qtbase-devel mingw64-qt6-qttools mingw64-filesystem
```

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64 qt6-base-dev-tools
# For Qt6 MinGW packages, you may need to add additional repositories or build Qt6 from source
```

#### Arch Linux
```bash
sudo pacman -S mingw-w64-gcc mingw-w64-qt6-base
```

### Building

1. **Clone and prepare the project**:
   ```bash
   git clone <repository-url>
   cd WallyHaze
   ```

2. **Run the Windows build script**:
   ```bash
   chmod +x build_windows.sh
   ./build_windows.sh
   ```

3. **The script will**:
   - Cross-compile WallyHaze.exe
   - Copy required Qt6 and MinGW DLLs
   - Create a portable Windows package
   - Generate installation files

4. **Output**: `WallyHaze-Windows-1.0.0.zip` ready for distribution

## Method 2: Native Windows Build

### Prerequisites

1. **Install Qt6 for Windows**:
   - Download Qt6 installer from https://qt.io/download
   - Install Qt6.5+ with MinGW 64-bit compiler
   - Add Qt6 bin directory to PATH

2. **Install CMake**:
   - Download from https://cmake.org/download/
   - Or use winget: `winget install Kitware.CMake`

3. **Install Git** (if not already installed):
   - Download from https://git-scm.com/
   - Or use winget: `winget install Git.Git`

### Building on Windows

1. **Open Command Prompt or PowerShell**

2. **Clone the repository**:
   ```cmd
   git clone <repository-url>
   cd WallyHaze
   ```

3. **Create build directory**:
   ```cmd
   mkdir build-windows
   cd build-windows
   ```

4. **Configure with CMake**:
   ```cmd
   cmake .. -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
   ```

5. **Build**:
   ```cmd
   mingw32-make -j4
   ```

6. **Deploy Qt dependencies**:
   ```cmd
   windeployqt6 WallyHaze.exe
   ```

## Method 3: Visual Studio Build

### Prerequisites

1. **Install Visual Studio 2019/2022** with C++ development tools
2. **Install Qt6 with MSVC compiler**
3. **Install CMake** (can be installed via Visual Studio Installer)

### Building

1. **Open Visual Studio Developer Command Prompt**

2. **Configure with CMake**:
   ```cmd
   mkdir build-vs
   cd build-vs
   cmake .. -G "Visual Studio 16 2019" -A x64 -DCMAKE_BUILD_TYPE=Release
   ```

3. **Build**:
   ```cmd
   cmake --build . --config Release
   ```

4. **Deploy**:
   ```cmd
   windeployqt6 Release\WallyHaze.exe
   ```

## Creating Windows Installer

### Using NSIS (Nullsoft Scriptable Install System)

1. **Install NSIS**:
   - Download from https://nsis.sourceforge.io/
   - Or use chocolatey: `choco install nsis`

2. **Use the generated installer script**:
   ```cmd
   makensis wallyhaze-installer.nsi
   ```

3. **Output**: `WallyHaze-1.0.0-Setup.exe`

### Using Inno Setup

1. **Install Inno Setup**:
   - Download from https://jrsoftware.org/isinfo.php

2. **Create installer script** (`wallyhaze-setup.iss`):
   ```ini
   [Setup]
   AppName=WallyHaze
   AppVersion=1.0.0
   DefaultDirName={pf}\WallyHaze
   DefaultGroupName=WallyHaze
   OutputBaseFilename=WallyHaze-Setup
   Compression=lzma2
   SolidCompression=yes

   [Files]
   Source: "WallyHaze.exe"; DestDir: "{app}"
   Source: "*.dll"; DestDir: "{app}"
   Source: "platforms\*"; DestDir: "{app}\platforms"
   Source: "imageformats\*"; DestDir: "{app}\imageformats"

   [Icons]
   Name: "{group}\WallyHaze"; Filename: "{app}\WallyHaze.exe"
   Name: "{commondesktop}\WallyHaze"; Filename: "{app}\WallyHaze.exe"
   ```

3. **Compile**: Open the `.iss` file in Inno Setup and compile

## Troubleshooting

### Common Issues

1. **Qt6 not found**:
   - Ensure Qt6 is installed and in PATH
   - Set `CMAKE_PREFIX_PATH` to Qt6 installation directory

2. **Missing DLLs**:
   - Use `windeployqt6` to copy required DLLs
   - Check dependency walker for missing libraries

3. **SSL/Network issues**:
   - Ensure OpenSSL DLLs are included
   - Qt6 usually includes SSL support

4. **Plugin loading errors**:
   - Create `qt.conf` file with plugin paths
   - Ensure platform plugins are copied

### Example qt.conf
```ini
[Paths]
Plugins = .
```

## Distribution Checklist

- [ ] WallyHaze.exe built and working
- [ ] All Qt6 DLLs copied
- [ ] Platform plugins included
- [ ] Image format plugins included
- [ ] qt.conf created
- [ ] README and license included
- [ ] Installer created (optional)
- [ ] Tested on clean Windows system

## File Structure for Distribution

```
WallyHaze-Windows/
├── WallyHaze.exe
├── Qt6Core.dll
├── Qt6Gui.dll
├── Qt6Widgets.dll
├── Qt6Network.dll
├── platforms/
│   └── qwindows.dll
├── imageformats/
│   ├── qjpeg.dll
│   ├── qpng.dll
│   └── qwebp.dll
├── qt.conf
├── README-Windows.txt
└── LICENSE.txt
```

## Performance Optimization

### Static Linking (Advanced)

For a single executable without DLL dependencies:

1. **Build Qt6 statically** (time-consuming):
   ```cmd
   configure -static -release -no-opengl -skip qtwebengine
   ```

2. **Configure CMake for static build**:
   ```cmd
   cmake .. -DCMAKE_BUILD_TYPE=Release -DQt6_DIR=C:\Qt\6.x\msvc2019_64_static\lib\cmake\Qt6
   ```

### Size Optimization

- Use `strip` or link with `-s` flag to remove debug symbols
- Enable LTO (Link Time Optimization): `-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON`
- Use UPX for executable compression (optional)

---

**Note**: Windows builds require proper Qt6 setup and can be complex. The cross-compilation method on Linux is often easier and more reliable.