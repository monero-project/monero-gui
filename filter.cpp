#include "filter.h"
#include <QKeyEvent>
#include <QDebug>

filter::filter(QObject *parent) :
    QObject(parent)
{
    m_altPressed = true;
}

bool filter::eventFilter(QObject *obj, QEvent *ev) {
    switch(ev->type()) {
    case QEvent::KeyPress: {
        QKeyEvent *ke = static_cast<QKeyEvent*>(ev);
        if(ke->key() == Qt::Key_Alt) {
            emit altPressed();
            m_altPressed = true;
        } else {
            QKeySequence ks(ke->modifiers() + ke->key());
            QString sks = ks.toString();
            emit sequencePressed(sks);
        }
    } break;
    case QEvent::KeyRelease: {
        QKeyEvent *ke = static_cast<QKeyEvent*>(ev);
        if(ke->key() == Qt::Key_Alt) {
            emit altReleased();
            m_altPressed = false;
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
