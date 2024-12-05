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

#include "downloader.h"

#include <QReadLocker>
#include <QWriteLocker>

#include "updater.h"

namespace
{

class DownloaderStateGuard
{
public:
    DownloaderStateGuard(bool &active, QReadWriteLock &mutex, std::function<void()> onActiveChanged)
        : m_active(active)
        , m_acquired(false)
        , m_mutex(mutex)
        , m_onActiveChanged(std::move(onActiveChanged))
    {
        {
            QWriteLocker locker(&m_mutex);

            if (m_active)
            {
                return;
            }

            m_active = true;
        }
        m_onActiveChanged();

        m_acquired = true;
    }

    ~DownloaderStateGuard()
    {
        if (!m_acquired)
        {
            return;
        }

        {
            QWriteLocker locker(&m_mutex);

            m_active = false;
        }
        m_onActiveChanged();
    }

    bool acquired() const
    {
        return m_acquired;
    }

private:
    bool &m_active;
    bool m_acquired;
    QReadWriteLock &m_mutex;
    std::function<void()> m_onActiveChanged;
};

} // namespace

Downloader::Downloader(QObject *parent)
    : QObject(parent)
    , m_active(false)
    , m_httpClient(new HttpClient())
    , m_network(this)
    , m_scheduler(this)
{
    QObject::connect(m_httpClient.get(), SIGNAL(contentLengthChanged()), this, SIGNAL(totalChanged()));
    QObject::connect(m_httpClient.get(), SIGNAL(receivedChanged()), this, SIGNAL(loadedChanged()));
}

Downloader::~Downloader()
{
    cancel();
}

void Downloader::cancel()
{
    m_httpClient->cancel();

    QWriteLocker locker(&m_mutex);

    m_contents.clear();
}

bool Downloader::get(const QString &url, const QString &hash, const QJSValue &callback)
{
    auto future = m_scheduler.run(
        [this, url, hash]() {
            DownloaderStateGuard stateGuard(m_active, m_mutex, [this]() {
                emit activeChanged();
            });
            if (!stateGuard.acquired())
            {
                return QJSValueList({"downloading is already running"});
            }

            {
                QWriteLocker locker(&m_mutex);

                m_contents.clear();
            }

            std::string response;
            {
                QString error;
                auto task = m_scheduler.run([this, &error, &response, &url] {
                    error = m_network.get(m_httpClient, url, response);
                });
                if (!task.first)
                {
                    return QJSValueList({"failed to start downloading task"});
                }
                task.second.waitForFinished();

                if (!error.isEmpty())
                {
                    return QJSValueList({error});
                }
            }

            if (response.empty())
            {
                return QJSValueList({"empty response"});
            }

            try
            {
                const QByteArray calculatedHash = Updater().getHash(&response[0], response.size());
                if (QByteArray::fromHex(hash.toUtf8()) != calculatedHash)
                {
                    return QJSValueList({"hash sum mismatch"});
                }
            }
            catch (const std::exception &e)
            {
                return QJSValueList({e.what()});
            }

            {
                QWriteLocker locker(&m_mutex);

                m_contents = std::move(response);
            }

            return QJSValueList({});
        },
        callback);

    return future.first;
}

bool Downloader::saveToFile(const QString &path) const
{
    QWriteLocker locker(&m_mutex);

    if (m_active || m_contents.empty())
    {
        return false;
    }

    QFile file(path);
    if (!file.open(QIODevice::WriteOnly))
    {
        return false;
    }

    if (static_cast<size_t>(file.write(m_contents.data(), m_contents.size())) != m_contents.size())
    {
        return false;
    }

    return true;
}

bool Downloader::active() const
{
    QReadLocker locker(&m_mutex);

    return m_active;
}

quint64 Downloader::loaded() const
{
    return m_httpClient->received();
}

quint64 Downloader::total() const
{
    return m_httpClient->contentLength();
}

QString Downloader::proxyAddress() const
{
    QMutexLocker locker(&m_proxyMutex);
    return m_proxyAddress;
}

void Downloader::setProxyAddress(QString address)
{
    m_scheduler.run([this, address] {
        if (!m_httpClient->set_proxy(address.toStdString()))
        {
            qCritical() << "Failed to set proxy address" << address;
        }

        QMutexLocker locker(&m_proxyMutex);
        m_proxyAddress = address;
        emit proxyAddressChanged();
    });
}
