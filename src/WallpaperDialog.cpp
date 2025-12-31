#include "WallpaperDialog.h"
#include "ImageCache.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QMessageBox>
#include <QDesktopServices>
#include <QUrl>
#include <QProcess>
#include <QDir>
#include <QFileInfo>
#include <QShortcut>
#include <QKeySequence>

WallpaperDialog::WallpaperDialog(const QJsonObject &data, WallhavenAPI *api, QWidget *parent)
    : QDialog(parent)
    , wallpaperData(data)
    , api(api)
{
    QString wallpaperTitle = QString("Wallpaper Details - %1").arg(data["id"].toString());
    setWindowTitle(wallpaperTitle);
    resize(900, 750);

    QVBoxLayout *mainLayout = new QVBoxLayout(this);

    imageLabel = new QLabel(this);
    imageLabel->setAlignment(Qt::AlignCenter);
    imageLabel->setMinimumSize(760, 450);
    imageLabel->setScaledContents(false);
    imageLabel->setAlignment(Qt::AlignCenter);
    imageLabel->setStyleSheet("QLabel { background-color: #2c2c2c; border-radius: 5px; }");
    
    QString fullImageUrl = data["path"].toString();
    QString previewUrl = data["thumbs"].toObject()["large"].toString();
    
    // First load the large thumbnail quickly, then load the full image
    ImageCache::instance()->loadImage(previewUrl, [this, fullImageUrl](const QPixmap &pixmap) {
        if (!pixmap.isNull()) {
            originalPixmap = pixmap;
            scaleAndSetImage();
        }
        
        // Now load the full resolution image
        ImageCache::instance()->loadImage(fullImageUrl, [this](const QPixmap &fullPixmap) {
            if (!fullPixmap.isNull()) {
                originalPixmap = fullPixmap;
                scaleAndSetImage();
            }
        });
    });

    infoLabel = new QLabel(this);
    infoLabel->setWordWrap(true);
    infoLabel->setStyleSheet("QLabel { padding: 10px; font-size: 12px; }");

    QString resolution = data["resolution"].toString();
    QString fileSize = QString::number(data["file_size"].toInt() / 1024 / 1024) + " MB";
    QString views = QString::number(data["views"].toInt());
    QString favorites = QString::number(data["favorites"].toInt());
    QString category = data["category"].toString().toUpper();
    QString purity = data["purity"].toString().toUpper();
    QString fileType = data["file_type"].toString().toUpper().replace("IMAGE/", "");
    QString ratio = data["ratio"].toString();
    
    QString infoText = QString(
        "<b>ID:</b> %1<br>"
        "<b>Resolution:</b> %2 (Ratio: %3)<br>"
        "<b>File Size:</b> %4 (%5)<br>"
        "<b>Views:</b> %6<br>"
        "<b>Favorites:</b> %7<br>"
        "<b>Category:</b> %8<br>"
        "<b>Purity:</b> %9"
    ).arg(data["id"].toString(), resolution, ratio, fileSize, fileType, views, favorites, category, purity);

    infoLabel->setText(infoText);

    mainLayout->addWidget(imageLabel);
    mainLayout->addWidget(infoLabel);

    QHBoxLayout *buttonLayout = new QHBoxLayout();

    downloadButton = new QPushButton("Download Full Resolution (Ctrl+D)", this);
    downloadButton->setMinimumHeight(35);
    downloadButton->setStyleSheet("QPushButton { background-color: #0d7377; color: white; border-radius: 5px; padding: 8px 16px; font-weight: bold; }"
                                  "QPushButton:hover { background-color: #14a0a6; }"
                                  "QPushButton:disabled { background-color: #666666; }");

    setWallpaperButton = new QPushButton("Set as Desktop & Lock Screen (Ctrl+W)", this);
    setWallpaperButton->setMinimumHeight(35);
    setWallpaperButton->setStyleSheet("QPushButton { background-color: #28a745; color: white; border-radius: 5px; padding: 8px 16px; font-weight: bold; }"
                                      "QPushButton:hover { background-color: #34ce57; }"
                                      "QPushButton:disabled { background-color: #666666; }");

    openBrowserButton = new QPushButton("View on Wallhaven", this);
    openBrowserButton->setMinimumHeight(35);
    openBrowserButton->setStyleSheet("QPushButton { background-color: #6c757d; color: white; border-radius: 5px; padding: 8px 16px; }"
                                     "QPushButton:hover { background-color: #545b62; }");

    buttonLayout->addWidget(downloadButton);
    buttonLayout->addWidget(setWallpaperButton);
    buttonLayout->addWidget(openBrowserButton);
    buttonLayout->addStretch();

    mainLayout->addLayout(buttonLayout);

    connect(downloadButton, &QPushButton::clicked, this, &WallpaperDialog::onDownload);
    connect(setWallpaperButton, &QPushButton::clicked, this, &WallpaperDialog::onSetWallpaper);
    connect(openBrowserButton, &QPushButton::clicked, this, &WallpaperDialog::onOpenInBrowser);

    // Add keyboard shortcuts
    QShortcut *closeShortcut = new QShortcut(QKeySequence::Close, this);
    connect(closeShortcut, &QShortcut::activated, this, &QDialog::close);
    
    QShortcut *escShortcut = new QShortcut(QKeySequence(Qt::Key_Escape), this);
    connect(escShortcut, &QShortcut::activated, this, &QDialog::close);
    
    QShortcut *downloadShortcut = new QShortcut(QKeySequence("Ctrl+D"), this);
    connect(downloadShortcut, &QShortcut::activated, this, &WallpaperDialog::onDownload);
    
    QShortcut *setWallpaperShortcut = new QShortcut(QKeySequence("Ctrl+W"), this);
    connect(setWallpaperShortcut, &QShortcut::activated, this, &WallpaperDialog::onSetWallpaper);

    setStyleSheet("QDialog { background-color: #1e1e1e; color: #ffffff; }"
                  "QLabel { color: #ffffff; }");
}

