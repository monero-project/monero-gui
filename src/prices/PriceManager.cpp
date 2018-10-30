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
#include "PriceManager.h"

#include <QTimer>
#include <QUrl>
#include <QString>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>

#include "Price.h"
#include "Currency.h"
#include "PriceSource.h"
#include "CurrencySelectorModel.h"
#include "PriceSourceSelectorModel.h"


namespace {
    static const int DEFAULT_REFRESH_PERIOD_MILLISECONDS = 15 * 1000;
    static const QByteArray USER_AGENT = "Mozilla 5.0";
}

PriceManager * PriceManager::m_instance = nullptr;

PriceManager *PriceManager::instance(QNetworkAccessManager *networkAccessManager)
{
    if (!m_instance) {
        qDebug() << __FUNCTION__ << ": Creating new PriceManager";
        m_instance = new PriceManager(networkAccessManager);
    }

    return m_instance;
}

PriceManager::PriceManager(QNetworkAccessManager *manager, QObject *parent) :
    QObject(parent),
    m_manager(manager),
    m_reply(nullptr),
    m_timer(nullptr),
    m_currentPrice(nullptr),
    m_currentCurrency(nullptr),
    m_currentPriceSource(nullptr),
    m_priceSourcesAvailableModel(nullptr),
    m_currenciesAvailableModel(nullptr)
{
    m_running = false;
    m_refreshing = false;
    m_currentPrice = new Price(this);
    m_timer = new QTimer(this);

    PriceManager * pm = const_cast<PriceManager*>(this);
    m_priceSourcesAvailableModel = new PriceSourceSelectorModel(pm, m_priceSourcesAvailable);
    m_currenciesAvailableModel = new CurrencySelectorModel(pm);

    connect(m_timer, SIGNAL(timeout()), this, SLOT(runPriceRefresh()));
    connect(this, SIGNAL(priceSourceChanged()), this, SLOT(updateCurrenciesAvailable()));
    connect(this, SIGNAL(priceSourceChanged()), this, SLOT(restart()));
    connect(this, SIGNAL(currencyChanged()), this, SLOT(restart()));
}

PriceManager::PriceManager(QObject *parent) :
    PriceManager(nullptr, parent)
{
}

void PriceManager::start()
{
    qDebug() << __FUNCTION__ << ": Starting PriceManager";
    emit starting();
    m_running = true;
    runPriceRefresh();
    m_timer->start(DEFAULT_REFRESH_PERIOD_MILLISECONDS);
}

void PriceManager::stop()
{
    qDebug() << __FUNCTION__ << ": Stopping PriceManager";
    emit stopping();
    m_timer->stop();
    abortReply();
    m_running = false;
    emit stopped();
}

void PriceManager::restart()
{
    stop();
    start();
}

void PriceManager::abortReply()
{
    if (m_reply && m_reply->isRunning()) {
        m_reply->abort();
        m_reply->deleteLater();
    }
}

void PriceManager::runPriceRefresh()
{
    if (!m_currentPriceSource || !m_currentCurrency) {
        qDebug() << __FUNCTION__ << ": Cannot refresh price without a price source or currency set; NOOP";
        return;
    }

    if (refreshing()) {
        qWarning() << __FUNCTION__ << ": Refresh called while in process of refreshing; aborting current reply";
        abortReply();
    }

    emit priceRefreshStarted();
    m_refreshing = true;

    QUrl reqUrl = m_currentPriceSource->renderUrl(m_currentCurrency);

    QNetworkRequest request;
    request.setUrl(reqUrl);
    request.setRawHeader("User-Agent", USER_AGENT);

    m_reply = m_manager->get(request);

    connect(m_reply, SIGNAL(finished()), this, SLOT(handleHTTPFinished()));
}

void PriceManager::handleHTTPFinished()
{
    m_refreshing = false;

    if (!m_reply)
        return;

    if (m_reply->error() == QNetworkReply::NoError)
        updatePrice();
    else
        handleNetworkError();

    m_reply->deleteLater();
}

