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

#include "i2p/I2pBridge.h"

#include <QTcpSocket>
#include <QTimer>

namespace
{
    // How long (ms) to wait for the TCP handshake before giving up.
    constexpr int PROBE_TIMEOUT_MS = 3000;
}

I2pBridge::I2pBridge(QObject *parent)
    : QObject(parent)
{
}

I2pBridge::~I2pBridge() = default;

void I2pBridge::probe(const QString &host, quint16 port)
{
    // Cancel any in-flight probe before starting a new one.
    if (m_socket)
    {
        m_socket->abort();
        m_socket->deleteLater();
        m_socket = nullptr;
    }

    m_socket = new QTcpSocket(this);

    connect(m_socket, &QTcpSocket::connected,      this, &I2pBridge::onConnected);
    connect(m_socket, &QAbstractSocket::errorOccurred, this, &I2pBridge::onErrorOccurred);

    m_socket->connectToHost(host, port);

    // Arm a timeout so we don't wait forever for an unreachable host.
    QTimer::singleShot(PROBE_TIMEOUT_MS, m_socket, [this]() {
        if (m_socket && m_socket->state() != QAbstractSocket::ConnectedState)
        {
            m_socket->abort();
            onErrorOccurred();
        }
    });
}

bool I2pBridge::isReachable() const
{
    return m_reachable;
}

QVariantMap I2pBridge::status(const QString &host, quint16 port) const
{
    QVariantMap map;
    map.insert("reachable", m_reachable);
    map.insert("samHost",   host);
    map.insert("samPort",   static_cast<int>(port));
    return map;
}

void I2pBridge::onConnected()
{
    if (m_socket)
    {
        m_socket->abort();
        m_socket->deleteLater();
        m_socket = nullptr;
    }
    setReachable(true);
    emit probeFinished(true);
}

void I2pBridge::onErrorOccurred()
{
    if (m_socket)
    {
        m_socket->deleteLater();
        m_socket = nullptr;
    }
    setReachable(false);
    emit probeFinished(false);
}

void I2pBridge::setReachable(bool reachable)
{
    if (m_reachable == reachable)
    {
        return;
    }
    m_reachable = reachable;
    emit reachableChanged(m_reachable);
}