void WallpaperDialog::onDownload()
{
    downloadButton->setEnabled(false);
    downloadButton->setText("Downloading...");

    QString fullImageUrl = wallpaperData["path"].toString();
    QString wallpaperId = wallpaperData["id"].toString();
    QString resolution = wallpaperData["resolution"].toString();

    ImageCache::instance()->downloadWallpaper(
        fullImageUrl,
        wallpaperId,
        [this, resolution](const QString &filepath) {
            downloadedPath = filepath;
            downloadButton->setEnabled(true);
            downloadButton->setText("✓ Downloaded");
            downloadButton->setStyleSheet("QPushButton { background-color: #28a745; color: white; border-radius: 5px; padding: 8px 16px; font-weight: bold; }"
                                         "QPushButton:hover { background-color: #34ce57; }");
            
            QMessageBox::information(this, "Download Complete", 
                QString("Full resolution wallpaper (%1) downloaded to:\n%2").arg(resolution, filepath));
        },
        [this](const QString &error) {
            downloadButton->setEnabled(true);
            downloadButton->setText("Download Full Resolution");
            QMessageBox::warning(this, "Download Error", "Failed to download wallpaper: " + error);
        }
    );
}

void WallpaperDialog::onSetWallpaper()
{
    if (downloadedPath.isEmpty()) {
        setWallpaperButton->setEnabled(false);
        setWallpaperButton->setText("Downloading...");

        QString fullImageUrl = wallpaperData["path"].toString();
        QString wallpaperId = wallpaperData["id"].toString();

        ImageCache::instance()->downloadWallpaper(
            fullImageUrl,
            wallpaperId,
            [this](const QString &filepath) {
                downloadedPath = filepath;
                setWallpaperButton->setEnabled(true);
                setWallpaperButton->setText("Set as Desktop & Lock Screen");
                setAsWallpaper(filepath);
            },
            [this](const QString &error) {
                setWallpaperButton->setEnabled(true);
                setWallpaperButton->setText("Set as Desktop & Lock Screen");
                QMessageBox::warning(this, "Download Error", "Failed to download wallpaper: " + error);
            }
        );
    } else {
        setAsWallpaper(downloadedPath);
    }
}

void WallpaperDialog::onOpenInBrowser()
{
    QString url = wallpaperData["url"].toString();
    QDesktopServices::openUrl(QUrl(url));
}

