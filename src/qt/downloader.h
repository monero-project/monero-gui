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

#include <QReadWriteLock>

#include "network.h"

class Downloader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool active READ active NOTIFY activeChanged);
    Q_PROPERTY(quint64 loaded READ loaded NOTIFY loadedChanged);
    Q_PROPERTY(quint64 total READ total NOTIFY totalChanged);
    Q_PROPERTY(QString proxyAddress READ proxyAddress WRITE setProxyAddress NOTIFY proxyAddressChanged)

public:
    Downloader(QObject *parent = nullptr);
    ~Downloader();

    Q_INVOKABLE void cancel();
    Q_INVOKABLE bool get(const QString &url, const QString &hash, const QJSValue &callback);
    Q_INVOKABLE bool saveToFile(const QString &path) const;

signals:
    void activeChanged() const;
    void loadedChanged() const;
    void totalChanged() const;
    void proxyAddressChanged() const;

private:
    bool active() const;
    quint64 loaded() const;
    quint64 total() const;
    QString proxyAddress() const;
    void setProxyAddress(QString address);

private:
    bool m_active;
    std::string m_contents;
    std::shared_ptr<HttpClient> m_httpClient;
    mutable QReadWriteLock m_mutex;
    Network m_network;
    QString m_proxyAddress;
    mutable QMutex m_proxyMutex;
    mutable FutureScheduler m_scheduler;
};
