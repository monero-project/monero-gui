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

#include "Coins.h"
#include "qt/FutureScheduler.h"

#include <QDebug>
#include <QHash>

#include <algorithm>

Coins::Coins(Monero::Wallet *walletImpl, FutureScheduler &scheduler, QObject *parent)
    : QObject(parent)
    , m_walletImpl(walletImpl)
    , m_scheduler(scheduler)
    , m_accountIndex(0)
    , m_refreshing(false)
    , m_refreshPending(false)
    , m_generation(0)
{
}

void Coins::refresh(quint32 accountIndex)
{
    m_accountIndex = accountIndex;

    // Incoming money arrives in bursts during a wallet refresh, and every fetch waits for the refresh.
    // At most one fetch is in flight; requests made meanwhile collapse into one follow-up.
    if (m_refreshing)
    {
        m_refreshPending = true;
        return;
    }

    m_refreshing = true;
    const quint64 generation = ++m_generation;
    const auto future = m_scheduler.run([this, accountIndex, generation] {
        const QList<CoinsInfo> rows = fetch(accountIndex);
        QMetaObject::invokeMethod(this, [this, generation, rows] {
            m_refreshing = false;
            apply(generation, rows);
            if (m_refreshPending)
            {
                m_refreshPending = false;
                refresh(m_accountIndex);
            }
        }, Qt::QueuedConnection);
    });
    if (!future.first)
    {
        m_refreshing = false;
    }
}

void Coins::setFrozenAsync(const QString &publicKey, bool frozen, const QJSValue &callback)
{
    const quint32 accountIndex = m_accountIndex;

    const auto future = m_scheduler.run(
        [this, publicKey, frozen, accountIndex] {
            if (frozen)
                m_walletImpl->freezeByPubKey(publicKey.toStdString());
            else
                m_walletImpl->thawByPubKey(publicKey.toStdString());

            const bool success = m_walletImpl->status() == Monero::Wallet::Status_Ok;
            const QString error = success ? QString() : QString::fromStdString(m_walletImpl->errorString());

            // bumped after the change: refreshes that may have read the old state are now stale
            const quint64 generation = ++m_generation;
            const QList<CoinsInfo> rows = fetch(accountIndex);
            QMetaObject::invokeMethod(this, [this, generation, rows] {
                apply(generation, rows);
            }, Qt::QueuedConnection);
            return QJSValueList({QJSValue(success), QJSValue(error)});
        },
        callback);
    if (!future.first)
    {
        QJSValue(callback).call(QJSValueList({QJSValue(false), QJSValue(QString())}));
    }
}

QList<CoinsInfo> Coins::fetch(quint32 accountIndex) const
{
    QList<CoinsInfo> rows;
    QHash<quint32, QString> labels;

    for (const auto &enote : m_walletImpl->getEnoteDetails()) {
        if (!enote || enote->subaddressIndexMajor() != accountIndex || enote->isSpent()) {
            continue;
        }

        const quint32 subaddrIndex = enote->subaddressIndexMinor();
        if (!labels.contains(subaddrIndex)) {
            labels.insert(subaddrIndex, QString::fromStdString(m_walletImpl->getSubaddressLabel(accountIndex, subaddrIndex)));
        }

        rows.append({
            enote->blockHeight(),
            QString::fromStdString(enote->txId()),
            enote->internalEnoteIndex(),
            enote->amount(),
            enote->isFrozen(),
            enote->isUnlocked(),
            subaddrIndex,
            labels.value(subaddrIndex),
            QString::fromStdString(enote->onetimeAddress()),
        });
    }

    std::stable_sort(rows.begin(), rows.end(), [](const CoinsInfo &a, const CoinsInfo &b) {
        return a.blockHeight > b.blockHeight;
    });

    return rows;
}

void Coins::apply(quint64 generation, const QList<CoinsInfo> &rows)
{
    if (generation != m_generation) {
        return;
    }

    emit refreshStarted();
    m_rows = rows;
    emit refreshFinished();
}

bool Coins::coin(int index, std::function<void (const CoinsInfo &)> callback) const
{
    if (index < 0 || index >= m_rows.size())
    {
        return false;
    }

    callback(m_rows[index]);
    return true;
}

quint64 Coins::count() const
{
    return m_rows.size();
}
