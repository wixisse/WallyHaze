#ifndef WALLPAPERDIALOG_H
#define WALLPAPERDIALOG_H

#include <QDialog>
#include <QLabel>
#include <QPushButton>
#include <QJsonObject>
#include <QPixmap>
#include <QResizeEvent>

class WallhavenAPI;

class WallpaperDialog : public QDialog
{
    Q_OBJECT

public:
    explicit WallpaperDialog(const QJsonObject &data, WallhavenAPI *api, QWidget *parent = nullptr);

private slots:
    void onDownload();
    void onSetWallpaper();
    void onOpenInBrowser();

protected:
    void resizeEvent(QResizeEvent *event) override;

private:
    void setAsWallpaper(const QString &filepath);
    void scaleAndSetImage();

    QJsonObject wallpaperData;
    WallhavenAPI *api;
    QLabel *imageLabel;
    QLabel *infoLabel;
    QPushButton *downloadButton;
    QPushButton *setWallpaperButton;
    QPushButton *openBrowserButton;
    QString downloadedPath;
    QPixmap originalPixmap;
};

#endif // WALLPAPERDIALOG_H