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

#ifndef I2PBRIDGE_H
#define I2PBRIDGE_H

#include <QObject>
#include <QString>
#include <QVariantMap>

class QTcpSocket;

/// Lightweight helper that verifies a SAMv3-capable I2P router is reachable on
/// the local machine.  The Monero daemon speaks SAMv3 natively; this class
/// only needs to confirm the bridge port is open before the GUI passes
/// --tx-proxy / --anonymous-inbound to monerod.
class I2pBridge : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool reachable READ isReachable NOTIFY reachableChanged)

public:
    static constexpr quint16 DEFAULT_SAM_PORT = 7656;

    explicit I2pBridge(QObject *parent = nullptr);
    ~I2pBridge() override;

    /// Probe the SAM bridge at host:port with a non-blocking TCP connect.
    /// Emits probeFinished(bool) when done; also updates the reachable property.
    Q_INVOKABLE void probe(const QString &host, quint16 port);

    /// True if the last probe() succeeded.
    Q_INVOKABLE bool isReachable() const;

    /// Status snapshot: { reachable, samHost, samPort }.
    Q_INVOKABLE QVariantMap status(const QString &host, quint16 port) const;

signals:
    void reachableChanged(bool reachable);
    /// Emitted when a probe() call completes (success or failure).
    void probeFinished(bool reachable);

private slots:
    void onConnected();
    void onErrorOccurred();

private:
    void setReachable(bool reachable);

    QTcpSocket *m_socket = nullptr;
    bool m_reachable     = false;
};

#endif // I2PBRIDGE_H
