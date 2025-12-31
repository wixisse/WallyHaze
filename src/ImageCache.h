#ifndef IMAGECACHE_H
#define IMAGECACHE_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QPixmap>
#include <QHash>
#include <functional>

class ImageCache : public QObject
{
    Q_OBJECT

public:
    static ImageCache* instance();

    void loadImage(const QString &url, std::function<void(const QPixmap&)> onLoaded);
    void downloadWallpaper(const QString &url, const QString &wallpaperId,
                          std::function<void(const QString&)> onSuccess,
                          std::function<void(const QString&)> onError);

private:
    explicit ImageCache(QObject *parent = nullptr);
    QString getWallpapersDirectory();

    static ImageCache* m_instance;
    QNetworkAccessManager manager;
    QHash<QString, QPixmap> cache;
};

#endif // IMAGECACHE_H