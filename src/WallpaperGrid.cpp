#include "WallpaperGrid.h"
#include "WallpaperItem.h"
#include <QJsonObject>
#include <QResizeEvent>

WallpaperGrid::WallpaperGrid(WallhavenAPI *api, QWidget *parent)
    : QWidget(parent)
    , api(api)
{
    layout = new QGridLayout(this);
    layout->setSpacing(10);
    layout->setContentsMargins(0, 0, 0, 0);
    setLayout(layout);
}

void WallpaperGrid::addWallpapers(const QJsonArray &wallpapers)
{
    for (const QJsonValue &value : wallpapers) {
        QJsonObject wallpaper = value.toObject();
        WallpaperItem *item = new WallpaperItem(wallpaper, api, this);
        items.append(item);
    }

    updateLayout();
}

void WallpaperGrid::clear()
{
    for (WallpaperItem *item : items) {
        layout->removeWidget(item);
        item->deleteLater();
    }
    items.clear();
}

int WallpaperGrid::getItemCount() const
{
    return items.size();
}

void WallpaperGrid::resizeEvent(QResizeEvent *event)
{
    QWidget::resizeEvent(event);
    updateLayout();
}

void WallpaperGrid::updateLayout()
{
    int columns = qMax(1, width() / 300);

    // Clear existing layout
    for (int i = 0; i < items.size(); ++i) {
        layout->removeWidget(items[i]);
    }

    for (int i = 0; i < items.size(); ++i) {
        int row = i / columns;
        int col = i % columns;
        layout->addWidget(items[i], row, col);
    }
    
    // Set minimum size for the grid
    int rows = (items.size() + columns - 1) / columns;
    setMinimumSize(columns * 300, rows * 220);
}
