// Copyright (c) 2026, The Monero Project
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

#include "PeersModel.h"

#include <QDebug>
#include <QMetaObject>

#include "net/http_client.h"
#include "net/enums.h"
#include "rpc/core_rpc_server_commands_defs.h"
#include "storages/http_abstract_invoke.h"

namespace {

QString addressTypeToString(uint8_t addressType)
{
    switch (static_cast<epee::net_utils::address_type>(addressType))
    {
    case epee::net_utils::address_type::ipv4:
    case epee::net_utils::address_type::ipv6:
        return QStringLiteral("Clearnet");
    case epee::net_utils::address_type::i2p:
        return QStringLiteral("I2P");
    case epee::net_utils::address_type::tor:
        return QStringLiteral("Tor");
    default:
        return QStringLiteral("Unknown");
    }
}

} // namespace

PeersModel::PeersModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_scheduler(this)
{
}

PeersModel::~PeersModel()
{
    m_scheduler.shutdownWaitForFinished();
}

bool PeersModel::loading() const
{
    return m_loading;
}

void PeersModel::refresh(const QString &daemonAddress)
{
    if (m_loading)
        return;

    m_loading = true;
    emit loadingChanged();

    m_scheduler.run([this, daemonAddress] {
        QVariantList peers;

        const int splitIndex = daemonAddress.lastIndexOf(':');
        const QString host = splitIndex >= 0 ? daemonAddress.left(splitIndex) : daemonAddress;
        const QString port = splitIndex >= 0 ? daemonAddress.mid(splitIndex + 1) : QString();

        epee::net_utils::http::http_simple_client httpClient;
        httpClient.set_server(host.toStdString(), port.toStdString(), {});

        cryptonote::COMMAND_RPC_GET_CONNECTIONS::request req = AUTO_VAL_INIT(req);
        cryptonote::COMMAND_RPC_GET_CONNECTIONS::response res = AUTO_VAL_INIT(res);

        bool ok = epee::net_utils::invoke_http_json_rpc("/json_rpc", "get_connections", req, res, httpClient, std::chrono::seconds(3));
        if (ok)
        {
            for (const cryptonote::connection_info &conn : res.connections)
            {
                QVariantMap peer;
                peer.insert(QStringLiteral("incoming"), conn.incoming);
                peer.insert(QStringLiteral("address"), QString::fromStdString(conn.address));
                peer.insert(QStringLiteral("addressType"), addressTypeToString(conn.address_type));
                peer.insert(QStringLiteral("blockHeight"), static_cast<qulonglong>(conn.height));
                peer.insert(QStringLiteral("liveTime"), static_cast<qulonglong>(conn.live_time));
                peer.insert(QStringLiteral("recvCount"), static_cast<qulonglong>(conn.recv_count));
                peer.insert(QStringLiteral("sendCount"), static_cast<qulonglong>(conn.send_count));
                peers.append(peer);
            }
        }
        else
        {
            qDebug() << "PeersModel: get_connections RPC call failed for" << daemonAddress;
        }

        QMetaObject::invokeMethod(this, "onConnectionsFetched", Qt::QueuedConnection, Q_ARG(QVariantList, peers));
    });
}

void PeersModel::onConnectionsFetched(const QVariantList &peers)
{
    beginResetModel();
    m_peers = peers;
    endResetModel();

    m_loading = false;
    emit loadingChanged();
}

QVariant PeersModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_peers.size())
        return QVariant();

    const QString key = QString::fromLatin1(roleNames().value(role));
    if (key.isEmpty())
        return QVariant();

    return m_peers.at(index.row()).toMap().value(key);
}

int PeersModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_peers.size();
}

QHash<int, QByteArray> PeersModel::roleNames() const
{
    QHash<int, QByteArray> roles = QAbstractListModel::roleNames();
    roles.insert(IncomingRole, "incoming");
    roles.insert(AddressRole, "address");
    roles.insert(AddressTypeRole, "addressType");
    roles.insert(HeightRole, "blockHeight");
    roles.insert(LiveTimeRole, "liveTime");
    roles.insert(RecvCountRole, "recvCount");
    roles.insert(SendCountRole, "sendCount");
    return roles;
}
