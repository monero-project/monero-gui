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

#include <cstring>
#include <QApplication>
#include <QDir>
#include "I2PManager.h"

QString buildI2pdTunnelsConf(bool allowIncomingConnections) {
    if (!allowIncomingConnections) return QString("");
    return QString(
        "[monero-node]\n"
        "type = server\n"
        "host = 127.0.0.1\n"
        "# Anonymous inbound port\n"
        "port = 1885\n"
        "inport = 0\n"
        "keys = monero-mainnet.dat\n"
        "\n"
        "[monero-rpc]\n"
        "type = server\n"
        "host = 127.0.0.1\n"
        "# Restricted RPC port\n"
        "port = 18089\n"
        "keys = monero-mainnet.dat\n"
    );
}

bool writeI2pdTunnelsConf(QString path, bool allowIncomingConnections) {
    return fileWrite(path, buildI2pdTunnelsConf(allowIncomingConnections));
}

bool I2PManager::start(bool allowIncomingConnections, bool outproxyEnabled, QString outproxy, int outproxyPort)
{
    if (started) return false;

    if (!writeI2pdTunnelsConf(m_tunnelsconf, allowIncomingConnections)) {
        emit i2pStartFailure("\"" + QDir::toNativeSeparators(m_conf) + "\" " + tr("could not write i2pd tunnels config file"));
        return false;
    }

    initialized = m_i2pd.init(outproxyEnabled, outproxy.toStdString(), outproxyPort);

    if (!initialized) {
        emit i2pStartFailure(QString("I2P not initialized"));
        return false;
    }

    started = m_i2pd.start();

    if (started) emit i2pStartSuccess();
    else emit i2pStartFailure(QString("Could not start I2P"));
    
    return started;
}

void I2PManager::exit()
{
    if (!started) return;

    if (!m_i2pd.stop()) {
        return;
    }

    emit i2pStopped();
    started = false;
}

I2PManager::I2PManager(QObject *parent)
    : QObject(parent),
    m_i2pd(this)
{
    started = false;

    m_i2p_path = QApplication::applicationDirPath() + "/i2p";
    m_tunnelsconf = m_i2p_path + "/tunnels.conf";
    m_tunnelsdir = m_i2p_path + "/tunnels.conf.d";
    m_datadir = m_i2p_path + "/data";
    m_conf = m_datadir + "/i2pd.conf";
    m_keys = m_datadir + "/monero-mainnet.dat";
    m_certsdir = m_i2p_path + "/certs";
    m_loglevel = "debug";

    mkDir(m_i2p_path);
    mkDir(m_datadir);
    mkDir(m_certsdir);
    mkDir(m_tunnelsdir);

    std::vector<std::string> args;

    std::string conf = std::string("--conf=") + m_conf.toStdString();
    std::string tunconf = std::string("--tunconf=") + m_tunnelsconf.toStdString();
    std::string tunnelsdir = std::string("--tunnelsdir=") + m_tunnelsdir.toStdString();
    std::string logLevel = std::string("--loglevel=") + m_loglevel.toStdString();
    std::string dataDir = std::string("--datadir=") + m_datadir.toStdString();
    std::string certsDir = std::string("--certsdir=") + m_certsdir.toStdString();
    //std::string daemon = std::string("--daemon");

    args.push_back(conf);
    args.push_back(tunconf);
    args.push_back(tunnelsdir);
    args.push_back(dataDir);
    args.push_back(certsDir);
    args.push_back(logLevel);
    //args.push_back(daemon);
    qWarning() << "Inialiazing i2pd: " << m_conf;
    
    initialized = m_i2pd.init(args, m_datadir.toStdString());
}

I2PManager::~I2PManager() {
    exit();
}

QString I2PManager::getVersion() {
    return QString(I2PDaemon::getVersion().c_str());
}

QString I2PManager::getAddress() const {
    return QString(I2PDaemon::getAddress(m_keys.toStdString()).c_str());
}

QString I2PManager::getProxyAddress() const {
    return m_socks_host + QString(":") + QString::number(m_socks_port);
}