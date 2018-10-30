// Copyright (c) 2018, The Monero Project
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
#ifndef PRICE_H
#define PRICE_H

#include <QObject>
#include <QDateTime>
#include <QString>

#include "Currency.h"

class PriceManager;

class Price : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal price READ price NOTIFY updated)
    Q_PROPERTY(QString currencyCode READ currencyCode NOTIFY updated)
    Q_PROPERTY(QDateTime lastUpdated READ lastUpdated NOTIFY updated)
    Q_PROPERTY(Currency * currency READ currency NOTIFY updated)
    Q_PROPERTY(bool stale READ stale NOTIFY updated)
public:
    qreal price() const;
    Currency * currency() const;
    QString currencyCode() const;
    QDateTime lastUpdated() const;
    bool stale() const;
    Q_INVOKABLE QString convert(quint64 amount) const;

signals:
    // Emitted when update is called
    void updated();

public:
    explicit Price(QObject *parent = nullptr);
    void update(qreal price, Currency *currency);

private:
    friend class PriceManager;
    friend class PriceSource;
    qreal m_price;
    Currency * m_currency;
    QDateTime m_lastUpdated;
};

#endif // PRICE_H
