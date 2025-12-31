#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QLineEdit>
#include <QPushButton>
#include <QComboBox>
#include <QLabel>
#include <QScrollArea>
#include <QScrollBar>
#include <QTimer>
#include <QJsonArray>

class WallhavenAPI;
class WallpaperGrid;

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void onSearchClicked();
    void onLoadMore();
    void onCategoryChanged(int index);
    void onPurityChanged(int index);
    void onSortingChanged(int index);
    void onScrollChanged(int value);
    void checkScrollPosition();

private:
    void setupUI();
    void loadWallpapers(bool append = false);
    void smoothScrollToPosition(int targetPosition);

    WallhavenAPI *api;
    WallpaperGrid *wallpaperGrid;
    QScrollArea *scrollArea;
    
    QLineEdit *searchInput;
    QPushButton *searchButton;
    QPushButton *loadMoreButton;
    QComboBox *categoryCombo;
    QComboBox *purityCombo;
    QComboBox *sortingCombo;
    QLabel *statusLabel;
    QLabel *loadingIndicator;
    QTimer *scrollDebounceTimer;
    
    int currentPage;
    bool isLoadingMore;
    bool hasMorePages;
};

#endif // MAINWINDOW_H