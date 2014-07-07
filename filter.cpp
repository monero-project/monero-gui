#include "filter.h"
#include <QKeyEvent>

filter::filter(QObject *parent) :
    QObject(parent)
{
    m_ctrlPressed = true;
}

bool filter::eventFilter(QObject *obj, QEvent *ev) {
    switch(ev->type()) {
    case QEvent::KeyPress: {
        QKeyEvent *ke = static_cast<QKeyEvent*>(ev);
        if(ke->key() == Qt::Key_Control) {
            emit ctrlPressed();
            m_ctrlPressed = true;
        }
    } break;
    case QEvent::KeyRelease: {
        QKeyEvent *ke = static_cast<QKeyEvent*>(ev);
        if(ke->key() == Qt::Key_Control) {
            emit ctrlReleased();
            m_ctrlPressed = false;
        }
    } break;
    default: break;
    }

    return QObject::eventFilter(obj, ev);
}
