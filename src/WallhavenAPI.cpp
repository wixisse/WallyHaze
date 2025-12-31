#include "WallhavenAPI.h"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QUrlQuery>

WallhavenAPI::WallhavenAPI(QObject *parent)
    : QObject(parent)
{
}

void WallhavenAPI::searchWallpapers(const QString &query, const QString &categories,
                                   const QString &purity, const QString &sorting, int page,
                                   std::function<void(const QJsonArray&)> onSuccess,
                                   std::function<void(const QString&)> onError)
{
    QUrl url("https://wallhaven.cc/api/v1/search");
    QUrlQuery urlQuery;

    if (!query.isEmpty()) {
        urlQuery.addQueryItem("q", query);
    }
    urlQuery.addQueryItem("categories", categories);
    urlQuery.addQueryItem("purity", purity);
    urlQuery.addQueryItem("sorting", sorting);
    urlQuery.addQueryItem("page", QString::number(page));

    url.setQuery(urlQuery);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::UserAgentHeader, "WallyHaze-Qt6/1.0");

    QNetworkReply *reply = manager.get(request);

    connect(reply, &QNetworkReply::finished, this, [reply, onSuccess, onError]() {
        reply->deleteLater();

        if (reply->error() != QNetworkReply::NoError) {
            onError(reply->errorString());
            return;
        }

        QByteArray data = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(data);

        if (!doc.isObject()) {
            onError("Invalid response format");
            return;
        }

        QJsonObject obj = doc.object();
        if (!obj.contains("data")) {
            onError("No data in response");
            return;
        }

        QJsonArray wallpapers = obj["data"].toArray();
        onSuccess(wallpapers);
    });
}