void PriceManager::updatePrice()
{
    QByteArray data = m_reply->readAll();
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);

    if (doc.isNull()) {
        handleError(error.errorString());
    }

    if (!doc.isObject()) {
        handleError("PriceManager: Could not parse response JSON as object: " + doc.toJson());
        return;
    }

    bool success = m_currentPriceSource->updatePriceFromReply(m_currentPrice, m_currentCurrency, doc);

    qDebug() << __FUNCTION__ << ": Got price " << m_currentPrice->price() << " for " << m_currentPrice->currency()->label();
    if (success)
        emit priceRefreshed();
}

void PriceManager::handleError(const QString &msg) const
{
    qCritical() << __FUNCTION__ << ": Error: " << msg;
}

void PriceManager::handleNetworkError()
{
    emit networkError();
    handleError("Network error: " + m_reply->errorString());
}

Price * PriceManager::price() const
{
    return m_currentPrice;
}

QString PriceManager::convert(quint64 amount) const
{
    return m_currentPrice->convert(amount);
}

QList<PriceSource*> PriceManager::priceSourcesAvailable() const
{
    return m_priceSourcesAvailable;
}


PriceSourceSelectorModel *PriceManager::priceSourcesAvailableModel() const
{
    return m_priceSourcesAvailableModel;
}


QList<Currency*> PriceManager::currenciesAvailable() const
{
    if (!m_currentPriceSource)
        return QList<Currency*>();
    return m_currentPriceSource->currenciesAvailable();
}

void PriceManager::setPriceSource(int index)
{
    if (index < 0 || index >= m_priceSourcesAvailable.count()) {
        qWarning() << __FUNCTION__ << ": Bad index " << index << " passed to setPriceSource; NOOP";
        return;
    }

    m_currentPriceSource = m_priceSourcesAvailable.at(index);
    emit priceSourceChanged();
}

void PriceManager::setCurrency(int index)
{
    if (index < 0 || index >= currenciesAvailable().count()) {
        qWarning() << __FUNCTION__ << ": Bad index " << index << " passed to setCurrency; NOOP";
        return;
    }

    m_currentCurrency = currenciesAvailable().at(index);
    emit currencyChanged();
}

void PriceManager::updateCurrenciesAvailable()
{
    this->currenciesAvailableModel()->setAvailableCurrencies(this->currenciesAvailable());
}

CurrencySelectorModel *PriceManager::currenciesAvailableModel() const
{
    return m_currenciesAvailableModel;
}

void PriceManager::setPriceSource(QModelIndex index)
{
    QVariant p = m_priceSourcesAvailableModel->data(index, PriceSourceSelectorModel::PriceSourceRole);
    if (!p.isValid() || p.isNull()) {
        qWarning() << __FUNCTION__ << ": Invalid price source index passed, NOOP";
        return;
    }

    if (!p.canConvert<PriceSource *>()) {
        qCritical() << __FUNCTION__ << ": Did not get a price source in the model -- this should never happen";
        return;
    }

    m_currentPriceSource = p.value<PriceSource *>();
    emit priceSourceChanged();
}

void PriceManager::setCurrency(QModelIndex index)
{
    QVariant c = m_currenciesAvailableModel->data(index, CurrencySelectorModel::CurrencyRole);
    if (!c.isValid() || c.isNull()) {
        qWarning() << __FUNCTION__ << ": Invalid currency index passed, NOOP";
        return;
    }

    if (!c.canConvert<Currency *>()) {
        qCritical() << __FUNCTION__ <<  ": Did not get a currency in the model -- this should never happen";
        return;
    }

    m_currentCurrency = c.value<Currency *>();
    emit currencyChanged();
}


PriceSource *PriceManager::currentPriceSource() const
{
    return m_currentPriceSource;
}

Currency * PriceManager::currentCurrency() const
{
    return m_currentCurrency;
}

bool PriceManager::priceReady() const
{
    if (m_currentPrice->currency() && !m_currentPrice->stale())
        return true;
    return false;
}


bool PriceManager::running() const
{
    return m_running;
}

bool PriceManager::refreshing() const
{
    return m_refreshing;
}
