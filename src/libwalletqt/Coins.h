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

#ifndef COINS_H
#define COINS_H

#include <atomic>
#include <functional>

#include <wallet/api/wallet2_api.h>
#include <QJSValue>
#include <QObject>
#include <QList>
#include <QString>

class FutureScheduler;

struct CoinsInfo
{
    quint64 blockHeight;
    QString hash;
    quint64 internalOutputIndex;
    quint64 amount;
    bool frozen;
    bool unlocked;
    quint32 subaddrIndex;
    QString addressLabel;
    QString pubKey;
};

class Coins : public QObject
{
    Q_OBJECT
public:
    //! asynchronously lists the unspent outputs of the given account, newest first.
    //! call from this object's thread, as with setFrozenAsync()
    Q_INVOKABLE void refresh(quint32 accountIndex);
    //! asynchronously freezes or thaws an output, then calls callback(success, errorString)
    Q_INVOKABLE void setFrozenAsync(const QString &publicKey, bool frozen, const QJSValue &callback);
    bool coin(int index, std::function<void (const CoinsInfo &)> callback) const;
    quint64 count() const;

signals:
    void refreshStarted() const;
    void refreshFinished() const;

private:
    explicit Coins(Monero::Wallet *walletImpl, FutureScheduler &scheduler, QObject *parent);
    friend class Wallet;

    // blocks during a wallet refresh; call from the scheduler
    QList<CoinsInfo> fetch(quint32 accountIndex) const;
    // drops rows from requests older than the latest one
    void apply(quint64 generation, const QList<CoinsInfo> &rows);

    Monero::Wallet *m_walletImpl;
    FutureScheduler &m_scheduler;
    // only accessed from the thread this object lives in
    QList<CoinsInfo> m_rows;
    quint32 m_accountIndex;
    bool m_refreshing;
    bool m_refreshPending;
    // incremented for every fetch request
    std::atomic<quint64> m_generation;
};

#endif // COINS_H
