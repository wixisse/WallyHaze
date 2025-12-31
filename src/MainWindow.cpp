#include "MainWindow.h"
#include "WallpaperGrid.h"
#include "WallhavenAPI.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QGroupBox>
#include <QMessageBox>
#include <QTimer>
#include <QPropertyAnimation>
#include <QEasingCurve>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , currentPage(1)
{
    // Initialize loading state first
    isLoadingMore = false;
    hasMorePages = true;
    
    api = new WallhavenAPI(this);
    
    // Initialize scroll debounce timer
    scrollDebounceTimer = new QTimer(this);
    scrollDebounceTimer->setSingleShot(true);
    scrollDebounceTimer->setInterval(150); // 150ms debounce
    connect(scrollDebounceTimer, &QTimer::timeout, this, &MainWindow::checkScrollPosition);
    
    setupUI();
    
    // Delay initial loading to ensure UI is fully initialized
    QTimer::singleShot(100, this, [this]() {
        loadWallpapers();
    });
}

MainWindow::~MainWindow()
{
}

void MainWindow::setupUI()
{
    setWindowTitle("WallyHaze - Wallpaper Browser");
    resize(1200, 800);

    QWidget *centralWidget = new QWidget(this);
    setCentralWidget(centralWidget);

    QVBoxLayout *mainLayout = new QVBoxLayout(centralWidget);
    mainLayout->setSpacing(10);
    mainLayout->setContentsMargins(10, 10, 10, 10);

    QGroupBox *controlsGroup = new QGroupBox("Search & Filters", this);
    QVBoxLayout *controlsLayout = new QVBoxLayout(controlsGroup);

    QHBoxLayout *searchLayout = new QHBoxLayout();
    searchInput = new QLineEdit(this);
    searchInput->setPlaceholderText("Search wallpapers...");
    searchInput->setMinimumHeight(35);
    searchButton = new QPushButton("Search", this);
    searchButton->setMinimumHeight(35);
    searchButton->setMinimumWidth(100);
    searchLayout->addWidget(searchInput);
    searchLayout->addWidget(searchButton);

    QHBoxLayout *filtersLayout = new QHBoxLayout();

    categoryCombo = new QComboBox(this);
    categoryCombo->addItem("All Categories", "111");
    categoryCombo->addItem("General", "100");
    categoryCombo->addItem("Anime", "010");
    categoryCombo->addItem("People", "001");
    categoryCombo->setMinimumHeight(30);

    purityCombo = new QComboBox(this);
    purityCombo->addItem("SFW", "100");
    purityCombo->addItem("Sketchy", "010");
    purityCombo->addItem("SFW + Sketchy", "110");
    purityCombo->setMinimumHeight(30);

    sortingCombo = new QComboBox(this);
    sortingCombo->addItem("Date Added", "date_added");
    sortingCombo->addItem("Relevance", "relevance");
    sortingCombo->addItem("Random", "random");
    sortingCombo->addItem("Views", "views");
    sortingCombo->addItem("Favorites", "favorites");
    sortingCombo->addItem("Toplist", "toplist");
    sortingCombo->setMinimumHeight(30);
    sortingCombo->setCurrentIndex(0); // Default to Date Added

    filtersLayout->addWidget(new QLabel("Category:", this));
    filtersLayout->addWidget(categoryCombo, 1);
    filtersLayout->addWidget(new QLabel("Purity:", this));
    filtersLayout->addWidget(purityCombo, 1);
    filtersLayout->addWidget(new QLabel("Sorting:", this));
    filtersLayout->addWidget(sortingCombo, 1);

    controlsLayout->addLayout(searchLayout);
    controlsLayout->addLayout(filtersLayout);

    mainLayout->addWidget(controlsGroup);

    scrollArea = new QScrollArea(this);
    scrollArea->setWidgetResizable(true);
    scrollArea->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    scrollArea->setVerticalScrollBarPolicy(Qt::ScrollBarAsNeeded);

    wallpaperGrid = new WallpaperGrid(api, this);
    scrollArea->setWidget(wallpaperGrid);

    mainLayout->addWidget(scrollArea, 1);

    // Create and add loading indicator for infinite scroll
    loadingIndicator = new QLabel("Loading more wallpapers...", this);
    loadingIndicator->setAlignment(Qt::AlignCenter);
    loadingIndicator->setStyleSheet("QLabel { color: #ffffff; background-color: #2c2c2c; padding: 10px; border-radius: 5px; font-size: 14px; margin: 10px; }");
    loadingIndicator->setVisible(false);
    mainLayout->addWidget(loadingIndicator);

    // Connect scroll area to detect when user reaches bottom
    connect(scrollArea->verticalScrollBar(), &QScrollBar::valueChanged, this, &MainWindow::onScrollChanged);

    QHBoxLayout *bottomLayout = new QHBoxLayout();
    statusLabel = new QLabel("Ready - Latest wallpapers will load automatically", this);
    loadMoreButton = new QPushButton("Load More", this);
    loadMoreButton->setMinimumHeight(35);
    loadMoreButton->setMinimumWidth(150);
    bottomLayout->addWidget(statusLabel);
    bottomLayout->addStretch();
    bottomLayout->addWidget(loadMoreButton);

    mainLayout->addLayout(bottomLayout);

    connect(searchButton, &QPushButton::clicked, this, &MainWindow::onSearchClicked);
    connect(loadMoreButton, &QPushButton::clicked, this, &MainWindow::onLoadMore);
    connect(categoryCombo, QOverload<int>::of(&QComboBox::currentIndexChanged), this, &MainWindow::onCategoryChanged);
    connect(purityCombo, QOverload<int>::of(&QComboBox::currentIndexChanged), this, &MainWindow::onPurityChanged);
    connect(sortingCombo, QOverload<int>::of(&QComboBox::currentIndexChanged), this, &MainWindow::onSortingChanged);
    connect(searchInput, &QLineEdit::returnPressed, this, &MainWindow::onSearchClicked);
    
    // Enable smooth scrolling
    scrollArea->setVerticalScrollBarPolicy(Qt::ScrollBarAsNeeded);
    scrollArea->verticalScrollBar()->setSingleStep(20);
    scrollArea->verticalScrollBar()->setPageStep(100);
}

