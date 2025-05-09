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

#include "I2PDaemon.h"
#include <QtGlobal>
#include <QDebug>
#include <Daemon.h>
#include <Log.h>
#include <Identity.h>
#include <Config.h>
#include <version.h>
#include <cstring>
#include <FS.h>

void toArgv(const std::vector<std::string>& args, int& argc, char**& argv) {
    argc = args.size();
    argv = new char*[argc + 1];

    for (size_t i = 0; i < args.size(); ++i) {
        argv[i] = new char[args[i].size() + 1];
        std::strcpy(argv[i], args[i].c_str());
    }
    
    argv[argc] = nullptr;
}

std::string I2PDaemon::getAddress(const std::string &path) {
    std::ifstream s(path, std::ifstream::binary);

    if (!s.is_open()) {
        return std::string("");
	}

    s.seekg(0, std::ios::end);
	size_t len = s.tellg();
	s.seekg(0, std::ios::beg);
	uint8_t * buf = new uint8_t[len];
	s.read((char*)buf, len);

    i2p::data::PrivateKeys keys;
    
    if (!keys.FromBuffer(buf, len)) {
        return std::string("");
	}

    auto dest = keys.GetPublic();
	if(!dest) {
        return std::string("");
	}
    
    const auto & ident = dest->GetIdentHash();

    return ident.ToBase32() + std::string(".b32.i2p");
}

std::string I2PDaemon::getVersion() {
    return std::string("v") + std::string(I2PD_VERSION) + std::string (" (") + std::string(I2P_VERSION) + std::string(")");
}

bool I2PDaemon::init(const std::vector<std::string>& flags, const std::string& dataDir) {
    LogPrint(LogLevel::eLogError, "I2PDaemon::init");

    int argc = 0;
    char **argv;

    toArgv(flags, argc, argv);

    for (auto &flag : flags) {
        LogPrint(LogLevel::eLogError, flag);
    }
    
    Daemon.setDataDir(dataDir);
    bool r = Daemon.init(argc, argv);

    std::string config; i2p::config::GetOption("conf", config);
    std::string tunconf; i2p::config::GetOption("tunconf", tunconf);
    std::string dDir = i2p::fs::GetDataDir();

    LogPrint(LogLevel::eLogNone, "I2PDaemon::init(): conf is " + config + ", tunconf is " + tunconf);

    if (!r) {
        LogPrint(LogLevel::eLogError, "I2PDaemon::init(): not initialized");
    }
    else {
        LogPrint(LogLevel::eLogError, "I2PDaemon::init(): initialized");
    }

    return r;
}

bool I2PDaemon::init(bool outproxyEnabled, const std::string& outproxy, int outproxyPort) {    
    qWarning() << "I2P DAEMON INIT";
    if (!initialized) {
        if (!i2p::config::SetOption("ipv4", true)) {
            qWarning() <<  "Could not set ipv4 option";
            return false;
        }
        if (!i2p::config::SetOption("ipv6", false)) {
            qWarning() <<  "Could not set ipv6 option";
            return false;
        }
        if (!i2p::config::SetOption("loglevel", "debug")) {
            qWarning() <<  "Could not set info option";
            return false;
        }
        if (!i2p::config::SetOption("ntcp2.enabled", true)) {
            qWarning() <<  "Could not set ntpc2.enabled option";
            return false;
        }
        if (!i2p::config::SetOption("ssu2.enabled", true)) {
            qWarning() <<  "Could not set ssu2.enabled option";
            return false;
        }
        if (!i2p::config::SetOption("sam.enabled", false)) {
            qWarning() <<  "Could not set sam.enabled option";
            return false;
        }
        if (!i2p::config::SetOption("httpproxy.enabled", false)) {
            qWarning() <<  "Could not set httproxy.enabled option";
            return false;
        }
        if (!i2p::config::SetOption("socksproxy.enabled", true)) {
            qWarning() <<  "Could not set socksproxy.enabled option";
            return false;
        }
        //if (!i2p::config::SetOption("reseed.verify", true)) return false;
        initialized = true;

    }

    if (!i2p::config::SetOption("socksproxy.outproxy.enabled", outproxyEnabled)) {
        qWarning() << "Could not set socksproxy.outproxy.enabled option";
        return false;
    }

    if (outproxyEnabled && !outproxy.empty()) {
        if (!i2p::config::SetOption("socksproxy.outproxy", outproxy)) {
            qWarning() << "Could not set socksproxy.outproxy option";
            return false;
        }
        if (!i2p::config::SetOption("socksproxy.outproxyport", outproxyPort)) {
            qWarning() << "Could not set socksproxy.ourproxyport option";
            return false;
        }
    }

    return true;
}

bool I2PDaemon::start() {
    bool r = Daemon.start();

    if (!r) {
        LogPrint(LogLevel::eLogError, "I2PDaemon::start(): not started");
    }
    else {
        LogPrint(LogLevel::eLogError, "I2PDaemon::start(): started");
    }

    return r;
}

bool I2PDaemon::stop() {
    LogPrint(LogLevel::eLogError, "I2PDaemon::stop()");

    bool r = Daemon.stop();

    if (!r) {
        LogPrint(LogLevel::eLogError, "I2PDaemon::stop(): not stopped");
    }
    else {
        LogPrint(LogLevel::eLogError, "I2PDaemon::stop(): stopped");
    }

    return r;
}

bool I2PDaemon::isRunning() {
    return Daemon.running;
}

