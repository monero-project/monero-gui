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

#ifndef I2PManager_H
#define I2PManager_H

#include <memory>

#include <QMutex>
#include <QObject>
#include <QUrl>
#include <QProcess>
#include "qt/utils.h"
#include "I2PDaemon.h"

class I2PManager : public QObject
{
    Q_OBJECT

public:
    explicit I2PManager(QObject *parent = 0);
    ~I2PManager();

    Q_INVOKABLE bool start(bool allowIncomingConnections, bool outproxyEnabled, QString outproxy, int outproxyPort);
    Q_INVOKABLE void exit();
    Q_INVOKABLE bool running() const { return started; };
    Q_INVOKABLE static QString getVersion();
    Q_INVOKABLE QString getAddress() const;
    Q_INVOKABLE QString getProxyAddress() const;
    Q_INVOKABLE int getP2PPort() const { return m_port_p2p; };

signals:
    void i2pStartFailure(const QString &error) const;
    void i2pStartSuccess() const;
    void i2pStopped() const;

private:
    QString m_i2p_path;
    QString m_conf;
    QString m_tunnelsconf;
    QString m_tunnelsdir;
    QString m_loglevel;
    QString m_datadir;
    QString m_certsdir;
    QString m_keys;
    int m_port_p2p = 18085;
    int m_port_rpc = 18089;
    QString m_socks_host = QString("127.0.0.1");
    int m_socks_port = 4447;
    bool initialized = false;
    bool started = false;
    I2PDaemon m_i2pd;
};

#endif // I2PManager_H
