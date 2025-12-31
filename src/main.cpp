#include <QApplication>
#include "MainWindow.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setApplicationName("WallyHaze");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("WallyHaze");

    MainWindow window;
    window.show();

    return app.exec();
}
