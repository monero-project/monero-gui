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

#include "oshelper.h"
#include <QTemporaryFile>
#include <QDir>
#include <QDebug>
#include <QDesktopServices>
#include <QFileInfo>
#include <QString>
#include <QUrl>
#ifdef Q_OS_MAC
#include "qt/macoshelper.h"
#endif
#ifdef Q_OS_WIN
#include <Shlobj.h>
#include <windows.h>
#endif
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
#include <X11/XKBlib.h>
#undef KeyPress
#undef KeyRelease
#undef FocusIn
#undef FocusOut
// #undef those Xlib #defines that conflict with QEvent::Type enum
#endif

#if defined(Q_OS_WIN)
bool openFolderAndSelectItem(const QString &filePath)
{
    struct scope {
        ~scope() { ::CoTaskMemFree(pidl); }
        PIDLIST_ABSOLUTE pidl = nullptr;
    } scope;

    SFGAOF flags;
    HRESULT result = ::SHParseDisplayName(filePath.toStdWString().c_str(), nullptr, &scope.pidl, 0, &flags);
    if (result != S_OK)
    {
        qWarning() << "SHParseDisplayName failed" << result << "file path" << filePath;
        return false;
    }

    result = ::SHOpenFolderAndSelectItems(scope.pidl, 0, nullptr, 0);
    if (result != S_OK)
    {
        qWarning() << "SHOpenFolderAndSelectItems failed" << result << "file path" << filePath;
        return false;
    }

    return true;
}
#endif

OSHelper::OSHelper(QObject *parent) : QObject(parent)
{

}

bool OSHelper::openContainingFolder(const QString &filePath) const
{
#if defined(Q_OS_WIN)
    if (openFolderAndSelectItem(QDir::toNativeSeparators(filePath)))
    {
        return true;
    }
#elif defined(Q_OS_MAC)
    if (MacOSHelper::openFolderAndSelectItem(QUrl::fromLocalFile(filePath)))
    {
        return true;
    }
#endif

    QUrl url = QUrl::fromLocalFile(QFileInfo(filePath).absolutePath());
    if (!url.isValid())
    {
        qWarning() << "Malformed file path" << filePath << url.errorString();
        return false;
    }
    return QDesktopServices::openUrl(url);
}

QString OSHelper::temporaryFilename() const
{
    QString tempFileName;
    {
        QTemporaryFile f;
        f.open();
        tempFileName = f.fileName();
    }
    return tempFileName;
}

bool OSHelper::removeTemporaryWallet(const QString &fileName) const
{
    // Temporary files should be deleted automatically by default, in case they wouldn't, we delete them manually as well
    bool cache_deleted = QFile::remove(fileName);
    bool address_deleted = QFile::remove(fileName + ".address.txt");
    bool keys_deleted = QFile::remove(fileName +".keys");

    return cache_deleted && address_deleted && keys_deleted;
}

// https://stackoverflow.com/a/3006934
bool OSHelper::isCapsLock() const
{
    // platform dependent method of determining if CAPS LOCK is on
#if defined(Q_OS_WIN) // MS Windows version
    return GetKeyState(VK_CAPITAL) == 1;
#elif defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID) // X11 version
    Display * d = XOpenDisplay((char*)0);
    bool caps_state = false;
    if (d) {
        unsigned n;
        XkbGetIndicatorState(d, XkbUseCoreKbd, &n);
        caps_state = (n & 0x01) == 1;
    }
    return caps_state;
#elif defined(Q_OS_MAC)
    return MacOSHelper::isCapsLock();
#endif
    return false;
}

QString OSHelper::temporaryPath() const
{
    return QDir::tempPath();
}
