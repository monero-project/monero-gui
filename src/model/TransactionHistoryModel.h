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

#ifndef TRANSACTIONHISTORYMODEL_H
#define TRANSACTIONHISTORYMODEL_H

#include <QAbstractListModel>

class TransactionHistory;
class TransactionInfo;

/**
 * @brief The TransactionHistoryModel class - read-only list model for Transaction History
 */

class TransactionHistoryModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(TransactionHistory * transactionHistory READ transactionHistory WRITE setTransactionHistory NOTIFY transactionHistoryChanged)

public:
    enum TransactionInfoRole {
        TransactionDirectionRole = Qt::UserRole + 1,
        TransactionPendingRole,
        TransactionFailedRole,
        TransactionAmountRole,
        TransactionDisplayAmountRole,
        TransactionFeeRole,
        TransactionBlockHeightRole,
        TransactionSubaddrIndexRole,
        TransactionSubaddrAccountRole,
        TransactionLabelRole,
        TransactionConfirmationsRole,
        TransactionConfirmationsRequiredRole,
        TransactionHashRole,
        TransactionTimeStampRole,
        TransactionPaymentIdRole,
        // extra role (alias) for TransactionDirectionRole (as UI currently wants just boolean "out")
        TransactionIsOutRole,
        // extra roles for date and time (as UI wants date and time separately)
        TransactionDateRole,
        TransactionTimeRole,
        TransactionAtomicAmountRole,
        // only for outgoing
        TransactionDestinationsRole
    };
    Q_ENUM(TransactionInfoRole)

    TransactionHistoryModel(QObject * parent = 0);
    void setTransactionHistory(TransactionHistory * th);
    TransactionHistory * transactionHistory() const;
    /**
     * @brief dateFrom - returns firstmost transaction datetime
     * @return
     */
    QDateTime firstDateTime() const;

    /**
     * @brief dateTo - returns lastmost transaction datetime
     * @return
     */
    QDateTime lastDateTime() const;



    /// QAbstractListModel
    virtual QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const override;
    virtual int rowCount(const QModelIndex & parent = QModelIndex()) const override;
    virtual QHash<int, QByteArray> roleNames() const  override;

signals:
    void transactionHistoryChanged();

private:
    QVariant parseTransactionInfo(const TransactionInfo &tInfo, int role) const;

private:
    TransactionHistory * m_transactionHistory;
};

#endif // TRANSACTIONHISTORYMODEL_H
