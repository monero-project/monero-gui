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
#include "Currency.h"

#include "QLocale"

namespace Currencies {
    Currency * const USD = new Currency(
                QStringLiteral("USD"),
                QChar('$'),
                2);
    Currency * const GBP = new Currency(
                QStringLiteral("GBP"),
                QChar(0x00A3),
                2);
    Currency * const EUR = new Currency(
                QStringLiteral("EUR"),
                QChar(0x20AC),
                2);
    Currency * const JPY = new Currency(
                QStringLiteral("JPY"),
                QChar(0x00A5),
                2);
    Currency * const CNY = new Currency(
                QStringLiteral("CNY"),
                QChar(0x00A5),
                2);
    Currency * const KRW = new Currency(
                QStringLiteral("KRW"),
                QChar(0x20A9),
                0);
    Currency * const BTC = new Currency(
                QStringLiteral("BTC"),
                // Using a Thai Bhat symbol right now since most OS fonts still don't support Unicode 10
                QChar(0x0E3F),
                9);
    Currency * const ETH = new Currency(
                QStringLiteral("ETH"),
                QChar(0x039E),
                6);
}


Currency::Currency(const QString label, const QChar symbol, const int precision, QObject *parent) :
    QObject(parent),
    m_label(label),
    m_symbol(symbol),
    m_precision(precision)
{
}

QString Currency::label() const
{
    return m_label;
}

QChar Currency::symbol() const
{
    return m_symbol;
}

int Currency::precision() const
{
    return m_precision;
}

QString Currency::format(qreal amount) const
{
    return QLocale().toCurrencyString(amount, m_symbol, m_precision);
}


