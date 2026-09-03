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

#ifndef COLORSCHEME_H
#define COLORSCHEME_H

#include <QObject>

#ifdef HAVE_QT_DBUS
#include <QDBusVariant>
#endif

class QEvent;

/**
 * @brief The ColorScheme class - exports the OS light/dark preference to QML
 *
 * Consulted by MoneroComponents.Style when the theme setting is "system".
 */
class ColorScheme : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool prefersDark READ prefersDark NOTIFY prefersDarkChanged)

public:
    explicit ColorScheme(QObject *parent = nullptr);

    bool prefersDark() const;

signals:
    void prefersDarkChanged();

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

private slots:
    void refresh();

#ifdef HAVE_QT_DBUS
    void portalSettingChanged(const QString &group, const QString &key, const QDBusVariant &value);
#endif

private:
    bool detect() const;

    bool m_prefersDark;
};

#endif // COLORSCHEME_H
