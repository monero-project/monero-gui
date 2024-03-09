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

#include "TransactionHistoryModel.h"
#include "TransactionHistory.h"
#include "TransactionInfo.h"

#include <QDateTime>
#include <QDebug>


TransactionHistoryModel::TransactionHistoryModel(QObject *parent)
    : QAbstractListModel(parent), m_transactionHistory(nullptr)
{

}

void TransactionHistoryModel::setTransactionHistory(TransactionHistory *th)
{
    beginResetModel();
    m_transactionHistory = th;
    endResetModel();

    connect(m_transactionHistory, &TransactionHistory::refreshStarted,
            this, &TransactionHistoryModel::beginResetModel);
    connect(m_transactionHistory, &TransactionHistory::refreshFinished,
            this, &TransactionHistoryModel::endResetModel);

    emit transactionHistoryChanged();
}

TransactionHistory *TransactionHistoryModel::transactionHistory() const
{
    return m_transactionHistory;
}

QVariant TransactionHistoryModel::parseTransactionInfo(const TransactionInfo &tInfo, int role) const
{
    switch (role)
    {
    case TransactionDirectionRole:
        return QVariant::fromValue(tInfo.direction());
    case TransactionPendingRole:
        return tInfo.isPending();
    case TransactionFailedRole:
        return tInfo.isFailed();
    case TransactionAmountRole:
        return tInfo.amount();
    case TransactionDisplayAmountRole:
        return tInfo.displayAmount();
    case TransactionAtomicAmountRole:
        return tInfo.atomicAmount();
    case TransactionFeeRole:
        return tInfo.fee();
    case TransactionBlockHeightRole:
    {
        // Use NULL QVariant for transactions without height.
        // Forces them to be displayed at top when sorted by blockHeight.
        if (tInfo.blockHeight() != 0)
        {
            return tInfo.blockHeight();
        }
        return QVariant();
    }
    case TransactionSubaddrIndexRole:
    {
        QString str = QString{""};
        bool first = true;
        for (quint32 i : tInfo.subaddrIndex())
        {
            if (!first)
                str += QString{","};
            first = false;
            str += QString::number(i);
        }
        return str;
    }
    case TransactionSubaddrAccountRole:
        return tInfo.subaddrAccount();
    case TransactionLabelRole:
        return tInfo.subaddrIndex().size() == 1 && *tInfo.subaddrIndex().begin() == 0 ? tr("Primary address") : tInfo.label();
    case TransactionConfirmationsRole:
        return tInfo.confirmations();
    case TransactionConfirmationsRequiredRole:
        return (tInfo.blockHeight() < tInfo.unlockTime()) ? tInfo.unlockTime() - tInfo.blockHeight() : 10;
    case TransactionHashRole:
        return tInfo.hash();
    case TransactionTimeStampRole:
        return tInfo.timestamp();
    case TransactionPaymentIdRole:
        return tInfo.paymentId();
    case TransactionIsOutRole:
        return tInfo.direction() == TransactionInfo::Direction_Out;
    case TransactionDateRole:
        return tInfo.date();
    case TransactionTimeRole:
        return tInfo.time();
    case TransactionDestinationsRole:
        return tInfo.destinations_formatted();
    default:
    {
        qCritical() << "Unimplemented role" << role;
        return QVariant();
    }
    }
}

QVariant TransactionHistoryModel::data(const QModelIndex &index, int role) const
{
    if (!m_transactionHistory) {
        return QVariant();
    }

    QVariant result;
    bool found = m_transactionHistory->transaction(index.row(), [this, &result, &role](const TransactionInfo &tInfo) {
        result = parseTransactionInfo(tInfo, role);
    });
    if (!found) {
        qCritical("%s: internal error: no transaction info for index %d", __FUNCTION__, index.row());
    }
    return result;
}

int TransactionHistoryModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_transactionHistory ? m_transactionHistory->count() : 0;
}

QHash<int, QByteArray> TransactionHistoryModel::roleNames() const
{
    QHash<int, QByteArray> roleNames = QAbstractListModel::roleNames();
    roleNames.insert(TransactionDirectionRole, "direction");
    roleNames.insert(TransactionPendingRole, "isPending");
    roleNames.insert(TransactionFailedRole, "isFailed");
    roleNames.insert(TransactionAmountRole, "amount");
    roleNames.insert(TransactionDisplayAmountRole, "displayAmount");
    roleNames.insert(TransactionAtomicAmountRole, "atomicAmount");
    roleNames.insert(TransactionFeeRole, "fee");
    roleNames.insert(TransactionBlockHeightRole, "blockHeight");
    roleNames.insert(TransactionSubaddrIndexRole, "subaddrIndex");
    roleNames.insert(TransactionSubaddrAccountRole, "subaddrAccount");
    roleNames.insert(TransactionLabelRole, "label");
    roleNames.insert(TransactionConfirmationsRole, "confirmations");
    roleNames.insert(TransactionConfirmationsRequiredRole, "confirmationsRequired");
    roleNames.insert(TransactionHashRole, "hash");
    roleNames.insert(TransactionTimeStampRole, "timeStamp");
    roleNames.insert(TransactionPaymentIdRole, "paymentId");
    roleNames.insert(TransactionIsOutRole, "isOut");
    roleNames.insert(TransactionDateRole, "date");
    roleNames.insert(TransactionTimeRole, "time");
    roleNames.insert(TransactionDestinationsRole, "destinations");
    return roleNames;
}


