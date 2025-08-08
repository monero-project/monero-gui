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

#ifndef TORMANAGER_H
#define TORMANAGER_H

#include <memory>

#include <QMutex>
#include <QObject>
#include <QUrl>
#include <QProcess>
#include "qt/FutureScheduler.h"

class TorManager : public QObject
{
    Q_OBJECT

public:
    explicit TorManager(QObject *parent = 0);
    ~TorManager();

    QString host = "127.0.0.1";
    int port = 20561;

    Q_INVOKABLE bool start(bool allowIncomingConnections);
    Q_INVOKABLE void exit();
    Q_INVOKABLE bool isInstalled() const;
    Q_INVOKABLE void download();
    Q_INVOKABLE bool isAlreadyRunning() const;
    Q_INVOKABLE QString getP2PAddress() const;
    Q_INVOKABLE QString getRPCAddress() const;
    Q_INVOKABLE QString getProxyAddress() const;
    Q_INVOKABLE int getP2PPort() const { return m_hidden_service_port_p2p; };
    Q_INVOKABLE int getRPCPort() const { return m_hidden_service_port_rpc; };
    Q_INVOKABLE QString getHost() const { return host; };
    Q_INVOKABLE int getPort() const { return port; };
    Q_INVOKABLE QString getVersion() const;

    enum DownloadError {
        BinaryNotAvailable,
        ConnectionIssue,
        HashVerificationFailed,
        InstallationFailed,
    };
    Q_ENUM(DownloadError)

private:

    bool running() const;
signals:
    void torStartSuccess() const;
    void torStartFailure(const QString &message) const;
    void torStopped() const;
    void torDownloadFailure(int errorCode) const;
    void torDownloadSuccess() const;

private slots:
    void handleProcessOutput();
    void handleProcessError(QProcess::ProcessError error);

private:
    std::unique_ptr<QProcess> m_tord;
    QMutex m_torMutex;
    QString m_tor;
    QString m_torPath;
    QString m_datadir;
    QString m_torrc;
    QString m_p2p_hidden_service_dir;
    QString m_rpc_hidden_service_dir;
    int m_hidden_service_port_p2p = 18084;
    int m_hidden_service_port_rpc = 18089;
    bool started = false;
    bool starting = false;

    mutable FutureScheduler m_scheduler;
};

#endif // TORMANAGER_H
