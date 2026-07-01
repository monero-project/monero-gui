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
#include <QMap>
#include <QSaveFile>
#include <QSettings>
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
}

PortableSettings::PortableSettings(QObject *parent)
    : QObject(parent)
    , m_portable(portableConfigExists())
{
}

QString PortableSettings::unportableFileName() const
{
    return m_unportableFileName;
}

void PortableSettings::setUnportableFileName(const QString &fileName)
{
    if (m_unportableFileName == fileName)
        return;

    m_unportableFileName = fileName;
    if (!m_portable)
        emit locationChanged();
}

bool PortableSettings::portable() const
{
    return m_portable;
}

QUrl PortableSettings::location() const
{
    if (m_portable)
        return QUrl::fromLocalFile(portableFilePath());
    if (!m_unportableFileName.isEmpty())
        return QUrl::fromLocalFile(QFileInfo(m_unportableFileName).absoluteFilePath());
    return {};
}

bool PortableSettings::setPortable(bool enabled)
{
    if (enabled == m_portable)
        return true;

    SettingsMap values;
    {
        QSettings source = makeSettings(m_portable);
        if (!readSettings(source, values))
            return false;
    }

    {
        QSettings destination = makeSettings(enabled);
        if (!replaceSettings(destination, values))
            return false;
    }

    if (!setPortableMarker(enabled))
        return false;

    m_portable = enabled;
    emit portableChanged();
    emit locationChanged();
    return true;
}

QString PortableSettings::portableFolderName()
{
    return QStringLiteral("monero-storage");
}

bool PortableSettings::portableConfigExists()
{
    const QFileInfo marker(portableMarkerPath());
    return marker.exists() && marker.isFile();
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

    if (!enabled)
        return !QFile::exists(path) || QFile::remove(path);

    const QFileInfo info(path);
    QDir directory(info.absolutePath());
    if (!directory.exists() && !directory.mkpath(QStringLiteral(".")))
        return false;

    QSaveFile marker(path);
    marker.setDirectWriteFallback(false);
    if (!marker.open(QIODevice::WriteOnly))
        return false;

    const QByteArray markerContents("portable\n");
    if (marker.write(markerContents) != markerContents.size()) {
        marker.cancelWriting();
        return false;
    }

    return marker.commit();
}

QSettings PortableSettings::makeSettings(bool portable) const
{
    if (portable)
        return QSettings(portableFilePath(), QSettings::IniFormat);
    if (!m_unportableFileName.isEmpty())
        return QSettings(m_unportableFileName, QSettings::IniFormat);
    return QSettings();
}
