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

#include "CoinsModel.h"
#include "Coins.h"
#include "WalletManager.h"
#include <QDebug>
#include <QHash>

CoinsModel::CoinsModel(QObject *parent, Coins *coins)
    : QAbstractListModel(parent), m_coins(coins)
{
    connect(m_coins, &Coins::refreshStarted, this, &CoinsModel::startReset);
    connect(m_coins, &Coins::refreshFinished, this, &CoinsModel::endReset);
}

void CoinsModel::startReset(){
    beginResetModel();
}
void CoinsModel::endReset(){
    endResetModel();
}

int CoinsModel::rowCount(const QModelIndex &) const
{
    return m_coins->count();
}

QVariant CoinsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || static_cast<quint64>(index.row()) >= m_coins->count())
        return {};

    QVariant result;

    bool found = m_coins->coin(index.row(), [&result, &role](const CoinsInfo &coin) {
        switch (role) {
        case CoinsHashRole:
            result = coin.hash;
            break;
        case CoinsOutputIndexRole:
            result = coin.internalOutputIndex;
            break;
        case CoinsBlockHeightRole:
            result = coin.blockHeight;
            break;
        case CoinsAmountRole:
            result = WalletManager::displayAmount(coin.amount);
            break;
        case CoinsAtomicAmountRole:
            result = coin.amount;
            break;
        case CoinsFrozenRole:
            result = coin.frozen;
            break;
        case CoinsUnlockedRole:
            result = coin.unlocked;
            break;
        case CoinsSubaddrIndexRole:
            result = coin.subaddrIndex;
            break;
        case CoinsAddressLabelRole:
            result = coin.subaddrIndex == 0 ? tr("Primary address") : coin.addressLabel;
            break;
        case CoinsPubKeyRole:
            result = coin.pubKey;
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

QHash<int, QByteArray> CoinsModel::roleNames() const
{
    static QHash<int, QByteArray> roleNames;
    if (roleNames.empty())
    {
        roleNames.insert(CoinsHashRole, "hash");
        roleNames.insert(CoinsOutputIndexRole, "outputIndex");
        roleNames.insert(CoinsBlockHeightRole, "blockHeight");
        roleNames.insert(CoinsAmountRole, "amount");
        roleNames.insert(CoinsAtomicAmountRole, "atomicAmount");
        roleNames.insert(CoinsFrozenRole, "frozen");
        roleNames.insert(CoinsUnlockedRole, "unlocked");
        roleNames.insert(CoinsSubaddrIndexRole, "subaddrIndex");
        roleNames.insert(CoinsAddressLabelRole, "addressLabel");
        roleNames.insert(CoinsPubKeyRole, "pubKey");
    }
    return roleNames;
}
