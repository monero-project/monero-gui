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
#ifndef CURRENCY_H
#define CURRENCY_H

#include <QObject>
#include <QList>

class Currency : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString label READ label)
    Q_PROPERTY(QChar symbol READ symbol)
    Q_PROPERTY(int precision READ precision)
public:
    explicit Currency(const QString label = nullptr, const QChar symbol = 0, const int precision = 0, QObject *parent = nullptr);

    QString label() const;
    QChar symbol() const;
    int precision() const;
    Q_INVOKABLE QString format(qreal amount) const;

private:
    const QString m_label;
    const QChar m_symbol;
    const int m_precision;
};

namespace Currencies {
    extern Currency * const USD;
    extern Currency * const GBP;
    extern Currency * const EUR;
    extern Currency * const JPY;
    extern Currency * const CNY;
    extern Currency * const KRW;
    extern Currency * const BTC;
    extern Currency * const ETH;
}

#endif // CURRENCY_H
