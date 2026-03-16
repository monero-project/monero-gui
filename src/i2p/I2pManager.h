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

#ifndef I2PMANAGER_H
#define I2PMANAGER_H

#include <memory>

#include <QMutex>
#include <QObject>
#include <QProcess>
#include <QString>
#include <QStringList>
#include <QtGlobal>
#include <QVariantMap>

class I2pManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool running READ isRunning NOTIFY runningChanged)
    Q_PROPERTY(QString binaryPath READ binaryPath CONSTANT)

public:
    explicit I2pManager(QObject *parent = nullptr);
    ~I2pManager() override;

    /// Start the bundled i2pd router. Returns true if the process started
    /// successfully. Emits routerStarted() on success, routerError() on failure.
    Q_INVOKABLE bool start(const QString &dataDir,
                           quint16 httpProxyPort,
                           quint16 socksProxyPort,
                           quint16 samPort,
                           const QString &extraArguments = QString());

    /// Stop the i2pd router. Returns true if stopped (or was already stopped).
    Q_INVOKABLE bool stop();

    /// Stop and restart with new configuration.
    Q_INVOKABLE bool restart(const QString &dataDir,
                             quint16 httpProxyPort,
                             quint16 socksProxyPort,
                             quint16 samPort,
                             const QString &extraArguments = QString());

    /// Returns true if the i2pd process is currently running.
    Q_INVOKABLE bool isRunning() const;

    /// Returns true if the i2pd binary exists and is a regular file.
    Q_INVOKABLE bool available() const;

    /// Returns the default data directory for i2pd (platform-specific app data path).
    Q_INVOKABLE QString defaultDataDir() const;

    /// Returns a status snapshot map with keys: running, binaryPath, dataDir, ports.
    Q_INVOKABLE QVariantMap status() const;

    /// Returns the absolute path to the bundled i2pd binary.
    Q_INVOKABLE QString binaryPath() const;

signals:
    void runningChanged(bool running);
    void routerStarted();
    void routerStopped();
    void routerError(const QString &message);
    void routerLog(const QString &line);

private slots:
    void onReadyRead();
    void onReadyReadError();
    void onStateChanged(QProcess::ProcessState state);

private:
    struct RouterConfig {
        QString dataDir;
        quint16 httpProxyPort = 4444;
        quint16 socksProxyPort = 4447;
        quint16 samPort = 7656;
        QString extraArguments;

        bool operator==(const RouterConfig &other) const;
    };

    RouterConfig buildConfig(const QString &dataDir,
                             quint16 httpProxyPort,
                             quint16 socksProxyPort,
                             quint16 samPort,
                             const QString &extraArguments) const;

    QStringList assembleArguments(const RouterConfig &config) const;
    QString ensureDataDir(const QString &path) const;
    void resetProcess();
    void setRunning(bool running);

    std::unique_ptr<QProcess> m_process;
    RouterConfig m_currentConfig;
    QString m_binaryPath;
    mutable QMutex m_processMutex;
    bool m_running = false;
};

#endif // I2PMANAGER_H
