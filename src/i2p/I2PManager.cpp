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

#include "I2PManager.h"
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

#include <stdexcept>
#include <map>
#include <openssl/sha.h>

#if defined(Q_OS_MACOS) && defined(__aarch64__) && !defined(Q_OS_MACOS_AARCH64)
#define Q_OS_MACOS_AARCH64
#endif

std::vector<uint8_t> base64Decode(const std::string &input) {
    static const std::string base64_chars =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    std::map<char, uint8_t> base64_map;
    for (size_t i = 0; i < base64_chars.size(); ++i)
        base64_map[base64_chars[i]] = i;

    std::vector<uint8_t> output;
    int val = 0, valb = -8;
    for (uint8_t c : input) {
        if (base64_map.find(c) == base64_map.end()) break;
        val = (val << 6) + base64_map[c];
        valb += 6;
        if (valb >= 0) {
            output.push_back(uint8_t((val >> valb) & 0xFF));
            valb -= 8;
        }
    }
    return output;
}

std::string base32Encode(const std::vector<uint8_t> &input) {
    static const char *base32_alphabet = "abcdefghijklmnopqrstuvwxyz234567";

    std::string result;
    int buffer = 0, bitsLeft = 0;
    for (uint8_t byte : input) {
        buffer <<= 8;
        buffer |= byte & 0xFF;
        bitsLeft += 8;
        while (bitsLeft >= 5) {
            result += base32_alphabet[(buffer >> (bitsLeft - 5)) & 0x1F];
            bitsLeft -= 5;
        }
    }
    if (bitsLeft > 0) {
        buffer <<= (5 - bitsLeft);
        result += base32_alphabet[buffer & 0x1F];
    }
    return result;
}

std::string decodeAddress(std::string path) {
    std::ifstream s(path);

    if (!s || !s.is_open()) return std::string("");
    
    std::string base64_string;
    std::getline(s, base64_string);
    s.close();
    auto decoded = base64Decode(base64_string);

    uint8_t hash[SHA256_DIGEST_LENGTH];
    SHA256(decoded.data(), decoded.size(), hash);

    std::vector<uint8_t> hash_vec(hash, hash + SHA256_DIGEST_LENGTH);
    std::string b32 = base32Encode(hash_vec);

    return b32 + std::string(".b32.i2p");
}

QString buildI2pdConf() {
    return QString(
        "ipv4 = true\n"
        "ipv6 = false\n"
        "daemon = false\n"
        "[httpproxy]\n"
        "enabled = false\n"
        "[sam]\n"
        "enabled = false\n"
        "[socksproxy]\n"
        "enabled = true\n"
        "outproxy.enabled = true\n"
    );
}

QString buildI2pdTunnelsConf(bool allowIncomingConnections) {
    if (!allowIncomingConnections) return QString("");
    return QString(
        "[monero-node]\n"
        "type = server\n"
        "host = 127.0.0.1\n"
        "# Anonymous inbound port\n"
        "port = 18085\n"
        "inport = 0\n"
        "keys = monero-mainnet.dat\n"
        "\n"
        "[monero-rpc]\n"
        "type = server\n"
        "host = 127.0.0.1\n"
        "# Restricted RPC port\n"
        "port = 18089\n"
        "keys = monero-mainnet-rpc.dat\n"
    );
}

bool writeI2pdTunnelsConf(QString path, bool allowIncomingConnections) {
    return fileWrite(path, buildI2pdTunnelsConf(allowIncomingConnections));
}

bool writeI2pdConf(QString path) {
    return fileWrite(path, buildI2pdConf());
}

bool I2PManager::isAlreadyRunning() const {
    QTcpSocket socket;
    socket.connectToHost(host, port);
    return socket.waitForConnected(600);
}

QString I2PManager::getP2PAddress() const {
    return QString::fromStdString(decodeAddress(m_i2pd_p2p_dat.toStdString()));
}

QString I2PManager::getRPCAddress() const {
    return QString::fromStdString(decodeAddress(m_i2pd_rpc_dat.toStdString()));
}

bool I2PManager::start(bool allowIncomingConnections)
{
    if (m_i2pd) {
        auto state = m_i2pd->state();

        if (started && (state == QProcess::ProcessState::Running || state == QProcess::ProcessState::Starting)) {
            emit i2pStartFailure("I2P is already running");
            return false;
        }

        disconnect(m_i2pd.get(), &QProcess::readyReadStandardOutput, this, &I2PManager::handleProcessOutput);
        disconnect(m_i2pd.get(), &QProcess::errorOccurred, this, &I2PManager::handleProcessError);
    }

    if (!QFileInfo(m_i2pd_binary).isFile())
    {
        emit i2pStartFailure("\"" + QDir::toNativeSeparators(m_i2pd_binary) + "\" " + tr("executable is missing"));
        return false;
    }

    if (isAlreadyRunning()) {
        emit i2pStartFailure(QString("Unable to start I2P on %1:%2. Port already in use.").arg(host, QString::number(port)));
        return false;
    }

    if (!writeI2pdTunnelsConf(m_i2pd_tunnels_conf, allowIncomingConnections)) {
        emit i2pStartFailure("\"" + QDir::toNativeSeparators(m_i2pd_tunnels_conf) + "\" " + tr("could not write i2pd tunnels config file"));
        return false;
    }

    if (!writeI2pdConf(m_i2pd_conf)) {
        emit i2pStartFailure("\"" + QDir::toNativeSeparators(m_i2pd_conf) + "\" " + tr("could not write i2pd config file"));
        return false;
    }

    QStringList arguments;

    arguments << "--conf=" + m_i2pd_conf;
    arguments << "--tunconf=" + m_i2pd_tunnels_conf;
    arguments << "--tunnelsdir" << m_i2pd_tunnels_dir;
    arguments << "--loglevel" << m_i2pd_loglevel;
    arguments << "--datadir" << m_i2pd_datadir;
    arguments << "--certsdir" << m_i2pd_certsdir;
    
    qWarning() << "starting i2p " + m_i2pd_binary;
    qWarning() << "With command line arguments " << arguments;

    starting = true;

    QMutexLocker locker(&m_i2pdMutex);

    m_i2pd.reset(new QProcess(this));

    m_i2pd->setProcessChannelMode(QProcess::MergedChannels);
    connect(m_i2pd.get(), &QProcess::readyReadStandardOutput, this, &I2PManager::handleProcessOutput);
    connect(m_i2pd.get(), &QProcess::errorOccurred, this, &I2PManager::handleProcessError);
    // Start i2p
    try {
        m_i2pd->start(m_i2pd_binary, arguments);
        connect(m_i2pd.get(), SIGNAL(stateChanged(QProcess::ProcessState)), this, SLOT(stateChanged(QProcess::ProcessState)));
        started = true;
        auto state = m_i2pd->state();
        if (state == QProcess::ProcessState::Running || state == QProcess::ProcessState::Starting) {
            // wait for i2pd to catch up
            std::this_thread::sleep_for(std::chrono::milliseconds(5000));
            emit i2pStartSuccess();
        }
        else if (state == QProcess::ProcessState::NotRunning) {
            emit i2pStartFailure("I2P start failed");
        }
    }
    catch (const std::exception& ex) {
        qWarning() << "Error while starting i2p: " << ex.what();
        emit i2pStartFailure("I2P start failed");
        started = false;
    }

    return started;
}

