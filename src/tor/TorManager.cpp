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

#include "TorManager.h"
#include "net/http_client.h"
#include "common/util.h"
#include "qt/utils.h"
#include <QElapsedTimer>
#include <QFile>
#include <QMutexLocker>
#include <QFileInfo>
#include <QDir>
#include <QDebug>
#include <QUrl>
#include <QtConcurrent/QtConcurrent>
#include <QApplication>
#include <QProcess>
#include <QMap>
#include <QTcpSocket>
#include <QCryptographicHash>
#include <thread>

#if defined(Q_OS_MACOS) && defined(__aarch64__) && !defined(Q_OS_MACOS_AARCH64)
#define Q_OS_MACOS_AARCH64
#endif


bool TorManager::isAlreadyRunning() const {
    QTcpSocket socket;
    socket.connectToHost(host, port);
    return socket.waitForConnected(600);
}

QString TorManager::getP2PAddress() const {
    QString hostname = m_p2p_hidden_service_dir + "/hostname";
    if (!fileExists(hostname)) return QString();

    QByteArray data = fileOpen(hostname);

    QString address = QString(data);

    return address.replace("\n", "");
}

QString TorManager::getRPCAddress() const {
    QString hostname = m_rpc_hidden_service_dir + "/hostname";
    if (!fileExists(hostname)) return QString();

    QByteArray data = fileOpen(hostname);

    QString address = QString(data);

    return address.replace("\n", "");
}

void TorManager::download() {
    m_scheduler.run([this] {
        QUrl url;
        QString fileName;
        QString validHash;
        #ifdef Q_OS_WIN
            url = "https://archive.torproject.org/tor-package-archive/torbrowser/14.0.7/tor-expert-bundle-windows-x86_64-14.0.7.tar.gz";
            fileName = m_torPath + "/tor-expert-bundle-windows-x86_64-14.0.7.tar.gz";
            validHash = "5102cad9b0454ad61608eafff1008b14a8a06b1562c19b98e906d2a66f0983f2";
        #elif defined(Q_OS_LINUX)
            url = "https://archive.torproject.org/tor-package-archive/torbrowser/14.0.7/tor-expert-bundle-linux-x86_64-14.0.7.tar.gz";
            fileName = m_torPath + "/tor-expert-bundle-linux-x86_64-14.0.7.tar.gz";
            validHash = "a81f2905569afdd60aa068b244508b3cbc2f17c0d13a6fe90323951550264cbe";
        #elif defined(Q_OS_MACOS_AARCH64)
            url = "https://archive.torproject.org/tor-package-archive/torbrowser/14.0.7/tor-expert-bundle-macos-aarch64-14.0.7.tar.gz";
            fileName = m_torPath + "/tor-expert-bundle-macos-aarch64-14.0.7.tar.gz";
            validHash = "4b81656b6d068837d2d0be1e7c3ca37564c97b905d6571e0a6f34d64936b9a59";
        #elif defined(Q_OS_MACOS)
            url = "https://archive.torproject.org/tor-package-archive/torbrowser/14.0.7/tor-expert-bundle-macos-x86_64-14.0.7.tar.gz";
            fileName = m_torPath + "/tor-expert-bundle-macos-x86_64-14.0.7.tar.gz";
            validHash = "41423117eff9e608d9c3922539d732a29610335c3948c7fccb52b170b59c366c";
        #endif
        QFile file(fileName);
        epee::net_utils::http::http_simple_client http_client;
        const epee::net_utils::http::http_response_info* response = NULL;
        std::string userAgent = randomUserAgent().toStdString();
        std::chrono::milliseconds timeout = std::chrono::seconds(10);
        http_client.set_server(url.host().toStdString(), "443", {});
        bool success = http_client.invoke_get(url.path().toStdString(), timeout, {}, std::addressof(response), {{"User-Agent", userAgent}});
        if (success && response->m_response_code == 404) {
            emit torDownloadFailure(BinaryNotAvailable);
            return;
        } else if (success && response->m_response_code == 302) {
            epee::net_utils::http::fields_list fields = response->m_header_info.m_etc_fields;
            for (std::pair<std::string, std::string> i : fields) {
                if (i.first == "Location") {
                    url = QString::fromStdString(i.second);
                    http_client.set_server(url.host().toStdString(), "443", {});
                    std::string query = url.query(QUrl::FullyEncoded).toStdString();
                    std::string path = url.path().toStdString() + "?" + query;
                    http_client.wipe_response();
                    success = http_client.invoke_get(path, timeout, {}, std::addressof(response), {{"User-Agent", userAgent}});
                }
            }
        }
        if (!success) {
            emit torDownloadFailure(ConnectionIssue);
        }
        else {
            std::string stringData = response->m_body;
            QByteArray data(stringData.c_str(), stringData.length());
            QByteArray hashData = QCryptographicHash::hash(data, QCryptographicHash::Sha256);
            QString hash = hashData.toHex();
            if (hash != validHash) {
                emit torDownloadFailure(HashVerificationFailed);
            }
            else {
                file.open(QIODevice::WriteOnly);
                file.write(data);
                file.close();
                QProcess::execute("tar", {"-xzf", fileName, "--strip=1", "-C", m_torPath});
                if (isInstalled()) {
                    emit torDownloadSuccess();
                }
                else {
                    emit torDownloadFailure(InstallationFailed);
                }
            }
        }
    });
    return;
}

bool TorManager::isInstalled() const {
    if (!QFileInfo(m_tor).isFile())
    {
        return false;
    }
    return true;
}

