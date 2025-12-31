#ifndef WALLHAVENAPI_H
#define WALLHAVENAPI_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QJsonArray>
#include <functional>

class WallhavenAPI : public QObject
{
    Q_OBJECT

public:
    explicit WallhavenAPI(QObject *parent = nullptr);

    void searchWallpapers(const QString &query, const QString &categories,
                         const QString &purity, const QString &sorting, int page,
                         std::function<void(const QJsonArray&)> onSuccess,
                         std::function<void(const QString&)> onError);

private:
    QNetworkAccessManager manager;
};

#endif // WALLHAVENAPI_H