void I2PManager::handleProcessOutput() {
    QByteArray output = [this]() {
        QMutexLocker locker(&m_i2pdMutex);
        return m_i2pd->readAllStandardOutput();
    }();

    qDebug() << output;
}

void I2PManager::handleProcessError(QProcess::ProcessError error) {
    bool failed = false;
    QString message = "Unkown error";

    if (error == QProcess::ProcessError::Crashed) {
        message = "I2P crashed or killed";
        failed = true;
    }
    else if (error == QProcess::ProcessError::FailedToStart) {
        message =  "I2P binary failed to start";
        failed = true;
    }

    auto state = m_i2pd->state();

    if (state == QProcess::ProcessState::NotRunning) {
        failed = true;
    }
    if (failed && starting) {
        emit i2pStartFailure(message); 
    }
    else if (failed) {
        emit i2pStopped();
    }

    starting = false;
}

void I2PManager::exit()
{
    qDebug("I2PManager: exit()");
    if (started && m_i2pd.get() != nullptr) {
        m_i2pd->kill();
        std::this_thread::sleep_for(std::chrono::milliseconds(1500));
        starting = started = false;
        emit i2pStopped();
    }
}

void I2PManager::stateChanged(QProcess::ProcessState state)
{
    qDebug() << "STATE CHANGED: " << state;
    if (state == QProcess::NotRunning) {
        emit i2pStopped();
    }
}

QString I2PManager::getVersion() const {
    QProcess process;
    process.setProcessChannelMode(QProcess::MergedChannels);
    process.start(m_i2pd_binary, QStringList() << "--version");
    process.waitForFinished(-1);
    QString output = process.readAllStandardOutput();

    if(output.isEmpty() || !output.contains("i2pd version")) {
        qWarning() << "Could not grab i2pd version";
        return QString();
    }

    auto lines = output.split("\n");

    if (lines.size() == 0) {
        qWarning() << "Could not grab i2pd version";
        return QString();
    }

    auto firstLine = lines.at(0);

    auto components = firstLine.split(" ");

    if (components.size() < 3) {
        qWarning() << "Could not grab i2pd version";
        return QString();
    }

    return components.at(2);
}

QString I2PManager::getProxyAddress() const {
    return host + QString(":") + QString::number(port);
}

I2PManager::I2PManager(QObject *parent)
    : QObject(parent)
{
    started = false;
    // Platform dependent path to i2p
    m_i2pd_path = QApplication::applicationDirPath() + "/i2p";

#ifdef Q_OS_WIN
    if (!QDir(m_i2pd_path).exists()) {
        QDir().mkdir(m_i2pd_path);
    }
    m_i2pd_binary = QApplication::applicationDirPath() + "/i2pd.exe";
    
#elif defined(Q_OS_UNIX)
    m_i2pd_binary = QApplication::applicationDirPath() + "/i2pd";
#endif

    m_i2pd_datadir = m_i2pd_path + "/data";
    m_i2pd_conf = m_i2pd_path + "/i2pd.conf";
    m_i2pd_tunnels_conf = m_i2pd_path + "/tunnels.conf";
    m_i2pd_tunnels_dir = m_i2pd_path + "/tunnels.conf.d";
    m_i2pd_loglevel = "warn";
    m_i2pd_p2p_dat = m_i2pd_datadir + "/monero-mainnet.dat";
    m_i2pd_rpc_dat = m_i2pd_datadir + "/monero-mainnet-rpc.dat";

    if (m_i2pd_binary.length() == 0) {
        qCritical() << "no i2p binary defined for current platform";
    }

    mkDir(m_i2pd_path);
    mkDir(m_i2pd_datadir);
    mkDir(m_i2pd_certsdir);
    mkDir(m_i2pd_tunnels_dir);

    m_i2pd.reset(new QProcess(this));

    connect(m_i2pd.get(), &QProcess::readyReadStandardOutput, this, &I2PManager::handleProcessOutput);
    connect(m_i2pd.get(), &QProcess::errorOccurred, this, &I2PManager::handleProcessError);
}

I2PManager::~I2PManager() {

}