bool TorManager::start(bool allowIncomingConnections)
{
    if (m_tord) {
        auto state = m_tord->state();

        if (state == QProcess::ProcessState::Running || state == QProcess::ProcessState::Starting) {
            emit torStartFailure("Tor is already running");
            return false;
        }

        disconnect(m_tord.get(), &QProcess::readyReadStandardOutput, this, &TorManager::handleProcessOutput);
        disconnect(m_tord.get(), &QProcess::errorOccurred, this, &TorManager::handleProcessError);
    }

    if (isAlreadyRunning()) {
        emit torStartFailure(QString("Unable to start Tor on %1:%2. Port already in use.").arg(host, QString::number(port)));
        return false;
    }


    QStringList arguments;

    arguments << "--ignore-missing-torrc";
    arguments << "--SocksPort" << QString("%1:%2").arg(host, QString::number(port));
    arguments << "--TruncateLogFile" << "1";
    arguments << "--DataDirectory" << m_datadir;
    
    if (allowIncomingConnections) {
        QString host = QString(" 127.0.0.1:");
        QString p2pPort = QString::number(m_hidden_service_port_p2p);
        QString rpcPort = QString::number(m_hidden_service_port_rpc);
        arguments << "--HiddenServiceDir" << m_p2p_hidden_service_dir;
        arguments << "--HiddenServicePort" << p2pPort + host  + p2pPort;
        arguments << "--HiddenServiceDir" << m_rpc_hidden_service_dir;
        arguments << "--HiddenServicePort" <<  rpcPort + host + rpcPort;
    }

    arguments << "--Log" << "notice";
    arguments << "--pidfile" << QDir(m_datadir).filePath("tor.pid");

    qDebug() << "starting tor " + m_tor;
    qDebug() << "With command line arguments " << arguments;

    starting = true;

    QMutexLocker locker(&m_torMutex);

    m_tord.reset(new QProcess(this));

    m_tord->setProcessChannelMode(QProcess::MergedChannels);

    connect(m_tord.get(), &QProcess::readyReadStandardOutput, this, &TorManager::handleProcessOutput);
    connect(m_tord.get(), &QProcess::errorOccurred, this, &TorManager::handleProcessError);

    // Start tor
    try {
        m_tord->start(m_tor, arguments);
        started = true;
    }
    catch (...) {
        qWarning() << "Error while starting tor";
        started = false;
    }

    return started;
}

void TorManager::handleProcessOutput() {
    QByteArray output = m_tord->readAllStandardOutput();

    if(output.contains(QByteArray("Bootstrapped 100%"))) {
        emit torStartSuccess();
    }
}

void TorManager::handleProcessError(QProcess::ProcessError error) {
    bool failed = false;
    QString message = "Unknown error";

    if (error == QProcess::ProcessError::Crashed) {
        message = "Tor crashed or killed";
        failed = true;
    }
    else if (error == QProcess::ProcessError::FailedToStart) {
        message = "Tor binary failed to start";
        failed = true;
    }

    if (failed && starting) {
        emit torStartFailure(message); 
    }
    else if (failed) {
        emit torStopped();
    }

    starting = false;
}

void TorManager::exit()
{
    qDebug("TorManager: exit()");
    if (started && m_tord.get() != nullptr) {
        m_tord->kill();
        std::this_thread::sleep_for(std::chrono::milliseconds(1500));
        starting = started = false;
        emit torStopped();
    }
}

QString TorManager::getVersion() const {
    if (!isInstalled()) return QString("Not installed");

    QProcess process;
    process.setProcessChannelMode(QProcess::MergedChannels);
    process.start(m_tor, QStringList() << "--version");
    process.waitForFinished(-1);
    QString output = process.readAllStandardOutput();

    if(output.isEmpty() || !output.contains("Tor version")) {
        qWarning() << "Could not grab Tor version";
        return QString();
    }

    auto lines = output.split("\n");

    if (lines.size() == 0) {
        qWarning() << "Could not grab Tor version";
        return QString();
    }

    auto firstLine = lines.at(0);

    auto components = firstLine.split(" ");

    if (components.size() < 3) {
        qWarning() << "Could not grab Tor version";
        return QString();
    }

    return components.at(2);
}

QString TorManager::getProxyAddress() const {
    return host + QString(":") + QString::number(port);
}

TorManager::TorManager(QObject *parent)
    : QObject(parent)
    , m_scheduler(this)
{
    started = false;
    // Platform dependent path to tor
#ifdef Q_OS_WIN
    m_torPath = QApplication::applicationDirPath() + "/tor";
    if (!QDir(m_torPath).exists()) {
        QDir().mkdir(m_torPath);
    }
    m_tor = m_torPath + "/tor.exe";
    
#elif defined(Q_OS_UNIX)
    m_torPath = QApplication::applicationDirPath() + "/tor";
    m_tor = m_torPath + "/tor";
#endif

    m_datadir = m_torPath + "/data";
    m_p2p_hidden_service_dir = m_torPath + "/p2p_hidden_service";
    m_rpc_hidden_service_dir = m_torPath + "/rpc_hidden_service";
    m_torrc = m_torPath + "/torrc";

    if (m_tor.length() == 0) {
        qCritical() << "no tor binary defined for current platform";
    }

    mkDir(m_torPath);
    mkDir(m_datadir);
    mkDir(m_p2p_hidden_service_dir, true);
    mkDir(m_rpc_hidden_service_dir, true);

    m_tord.reset(new QProcess(this));

    connect(m_tord.get(), &QProcess::readyReadStandardOutput, this, &TorManager::handleProcessOutput);
    connect(m_tord.get(), &QProcess::errorOccurred, this, &TorManager::handleProcessError);
}

TorManager::~TorManager() {
    m_scheduler.shutdownWaitForFinished();
}
