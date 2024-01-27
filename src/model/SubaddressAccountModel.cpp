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

#include "SubaddressAccountModel.h"
#include "SubaddressAccount.h"
#include <QDebug>
#include <QHash>
#include <wallet/api/wallet2_api.h>

SubaddressAccountModel::SubaddressAccountModel(QObject *parent, SubaddressAccount *subaddressAccount)
    : QAbstractListModel(parent), m_subaddressAccount(subaddressAccount)
{
    connect(m_subaddressAccount,SIGNAL(refreshStarted()),this,SLOT(startReset()));
    connect(m_subaddressAccount,SIGNAL(refreshFinished()),this,SLOT(endReset()));
}

void SubaddressAccountModel::startReset(){
    beginResetModel();
}
void SubaddressAccountModel::endReset(){
    endResetModel();
}

int SubaddressAccountModel::rowCount(const QModelIndex &) const
{
    return m_subaddressAccount->count();
}

QVariant SubaddressAccountModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || static_cast<quint64>(index.row()) >= m_subaddressAccount->count())
        return {};

    QVariant result;

    bool found = m_subaddressAccount->getRow(index.row(), [&result, &role](const Monero::SubaddressAccountRow &row) {
        switch (role) {
        case SubaddressAccountAddressRole:
            result = QString::fromStdString(row.getAddress());
            break;
        case SubaddressAccountLabelRole:
            result = QString::fromStdString(row.getLabel());
            break;
        case SubaddressAccountBalanceRole:
            result = QString::fromStdString(row.getBalance());
            break;
        case SubaddressAccountUnlockedBalanceRole:
            result = QString::fromStdString(row.getUnlockedBalance());
            break;
        default:
            qCritical() << "Unimplemented role" << role;
        }
    });
    if (!found) {
        qCritical("%s: internal error: invalid index %d", __FUNCTION__, index.row());
    }

    return result;
}

QHash<int, QByteArray> SubaddressAccountModel::roleNames() const
{
    static QHash<int, QByteArray> roleNames;
    if (roleNames.empty())
    {
        roleNames.insert(SubaddressAccountAddressRole, "address");
        roleNames.insert(SubaddressAccountLabelRole, "label");
        roleNames.insert(SubaddressAccountBalanceRole, "balance");
        roleNames.insert(SubaddressAccountUnlockedBalanceRole, "unlockedBalance");
    }
    return roleNames;
}
