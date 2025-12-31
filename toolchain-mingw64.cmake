# CMake Toolchain file for cross-compiling WallyHaze for Windows
# Usage: cmake -DCMAKE_TOOLCHAIN_FILE=toolchain-mingw64.cmake ..

set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

# Specify the cross compiler
set(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc)
set(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++)
set(CMAKE_RC_COMPILER x86_64-w64-mingw32-windres)

# Where to find the target environment
set(CMAKE_FIND_ROOT_PATH
    /usr/x86_64-w64-mingw32
    /usr/local/x86_64-w64-mingw32
)

# Search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# Search for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Set Qt6 path for Windows
set(Qt6_DIR "/usr/x86_64-w64-mingw32/lib/cmake/Qt6")

# Windows specific settings
set(CMAKE_WIN32_EXECUTABLE ON)
set(CMAKE_EXECUTABLE_SUFFIX ".exe")

# Compiler flags for Windows
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -static-libgcc -static-libstdc++")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static -static-libgcc -static-libstdc++ -Wl,--subsystem,windows")
