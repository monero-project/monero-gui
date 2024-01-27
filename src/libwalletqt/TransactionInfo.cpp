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

#include "TransactionInfo.h"
#include "WalletManager.h"
#include "Transfer.h"
#include <QDateTime>
#include <QDebug>

TransactionInfo::Direction TransactionInfo::direction() const
{
    return m_direction;
}

bool TransactionInfo::isPending() const
{
    return m_pending;
}

bool TransactionInfo::isFailed() const
{
    return m_failed;
}

bool TransactionInfo::isCoinbase() const
{
    return m_coinbase;
}

double TransactionInfo::amount() const
{
    // there's no unsigned uint64 for JS, so better use double
    return displayAmount().toDouble();
}

quint64 TransactionInfo::atomicAmount() const
{
    return m_amount;
}

QString TransactionInfo::displayAmount() const
{
    return WalletManager::displayAmount(m_amount);
}

QString TransactionInfo::fee() const
{
    if(m_fee == 0)
        return "";
    return WalletManager::displayAmount(m_fee);
}

quint64 TransactionInfo::blockHeight() const
{
    return m_blockHeight;
}

QSet<quint32> TransactionInfo::subaddrIndex() const
{
    return m_subaddrIndex;
}

quint32 TransactionInfo::subaddrAccount() const
{
    return m_subaddrAccount;
}

QString TransactionInfo::label() const
{
    return m_label;
}

quint64 TransactionInfo::confirmations() const
{
    return m_confirmations;
}

quint64 TransactionInfo::unlockTime() const
{
    return m_unlockTime;
}

QString TransactionInfo::hash() const
{
    return m_hash;
}

QDateTime TransactionInfo::timestamp() const
{
    return m_timestamp;
}

QString TransactionInfo::date() const
{
    return timestamp().date().toString(Qt::ISODate);
}

QString TransactionInfo::time() const
{
    return timestamp().time().toString(Qt::ISODate);
}

QString TransactionInfo::paymentId() const
{
    return m_paymentId;
}

QString TransactionInfo::description() const
{
    return m_description;
}

QString TransactionInfo::destinations_formatted() const
{
    QString destinations;
    for (auto const& t: m_transfers) {
        if (!destinations.isEmpty())
          destinations += "<br> ";
        destinations +=  WalletManager::displayAmount(t->amount()) + ": " + t->address();
    }
    return destinations;
}

TransactionInfo::TransactionInfo(const Monero::TransactionInfo *pimpl, QObject *parent)
    : QObject(parent)
    , m_amount(pimpl->amount())
    , m_blockHeight(pimpl->blockHeight())
    , m_confirmations(pimpl->confirmations())
    , m_direction(static_cast<Direction>(pimpl->direction()))
    , m_failed(pimpl->isFailed())
    , m_coinbase(pimpl->isCoinbase())
    , m_fee(pimpl->fee())
    , m_hash(QString::fromStdString(pimpl->hash()))
    , m_label(QString::fromStdString(pimpl->label()))
    , m_paymentId(QString::fromStdString(pimpl->paymentId()))
    , m_description(QString::fromStdString(pimpl->description()))
    , m_pending(pimpl->isPending())
    , m_subaddrAccount(pimpl->subaddrAccount())
    , m_timestamp(QDateTime::fromTime_t(pimpl->timestamp()))
    , m_unlockTime(pimpl->unlockTime())
{
    for (auto const &t: pimpl->transfers())
    {
        Transfer *transfer = new Transfer(t.amount, QString::fromStdString(t.address), this);
        m_transfers.append(transfer);
    }
    for (uint32_t i : pimpl->subaddrIndex())
    {
        m_subaddrIndex.insert(i);
    }
}
