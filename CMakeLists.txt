cmake_minimum_required(VERSION 3.16)
project(WallyHaze VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Network)

set(PROJECT_SOURCES
    src/main.cpp
    src/MainWindow.cpp
    src/MainWindow.h
    src/WallhavenAPI.cpp
    src/WallhavenAPI.h
    src/ImageCache.cpp
    src/ImageCache.h
    src/WallpaperGrid.cpp
    src/WallpaperGrid.h
    src/WallpaperItem.cpp
    src/WallpaperItem.h
    src/WallpaperDialog.cpp
    src/WallpaperDialog.h
)

add_executable(${PROJECT_NAME} ${PROJECT_SOURCES})

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Network
)

# Install icons
install(FILES
    wallyhaze-logo.svg
    icons/wallyhaze.svg
    icons/wallyhaze-16.svg
    icons/wallyhaze-32.svg
    icons/wallyhaze-64.svg
    icons/wallyhaze-256.svg
    DESTINATION share/icons/hicolor/scalable/apps
)

# Install desktop file
install(FILES wallyhaze.desktop
    DESTINATION share/applications
)

# Install appdata file
install(FILES wallyhaze.appdata.xml
    DESTINATION share/metainfo
)

install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
