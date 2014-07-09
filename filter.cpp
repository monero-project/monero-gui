#include "filter.h"
#include <QKeyEvent>
#include <QDebug>

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
        } else {
            QKeySequence ks(ke->modifiers() + ke->key());
            QString sks = ks.toString();
            emit sequencePressed(sks);
        }
    } break;
    case QEvent::KeyRelease: {
        QKeyEvent *ke = static_cast<QKeyEvent*>(ev);
        if(ke->key() == Qt::Key_Control) {
            emit ctrlReleased();
            m_ctrlPressed = false;
        }
    } break;
    case QEvent::MouseButtonPress: {
        QMouseEvent *me = static_cast<QMouseEvent*>(ev);
        emit mousePressed(QVariant::fromValue<QObject*>(obj), me->x(), me->y());
        m_mousePressed = true;
    } break;
    case QEvent::MouseButtonRelease: {
        QMouseEvent *me = static_cast<QMouseEvent*>(ev);
        emit mouseReleased(QVariant::fromValue<QObject*>(obj), me->x(), me->y());
        m_mousePressed = false;
    } break;
    default: break;
    }

    return QObject::eventFilter(obj, ev);
}
