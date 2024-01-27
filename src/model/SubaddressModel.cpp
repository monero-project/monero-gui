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

#include "SubaddressModel.h"
#include "Subaddress.h"
#include <QDebug>
#include <QHash>
#include <wallet/api/wallet2_api.h>

SubaddressModel::SubaddressModel(QObject *parent, Subaddress *subaddress)
    : QAbstractListModel(parent), m_subaddress(subaddress)
{
    connect(m_subaddress,SIGNAL(refreshStarted()),this,SLOT(startReset()));
    connect(m_subaddress,SIGNAL(refreshFinished()),this,SLOT(endReset()));

}

void SubaddressModel::startReset(){
    beginResetModel();
}
void SubaddressModel::endReset(){
    endResetModel();
}

int SubaddressModel::rowCount(const QModelIndex &) const
{
    return m_subaddress->count();
}

QVariant SubaddressModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || static_cast<quint64>(index.row()) >= m_subaddress->count())
        return {};

    QVariant result;

    bool found = m_subaddress->getRow(index.row(), [&index, &result, &role](const Monero::SubaddressRow &subaddress) {
        switch (role) {
        case SubaddressAddressRole:
            result = QString::fromStdString(subaddress.getAddress());
            break;
        case SubaddressLabelRole:
            result = index.row() == 0 ? tr("Primary address") : QString::fromStdString(subaddress.getLabel());
            break;
        default:
            qCritical() << "Unimplemented role" << role;
        }
    });
    if (!found)
    {
        qCritical("%s: internal error: invalid index %d", __FUNCTION__, index.row());
    }

    return result;
}

QHash<int, QByteArray> SubaddressModel::roleNames() const
{
    static QHash<int, QByteArray> roleNames;
    if (roleNames.empty())
    {
        roleNames.insert(SubaddressAddressRole, "address");
        roleNames.insert(SubaddressLabelRole, "label");
    }
    return roleNames;
}
