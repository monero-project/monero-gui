// Copyright (c) 2014-2019, The Monero Project
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
    qDebug(__FUNCTION__);
    connect(m_subaddressAccount,SIGNAL(refreshStarted()),this,SLOT(startReset()));
    connect(m_subaddressAccount,SIGNAL(refreshFinished()),this,SLOT(endReset()));
}

void SubaddressAccountModel::startReset(){
    qDebug("SubaddressAccountModel::startReset");
    beginResetModel();
}
void SubaddressAccountModel::endReset(){
    qDebug("SubaddressAccountModel::endReset");
    endResetModel();
}

int SubaddressAccountModel::rowCount(const QModelIndex &) const
{
    return m_subaddressAccount->count();
}

QVariant SubaddressAccountModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || (unsigned)index.row() >= m_subaddressAccount->count())
        return {};

    Monero::SubaddressAccountRow * sr = m_subaddressAccount->getRow(index.row());

    QVariant result = "";
    switch (role) {
    case SubaddressAccountAddressRole:
        result = QString::fromStdString(sr->getAddress());
        break;
    case SubaddressAccountLabelRole:
        result = QString::fromStdString(sr->getLabel());
        break;
    case SubaddressAccountBalanceRole:
        result = QString::fromStdString(sr->getBalance());
        break;
    case SubaddressAccountUnlockedBalanceRole:
        result = QString::fromStdString(sr->getUnlockedBalance());
        break;
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
