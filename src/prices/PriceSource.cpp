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
#include "PriceSource.h"

#include <QVariant>
#include <QDebug>
#include <QMetaType>
#include <QUrl>
#include <QUrlQuery>

#include "Currency.h"
#include "Price.h"
#include "qtjsonpath.h"

namespace PriceSources {
    PriceSource * const CoinMarketCap = new CoinMarketCapSource();
    PriceSource * const Binance = new BinanceSource();
    PriceSource * const CryptoCompare = new CryptoCompareSource();
}

QUrl CoinMarketCapSource::renderUrl(Currency * currency)
{
    QUrl rendered(m_baseUrl);
    QUrlQuery query = QUrlQuery();
    query.addQueryItem(QStringLiteral("convert"), currency->label());
    rendered.setQuery(query);
    return rendered;
}

bool CoinMarketCapSource::updatePriceFromReply(Price *price, Currency * currency, QJsonDocument &reply)
{
    QtJsonPath walker(reply);
    QString modpath = QString(QStringLiteral("data/quotes/"))
            .append(currency->label())
            .append(QStringLiteral("/price"));
    QVariant res = walker.getValue(modpath);
    if (!res.isValid() || res.isNull() || res.userType() != QMetaType::Double) {
        qWarning() << __FUNCTION__ << ": Invalid parsing of response from JSON; ignoring price update";
        return false;
    }

    price->update(res.toDouble(), currency);
    return true;
}

QUrl BinanceSource::renderUrl(Currency * currency)
{
    QUrl rendered(m_baseUrl);
    QUrlQuery query = QUrlQuery();
    QString pair(QStringLiteral("XMR"));
    pair.append(currency->label());
    query.addQueryItem(QStringLiteral("symbol"), pair);
    rendered.setQuery(query);
    return rendered;
}

bool BinanceSource::updatePriceFromReply(Price *price, Currency * currency, QJsonDocument &reply)
{
    if (!reply.isObject() || reply.isEmpty()) {
        qWarning() << __FUNCTION__ << ": Invalid JSON response [reply is not object or empty]; ignoring price update";
        return false;
    }

    QString priceRaw = reply
            .object()
            .value(QStringLiteral("lastPrice"))
            .toString();
    if (priceRaw.isNull()) {
        qWarning() << __FUNCTION__ << ": Invalid JSON response [does not contain valid key 'lastPrice']; ignoring price update";
        return false;
    }

    bool success;
    qreal priceDouble = priceRaw.toDouble(&success);
    if (!success) {
        qWarning() << __FUNCTION__ << ": Invalid JSON response [value " << priceRaw << " at key 'lastPrice' cannot be converted to double]; ignoring price update";
        return false;
    }

    price->update(priceDouble, currency);
    return true;
}


QUrl CryptoCompareSource::renderUrl(Currency * currency) {
    QUrl rendered(m_baseUrl);
    QUrlQuery query = QUrlQuery();
    query.addQueryItem(QStringLiteral("fsym"), QStringLiteral("XMR"));
    query.addQueryItem(QStringLiteral("tsyms"), currency->label());
    rendered.setQuery(query);
    return rendered;
}

bool CryptoCompareSource::updatePriceFromReply(Price *price, Currency * currency, QJsonDocument &reply)
{
    if (!reply.isObject() || reply.isEmpty()) {
        qWarning() << __FUNCTION__ << ": Invalid JSON response [reply is not object or empty]; ignoring price update";
        return false;
    }

    QJsonValue priceRaw = reply
            .object()
            .value(currency->label());
    if (priceRaw.isNull()) {
        qWarning() << __FUNCTION__ << ": Invalid JSON response [does not contain valid key '" << currency->label() << "']; ignoring price update";
        return false;
    }

    qreal priceDouble = priceRaw.toDouble();
    if (priceDouble == 0.0) {
        qWarning() << __FUNCTION__ << ": Invalid JSON response [value " << priceRaw << " at key '"<< currency->label() << "' cannot be converted to double]; ignoring price update";
        return false;
    }

    price->update(priceDouble, currency);
    return true;
}
