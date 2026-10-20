// Copyright (c) 2014-2024, The Monero Project
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

#include "ColorScheme.h"

#include <QColor>
#include <QEvent>
#include <QGuiApplication>
#include <QPalette>
#include <QStyleHints>

#ifdef HAVE_QT_DBUS
#include <QDBusConnection>
#include <QDBusMessage>
#include <QVariant>
#endif

namespace {

// Platform themes that do not report a colour scheme still reflect the desktop's choice
// in the application palette (qt6ct, gtk3). Comparing the window and text lightness is
// more robust than testing the window colour against a fixed threshold, because it stays
// correct for low-contrast and tinted palettes.
bool palettePrefersDark()
{
    const QPalette palette = QGuiApplication::palette();
    const QColor window = palette.color(QPalette::Active, QPalette::Window);
    const QColor windowText = palette.color(QPalette::Active, QPalette::WindowText);
    return window.lightness() < windowText.lightness();
}

#ifdef HAVE_QT_DBUS
// org.freedesktop.appearance color-scheme: 0 = no preference, 1 = prefer dark, 2 = prefer light.
bool colorSchemeFromVariant(const QVariant &value, bool &prefersDark)
{
    QVariant unwrapped = value;
    // Settings.Read returns the value wrapped in one or two layers of variant,
    // depending on the portal implementation.
    while (unwrapped.canConvert<QDBusVariant>())
    {
        unwrapped = unwrapped.value<QDBusVariant>().variant();
    }

    bool ok = false;
    const uint colorScheme = unwrapped.toUInt(&ok);
    if (!ok || colorScheme == 0)
    {
        return false;
    }

    prefersDark = colorScheme == 1;
    return true;
}

// Ask xdg-desktop-portal for the desktop's colour-scheme preference. Qt only fills in
// QStyleHints::colorScheme on KDE and GNOME; every other desktop (COSMIC, Sway, ...)
// gets the generic Unix theme, which leaves it Unknown, and the palette under qt6ct is
// a static profile that never follows the desktop.
bool portalPrefersDark(bool &prefersDark)
{
    QDBusConnection sessionBus = QDBusConnection::sessionBus();
    if (!sessionBus.isConnected())
    {
        return false;
    }

    QDBusMessage request = QDBusMessage::createMethodCall(
        QStringLiteral("org.freedesktop.portal.Desktop"),
        QStringLiteral("/org/freedesktop/portal/desktop"),
        QStringLiteral("org.freedesktop.portal.Settings"),
        QStringLiteral("Read"));
    request << QStringLiteral("org.freedesktop.appearance") << QStringLiteral("color-scheme");

    // Short timeout: a missing or wedged portal must not delay startup.
    const QDBusMessage reply = sessionBus.call(request, QDBus::Block, 500);
    if (reply.type() != QDBusMessage::ReplyMessage || reply.arguments().isEmpty())
    {
        return false;
    }

    return colorSchemeFromVariant(reply.arguments().constFirst(), prefersDark);
}
#endif

}

ColorScheme::ColorScheme(QObject *parent)
    : QObject(parent)
    , m_prefersDark(detect())
{
    // Windows, macOS, KDE and GNOME report the preference through QStyleHints and signal
    // when it changes.
    connect(QGuiApplication::styleHints(), &QStyleHints::colorSchemeChanged,
            this, &ColorScheme::refresh);

    // Everything else only shows up as a palette change.
    qApp->installEventFilter(this);

#ifdef HAVE_QT_DBUS
    QDBusConnection::sessionBus().connect(
        QString(),
        QStringLiteral("/org/freedesktop/portal/desktop"),
        QStringLiteral("org.freedesktop.portal.Settings"),
        QStringLiteral("SettingChanged"),
        this,
        SLOT(portalSettingChanged(QString, QString, QDBusVariant)));
#endif
}

bool ColorScheme::prefersDark() const
{
    return m_prefersDark;
}

bool ColorScheme::detect() const
{
#ifdef HAVE_QT_DBUS
    bool prefersDark = false;
    if (portalPrefersDark(prefersDark))
    {
        return prefersDark;
    }
#endif

    switch (QGuiApplication::styleHints()->colorScheme())
    {
    case Qt::ColorScheme::Dark:
        return true;
    case Qt::ColorScheme::Light:
        return false;
    case Qt::ColorScheme::Unknown:
        break;
    }

    return palettePrefersDark();
}

bool ColorScheme::eventFilter(QObject *watched, QEvent *event)
{
    if (watched == qApp && (event->type() == QEvent::ApplicationPaletteChange
                            || event->type() == QEvent::ThemeChange))
    {
        refresh();
    }

    return QObject::eventFilter(watched, event);
}

void ColorScheme::refresh()
{
    const bool prefersDark = detect();
    if (prefersDark == m_prefersDark)
    {
        return;
    }

    m_prefersDark = prefersDark;
    emit prefersDarkChanged();
}

#ifdef HAVE_QT_DBUS
void ColorScheme::portalSettingChanged(const QString &group, const QString &key, const QDBusVariant &value)
{
    Q_UNUSED(value)

    if (group != QStringLiteral("org.freedesktop.appearance") || key != QStringLiteral("color-scheme"))
    {
        return;
    }

    // Re-read through detect() so the source precedence stays in one place.
    refresh();
}
#endif