void MainWindow::loadWallpapers(bool append)
{
    if (isLoadingMore) {
        return; // Prevent multiple simultaneous requests
    }
    
    isLoadingMore = true;
    statusLabel->setText(append ? "Loading more wallpapers..." : "Loading wallpapers...");
    searchButton->setEnabled(false);
    loadMoreButton->setEnabled(false);
    
    // Show loading indicator for infinite scroll
    if (append) {
        loadingIndicator->setVisible(true);
    }

    QString query = searchInput->text();
    QString categories = categoryCombo->currentData().toString();
    QString purity = purityCombo->currentData().toString();
    QString sorting = sortingCombo->currentData().toString();

    api->searchWallpapers(query, categories, purity, sorting, currentPage,
        [this, append](const QJsonArray &wallpapers) {
            if (!append) {
                wallpaperGrid->clear();
            }
            wallpaperGrid->addWallpapers(wallpapers);
            
            int totalItems = wallpaperGrid->getItemCount();
            if (currentPage == 1 && !append) {
                statusLabel->setText(QString("Showing latest wallpapers - %1 loaded (sorted by date added)").arg(totalItems));
            } else {
                statusLabel->setText(QString("Loaded %1 wallpapers (Page %2) - scroll down for more").arg(totalItems).arg(currentPage));
            }
            
            searchButton->setEnabled(true);
            loadMoreButton->setEnabled(wallpapers.size() > 0); // Disable if no more wallpapers
            isLoadingMore = false;
            
            // If we got fewer than expected wallpapers, we might be at the end
            hasMorePages = wallpapers.size() >= 24; // Wallhaven typically returns 24 per page
            
            // Hide loading indicator
            loadingIndicator->setVisible(false);
            
            // Add smooth scroll animation when loading new content
            if (append && wallpapers.size() > 0) {
                QTimer::singleShot(100, this, [this]() {
                    smoothScrollToPosition(scrollArea->verticalScrollBar()->value() + 200);
                });
            }
        },
        [this](const QString &error) {
            statusLabel->setText("Error: " + error);
            searchButton->setEnabled(true);
            loadMoreButton->setEnabled(true);
            isLoadingMore = false;
            loadingIndicator->setVisible(false);
            QMessageBox::warning(this, "Error", "Failed to load wallpapers: " + error);
        }
    );
}

void MainWindow::onSearchClicked()
{
    currentPage = 1;
    loadWallpapers(false);
}

void MainWindow::onLoadMore()
{
    currentPage++;
    loadWallpapers(true);
}

void MainWindow::onCategoryChanged(int)
{
    currentPage = 1;
    loadWallpapers(false);
}

void MainWindow::onPurityChanged(int)
{
    currentPage = 1;
    loadWallpapers(false);
}

void MainWindow::onSortingChanged(int)
{
    currentPage = 1;
    hasMorePages = true;
    loadWallpapers(false);
}

void MainWindow::onScrollChanged(int value)
{
    if (isLoadingMore || !hasMorePages) {
        return;
    }
    
    // Debounce scroll events for better performance
    scrollDebounceTimer->start();
}

void MainWindow::checkScrollPosition()
{
    if (isLoadingMore || !hasMorePages) {
        return;
    }
    
    QScrollBar *scrollBar = scrollArea->verticalScrollBar();
    int maximum = scrollBar->maximum();
    int current = scrollBar->value();
    
    // Load more when user is within 300px of the bottom for smoother experience
    if (maximum > 0 && current >= maximum - 300) {
        currentPage++;
        loadWallpapers(true); // Append to existing wallpapers
    }
}

void MainWindow::smoothScrollToPosition(int targetPosition)
{
    QScrollBar *scrollBar = scrollArea->verticalScrollBar();
    
    QPropertyAnimation *animation = new QPropertyAnimation(scrollBar, "value");
    animation->setDuration(300); // 300ms smooth animation
    animation->setStartValue(scrollBar->value());
    animation->setEndValue(targetPosition);
    animation->setEasingCurve(QEasingCurve::OutCubic);
    
    connect(animation, &QPropertyAnimation::finished, animation, &QPropertyAnimation::deleteLater);
    animation->start();
}
