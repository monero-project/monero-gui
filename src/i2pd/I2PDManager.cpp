// Copyright (c) 2014-2022, The Monero Project
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

#include "I2PDManager.h"
#include "../../external/i2pd/daemon/Daemon.h"
#include <vector>
#include <QApplication>
#include <QDir>
#include <QDebug>

I2PDManager::I2PDManager(QObject *parent)
    : QObject(parent)
{
#ifdef Q_OS_WIN
    m_i2pdDataDir = QApplication::applicationDirPath() + "/i2pd";
    if (!QDir(m_i2pdDataDir).exists()) {
        QDir().mkdir(m_i2pdDataDir);
    }
#elif defined(Q_OS_UNIX)
    m_i2pdDataDir = QApplication::applicationDirPath() + "/i2pd";
        if (!QDir(m_i2pdDataDir).exists()) {
        QDir().mkdir(m_i2pdDataDir);
    }
#endif
    if (m_i2pdDataDir.length() == 0) {
        qCritical() << "I2PD not compatible with current platform";
    }

    std::string dataDir = "--datadir=" + m_i2pdDataDir.toStdString();
    std::vector<const char*> argv({"i2pd", dataDir.data()});
    Daemon.init(argv.size(), (char**) argv.data());
}

I2PDManager::~I2PDManager()
{

}

void I2PDManager::start()
{
    if (!isRunning()) {
        Daemon.start();
        Daemon.running;
    }
}

void I2PDManager::stop()
{
    if (isRunning()) {
        Daemon.stop();
    }
}

bool I2PDManager::isRunning() const
{
    return Daemon.running;
}
