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
#include "Price.h"

#include <QDateTime>
#include <QLocale>
#include <QDebug>

#include "Currency.h"

namespace {
    static const qint64 DEFAULT_STALE_TIME_MILLISECONDS = 900 * 1000;
    static const qint64 MONERO_STANDARD_UNIT = 1000000000000;
}

Price::Price(QObject *parent) : QObject(parent),
    m_price(0),
    m_currency(Currencies::BTC)
{
    m_lastUpdated = QDateTime();
}

void Price::update(qreal price, Currency * currency)
{
    m_price = price;
    m_currency = currency;
    m_lastUpdated = QDateTime::currentDateTimeUtc();
    qDebug() << __FUNCTION__ << ": Updated price: " << m_price << ", currency: " << m_currency << ", last updated: " << m_lastUpdated.toString();
    emit updated();
}

QString Price::currencyCode() const
{
    return m_currency->label();
}

qreal Price::price() const
{
    return m_price;
}

QDateTime Price::lastUpdated() const
{
    return m_lastUpdated;
}

bool Price::stale() const
{
    return m_lastUpdated.isNull() ||
            (QDateTime::currentMSecsSinceEpoch() - m_lastUpdated.toMSecsSinceEpoch() > DEFAULT_STALE_TIME_MILLISECONDS);
}

QString Price::convert(quint64 amount) const
{
    if (stale()) {
        qWarning() << __FUNCTION__ << ": convert() called while price is stale (last updated: " << m_lastUpdated.toString() << ")";
        return QString();
    }

    if (!m_currency) {
        qWarning() << __FUNCTION__ << ": convert() called when no currency was selected";
        return QString();
    }

    qreal total = amount * m_price / MONERO_STANDARD_UNIT;
    return m_currency->format(total);
}

Currency * Price::currency() const
{
    return m_currency;
}
