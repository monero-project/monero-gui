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

#include <QDebug>
#include <QtCore>

// TODO: wallet_merged - epee library triggers the warnings
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"
#pragma GCC diagnostic ignored "-Wreorder"
#include <net/http_client.h>
#pragma GCC diagnostic pop

#include "utils.h"
#include "prices.h"

Prices::Prices(QObject *parent)
    : QObject(parent)
    , m_scheduler(this)
{
}

void Prices::getJSON(const QString url) const
{
    qDebug() << QString("Fetching: %1").arg(url);

    m_scheduler.run([this, url] {
        epee::net_utils::http::http_simple_client http_client;

        const QUrl urlParsed(url);
        http_client.set_server(urlParsed.host().toStdString(), urlParsed.scheme() == "https" ? "443" : "80", {});

        const QString uri = (urlParsed.hasQuery() ? urlParsed.path() + "?" + urlParsed.query() : urlParsed.path());
        const epee::net_utils::http::http_response_info* pri = NULL;
        constexpr std::chrono::milliseconds timeout = std::chrono::seconds(15);

        const bool result = http_client.invoke(
            uri.toStdString(),
            "GET",
            {},
            timeout,
            std::addressof(pri),
            {
                {"Content-Type", "application/json; charset=utf-8"},
                {"User-Agent", randomUserAgent().toStdString()}
            });

        if (!result)
        {
            this->gotError("unknown error");
        }
        else if (!pri)
        {
            this->gotError("internal error (null response ptr)");
        }
        else if (pri->m_response_code != 200)
        {
            this->gotError(QString("response code: %1").arg(pri->m_response_code));
        }
        else
        {
            QJsonDocument doc = QJsonDocument::fromJson({&pri->m_body[0], static_cast<int>(pri->m_body.size())});
            if (doc.isEmpty())
            {
                this->gotError("bad JSON");
            }
            else
            {
                // Insert source url for later reference
                QJsonObject docobj = doc.object();
                docobj["_url"] = url;
                doc.setObject(docobj);

                QVariantMap vMap = doc.object().toVariantMap();
                emit priceJsonReceived(vMap);
            }
        }
    });
}

void Prices::gotError(const QString &message) const
{
    qCritical() << "[Fiat API] Error:" << message;
    emit priceJsonError(message);
}