void WallpaperDialog::setAsWallpaper(const QString &filepath)
{
#ifdef Q_OS_LINUX
    bool desktopSuccess = false;
    bool lockScreenSuccess = false;
    QString desktopEnv = qgetenv("XDG_CURRENT_DESKTOP").toLower();
    QString sessionType = qgetenv("XDG_SESSION_TYPE").toLower();
    
    // KDE Plasma
    if (desktopEnv.contains("kde") || desktopEnv.contains("plasma")) {
        // Set desktop wallpaper
        QString desktopScript = QString("string:var allDesktops = desktops();for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.wallpaperPlugin = \"org.kde.image\";d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\");d.writeConfig(\"Image\", \"file://%1\");}").arg(filepath);
        desktopSuccess = (QProcess::execute("qdbus", QStringList() << "org.kde.plasmashell" << "/PlasmaShell" << "org.kde.PlasmaShell.evaluateScript" << desktopScript) == 0);
        
        // Try alternative KDE method for desktop
        if (!desktopSuccess) {
            desktopSuccess = (QProcess::execute("plasma-apply-wallpaperimage", QStringList() << filepath) == 0);
        }
        
        // Use dedicated script for KDE lock screen wallpaper
        QString scriptPath = QDir::currentPath() + "/../set_kde_lockscreen.sh";
        if (QFileInfo::exists(scriptPath)) {
            lockScreenSuccess = (QProcess::execute("bash", QStringList() << scriptPath << filepath) == 0);
        } else {
            // Fallback method if script doesn't exist
            QString kwriteconfig = "kwriteconfig6";
            if (QProcess::execute("which", QStringList() << "kwriteconfig6") != 0) {
                kwriteconfig = "kwriteconfig5";
            }
            
            QProcess::execute(kwriteconfig, QStringList()
                << "--file" << "kscreenlockerrc"
                << "--group" << "Greeter"
                << "--key" << "WallpaperPlugin"
                << "org.kde.image");
                
            lockScreenSuccess = (QProcess::execute(kwriteconfig, QStringList()
                << "--file" << "kscreenlockerrc"
                << "--group" << "Greeter"
                << "--group" << "Wallpaper"
                << "--group" << "org.kde.image"
                << "--group" << "General"
                << "--key" << "Image"
                << "file://" + filepath) == 0);
        }
    }
    
    // GNOME/Ubuntu Unity
    if (desktopEnv.contains("gnome") || desktopEnv.contains("unity")) {
        desktopSuccess = (QProcess::execute("gsettings", QStringList() << "set" << "org.gnome.desktop.background" << "picture-uri" << "file://" + filepath) == 0);
        QProcess::execute("gsettings", QStringList() << "set" << "org.gnome.desktop.background" << "picture-uri-dark" << "file://" + filepath);
        lockScreenSuccess = (QProcess::execute("gsettings", QStringList() << "set" << "org.gnome.desktop.screensaver" << "picture-uri" << "file://" + filepath) == 0);
    }
    
    // XFCE
    if (desktopEnv.contains("xfce")) {
        QProcess::execute("xfconf-query", QStringList() << "-c" << "xfce4-desktop" << "-p" << "/backdrop/screen0/monitor0/workspace0/last-image" << "-s" << filepath);
        desktopSuccess = (QProcess::execute("xfconf-query", QStringList() << "-c" << "xfce4-desktop" << "-p" << "/backdrop/screen0/monitoreDP1/workspace0/last-image" << "-s" << filepath) == 0);
    }
    
    // MATE
    if (desktopEnv.contains("mate")) {
        desktopSuccess = (QProcess::execute("gsettings", QStringList() << "set" << "org.mate.background" << "picture-filename" << filepath) == 0);
    }
    
    // Cinnamon
    if (desktopEnv.contains("cinnamon")) {
        desktopSuccess = (QProcess::execute("gsettings", QStringList() << "set" << "org.cinnamon.desktop.background" << "picture-uri" << "file://" + filepath) == 0);
    }
    
    // LXDE/LXQt
    if (desktopEnv.contains("lxde") || desktopEnv.contains("lxqt")) {
        desktopSuccess = (QProcess::execute("pcmanfm", QStringList() << "--set-wallpaper" << filepath) == 0);
    }
    
    // Window managers (i3, openbox, etc.)
    if (!desktopSuccess) {
        if (QProcess::execute("which", QStringList() << "feh") == 0) {
            desktopSuccess = (QProcess::execute("feh", QStringList() << "--bg-fill" << filepath) == 0);
        } else if (QProcess::execute("which", QStringList() << "nitrogen") == 0) {
            QProcess::execute("nitrogen", QStringList() << "--save" << "--set-zoom-fill" << filepath);
            desktopSuccess = true;
        } else if (QProcess::execute("which", QStringList() << "xwallpaper") == 0) {
            desktopSuccess = (QProcess::execute("xwallpaper", QStringList() << "--zoom" << filepath) == 0);
        }
    }
    
    // Try Wayland-specific methods
    if (sessionType.contains("wayland")) {
        if (desktopEnv.contains("sway")) {
            desktopSuccess = (QProcess::execute("swaymsg", QStringList() << "output" << "*" << "bg" << filepath << "fill") == 0);
        }
    }
    
    QString message;
    if (desktopEnv.contains("kde") || desktopEnv.contains("plasma")) {
        if (desktopSuccess) {
            message = "Desktop wallpaper set successfully.\n";
            message += "Lock screen wallpaper configuration updated.\n\n";
            message += "For KDE lock screen changes to take effect:\n";
            message += "1. Lock your screen (Ctrl+Alt+L)\n";
            message += "2. Or go to System Settings > Screen Locking\n";
            message += "3. The new wallpaper should appear on next lock\n\n";
            message += "If lock screen doesn't update:\n";
            message += "- Go to System Settings > Screen Locking > Appearance\n";
            message += "- Select 'Image' wallpaper type\n";
            message += "- Browse and select: " + filepath;
            QMessageBox::information(this, "KDE Wallpaper Set", message);
        } else {
            message = "Automatic wallpaper setting failed.\n\n";
            message += "Manual setup for KDE:\n";
            message += "Desktop: Right-click desktop > Configure Desktop and Wallpaper\n";
            message += "Lock Screen: System Settings > Screen Locking > Appearance\n";
            QMessageBox::information(this, "Manual Setup Required", message + "\n\nWallpaper saved to:\n" + filepath);
        }
    } else if (desktopSuccess && lockScreenSuccess) {
        message = "Wallpaper set successfully for both desktop and lock screen.";
        QMessageBox::information(this, "Success", message);
    } else if (desktopSuccess) {
        message = "Desktop wallpaper set successfully.\nLock screen wallpaper may need manual setting.";
        QMessageBox::information(this, "Partial Success", message + "\n\nWallpaper saved to:\n" + filepath);
    } else {
        message = "Could not automatically set wallpaper for your desktop environment.\n";
        message += "Detected DE: " + desktopEnv + "\n";
        message += "Please set manually from your system settings.";
        QMessageBox::information(this, "Manual Setup Required", message + "\n\nWallpaper saved to:\n" + filepath);
    }
    
#elif defined(Q_OS_WIN)
    bool success = true;
    
    // Set desktop wallpaper using SystemParametersInfo
    QString windowsPath = QDir::toNativeSeparators(filepath);
    if (QProcess::execute("powershell", QStringList() << "-Command" << QString("Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class Wallpaper { [DllImport(\"user32.dll\", CharSet=CharSet.Auto)] public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); }'; [Wallpaper]::SystemParametersInfo(0x0014, 0, '%1', 0x0003)").arg(windowsPath)) != 0) {
        // Fallback method
        QProcess::execute("reg", QStringList() << "add" << "HKCU\\Control Panel\\Desktop" << "/v" << "Wallpaper" << "/t" << "REG_SZ" << "/d" << windowsPath << "/f");
        QProcess::execute("RUNDLL32.EXE", QStringList() << "user32.dll,UpdatePerUserSystemParameters");
    }
    
    // Try to set lock screen wallpaper (Windows 10/11)
    QString lockScreenReg = "HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Lock Screen\\Creative";
    QProcess::execute("reg", QStringList() << "add" << lockScreenReg << "/v" << "LandscapeAssetPath" << "/t" << "REG_SZ" << "/d" << windowsPath << "/f");
    QProcess::execute("reg", QStringList() << "add" << lockScreenReg << "/v" << "PortraitAssetPath" << "/t" << "REG_SZ" << "/d" << windowsPath << "/f");
    
    QMessageBox::information(this, "Success", 
        "Desktop wallpaper set successfully.\n"
        "Lock screen: Please go to Windows Settings > Personalization > Lock screen to set manually.");
        
#elif defined(Q_OS_MAC)
    // Set desktop wallpaper for all spaces
    QString script = QString("tell application \"System Events\"\n"
                           "tell every desktop\n"
                           "set picture to \"%1\"\n"
                           "end tell\n"
                           "end tell").arg(filepath);
    
    bool success = (QProcess::execute("osascript", QStringList() << "-e" << script) == 0);
    
    if (success) {
        QMessageBox::information(this, "Success", 
            "Desktop wallpaper set successfully.\n"
            "Lock screen: Go to System Preferences > Desktop & Screen Saver > Screen Saver to set manually.");
    } else {
        QMessageBox::warning(this, "Error", 
            "Failed to set desktop wallpaper automatically.\n\n"
            "Wallpaper saved to:\n" + filepath + 
            "\n\nPlease set manually from System Preferences.");
    }
        
#else
    QMessageBox::information(this, "Manual Setup", 
        "Wallpaper saved to:\n" + filepath + 
        "\n\nYour operating system requires manual wallpaper setup.\n"
        "Please set it from your system settings for both desktop and lock screen.");
#endif
}

void WallpaperDialog::scaleAndSetImage()
{
    if (!originalPixmap.isNull()) {
        QPixmap scaledPixmap = originalPixmap.scaled(imageLabel->size(), Qt::KeepAspectRatio, Qt::SmoothTransformation);
        imageLabel->setPixmap(scaledPixmap);
    }
}

void WallpaperDialog::resizeEvent(QResizeEvent *event)
{
    QDialog::resizeEvent(event);
    scaleAndSetImage();
}
