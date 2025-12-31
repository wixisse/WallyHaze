#ifndef WALLPAPERGRID_H
#define WALLPAPERGRID_H

#include <QWidget>
#include <QGridLayout>
#include <QJsonArray>
#include <QList>

class WallhavenAPI;
class WallpaperItem;

class WallpaperGrid : public QWidget
{
    Q_OBJECT

public:
    explicit WallpaperGrid(WallhavenAPI *api, QWidget *parent = nullptr);

    void addWallpapers(const QJsonArray &wallpapers);
    void clear();
    int getItemCount() const;

protected:
    void resizeEvent(QResizeEvent *event) override;

private:
    void updateLayout();

    WallhavenAPI *api;
    QGridLayout *layout;
    QList<WallpaperItem*> items;
};

#endif // WALLPAPERGRID_H