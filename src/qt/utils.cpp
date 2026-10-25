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

#include <QtCore>
#include <QCoreApplication>
#include <QtGlobal>
#include <QStringList>

#include "TailsOS.h"
#include "utils.h"

bool fileExists(QString path) {
    QFileInfo check_file(path);
    return check_file.exists() && check_file.isFile();
}

QByteArray fileGetContents(QString path)
{
    QFile file(path);
    if (!file.open(QFile::ReadOnly))
    {
        throw std::runtime_error(QString("failed to open %1").arg(path).toStdString());
    }

    QByteArray data;
    data.resize(file.size());
    if (file.read(data.data(), data.size()) != data.size())
    {
        throw std::runtime_error(QString("failed to read %1").arg(path).toStdString());
    }

    return data;
}

QByteArray fileOpen(QString path) {
    QFile file(path);
    if(!file.open(QFile::ReadOnly | QFile::Text))
        return QByteArray();

    QByteArray data = file.readAll();
    file.close();
    return data;
}

bool fileWrite(QString path, QString data) {
    QFile file(path);
    if(file.open(QIODevice::WriteOnly)){
        QTextStream out(&file);
        out << data << '\n';
        file.close();
        return true;
    }

    return false;
}

QString getAccountName(){
    QString accountName = qgetenv("USER"); // mac/linux
    if (accountName.isEmpty())
        accountName = qgetenv("USERNAME"); // Windows
    if (accountName.isEmpty())
        accountName = "My monero Account";
    return accountName;
}

#ifdef Q_OS_LINUX
QString xdgMime(){
    return QString(
        "[Desktop Entry]\n"
        "Name=Monero GUI\n"
        "GenericName=Monero-GUI\n"
        "X-GNOME-FullName=Monero-GUI\n"
        "Comment=Monero GUI\n"
        "Keywords=Monero;\n"
        "Exec=\"%1\" %u\n"
        "Terminal=false\n"
        "Type=Application\n"
        "Icon=monero\n"
        "Categories=Network;GNOME;Qt;\n"
        "MimeType=x-scheme-handler/monero;x-scheme-handler/moneroseed\n"
        "StartupNotify=true\n"
        "X-GNOME-Bugzilla-Bugzilla=GNOME\n"
        "X-GNOME-UsesNotifications=true\n"
        "StartupWMClass=monero-wallet-gui\n"
    ).arg(QCoreApplication::applicationFilePath());
}

void registerXdgMime(){
    // Register desktop entry
    // - MacOS handled via Info.plist
    // - Windows handled in the installer by rbrunner7
    // - Linux written to `QStandardPaths::ApplicationsLocation`
    // - Tails written to persistent dotfiles
    QString mime = xdgMime();
    QString appPath = QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation);
    QString filePath = QString("%1/monero-gui.desktop").arg(appPath);

    if (TailsOS::detect())
    {
        if (TailsOS::detectDotPersistence() && TailsOS::usePersistence)
        {
            TailsOS::persistXdgMime(filePath, mime);
        }
    }
    else
    {
        QDir().mkpath(QFileInfo(filePath).path());
        fileWrite(filePath, mime);
    }
}
#endif

QString browserUserAgent()
{
    // Matches the user agent sent by the current stable Tor Browser (Firefox ESR 140) on each platform
#if defined(Q_OS_WIN)
    return QStringLiteral("Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0");
#elif defined(Q_OS_MACOS)
    return QStringLiteral("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:140.0) Gecko/20100101 Firefox/140.0");
#else
    return QStringLiteral("Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0");
#endif
}
