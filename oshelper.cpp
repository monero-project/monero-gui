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
#include <QString>
#ifdef Q_OS_MAC
#include "qt/macoshelper.h"
#endif
#ifdef Q_OS_WIN32
#include <windows.h>
#endif
#ifdef Q_OS_LINUX
#include <X11/XKBlib.h>
#undef KeyPress
#undef KeyRelease
#undef FocusIn
#undef FocusOut
// #undef those Xlib #defines that conflict with QEvent::Type enum
#endif

OSHelper::OSHelper(QObject *parent) : QObject(parent)
{

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
#if defined(Q_OS_WIN32) // MS Windows version
    return GetKeyState(VK_CAPITAL) == 1;
#elif defined(Q_OS_LINUX) // X11 version
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
