// Copyright (c) 2020-2024, The Monero Project
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

#pragma once

#include <QCoreApplication>
#include <QtNetwork>

// TODO: wallet_merged - epee library triggers the warnings
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"
#pragma GCC diagnostic ignored "-Wreorder"
#include <net/http.h>
#pragma GCC diagnostic pop

#include "FutureScheduler.h"

class HttpClient : public QObject, public net::http::client
{
    Q_OBJECT
    Q_PROPERTY(quint64 contentLength READ contentLength NOTIFY contentLengthChanged);
    Q_PROPERTY(quint64 received READ received NOTIFY receivedChanged);

public:
    HttpClient(QObject *parent = nullptr);

    void cancel();
    quint64 contentLength() const;
    quint64 received() const;

signals:
    void contentLengthChanged() const;
    void receivedChanged() const;

protected:
    bool on_header(const epee::net_utils::http::http_response_info &headers) final;
    bool handle_target_data(std::string &piece_of_transfer) final;

private:
    std::atomic<bool> m_cancel;
    std::atomic<size_t> m_contentLength;
    std::atomic<size_t> m_received;
};

class Network : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString proxyAddress MEMBER m_proxyAddress NOTIFY proxyAddressChanged)

public:
    Network(QObject *parent = nullptr);

public:
    Q_INVOKABLE void get(const QString &url, const QJSValue &callback, const QString &contentType = {}) const;
    Q_INVOKABLE void getJSON(const QString &url, const QJSValue &callback) const;

    std::string get(const QString &url, const QString &contentType = {}) const;
    QString get(
        std::shared_ptr<epee::net_utils::http::abstract_http_client> httpClient,
        const QString &url,
        std::string &response,
        const QString &contentType = {}) const;

signals:
    void proxyAddressChanged() const;

private:
    std::shared_ptr<epee::net_utils::http::abstract_http_client> newClient() const;

private:
    QString m_proxyAddress;
    mutable FutureScheduler m_scheduler;
};
