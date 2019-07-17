/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
****************************************************************************/
// Copyright (c) 2014-2019, The Monero Project
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

#include <QtCore>
#include <QMetaObject>
#include <QSettings>
#include <QPointer>
#include <QJSValue>
#include <QHash>
#include <QMetaProperty>

#include "src/qt/MoneroSettings.h"

/*!
    \qmlmodule moneroSettings 1.0
    \title Monero Settings QML Component
    \ingroup qmlmodules
    \brief Provides persistent platform-independent application settings.

    This component was introduced in order to have control over where the
    configuration file is written. This is needed for Tails OS and
    portable installations.

    For more information, see: https://doc.qt.io/qt-5/qml-qt-labs-settings-settings.html and
    https://github.com/qt/qtdeclarative/blob/v5.12.0/src/imports/settings/qqmlsettings.cpp

    To use this module, import the module with the following line:
    \code
    import moneroComponents.Settings 1.0
    \endcode

    Usage:
    \code
    MoneroSettings { id: persistentSettings, property bool foo: true }
    \endcode

    @TODO: Remove this QML component after migrating to Qt >= 5.12.0, as
    `Qt.labs.settings` provides the fileName via a Q_PROPERTY
*/


void MoneroSettings::load()
{
    const QMetaObject *mo = this->metaObject();
    const int offset = mo->propertyOffset();
    const int count = mo->propertyCount();

    for (int i = offset; i < count; ++i) {
        QMetaProperty property = mo->property(i);
        const QVariant previousValue = readProperty(property);
        const QVariant currentValue = this->m_settings->value(property.name(), previousValue);

        if (!currentValue.isNull() && (!previousValue.isValid()
                || (currentValue.canConvert(previousValue.type()) && previousValue != currentValue))) {
            property.write(this, currentValue);
#ifdef QT_DEBUG
            qDebug() << "QQmlSettings: load" << property.name() << "setting:" << currentValue << "default:" << previousValue;
#endif
        }

        // ensure that a non-existent setting gets written
        // even if the property wouldn't change later
        if (!this->m_settings->contains(property.name()))
            this->_q_propertyChanged();

        // setup change notifications on first load
        if (!this->m_initialized && property.hasNotifySignal()) {
            static const int propertyChangedIndex = mo->indexOfSlot("_q_propertyChanged()");
            int signalIndex = property.notifySignalIndex();
            QMetaObject::connect(this, signalIndex, this, propertyChangedIndex);
        }
    }
}

void MoneroSettings::_q_propertyChanged()
{
    // Called on QML property change
    const QMetaObject *mo = this->metaObject();
    const int offset = mo->propertyOffset();
    const int count = mo->propertyCount();
    for (int i = offset; i < count; ++i) {
        const QMetaProperty &property = mo->property(i);
        const QVariant value = readProperty(property);
        this->m_changedProperties.insert(property.name(), value);
#ifdef QT_DEBUG
        //qDebug() << "QQmlSettings: cache" << property.name() << ":" << value;
#endif
    }

    if (this->m_timerId != 0)
        this->killTimer(this->m_timerId);
    this->m_timerId = this->startTimer(settingsWriteDelay);
}

QVariant MoneroSettings::readProperty(const QMetaProperty &property) const
{
    QVariant var = property.read(this);
    if (var.userType() == qMetaTypeId<QJSValue>())
        var = var.value<QJSValue>().toVariant();
    return var;
}

void MoneroSettings::init()
{
    if (!this->m_initialized) {
        this->m_settings = this->m_fileName.isEmpty() ? new QSettings() : new QSettings(this->m_fileName, QSettings::IniFormat);
#ifdef QT_DEBUG
        qDebug() << "QQmlSettings: stored at" << this->m_settings->fileName();
#endif
        this->load();
        this->m_initialized = true;
    }
}

void MoneroSettings::reset()
{
    if (this->m_initialized && this->m_settings && !this->m_changedProperties.isEmpty())
        this->store();
    delete this->m_settings;
}

void MoneroSettings::store()
{
    QHash<const char *, QVariant>::const_iterator it = this->m_changedProperties.constBegin();

    while (it != this->m_changedProperties.constEnd()) {
        this->m_settings->setValue(it.key(), it.value());

#ifdef QT_DEBUG
            //qDebug() << "QQmlSettings: store" << it.key() << ":" << it.value();
#endif

        ++it;
    }

    this->m_changedProperties.clear();
}

void MoneroSettings::setFileName(const QString &fileName)
{
    if (fileName != this->m_fileName) {
        this->reset();
        this->m_fileName = fileName;
        if (this->m_initialized)
            this->load();
    }
}

QString MoneroSettings::fileName() const
{
    return this->m_fileName;
}

void MoneroSettings::timerEvent(QTimerEvent *event)
{
    if (event->timerId() == this->m_timerId) {
        killTimer(this->m_timerId);
        this->m_timerId = 0;
        this->store();
    }
    QObject::timerEvent(event);
}

void MoneroSettings::componentComplete()
{
    this->init();
}

void MoneroSettings::classBegin()
{
}

MoneroSettings::MoneroSettings(QObject *parent) :
    QObject(parent)
{
}
