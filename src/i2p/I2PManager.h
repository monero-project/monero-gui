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

#ifndef I2PMANAGER_H
#define I2PMANAGER_H

#include <memory>

#include <QMutex>
#include <QObject>
#include <QUrl>
#include <QProcess>
#include "qt/FutureScheduler.h"

class I2PManager : public QObject
{
    Q_OBJECT

public:
    explicit I2PManager(QObject *parent = 0);
    ~I2PManager();

    QString host = "127.0.0.1";
    int port = 4447;

    Q_INVOKABLE bool start(bool allowIncomingConnections);
    Q_INVOKABLE void exit();
    Q_INVOKABLE bool isAlreadyRunning() const;
    Q_INVOKABLE QString getP2PAddress() const;
    Q_INVOKABLE QString getRPCAddress() const;
    Q_INVOKABLE QString getProxyAddress() const;
    Q_INVOKABLE int getP2PPort() const { return m_p2p_port; };

    Q_INVOKABLE QString getHost() const { return host; };
    Q_INVOKABLE int getPort() const { return port; };
    Q_INVOKABLE QString getVersion() const;

private:

    bool running() const;
signals:
    void i2pStartSuccess() const;
    void i2pStartFailure(const QString &message) const;
    void i2pStopped() const;

public slots:
    void stateChanged(QProcess::ProcessState state);

private slots:
    void handleProcessOutput();
    void handleProcessError(QProcess::ProcessError error);

private:
    std::unique_ptr<QProcess> m_i2pd;
    QMutex m_i2pdMutex;
    QString m_i2pd_binary;
    QString m_i2pd_path;
    QString m_i2pd_datadir;
    QString m_i2pd_conf;
    QString m_i2pd_tunnels_dir;
    QString m_i2pd_tunnels_conf;
    QString m_i2pd_loglevel;
    QString m_i2pd_certsdir;
    QString m_i2pd_p2p_dat;
    QString m_i2pd_rpc_dat;

    int m_p2p_port = 18085;
    int m_rpc_port = 18089;
    bool started = false;
    bool starting = false;

};

#endif // I2PMANAGER_H
