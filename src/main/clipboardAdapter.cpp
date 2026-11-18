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

#include "clipboardAdapter.h"

#include <QTimer>

#ifdef Q_OS_MACOS
#include "qt/macoshelper.h"
#else
#include <QCryptographicHash>
#endif

namespace
{
#ifndef Q_OS_MACOS
QByteArray hashText(const QString &text)
{
    return QCryptographicHash::hash(text.toUtf8(), QCryptographicHash::Sha256);
}
#endif

// Clears copied secrets after a delay unless something else was copied since.
// Shared by all clipboardAdapter instances.
class SensitiveClipboardGuard : public QObject
{
public:
    static SensitiveClipboardGuard &instance()
    {
        static SensitiveClipboardGuard *guard = new SensitiveClipboardGuard(qApp);
        return *guard;
    }

#ifdef Q_OS_MACOS
    void track(long changeCount, int clearDelaySeconds)
    {
        m_changeCount = changeCount;
        start(clearDelaySeconds);
    }
#else
    void track(const QString &text, int clearDelaySeconds)
    {
        m_hash = hashText(text);
        start(clearDelaySeconds);
    }
#endif

    void clearIfUnchanged()
    {
        m_timer.stop();
        if (!m_pending)
            return;
        m_pending = false;

#ifdef Q_OS_MACOS
        MacOSHelper::clearPasteboardIfUnchanged(m_changeCount);
#else
        QClipboard *clipboard = QGuiApplication::clipboard();
        for (const QClipboard::Mode mode : {QClipboard::Clipboard, QClipboard::Selection})
        {
            if (hashText(clipboard->text(mode)) == m_hash)
                clipboard->clear(mode);
        }
        m_hash.clear();
#endif
    }

private:
    explicit SensitiveClipboardGuard(QObject *parent) :
        QObject(parent)
    {
        m_timer.setSingleShot(true);
        connect(&m_timer, &QTimer::timeout, this, &SensitiveClipboardGuard::clearIfUnchanged);
        connect(qApp, &QCoreApplication::aboutToQuit, this, &SensitiveClipboardGuard::clearIfUnchanged);
    }

    void start(int clearDelaySeconds)
    {
        m_pending = clearDelaySeconds > 0;
        if (m_pending)
            m_timer.start(clearDelaySeconds * 1000);
        else
            m_timer.stop();
    }

    QTimer m_timer;
    bool m_pending = false;
#ifdef Q_OS_MACOS
    long m_changeCount = 0;
#else
    QByteArray m_hash;
#endif
};
} // namespace

clipboardAdapter::clipboardAdapter(QObject *parent) :
    QObject(parent)
{
    m_pClipboard = QGuiApplication::clipboard();
}

void clipboardAdapter::setText(const QString &text) {
    m_pClipboard->setText(text, QClipboard::Clipboard);
    m_pClipboard->setText(text, QClipboard::Selection);
}

void clipboardAdapter::setSensitiveText(const QString &text, int clearDelaySeconds) {
#ifdef Q_OS_MACOS
    // Qt doesn't return the change count
    const long changeCount = MacOSHelper::setPasteboardText(text);
    SensitiveClipboardGuard::instance().track(changeCount, clearDelaySeconds);
#else
    setText(text);
    SensitiveClipboardGuard::instance().track(text, clearDelaySeconds);
#endif
}

QString clipboardAdapter::text() const {
    return m_pClipboard->text();
}
