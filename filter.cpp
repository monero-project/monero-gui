// Copyright (c) 2014-2015, The Monero Project
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
#ifdef Q_OS_ANDROID
        if(ke->key() == Qt::Key_Back) {
            qDebug() << "Android back hit";
            sks = "android_back";
        }
#endif
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
