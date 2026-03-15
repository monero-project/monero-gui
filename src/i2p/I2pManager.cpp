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

#include "i2p/I2pManager.h"

#include <QApplication>
#include <QDir>
#include <QFileInfo>
#include <QMutexLocker>
#include <QRegularExpression>
#include <QStandardPaths>
#include <QThread>

namespace
{
    constexpr quint16 DEFAULT_HTTP_PORT = 4444;
    constexpr quint16 DEFAULT_SOCKS_PORT = 4447;
    constexpr quint16 DEFAULT_SAM_PORT = 7656;
}

I2pManager::I2pManager(QObject *parent)
    : QObject(parent)
{
#ifdef Q_OS_WIN
    m_binaryPath = QApplication::applicationDirPath() + "/i2pd.exe";
#else
    m_binaryPath = QApplication::applicationDirPath() + "/i2pd";
#endif
}

I2pManager::~I2pManager()
{
    stop();
}

bool I2pManager::start(const QString &dataDir,
                       quint16 httpProxyPort,
                       quint16 socksProxyPort,
                       quint16 samPort,
                       const QString &extraArguments)
{
    if (!available())
    {
        emit routerError(tr("Missing i2p router binary at %1").arg(m_binaryPath));
        return false;
    }

    const RouterConfig desiredConfig = buildConfig(dataDir,
                                                  httpProxyPort,
                                                  socksProxyPort,
                                                  samPort,
                                                  extraArguments);

    if (isRunning() && desiredConfig == m_currentConfig)
    {
        return true;
    }

    if (isRunning())
    {
        stop();
    }

    QStringList arguments = assembleArguments(desiredConfig);

    auto process = std::make_unique<QProcess>();
    process->setProgram(m_binaryPath);
    process->setArguments(arguments);
    process->setProcessChannelMode(QProcess::MergedChannels);

    connect(process.get(), &QProcess::readyReadStandardOutput, this, &I2pManager::handleReadyRead);
    connect(process.get(), &QProcess::readyReadStandardError, this, &I2pManager::handleReadyReadError);
    connect(process.get(), &QProcess::stateChanged, this, &I2pManager::handleStateChanged);

    process->start();
    if (!process->waitForStarted(10000))
    {
        const QString errorMessage = tr("Unable to start i2pd (%1)").arg(process->errorString());
        emit routerError(errorMessage);
        resetProcess();
        return false;
    }

    {
        QMutexLocker locker(&m_processMutex);
        m_process = std::move(process);
        m_currentConfig = desiredConfig;
    }

    setRunning(true);
    emit routerStarted();
    return true;
}

bool I2pManager::stop()
{
    QMutexLocker locker(&m_processMutex);
    if (!m_process)
    {
        return true;
    }

    m_process->terminate();
    if (!m_process->waitForFinished(5000))
    {
        m_process->kill();
        m_process->waitForFinished(2000);
    }

    m_process.reset();
    setRunning(false);
    emit routerStopped();
    return true;
}

bool I2pManager::restart(const QString &dataDir,
                         quint16 httpProxyPort,
                         quint16 socksProxyPort,
                         quint16 samPort,
                         const QString &extraArguments)
{
    stop();
    return start(dataDir, httpProxyPort, socksProxyPort, samPort, extraArguments);
}

bool I2pManager::isRunning() const
{
    QMutexLocker locker(&m_processMutex);
    return m_process && m_process->state() == QProcess::Running;
}

bool I2pManager::available() const
{
    return QFileInfo::exists(m_binaryPath) && QFileInfo(m_binaryPath).isFile();
}

QString I2pManager::defaultDataDir() const
{
    const QString base = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(base + QLatin1String("/i2p"));
    dir.mkpath(".");
    return dir.absolutePath();
}

