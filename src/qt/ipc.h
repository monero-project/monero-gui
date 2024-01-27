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

#ifndef IPC_H
#define IPC_H

#include <QtCore>
#include <QLocalServer>
#include <qt/utils.h>

class IPC : public QObject
{
Q_OBJECT
public:
    IPC(QObject *parent = 0) : QObject(parent) {}
    QFileInfo socketFile() const { return m_socketFile; }
    Q_INVOKABLE QString queuedCmd() { return m_queuedCmd; }
    void SetQueuedCmd(const QString cmdString) { m_queuedCmd = cmdString; }

public slots:
    void bind();
    void handleConnection();
    bool saveCommand(QString cmdString);
    bool saveCommand(const QUrl &url);
    void parseCommand(QString cmdString);
    void parseCommand(const QUrl &url);
    void emitUriHandler(QString uriString);

signals:
    void uriHandler(QString uriString);

private:
    QLocalServer *m_server;
    QString m_queuedCmd;
    QFileInfo m_socketFile = QFileInfo(QString(QDir::tempPath() + "/xmr-gui_%2.sock").arg(getAccountName()));
};

#endif // IPC_H
