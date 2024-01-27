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

#ifndef TRANSACTIONINFO_H
#define TRANSACTIONINFO_H

#include <wallet/api/wallet2_api.h>
#include <QObject>
#include <QDateTime>
#include <QSet>

class Transfer;

class TransactionInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Direction direction READ direction)
    Q_PROPERTY(bool isPending READ isPending)
    Q_PROPERTY(bool isFailed READ isFailed)
    Q_PROPERTY(bool isCoinbase READ isCoinbase)
    Q_PROPERTY(double amount READ amount)
    Q_PROPERTY(quint64 atomicAmount READ atomicAmount)
    Q_PROPERTY(QString displayAmount READ displayAmount)
    Q_PROPERTY(QString fee READ fee)
    Q_PROPERTY(quint64 blockHeight READ blockHeight)
    Q_PROPERTY(QSet<quint32> subaddrIndex READ subaddrIndex)
    Q_PROPERTY(quint32 subaddrAccount READ subaddrAccount)
    Q_PROPERTY(QString label READ label)
    Q_PROPERTY(quint64 confirmations READ confirmations)
    Q_PROPERTY(quint64 unlockTime READ unlockTime)
    Q_PROPERTY(QString hash READ hash)
    Q_PROPERTY(QDateTime timestamp READ timestamp)
    Q_PROPERTY(QString date READ date)
    Q_PROPERTY(QString time READ time)
    Q_PROPERTY(QString paymentId READ paymentId)
    Q_PROPERTY(QString description READ description)
    Q_PROPERTY(QString destinations_formatted READ destinations_formatted)

public:
    enum Direction {
        Direction_In  =  Monero::TransactionInfo::Direction_In,
        Direction_Out =  Monero::TransactionInfo::Direction_Out,
        Direction_Both // invalid direction value, used for filtering
    };

    Q_ENUM(Direction)

    Direction  direction() const;
    bool isPending() const;
    bool isFailed() const;
    bool isCoinbase() const;
    double amount() const;
    quint64 atomicAmount() const;
    QString displayAmount() const;
    QString fee() const;
    quint64 blockHeight() const;
    QSet<quint32> subaddrIndex() const;
    quint32 subaddrAccount() const;
    QString label() const;
    quint64 confirmations() const;
    quint64 unlockTime() const;
    //! transaction_id
    QString hash() const;
    QDateTime timestamp() const;
    QString date() const;
    QString time() const;
    QString paymentId() const;
    QString description() const;
    //! only applicable for output transactions
    //! used in tx details popup
    QString destinations_formatted() const;
private:
    explicit TransactionInfo(const Monero::TransactionInfo *pimpl, QObject *parent = 0);
private:
    friend class TransactionHistory;
    mutable QList<Transfer*> m_transfers;
    quint64 m_amount;
    quint64 m_blockHeight;
    quint64 m_confirmations;
    Direction m_direction;
    bool m_failed;
    quint64 m_fee;
    QString m_hash;
    QString m_label;
    QString m_paymentId;
    QString m_description;
    bool m_pending;
    bool m_coinbase;
    quint32 m_subaddrAccount;
    QSet<quint32> m_subaddrIndex;
    QDateTime m_timestamp;
    quint64 m_unlockTime;
};

#endif // TRANSACTIONINFO_H
