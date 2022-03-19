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

#include "Logger.h"

#include <QCoreApplication>
#include <QStandardPaths>
#include <QFileInfo>
#include <QString>
#include <QDir>
#include <QDebug>

#include <easylogging++.h>
#include <wallet/api/wallet2_api.h>

#include "qt/MoneroSettings.h"
#include "qt/TailsOS.h"

// default log path by OS (should be writable)
static const QString defaultLogName = "monero-wallet-gui.log";
#if defined(Q_OS_IOS)
    //AppDataLocation = "<APPROOT>/Library/Application Support"
    static const QString osPath = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation).at(0);
    static const QString appFolder = "monero-wallet-gui";
#elif defined(Q_OS_WIN)
    //AppDataLocation = "C:/Users/<USER>/AppData/Roaming/<APPNAME>"
    static const QString osPath = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation).at(0);
    static const QString appFolder = "monero-wallet-gui";
#elif defined(Q_OS_ANDROID)
    //AppDataLocation = "<USER>/<APPNAME>/files"
    static const QString osPath = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation).at(1);
    static const QString appFolder = "";
#elif defined(Q_OS_MAC)
    //HomeLocation = "~"
    static const QString osPath = QStandardPaths::standardLocations(QStandardPaths::HomeLocation).at(0);
    static const QString appFolder = "Library/Logs";
#else // linux + bsd
    //HomeLocation = "~"
    static const QString osPath = QStandardPaths::standardLocations(QStandardPaths::HomeLocation).at(0);
    static const QString appFolder = ".bitmonero";
#endif


// return the absolute path of the logfile and ensure path folder exists
const QString getLogPath(const QString &userDefinedLogFilePath, bool portable)
{
    const QFileInfo fi(userDefinedLogFilePath);
    if (!userDefinedLogFilePath.isEmpty() && !fi.isDir())
    {
        return fi.absoluteFilePath();
    }

    if (portable)
    {
        return QDir(MoneroSettings::portableFolderName()).filePath(defaultLogName);
    }

    if(TailsOS::detect() && TailsOS::usePersistence)
        return QDir::homePath() + "/Persistent/Monero/logs/" + defaultLogName;
    else {
        QDir appDir(osPath + "/" + appFolder);
        if(!appDir.exists())
            if(!appDir.mkpath("."))
                qWarning() << "Logger: Cannot create log directory " + appDir.path();
        return appDir.path() + "/" + defaultLogName;
    }
}


// custom messageHandler that foward all messages to easylogging
void messageHandler(QtMsgType type, const QMessageLogContext &context, const QString &message)
{
    (void) context; // context isn't used in release builds
    const std::string cat = "frontend"; // category displayed in the log
    const std::string msg = message.toStdString();
    switch(type)
    {
        case QtDebugMsg: Monero::Wallet::debug(cat, msg); break;
        case QtInfoMsg: Monero::Wallet::info(cat, msg); break;
        case QtWarningMsg: Monero::Wallet::warning(cat, msg); break;
        case QtCriticalMsg: Monero::Wallet::error(cat, msg); break;
        case QtFatalMsg: Monero::Wallet::error(cat, msg); break;
    }
}

Logger::Logger(QCoreApplication &parent, QString userDefinedLogFilePath)
    : QObject(&parent)
    , m_applicationFilePath(parent.applicationFilePath().toStdString())
    , m_userDefinedLogFilePath(std::move(userDefinedLogFilePath))
{
    el::Configurations c;
    c.setGlobally(el::ConfigurationType::ToFile, "false");
    c.setGlobally(el::ConfigurationType::ToStandardOutput, "true");
    el::Loggers::setDefaultConfigurations(c, true);
    qInstallMessageHandler(messageHandler);
}

void Logger::resetLogFilePath(bool portable)
{
    m_logFilePath = QDir::toNativeSeparators(getLogPath(m_userDefinedLogFilePath, portable));
    Monero::Wallet::init(m_applicationFilePath.c_str(), "monero-wallet-gui", m_logFilePath.toStdString(), true);
    qWarning() << "Logging to" << m_logFilePath;
    emit logFilePathChanged();
}

QString Logger::logFilePath() const
{
    return m_logFilePath;
}
