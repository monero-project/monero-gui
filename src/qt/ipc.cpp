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

#include <QCoreApplication>
#include <QLocalSocket>
#include <QLocalServer>
#include <QtNetwork>
#include <QDebug>
#include <QDir>
#include <QRandomGenerator>
#include <QFile>

#include "ipc.h"
#include "utils.h"

// Max size of an IPC command in bytes. Payment URIs are short; anything larger
// is treated as invalid to avoid unbounded reads from local clients.
static const int IPC_MAX_CMD_SIZE = 4096;

// Start listening for incoming IPC commands on UDS (Unix) or named pipe (Windows)
void IPC::bind(){
    QString path = QString(this->m_socketFile.absoluteFilePath());

    // Generate a fresh shared secret so only processes that know it (i.e. other
    // instances started by the same user) can submit commands to this server.
    if (!writeTokenFile()) {
        qWarning() << "IPC: unable to write token file, commands will be rejected";
        m_token.clear();
    }
    qDebug() << "IPC socket:" << path;

    this->m_server = new QLocalServer(this);
    this->m_server->setSocketOptions(QLocalServer::UserAccessOption);

    bool restarted = false;
    if(!this->m_server->listen(path)){
        // On Unix if the server crashes without closing listen will fail with AddressInUseError.
        // To create a new server the file should be removed. On Windows two local servers can listen
        // to the same pipe at the same time, but any connections will go to one of the server.
#ifdef Q_OS_UNIX
        qDebug() << QString("Unable to start IPC server in \"%1\": \"%2\". Retrying.").arg(path).arg(this->m_server->errorString());
        if(this->m_socketFile.exists()){
            QFile file(path);
            file.remove();

            if(this->m_server->listen(path)){
                restarted = true;
            }
        }
#endif
        if(!restarted)
            qDebug() << QString("Unable to start IPC server in \"%1\": \"%2\".").arg(path).arg(this->m_server->errorString());
    }

    connect(this->m_server, &QLocalServer::newConnection, this, &IPC::handleConnection);
}

// Process incoming IPC command. First check if monero-wallet-gui is
// already running. If it is, send it to that instance instead, if not,
// queue the command for later use inside our QML engine. Returns true
// when queued, false if sent to another instance, at which point we can
// kill the current process.
bool IPC::saveCommand(QString cmdString){
    if (cmdString.length() > IPC_MAX_CMD_SIZE) {
        qWarning() << "saveCommand: command too large, ignoring";
        return true;
    }

    // The server only accepts commands that carry the shared token.
    QString token;
    if (!readTokenFile(token) || token.isEmpty()) {
        qWarning() << "saveCommand: no IPC token available, queueing command";
        this->SetQueuedCmd(cmdString);
        return true;
    }

    QLocalSocket ls;
    QByteArray buffer;
    buffer.append(token.toUtf8());
    buffer.append('\n');
    buffer.append(cmdString.toUtf8());
    QString socketFilePath = this->socketFile().filePath();

    ls.connectToServer(socketFilePath, QIODevice::WriteOnly);
    if(ls.waitForConnected(1000)){
        ls.write(buffer);
        if (!ls.waitForBytesWritten(1000)){
            qDebug() << QString("Could not send command over IPC %1: \"%2\"").arg(socketFilePath, ls.errorString());
            return false;
        }

        qDebug() << "Sent command over IPC" << socketFilePath;
        return false;
    }

    if(ls.isOpen())
        ls.disconnectFromServer();

    // Queue for later
    this->SetQueuedCmd(cmdString);
    return true;
}

bool IPC::saveCommand(const QUrl &url){
    return this->saveCommand(url.toString());
}

void IPC::handleConnection(){
    QLocalSocket *clientConnection = this->m_server->nextPendingConnection();
    connect(clientConnection, &QLocalSocket::disconnected,
            clientConnection, &QLocalSocket::deleteLater);

    clientConnection->waitForReadyRead(2);
    QByteArray data = clientConnection->readAll();

    // Reject oversized or empty payloads.
    if (data.isEmpty() || data.size() > IPC_MAX_CMD_SIZE + 1 + 64) {
        clientConnection->close();
        delete clientConnection;
        return;
    }

    // The payload must start with the shared token followed by a newline.
    int sep = data.indexOf('\n');
    if (sep <= 0) {
        clientConnection->close();
        delete clientConnection;
        return;
    }

    QString receivedToken = QString::fromUtf8(data.left(sep));
    if (receivedToken != m_token) {
        qWarning() << "IPC: rejecting command with invalid token";
        clientConnection->close();
        delete clientConnection;
        return;
    }

    QString cmdString = QString::fromUtf8(data.mid(sep + 1));
    this->parseCommand(cmdString);

    clientConnection->close();
    delete clientConnection;
}

void IPC::parseCommand(const QUrl &url){
    this->parseCommand(url.toString());
}

void IPC::parseCommand(QString cmdString){
    if(cmdString.contains(reURI)){
        this->emitUriHandler(cmdString);
    }
}

void IPC::emitUriHandler(QString uriString){
    emit uriHandler(uriString);
}

bool IPC::writeTokenFile()
{
    // 32 random bytes, hex-encoded (64 chars). The token is regenerated on
    // every bind() so an attacker cannot predict it across runs.
    QByteArray random;
    for (int i = 0; i < 8; ++i)
        random.append(QRandomGenerator::system()->generate());
    m_token = QString::fromLatin1(random.toHex());

    QFile f(m_tokenFile.absoluteFilePath());
    if (!f.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return false;
    f.write(m_token.toUtf8());
    f.close();
#ifdef Q_OS_UNIX
    QFile::setPermissions(m_tokenFile.absoluteFilePath(),
                          QFile::ReadOwner | QFile::WriteOwner);
#endif
    return true;
}

bool IPC::readTokenFile(QString &token) const
{
    QFile f(m_tokenFile.absoluteFilePath());
    if (!f.open(QIODevice::ReadOnly))
        return false;
    token = QString::fromUtf8(f.readAll()).trimmed();
    f.close();
    return !token.isEmpty();
}