QVariantMap I2pManager::status() const
{
    QVariantMap map;
    map.insert("running", isRunning());
    map.insert("binaryPath", m_binaryPath);
    map.insert("dataDir", m_currentConfig.dataDir);
    map.insert("httpProxyPort", static_cast<int>(m_currentConfig.httpProxyPort));
    map.insert("socksProxyPort", static_cast<int>(m_currentConfig.socksProxyPort));
    map.insert("samPort", static_cast<int>(m_currentConfig.samPort));
    map.insert("extraArguments", m_currentConfig.extraArguments);
    return map;
}

QString I2pManager::binaryPath() const
{
    return m_binaryPath;
}

void I2pManager::handleReadyRead()
{
    QMutexLocker locker(&m_processMutex);
    if (!m_process)
    {
        return;
    }
    const QString output = QString::fromUtf8(m_process->readAllStandardOutput());
    const QStringList lines = output.split(QRegularExpression("\r?\n"), Qt::SkipEmptyParts);
    for (const QString &line : lines)
    {
        emit routerLog(line);
    }
}

void I2pManager::handleReadyReadError()
{
    QMutexLocker locker(&m_processMutex);
    if (!m_process)
    {
        return;
    }
    const QString output = QString::fromUtf8(m_process->readAllStandardError());
    const QStringList lines = output.split(QRegularExpression("\r?\n"), Qt::SkipEmptyParts);
    for (const QString &line : lines)
    {
        emit routerLog(line);
    }
}

void I2pManager::handleStateChanged(QProcess::ProcessState state)
{
    if (state == QProcess::NotRunning)
    {
        setRunning(false);
        emit routerStopped();
    }
}

bool I2pManager::RouterConfig::operator==(const RouterConfig &other) const
{
    return dataDir == other.dataDir
        && httpProxyPort == other.httpProxyPort
        && socksProxyPort == other.socksProxyPort
        && samPort == other.samPort
        && extraArguments == other.extraArguments;
}

I2pManager::RouterConfig I2pManager::buildConfig(const QString &dataDir,
                                                  quint16 httpProxyPort,
                                                  quint16 socksProxyPort,
                                                  quint16 samPort,
                                                  const QString &extraArguments) const
{
    RouterConfig config;
    config.dataDir = ensureDataDir(dataDir.isEmpty() ? defaultDataDir() : dataDir);
    config.httpProxyPort = httpProxyPort == 0 ? DEFAULT_HTTP_PORT : httpProxyPort;
    config.socksProxyPort = socksProxyPort == 0 ? DEFAULT_SOCKS_PORT : socksProxyPort;
    config.samPort = samPort == 0 ? DEFAULT_SAM_PORT : samPort;
    config.extraArguments = extraArguments;
    return config;
}

QStringList I2pManager::assembleArguments(const RouterConfig &config) const
{
    QStringList args;
    args << QStringLiteral("--datadir=%1").arg(config.dataDir);
    args << QStringLiteral("--httpproxy.port=%1").arg(config.httpProxyPort);
    args << QStringLiteral("--socksproxy.port=%1").arg(config.socksProxyPort);
    args << QStringLiteral("--sam.port=%1").arg(config.samPort);
    args << QStringLiteral("--loglevel=info");

    QString trimmed = config.extraArguments.trimmed();
    if (!trimmed.isEmpty())
    {
#if QT_VERSION >= QT_VERSION_CHECK(5, 15, 0)
        args << QProcess::splitCommand(trimmed);
#else
        const QRegularExpression splitter("\\s+");
        const QStringList extraParts = trimmed.split(splitter, Qt::SkipEmptyParts);
        args << extraParts;
#endif
    }

    return args;
}

QString I2pManager::ensureDataDir(const QString &path) const
{
    QDir dir(path);
    dir.mkpath(".");
    return dir.absolutePath();
}

void I2pManager::resetProcess()
{
    QMutexLocker locker(&m_processMutex);
    if (m_process)
    {
        m_process->kill();
        m_process->waitForFinished(1000);
        m_process.reset();
    }
    setRunning(false);
}

void I2pManager::setRunning(bool running)
{
    if (m_running == running)
    {
        return;
    }
    m_running = running;
    emit runningChanged(m_running);
}
