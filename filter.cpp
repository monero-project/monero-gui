#include "filter.h"
#include <QKeyEvent>
#include <QDebug>

filter::filter(QObject *parent) :
    QObject(parent)
{
    m_tabPressed = false;
}

bool filter::eventFilter(QObject *obj, QEvent *ev) {
    switch(ev->type()) {
    case QEvent::KeyPress: {
        QKeyEvent *ke = static_cast<QKeyEvent*>(ev);
        if(ke->key() == Qt::Key_Tab || ke->key() == Qt::Key_Backtab) {
            if(m_tabPressed)
                break;
            else m_tabPressed = true;
        }

        QString sks;
        if(ke->key() == Qt::Key_Control) {
            sks = "Ctrl";
#ifdef Q_OS_MAC
        } else if(ke->key() == Qt::Key_Meta) {
            sks = "Ctrl";
#endif
        } else {
            QKeySequence ks(ke->modifiers() + ke->key());
            sks = ks.toString();
        }
#ifndef Q_OS_MAC
        if(sks.contains("Alt+Tab") || sks.contains("Alt+Shift+Backtab"))
            break;
#else
        sks.replace("Meta", "Ctrl");
#endif
        emit sequencePressed(QVariant::fromValue<QObject*>(obj), sks);
    } break;
    case QEvent::KeyRelease: {
        QKeyEvent *ke = static_cast<QKeyEvent*>(ev);
        if(ke->key() == Qt::Key_Tab || ke->key() == Qt::Key_Backtab)
            m_tabPressed = false;

        QString sks;
        if(ke->key() == Qt::Key_Control) {
            sks = "Ctrl";
#ifdef Q_OS_MAC
        } else if(ke->key() == Qt::Key_Meta) {
            sks = "Ctrl";
#endif
        } else {
            QKeySequence ks(ke->modifiers() + ke->key());
            sks = ks.toString();
        }
#ifndef Q_OS_MAC
        if(sks.contains("Alt+Tab") || sks.contains("Alt+Shift+Backtab"))
            break;
#else
        sks.replace("Meta", "Ctrl");
#endif
        emit sequenceReleased(QVariant::fromValue<QObject*>(obj), sks);
    } break;
    case QEvent::MouseButtonPress: {
        QMouseEvent *me = static_cast<QMouseEvent*>(ev);
        emit mousePressed(QVariant::fromValue<QObject*>(obj), me->x(), me->y());
    } break;
    case QEvent::MouseButtonRelease: {
        QMouseEvent *me = static_cast<QMouseEvent*>(ev);
        emit mouseReleased(QVariant::fromValue<QObject*>(obj), me->x(), me->y());
    } break;
    default: break;
    }

    return QObject::eventFilter(obj, ev);
}
