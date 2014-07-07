#include <QApplication>
#include <QQmlApplicationEngine>

#include "filter.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    filter *eventFilter = new filter;
    app.installEventFilter(eventFilter);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));
    QObject *rootObject = engine.rootObjects().first();

    QObject::connect(eventFilter, SIGNAL(ctrlPressed()), rootObject, SLOT(ctrlKeyPressed()));
    QObject::connect(eventFilter, SIGNAL(ctrlReleased()), rootObject, SLOT(ctrlKeyReleased()));

    return app.exec();
}
