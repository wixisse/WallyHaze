#include "ImageCache.h"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QDir>
#include <QStandardPaths>
#include <QFile>

ImageCache* ImageCache::m_instance = nullptr;

ImageCache::ImageCache(QObject *parent)
    : QObject(parent)
{
}

ImageCache* ImageCache::instance()
{
    if (!m_instance) {
        m_instance = new ImageCache();
    }
    return m_instance;
}

QString ImageCache::getWallpapersDirectory()
{
    QString picturesPath = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
    QString wallyhazePath = picturesPath + "/WallyHaze";

    QDir dir;
    if (!dir.exists(wallyhazePath)) {
        dir.mkpath(wallyhazePath);
    }

    return wallyhazePath;
}

void ImageCache::loadImage(const QString &url, std::function<void(const QPixmap&)> onLoaded)
{
    if (cache.contains(url)) {
        onLoaded(cache[url]);
        return;
    }

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::UserAgentHeader, "WallyHaze-Qt6/1.0");

    QNetworkReply *reply = manager.get(request);

    connect(reply, &QNetworkReply::finished, this, [this, reply, url, onLoaded]() {
        reply->deleteLater();

        if (reply->error() == QNetworkReply::NoError) {
            QByteArray data = reply->readAll();
            
            QPixmap pixmap;
            if (pixmap.loadFromData(data)) {
                cache[url] = pixmap;
                onLoaded(pixmap);
            }
        }
    });
}

void ImageCache::downloadWallpaper(const QString &url, const QString &wallpaperId,
                                  std::function<void(const QString&)> onSuccess,
                                  std::function<void(const QString&)> onError)
{
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::UserAgentHeader, "WallyHaze-Qt6/1.0");

    QNetworkReply *reply = manager.get(request);

    connect(reply, &QNetworkReply::finished, this, [this, reply, url, wallpaperId, onSuccess, onError]() {
        reply->deleteLater();

        if (reply->error() != QNetworkReply::NoError) {
            onError(reply->errorString());
            return;
        }

        QByteArray data = reply->readAll();

        QString extension = url.mid(url.lastIndexOf('.'));
        QString filename = wallpaperId + extension;
        QString filepath = getWallpapersDirectory() + "/" + filename;

        QFile file(filepath);
        if (file.open(QIODevice::WriteOnly)) {
            file.write(data);
            file.close();
            onSuccess(filepath);
        } else {
            onError("Failed to save file");
        }
    });
}
