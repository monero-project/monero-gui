// Copyright (c) 2026, The Monero Project
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

#include "qt/PortableSettings.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJSValue>
#include <QMap>
#include <QMetaProperty>
#include <QSaveFile>
#include <QSettings>
#include <QTemporaryDir>
#include <QVariant>

namespace
{
using SettingsMap = QMap<QString, QVariant>;

bool readSettings(QSettings &settings, SettingsMap &values)
{
    settings.setFallbacksEnabled(false);
    settings.sync();

    if (settings.status() != QSettings::NoError)
        return false;

    for (const QString &key : settings.allKeys())
        values.insert(key, settings.value(key));

    return true;
}

bool replaceSettings(QSettings &settings, const SettingsMap &values)
{
    settings.setFallbacksEnabled(false);
    settings.setAtomicSyncRequired(true);
    settings.clear();

    for (auto it = values.cbegin(); it != values.cend(); ++it)
        settings.setValue(it.key(), it.value());

    settings.sync();
    return settings.status() == QSettings::NoError;
}

void readLiveSettings(QObject *settings, SettingsMap &values)
{
    if (!settings)
        return;

    // QML Settings::sync() does not flush pending property changes.
    const QMetaObject *metaObject = settings->metaObject();
    for (int i = QObject::staticMetaObject.propertyCount(); i < metaObject->propertyCount(); ++i) {
        const QMetaProperty property = metaObject->property(i);
        const QString name = QString::fromUtf8(property.name());
        if (name == QStringLiteral("category") || name == QStringLiteral("location"))
            continue;
        QVariant value = property.read(settings);
        if (value.metaType() == QMetaType::fromType<QJSValue>())
            value = value.value<QJSValue>().toVariant();
        values.insert(name, value);
    }
}
}

PortableSettings::PortableSettings(QObject *parent)
    : QObject(parent)
    , m_portable(portableConfigExists())
{
}

PortableSettings::~PortableSettings() = default;

QString PortableSettings::unportableFileName() const
{
    return m_unportableFileName;
}

void PortableSettings::setUnportableFileName(const QString &fileName)
{
    if (m_unportableFileName == fileName)
        return;

    // Keep the temporary directory alive while Settings flushes the old location.
    auto pendingSettings = std::move(m_pendingSettings);
    const auto pendingCleanup = m_pendingCleanup;
    m_pendingCleanup = {};
    m_unportableFileName = fileName;
    m_locationInitialized = false;
    if (!m_portable)
        emit locationChanged();
    disconnect(pendingCleanup);
}

bool PortableSettings::portable() const
{
    return m_portable;
}

QUrl PortableSettings::location() const
{
    initializeLocation();
    if (m_portable)
        return QUrl::fromLocalFile(portableFilePath());
    if (m_pendingSettings) {
        if (!m_pendingSettings->isValid())
            return QUrl(QStringLiteral("qrc:/unavailable-settings.ini"));
        return QUrl::fromLocalFile(m_pendingSettings->filePath(QStringLiteral("settings.ini")));
    }
    if (!m_unportableFileName.isEmpty())
        return QUrl::fromLocalFile(QFileInfo(m_unportableFileName).absoluteFilePath());
    return {};
}

QObject *PortableSettings::settings() const
{
    return m_settings;
}

void PortableSettings::setSettings(QObject *settings)
{
    m_settings = settings;
    retainPendingSettings();
}

bool PortableSettings::setPortable(bool enabled)
{
    initializeLocation();
    if (m_pendingSettings && !m_pendingSettings->isValid())
        return false;
    if (enabled == m_portable && !m_pendingSettings)
        return true;

    SettingsMap values;
    {
        QSettings source = m_pendingSettings
            ? QSettings(m_pendingSettings->filePath(QStringLiteral("settings.ini")), QSettings::IniFormat)
            : makeSettings(m_portable);
        if (!readSettings(source, values))
            return false;
    }
    readLiveSettings(m_settings, values);

    QSettings destination = makeSettings(enabled);
    SettingsMap previousDestination;
    if (!readSettings(destination, previousDestination))
        return false;
    const bool portableFileExisted = QFile::exists(portableFilePath());

    if (!replaceSettings(destination, values) || !setPortableMarker(enabled)) {
        QSettings previous = makeSettings(enabled);
        if (!replaceSettings(previous, previousDestination))
            qWarning("Failed to restore settings after portable mode configuration failed");
        if (enabled && !portableFileExisted && QFile::exists(portableFilePath()))
            QFile::remove(portableFilePath());
        return false;
    }

    auto pendingSettings = std::move(m_pendingSettings);
    const auto pendingCleanup = m_pendingCleanup;
    m_pendingCleanup = {};
    m_portable = enabled;
    emit portableChanged();
    emit locationChanged();
    disconnect(pendingCleanup);
    return true;
}

QString PortableSettings::portableFolderName()
{
    return QStringLiteral("monero-storage");
}

bool PortableSettings::portableConfigExists()
{
    const QFileInfo marker(portableMarkerPath());
    if (marker.exists()) {
        QFile file(marker.filePath());
        return marker.isFile() && (!file.open(QIODevice::ReadOnly)
            || file.readAll().trimmed() != QByteArrayLiteral("disabled"));
    }

    // Qt 5 used settings.ini as the portable marker.
    return QFileInfo(portableFilePath()).isFile();
}

QString PortableSettings::portableFilePath()
{
    return QDir(portableFolderName()).absoluteFilePath(QStringLiteral("settings.ini"));
}

QString PortableSettings::portableMarkerPath()
{
    return QDir(portableFolderName()).absoluteFilePath(QStringLiteral(".portable"));
}

bool PortableSettings::setPortableMarker(bool enabled)
{
    const QString path = portableMarkerPath();

    if (!enabled && !QFile::exists(path) && !QFile::exists(portableFilePath()))
        return true;

    const QFileInfo info(path);
    QDir directory(info.absolutePath());
    if (!directory.exists() && !directory.mkpath(QStringLiteral(".")))
        return false;

    QSaveFile marker(path);
    marker.setDirectWriteFallback(false);
    if (!marker.open(QIODevice::WriteOnly))
        return false;

    // Distinguish disabled mode from legacy portable settings.
    const QByteArray markerContents(enabled ? "portable\n" : "disabled\n");
    if (marker.write(markerContents) != markerContents.size()) {
        marker.cancelWriting();
        return false;
    }

    return marker.commit();
}

void PortableSettings::initializeLocation() const
{
    if (m_locationInitialized)
        return;
    m_locationInitialized = true;
    if (m_portable)
        return;

    QSettings settings = makeSettings(false);
    if (settings.status() != QSettings::NoError || !settings.allKeys().isEmpty())
        return;

    // Defer first-run host preferences until the storage mode is chosen.
    m_pendingSettings = std::make_shared<QTemporaryDir>(
        QDir::tempPath() + QStringLiteral("/monero-gui-settings-XXXXXX"));
    retainPendingSettings();
}

void PortableSettings::retainPendingSettings() const
{
    disconnect(m_pendingCleanup);
    m_pendingCleanup = {};
    if (m_pendingSettings && m_settings) {
        // Settings may outlive us and flush to this directory in its destructor.
        m_pendingCleanup = connect(m_settings, &QObject::destroyed,
            [pending = m_pendingSettings]() mutable { pending.reset(); });
    }
}

QSettings PortableSettings::makeSettings(bool portable) const
{
    if (portable)
        return QSettings(portableFilePath(), QSettings::IniFormat);
    if (!m_unportableFileName.isEmpty())
        return QSettings(m_unportableFileName, QSettings::IniFormat);
    return QSettings();
}
