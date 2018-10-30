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
#ifndef PRICEMANAGER_H
#define PRICEMANAGER_H

#include <QTimer>
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QPointer>
#include <QString>
#include <QSet>
#include <QModelIndex>

#include "PriceSource.h"
#include "Currency.h"

class Price;
class CurrencySelectorModel;
class PriceSourceSelectorModel;

class PriceManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool running READ running)
    Q_PROPERTY(bool refreshing READ refreshing)
    Q_PROPERTY(bool priceReady READ priceReady NOTIFY priceRefreshed)
    Q_PROPERTY(Currency * currentCurrency READ currentCurrency NOTIFY currencyChanged)
    Q_PROPERTY(QList<Currency*> currenciesAvailable READ currenciesAvailable NOTIFY priceSourceChanged)
    Q_PROPERTY(CurrencySelectorModel * currenciesAvailableModel READ currenciesAvailableModel NOTIFY priceSourceChanged)
    Q_PROPERTY(Price * price READ price NOTIFY priceRefreshed)
    Q_PROPERTY(const QList<PriceSource*> priceSourcesAvailable READ priceSourcesAvailable)
    Q_PROPERTY(PriceSourceSelectorModel * priceSourcesAvailableModel READ priceSourcesAvailableModel)
    Q_PROPERTY(PriceSource * currentPriceSource READ currentPriceSource NOTIFY priceSourceChanged)

public:
    static PriceManager * instance(QNetworkAccessManager *manager);

    // Start the price polling thread
    Q_INVOKABLE void start();
    // Stop the price polling thread
    Q_INVOKABLE void stop();
    // Is there a price available yet?
    bool priceReady() const;
    // Are we running?
    bool running() const;
    // Are we refreshing the price?
    bool refreshing() const;
    // Get the current currency
    Currency * currentCurrency() const;
    // Get the current price
    Price *price() const;
    // Convert the amount given at the current price and currency
    Q_INVOKABLE QString convert(quint64 amount) const;
    // Get current price source
    PriceSource * currentPriceSource() const;
    // Set price source
    void setPriceSource(int index);
    Q_INVOKABLE void setPriceSource(QModelIndex index);
    // Set currency
    void setCurrency(int index);
    Q_INVOKABLE void setCurrency(QModelIndex index);
    // Get price sources which are available
    QList<PriceSource*> priceSourcesAvailable() const;
    // Get the available price sources in a StringListModel for display
    PriceSourceSelectorModel *priceSourcesAvailableModel() const;
    // Get list of available currencies
    QList<Currency*> currenciesAvailable() const;
    // Get the available currencies in a StringListModel for display
    CurrencySelectorModel * currenciesAvailableModel() const;

    Q_INVOKABLE void handleError(const QString &msg) const;

private:
    void updatePrice();
    void abortReply();

signals:
    void starting() const;
    void started() const;
    void priceRefreshStarted() const;
    void priceRefreshed() const;
    void priceSourceChanged() const;
    void currencyChanged() const;
    void networkError() const;
    void stopping() const;
    void stopped() const;

public slots:
    Q_INVOKABLE void restart();
    // Called when the timer hits (perform HTTP request)
    void runPriceRefresh();
    // Called when the HTTP request completes
    void handleHTTPFinished();
    // Called when the HTTP request fails
    void handleNetworkError();
    // Called when the PriceSource is changed
    void updateCurrenciesAvailable();

private:
    explicit PriceManager(QNetworkAccessManager *manager, QObject *parent = nullptr);
    explicit PriceManager(QObject *parent = nullptr);
    static PriceManager * m_instance;
    mutable bool m_running;
    mutable bool m_refreshing;
    QNetworkAccessManager * m_manager;
    mutable QPointer<QNetworkReply> m_reply;
    QTimer * m_timer;
    Price * m_currentPrice;
    Currency * m_currentCurrency;
    PriceSource * m_currentPriceSource;
    const QList<PriceSource*> m_priceSourcesAvailable = {PriceSources::CryptoCompare,
                                                         PriceSources::CoinMarketCap,
                                                         PriceSources::Binance};
    PriceSourceSelectorModel * m_priceSourcesAvailableModel;
    CurrencySelectorModel * m_currenciesAvailableModel;

};

#endif // PRICEMANAGER_H
