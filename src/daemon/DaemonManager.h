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

#ifndef DAEMONMANAGER_H
#define DAEMONMANAGER_H

#include <QObject>
#include <QUrl>
#include <QProcess>
#include <QVariantMap>
#include "qt/FutureScheduler.h"
#include "NetworkType.h"

class DaemonManager : public QObject
{
    Q_OBJECT

public:

    static DaemonManager * instance(const QStringList *args);

    Q_INVOKABLE bool start(const QString &flags, NetworkType::Type nettype, const QString &dataDir = "", const QString &bootstrapNodeAddress = "");
    Q_INVOKABLE bool stop(NetworkType::Type nettype);

    // return true if daemon process is started
    Q_INVOKABLE bool running(NetworkType::Type nettype) const;
    // Send daemon command from qml and prints output in console window.
    Q_INVOKABLE bool sendCommand(const QString &cmd, NetworkType::Type nettype) const;
    Q_INVOKABLE void exit();
    Q_INVOKABLE QVariantMap validateDataDir(const QString &dataDir) const;

private:

    bool sendCommand(const QString &cmd, NetworkType::Type nettype, QString &message) const;
    bool startWatcher(NetworkType::Type nettype) const;
    bool stopWatcher(NetworkType::Type nettype) const;
signals:
    void daemonStarted() const;
    void daemonStopped() const;
    void daemonStartFailure() const;
    void daemonConsoleUpdated(QString message) const;

public slots:
    void printOutput();
    void printError();
    void stateChanged(QProcess::ProcessState state);

private:
    explicit DaemonManager(QObject *parent = 0);
    ~DaemonManager();

    static DaemonManager * m_instance;
    static QStringList m_clArgs;
    QProcess *m_daemon;
    bool initialized = false;
    QString m_monerod;
    bool m_has_daemon = true;
    bool m_app_exit = false;

    FutureScheduler m_scheduler;
};

#endif // DAEMONMANAGER_H
