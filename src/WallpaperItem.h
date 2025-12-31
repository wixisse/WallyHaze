#ifndef WALLPAPERITEM_H
#define WALLPAPERITEM_H

#include <QWidget>
#include <QLabel>
#include <QJsonObject>

class WallhavenAPI;

class WallpaperItem : public QWidget
{
    Q_OBJECT

public:
    explicit WallpaperItem(const QJsonObject &data, WallhavenAPI *api, QWidget *parent = nullptr);

protected:
    void mousePressEvent(QMouseEvent *event) override;

private slots:
    void onClicked();

private:
    QJsonObject wallpaperData;
    WallhavenAPI *api;
    QLabel *imageLabel;
    QLabel *resolutionLabel;
};

#endif // WALLPAPERITEM_H