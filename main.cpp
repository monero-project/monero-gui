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

    QObject::connect(eventFilter, SIGNAL(altPressed()), rootObject, SLOT(altKeyPressed()));
    QObject::connect(eventFilter, SIGNAL(altReleased()), rootObject, SLOT(altKeyReleased()));
    QObject::connect(eventFilter, SIGNAL(sequencePressed(QVariant)), rootObject, SLOT(sequencePressed(QVariant)));
    QObject::connect(eventFilter, SIGNAL(mousePressed(QVariant,QVariant,QVariant)), rootObject, SLOT(mousePressed(QVariant,QVariant,QVariant)));
    QObject::connect(eventFilter, SIGNAL(mouseReleased(QVariant,QVariant,QVariant)), rootObject, SLOT(mouseReleased(QVariant,QVariant,QVariant)));

    return app.exec();
}
