#include "WallpaperItem.h"
#include "WallpaperDialog.h"
#include "ImageCache.h"
#include <QVBoxLayout>
#include <QJsonObject>
#include <QMouseEvent>

WallpaperItem::WallpaperItem(const QJsonObject &data, WallhavenAPI *api, QWidget *parent)
    : QWidget(parent)
    , wallpaperData(data)
    , api(api)
{
    setFixedSize(280, 200);
    setCursor(Qt::PointingHandCursor);

    QVBoxLayout *layout = new QVBoxLayout(this);
    layout->setContentsMargins(5, 5, 5, 5);
    layout->setSpacing(5);

    imageLabel = new QLabel(this);
    imageLabel->setFixedSize(270, 170);
    imageLabel->setScaledContents(true);
    imageLabel->setStyleSheet("QLabel { background-color: #2c2c2c; border-radius: 5px; }");

    resolutionLabel = new QLabel(this);
    resolutionLabel->setAlignment(Qt::AlignCenter);
    resolutionLabel->setStyleSheet("QLabel { color: #ffffff; font-size: 11px; }");

    layout->addWidget(imageLabel);
    layout->addWidget(resolutionLabel);

    QString thumbUrl = data["thumbs"].toObject()["small"].toString();
    QString resolution = data["resolution"].toString();

    resolutionLabel->setText(resolution);

    ImageCache::instance()->loadImage(thumbUrl, [this](const QPixmap &pixmap) {
        imageLabel->setPixmap(pixmap);
    });

    setStyleSheet("WallpaperItem { background-color: #1e1e1e; border-radius: 8px; }"
                  "WallpaperItem:hover { background-color: #2a2a2a; }");
}

void WallpaperItem::onClicked()
{
    WallpaperDialog dialog(wallpaperData, api, this);
    dialog.exec();
}

void WallpaperItem::mousePressEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton) {
        onClicked();
    }
    QWidget::mousePressEvent(event);
}
