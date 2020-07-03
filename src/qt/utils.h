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

#ifndef UTILS_H
#define UTILS_H

#include <QtCore>
#include <QRegExp>
#include <QApplication>

bool fileExists(QString path);
QByteArray fileGetContents(QString path);
QByteArray fileOpen(QString path);
bool fileWrite(QString path, QString data);
QString getAccountName();
#ifdef Q_OS_LINUX
struct xdgDesktopEntryPaths {
    QString pathApp;
    QString pathIcon;
    QString pathAppTails;
    QString PathIconTails;
    QString PathMime;
};
const xdgDesktopEntryPaths xdgPaths = {
        QString("%1/monero-gui.desktop").arg(QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation)),
        QString("%1/.local/share/icons/monero.png").arg(QDir::homePath()),
        QString("/live/persistence/TailsData_unlocked/dotfiles/.local/share/applications/monero-gui.desktop"),
        QString("/live/persistence/TailsData_unlocked/dotfiles/.local/share/icons/monero.png"),
        QString("/")
};
bool pixmapWrite(const QString &path, const QPixmap &pixmap);
QString xdgDesktopEntry();
bool xdgDesktopEntryWrite(const QString &path);
QString xdgDesktopEntryPath();
bool _xdgDesktopEntryRegister();
void xdgRefreshApplications();
#endif
const static QRegExp reURI = QRegExp("^\\w+:\\/\\/([\\w+\\-?\\-_\\-=\\-&]+)");
QString randomUserAgent();

#endif // UTILS_H
