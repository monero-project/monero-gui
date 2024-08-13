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

#include "P2PoolManager.h"
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
#include <QCryptographicHash>

#if defined(Q_OS_MACOS) && defined(__aarch64__) && !defined(Q_OS_MACOS_AARCH64)
#define Q_OS_MACOS_AARCH64
#endif

void P2PoolManager::download() {
    m_scheduler.run([this] {
        QUrl url;
        QString fileName;
        QString validHash;
        #ifdef Q_OS_WIN
            url = "https://github.com/SChernykh/p2pool/releases/download/v4.1/p2pool-v4.1-windows-x64.zip";
            fileName = m_p2poolPath + "/p2pool-v4.1-windows-x64.zip";
            validHash = "a2a6327e2442282fe344d69a5e61ddb6bf66950bffd32c5a99b9cecc62d3a7d6";
        #elif defined(Q_OS_LINUX)
            url = "https://github.com/SChernykh/p2pool/releases/download/v4.1/p2pool-v4.1-linux-x64.tar.gz";
            fileName = m_p2poolPath + "/p2pool-v4.1-linux-x64.tar.gz";
            validHash = "9d62adcb8426932ff51dae0eb02551b1b88996aa25804a470dc127bef30b4c07";
        #elif defined(Q_OS_MACOS_AARCH64)
            url = "https://github.com/SChernykh/p2pool/releases/download/v4.1/p2pool-v4.1-macos-aarch64.tar.gz";
            fileName = m_p2poolPath + "/p2pool-v4.1-macos-aarch64.tar.gz";
            validHash = "3cce06835e50395c986511019c7dabd93855de78c787d518f22e6c6572b44d2e";
        #elif defined(Q_OS_MACOS)
            url = "https://github.com/SChernykh/p2pool/releases/download/v4.1/p2pool-v4.1-macos-x64.tar.gz";
            fileName = m_p2poolPath + "/p2pool-v4.1-macos-x64.tar.gz";
            validHash = "e87dfda26388774688da8336a00df3f4befcb98c3ee4b26d496ff05179cce5e7";
        #endif
        QFile file(fileName);
        epee::net_utils::http::http_simple_client http_client;
        const epee::net_utils::http::http_response_info* response = NULL;
        std::string userAgent = randomUserAgent().toStdString();
        std::chrono::milliseconds timeout = std::chrono::seconds(10);
        http_client.set_server(url.host().toStdString(), "443", {});
        bool success = http_client.invoke_get(url.path().toStdString(), timeout, {}, std::addressof(response), {{"User-Agent", userAgent}});
        if (success && response->m_response_code == 404) {
            emit p2poolDownloadFailure(BinaryNotAvailable);
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
            emit p2poolDownloadFailure(ConnectionIssue);
        }
        else {
            std::string stringData = response->m_body;
            QByteArray data(stringData.c_str(), stringData.length());
            QByteArray hashData = QCryptographicHash::hash(data, QCryptographicHash::Sha256);
            QString hash = hashData.toHex();
            if (hash != validHash) {
                emit p2poolDownloadFailure(HashVerificationFailed);
            }
            else {
                file.open(QIODevice::WriteOnly);
                file.write(data);
                file.close();
                QProcess::execute("tar", {"-xzf", fileName, "--strip=1", "-C", m_p2poolPath});
                QFile::remove(fileName);
                if (isInstalled()) {
                    emit p2poolDownloadSuccess();
                }
                else {
                    emit p2poolDownloadFailure(InstallationFailed);
                }
            }
        }
    });
    return;
}

bool P2PoolManager::isInstalled() {
    if (!QFileInfo(m_p2pool).isFile())
    {
        return false;
    }
    return true;
}

void P2PoolManager::getStatus() {
    QString statsPath = m_p2poolPath + "/stats/local/miner";
    bool status = true;
    if (!QFileInfo(statsPath).isFile() || !started)
    {
        status = started;
        emit p2poolStatus(status, 0);
        return;
    }
    QFile statsFile(statsPath);
    statsFile.open(QIODevice::ReadOnly);
    QTextStream statsOut(&statsFile);
    QByteArray data;
    statsOut >> data;
    statsFile.close();
    QJsonDocument json = QJsonDocument::fromJson(data);
    QJsonObject jsonObj = json.object();
    int hashrate = jsonObj.value("current_hashrate").toInt();
    emit p2poolStatus(status, hashrate);
    return;
}

bool P2PoolManager::start(const QString &flags, const QString &address, const QString &chain, const QString &threads)
{
    // prepare command line arguments and pass to p2pool
    QStringList arguments;

    // Custom startup flags for p2pool
    foreach (const QString &str, flags.split(" ")) {
          qDebug() << QString(" [%1] ").arg(str);
          if (!str.isEmpty())
            arguments << str;
    }

    if (!arguments.contains("--local-api")) {
        arguments << "--local-api";
    }

    if (!arguments.contains("--data-api")) {
        QDir dir;
        QString dirName = m_p2poolPath + "/stats/";
        QDir statsDir(dirName);
        if (dir.exists(dirName)) {
            statsDir.removeRecursively();
        }
        dir.mkdir(dirName);
        arguments << "--data-api" << dirName;
    }

    if (!arguments.contains("--start-mining")) {
        arguments << "--start-mining" << threads;
    }

    if (chain == "mini") {
        arguments << "--mini";
    }

    if (!arguments.contains("--wallet")) {
        arguments << "--wallet" << address;
    }

    qDebug() << "starting p2pool " + m_p2pool;
    qDebug() << "With command line arguments " << arguments;

    QMutexLocker locker(&m_p2poolMutex);

    m_p2poold.reset(new QProcess());

    // Set program parameters
    m_p2poold->setProgram(m_p2pool);
    m_p2poold->setArguments(arguments);
    m_p2poold->setWorkingDirectory(m_p2poolPath);

    // Start p2pool
    started = m_p2poold->startDetached();

    if (!started) {
        qDebug() << "P2Pool start error: " + m_p2poold->errorString();
        emit p2poolStartFailure();
        return false;
    }

    return true;
}

void P2PoolManager::exit()
{
    qDebug("P2PoolManager: exit()");
    if (started) {
    #ifdef Q_OS_WIN
        QProcess::execute("taskkill",  {"/F", "/IM", "p2pool.exe"});
    #else
        QProcess::execute("pkill", {"p2pool"});
    #endif
        started = false;
        QString dirName = m_p2poolPath + "/stats/";
        QDir dir(dirName);
        dir.removeRecursively();
    }
}

P2PoolManager::P2PoolManager(QObject *parent)
    : QObject(parent)
    , m_scheduler(this)
{
    started = false;
    // Platform dependent path to p2pool
#ifdef Q_OS_WIN
    m_p2poolPath = QApplication::applicationDirPath() + "/p2pool";
    if (!QDir(m_p2poolPath).exists()) {
        QDir().mkdir(m_p2poolPath);
    }
    m_p2pool = m_p2poolPath + "/p2pool.exe";
#elif defined(Q_OS_UNIX)
    m_p2poolPath = QApplication::applicationDirPath();
    m_p2pool = m_p2poolPath + "/p2pool";
#endif
    if (m_p2pool.length() == 0) {
        qCritical() << "no p2pool binary defined for current platform";
    }
}

P2PoolManager::~P2PoolManager() {
    m_scheduler.shutdownWaitForFinished();
}
