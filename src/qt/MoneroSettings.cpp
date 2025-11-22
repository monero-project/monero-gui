/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
****************************************************************************/
// Copyright (c) 2014-2024, The Monero Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
// …
#include <QtCore>
#include <QMetaObject>
#include <QSettings>
#include <QPointer>
#include <QJSValue>
#include <QHash>
#include <QMetaProperty>
#include <QStringList>    // for QStringList in I2P trusted nodes

#include "qt/MoneroSettings.h"

/*!
    \qmlmodule moneroSettings 1.0
    \title Monero Settings QML Component
    …
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
        // qDebug() << "QQmlSettings: cache" << property.name() << ":" << value;
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
        this->m_settings = portableConfigExists() ? portableSettings() : unportableSettings();
#ifdef QT_DEBUG
        qDebug() << "QQmlSettings: stored at" << this->m_settings->fileName();
#endif
        this->load();
        this->m_initialized = true;
        emit portableChanged();
    }
}

void MoneroSettings::reset()
{
    if (this->m_initialized && this->m_settings && !this->m_changedProperties.isEmpty())
        this->store();
    if (this->m_settings)
        this->m_settings.reset();
}

void MoneroSettings::store()
{
    if (!m_writable) {
        return;
    }

    QHash<const char *, QVariant>::const_iterator it = this->m_changedProperties.constBegin();

    while (it != this->m_changedProperties.constEnd()) {
        this->m_settings->setValue(it.key(), it.value());

#ifdef QT_DEBUG
            // qDebug() << "QQmlSettings: store" << it.key() << ":" << it.value();
#endif

        ++it;
    }

    this->m_changedProperties.clear();
}

bool MoneroSettings::portable() const
{
    return this->m_settings && this->m_settings->fileName() == portableFilePath();
}

bool MoneroSettings::portableConfigExists()
{
    QFileInfo info(portableFilePath());
    return info.exists() && info.isFile();
}

QString MoneroSettings::portableFilePath()
{
    static QString filename(QDir(portableFolderName()).absoluteFilePath("settings.ini"));
    return filename;
}

QString MoneroSettings::portableFolderName()
{
    return "monero-storage";
}

std::unique_ptr<QSettings> MoneroSettings::portableSettings() const
{
    return std::unique_ptr<QSettings>(new QSettings(portableFilePath(), QSettings::IniFormat));
}

std::unique_ptr<QSettings> MoneroSettings::unportableSettings() const
{
    if (this->m_fileName.isEmpty()) {
        return std::unique_ptr<QSettings>(new QSettings());
    }
    return std::unique_ptr<QSettings>(new QSettings(this->m_fileName, QSettings::IniFormat));
}

void MoneroSettings::swap(std::unique_ptr<QSettings> newSettings)
{
    const QMetaObject *mo = this->metaObject();
    const int count = mo->propertyCount();
    for (int offset = mo->propertyOffset(); offset < count; ++offset) {
        const QMetaProperty &property = mo->property(offset);
        const QVariant value = readProperty(property);
        newSettings->setValue(property.name(), value);
    }

    this->m_settings.swap(newSettings);
    this->m_settings->sync();
    emit portableChanged();
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

bool MoneroSettings::setPortable(bool enabled)
{
    std::unique_ptr<QSettings> newSettings = enabled ? portableSettings() : unportableSettings();
    if (newSettings->status() != QSettings::NoError) {
        return false;
    }

    setWritable(true);
    swap(std::move(newSettings));

    if (!enabled) {
        QFile::remove(portableFilePath());
    }

    return true;
}

void MoneroSettings::setWritable(bool enabled)
{
    m_writable = enabled;
}

/* -----------------------------------------------------------------------
 *  I2P settings getters/setters
 *
 *  These methods persist the I2P configuration in the underlying QSettings.
 *  You must also add matching Q_PROPERTY declarations and signals
 *  (i2pEnabledChanged, i2pConnectionMethodChanged, i2pTrustedNodesChanged)
 *  to MoneroSettings.h.
 * --------------------------------------------------------------------- */

/**
 * Returns true if I2P tunnelling is enabled, false otherwise.
 * Default is false when not set.
 */
bool MoneroSettings::i2pEnabled() const
{
    return m_settings ? m_settings->value("i2pEnabled", false).toBool() : false;
}

void MoneroSettings::setI2pEnabled(bool enabled)
{
    if (!m_settings)
        return;
    bool current = m_settings->value("i2pEnabled", false).toBool();
    if (current == enabled)
        return;
    m_settings->setValue("i2pEnabled", enabled);
    emit i2pEnabledChanged();
}

/**
 * Returns the current I2P connection method (e.g. "auto", "stream", "SAM").
 * Default is "auto" when not set.
 */
QString MoneroSettings::i2pConnectionMethod() const
{
    return m_settings ? m_settings->value("i2pConnectionMethod", "auto").toString()
                      : QString("auto");
}

void MoneroSettings::setI2pConnectionMethod(const QString &method)
{
    if (!m_settings)
        return;
    QString current = m_settings->value("i2pConnectionMethod", "auto").toString();
    if (current == method)
        return;
    m_settings->setValue("i2pConnectionMethod", method);
    emit i2pConnectionMethodChanged();
}

/**
 * Returns a list of user-defined trusted I2P nodes.  Returns an empty
 * list if none have been stored.
 */
QStringList MoneroSettings::i2pTrustedNodes() const
{
    return m_settings ? m_settings->value("i2pTrustedNodes").toStringList()
                      : QStringList();
}

void MoneroSettings::setI2pTrustedNodes(const QStringList &nodes)
{
    if (!m_settings)
        return;
    QStringList current = m_settings->value("i2pTrustedNodes").toStringList();
    if (current == nodes)
        return;
    m_settings->setValue("i2pTrustedNodes", nodes);
    emit i2pTrustedNodesChanged();
}

/* --------------------------------------------------------------------- */

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
