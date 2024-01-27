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

#ifndef TRANSACTIONHISTORY_H
#define TRANSACTIONHISTORY_H

#include <functional>

#include <QObject>
#include <QList>
#include <QReadWriteLock>
#include <QDateTime>

namespace Monero {
struct TransactionHistory;
}

class TransactionInfo;

class TransactionHistory : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count)
    Q_PROPERTY(QDateTime firstDateTime READ firstDateTime NOTIFY firstDateTimeChanged)
    Q_PROPERTY(QDateTime lastDateTime READ lastDateTime NOTIFY lastDateTimeChanged)
    Q_PROPERTY(int minutesToUnlock READ minutesToUnlock)
    Q_PROPERTY(bool locked READ locked)

public:
    Q_INVOKABLE bool transaction(int index, std::function<void (TransactionInfo &)> callback);
    // Q_INVOKABLE TransactionInfo * transaction(const QString &id);
    Q_INVOKABLE void refresh(quint32 accountIndex);
    Q_INVOKABLE QString writeCSV(quint32 accountIndex, QString out);
    quint64 count() const;
    QDateTime firstDateTime() const;
    QDateTime lastDateTime() const;
    quint64 minutesToUnlock() const;
    bool locked() const;

signals:
    void refreshStarted() const;
    void refreshFinished() const;
    void firstDateTimeChanged() const;
    void lastDateTimeChanged() const;

public slots:


private:
    explicit TransactionHistory(Monero::TransactionHistory * pimpl, QObject *parent = 0);

private:
    friend class Wallet;
    mutable QReadWriteLock m_lock;
    Monero::TransactionHistory * m_pimpl;
    mutable QList<TransactionInfo*> m_tinfo;
    mutable QDateTime   m_firstDateTime;
    mutable QDateTime   m_lastDateTime;
    mutable int m_minutesToUnlock;
    // history contains locked transfers
    mutable bool m_locked;

};

#endif // TRANSACTIONHISTORY_H
