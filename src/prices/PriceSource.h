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
#ifndef PRICESOURCE_H
#define PRICESOURCE_H

#include <QObject>
#include <QUrl>
#include <QString>
#include <QList>
#include <QGuiApplication>

#include "Currency.h"

class Price;

class PriceSource : public QObject
{
    Q_OBJECT

    // Label of the source, IE, "CoinMarketCap"
    Q_PROPERTY(QString label READ label)
    // URL used to contact the API for prices
    Q_PROPERTY(QUrl baseUrl READ baseUrl)

public:
    explicit PriceSource(QObject *parent = nullptr) : QObject(parent) {}
    virtual QString label() const = 0;
    virtual QUrl baseUrl() const = 0;
    virtual QList<Currency*> currenciesAvailable() const = 0;
    virtual bool updatePriceFromReply(Price * price, Currency * currency, QJsonDocument & reply) = 0;
    virtual QUrl renderUrl(Currency * currency) = 0;

private:
    friend class PriceManager;
};

class CoinMarketCapSource : public PriceSource
{
    Q_OBJECT

public:
    using PriceSource::PriceSource;
    QString label() const {return m_label; }
    QUrl baseUrl() const {return m_baseUrl; }
    QList<Currency*> currenciesAvailable() const { return m_currenciesAvailable; }
    bool updatePriceFromReply(Price *price, Currency *currency, QJsonDocument &reply);
    QUrl renderUrl(Currency *currency);

private:
    const QString m_label = QLatin1Literal("CoinMarketCap");
    const QList<Currency*> m_currenciesAvailable = {Currencies::USD, Currencies::BTC, Currencies::GBP};
    const QUrl m_baseUrl = QUrl(QLatin1Literal("https://api.coinmarketcap.com/v2/ticker/328/"));
    const QString m_jsonPath = QLatin1Literal("data/quotes/{CURRENCY}/price");
};

class BinanceSource : public PriceSource
{
    Q_OBJECT

public:
    using PriceSource::PriceSource;
    QString label() const {return m_label; }
    QUrl baseUrl() const {return m_baseUrl; }
    QList<Currency*> currenciesAvailable() const { return m_currenciesAvailable; }
    bool updatePriceFromReply(Price *price, Currency *currency, QJsonDocument &reply);
    QUrl renderUrl(Currency *currency);

private:
    const QString m_label = QLatin1Literal("Binance");
    const QList<Currency*> m_currenciesAvailable = {Currencies::BTC};
    const QUrl m_baseUrl = QUrl(QLatin1Literal("https://api.binance.com/api/v1/ticker/24hr"));
};

class CryptoCompareSource: public PriceSource
{
    Q_OBJECT

public:
    using PriceSource::PriceSource;
    QString label() const {return m_label; }
    QUrl baseUrl() const { return m_baseUrl; }
    QList<Currency *> currenciesAvailable() const { return m_currenciesAvailable; }
    bool updatePriceFromReply(Price *price, Currency * currency, QJsonDocument &reply);
    QUrl renderUrl(Currency *currency);

private:
    const QString m_label = QLatin1Literal("CryptoCompare");
    const QList<Currency*> m_currenciesAvailable = {Currencies::USD, Currencies::BTC, Currencies::EUR,
                                                    Currencies::JPY, Currencies::KRW, Currencies::ETH,
                                                    Currencies::CNY, Currencies::GBP};
    const QUrl m_baseUrl = QUrl(QLatin1Literal("https://min-api.cryptocompare.com/data/price"));
};

namespace PriceSources {
    extern PriceSource * const CoinMarketCap;
    extern PriceSource * const Binance;
    extern PriceSource * const CryptoCompare;
}

#endif // PRICESOURCE_H
