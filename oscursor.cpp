#include "oscursor.h"
#include <QCursor>
OSCursor::OSCursor(QObject *parent)
    : QObject(parent)
{
}
QPoint OSCursor::getPosition() const
{
    return QCursor::pos();
}
