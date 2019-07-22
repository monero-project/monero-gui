// Copyright (c) 2014-2019, The Monero Project
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

#include <QtCore>
#include <QNetworkAccessManager>

#include "utils.h"
#include "prices.h"


Prices::Prices(QNetworkAccessManager *networkAccessManager, QObject *parent)
    : QObject(parent) {
    this->m_networkAccessManager = networkAccessManager;
}

void Prices::getJSON(const QString url) {
    qDebug() << QString("Fetching: %1").arg(url);
    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setRawHeader("User-Agent", randomUserAgent().toUtf8());
    request.setRawHeader("Content-Type", "application/json");

    m_reply = this->m_networkAccessManager->get(request);

    connect(m_reply, SIGNAL(finished()), this, SLOT(gotJSON()));
}

void Prices::gotJSON() {
    // Check connectivity
    if (!m_reply || m_reply->error() != QNetworkReply::NoError){
        this->gotError("Problem with reply from server. Check connectivity.");
        m_reply->deleteLater();
        return;
    }

    // Check json header
    QList<QByteArray> headerList = m_reply->rawHeaderList();
    QByteArray headerJson = m_reply->rawHeader("Content-Type");
    if(headerJson.length() <= 15){
        this->gotError("Bad Content-Type");
        m_reply->deleteLater();
        return;
    }

    QString headerJsonStr = QTextCodec::codecForMib(106)->toUnicode(headerJson);
    int _contentType = headerList.indexOf("Content-Type");
    if (_contentType < 0 || !headerJsonStr.startsWith("application/json")){
        this->gotError("Bad Content-Type");
        m_reply->deleteLater();
        return;
    }

    // Check valid json document
    QByteArray data = m_reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);
    QString jsonString = doc.toJson(QJsonDocument::Indented);
    if (jsonString.isEmpty()){
        this->gotError("Bad JSON");
        m_reply->deleteLater();
        return;
    }

    // Insert source url for later reference
    QUrl url = m_reply->url();
    QJsonObject docobj = doc.object();
    docobj["_url"] = url.toString();
    doc.setObject(docobj);

    qDebug() << QString("Fetched: %1").arg(url.toString());

    // Emit signal
    QVariantMap vMap = doc.object().toVariantMap();
    emit priceJsonReceived(vMap);

    m_reply->deleteLater();
}

void Prices::gotError() {
    this->gotError("Unknown error");
}

void Prices::gotError(const QString &message) {
    qCritical() << "[Fiat API] Error:" << message;
    emit priceJsonError(message);
}
