// Copyright (c) 2014-2024, The Monero Project
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

#ifndef P2POOLMANAGER_H
#define P2POOLMANAGER_H

#include <memory>

#include <QMutex>
#include <QObject>
#include <QUrl>
#include <QProcess>
#include "NetworkType.h"
#include "qt/FutureScheduler.h"

class P2PoolManager : public QObject
{
    Q_OBJECT

public:
    explicit P2PoolManager(QObject *parent = 0);
    ~P2PoolManager();

    Q_INVOKABLE bool start(const QString &flags, const QString &address, const QString &chain, const QString &threads);
    Q_INVOKABLE void exit();
    Q_INVOKABLE bool isInstalled();
    Q_INVOKABLE void getStatus();
    Q_INVOKABLE void download();

    enum DownloadError {
        BinaryNotAvailable,
        ConnectionIssue,
        HashVerificationFailed,
        InstallationFailed,
    };
    Q_ENUM(DownloadError)

private:

    bool running(NetworkType::Type nettype) const;
signals:
    void p2poolStartFailure() const;
    void p2poolStatus(bool isMining, int hashrate) const;
    void p2poolDownloadFailure(int errorCode) const;
    void p2poolDownloadSuccess() const;

private:
    std::unique_ptr<QProcess> m_p2poold;
    QMutex m_p2poolMutex;
    QString m_p2pool;
    QString m_p2poolPath;
    bool started = false;

    mutable FutureScheduler m_scheduler;
};

#endif // P2POOLMANAGER_H
