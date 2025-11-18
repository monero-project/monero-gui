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
#include <expected>
#include <string>

#include "FutureScheduler.h"

// TODO: wallet_merged - epee library triggers the warnings
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"
#pragma GCC diagnostic ignored "-Wreorder"
// Qt6: Include net/http.h - the HttpClient inheritance issue is in monero submodule
// This is a known compatibility issue that needs to be fixed in the monero submodule
#include <net/http.h>
#pragma GCC diagnostic pop

// Qt6: HttpClient inherits from net::http::client
// Note: There's a known issue where Qt6's meta type system tries to use HttpClient
// as a network_address type, causing compilation errors. This is a monero submodule issue.
class HttpClient : public QObject, public net::http::client
{
    Q_OBJECT
    // Qt6: Explicitly disable copy/move - QObject already does this, but be explicit
    Q_DISABLE_COPY_MOVE(HttpClient)
    Q_PROPERTY(quint64 contentLength READ contentLength NOTIFY contentLengthChanged);
    Q_PROPERTY(quint64 received READ received NOTIFY receivedChanged);

public:
    HttpClient(QObject *parent = nullptr);

    void cancel();
    quint64 contentLength() const;
    quint64 received() const;

    // epee::net_utils::network_address interface methods
    // Required for compatibility with epee's network_address template
    // Note: HttpClient cannot be copied (QObject), but these methods satisfy the interface
    bool equal(const HttpClient& other) const;
    bool less(const HttpClient& other) const;
    bool is_same_host(const HttpClient& other) const;
    std::string str() const;
    std::string host_str() const;
    bool is_loopback() const;
    bool is_local() const;
    epee::net_utils::address_type get_type_id() const;
    epee::net_utils::zone get_zone() const;
    bool is_blockable() const;
    std::uint16_t port() const;

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

// Note: Q_DECLARE_OPAQUE_POINTER removed - no longer needed since network_address
// template constructor is constrained via SFINAE in monero submodule

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

    // C++23: std::expected-based error handling
    // Provides type-safe error handling without exceptions
    std::expected<std::string, std::string> getExpected(const QString &url, const QString &contentType = {}) const;
    std::expected<std::string, QString> getExpected(
        std::shared_ptr<epee::net_utils::http::abstract_http_client> httpClient,
        const QString &url,
        const QString &contentType = {}) const;

    // C++23: Coroutine-based async operations (see CoroutineTask.h for implementation)
    // Example usage:
    //   Task<std::string> fetchAsync() {
    //       auto result = co_await getExpected("https://example.com");
    //       if (result.has_value()) {
    //           co_return result.value();
    //       }
    //       co_return std::string{};
    //   }

signals:
    void proxyAddressChanged() const;

private:
    std::shared_ptr<epee::net_utils::http::abstract_http_client> newClient() const;
    // C++23: std::expected-based client creation
    std::expected<std::shared_ptr<epee::net_utils::http::abstract_http_client>, std::string> newClientExpected() const;

private:
    QString m_proxyAddress;
    mutable FutureScheduler m_scheduler;
};
