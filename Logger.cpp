#include <QCoreApplication>
#include <QStandardPaths>
#include <QFileInfo>
#include <QString>

#include "Logger.h"
#include "wallet/api/wallet2_api.h"

// default log path by OS (should be writable)
static const QString default_name = "monero-wallet-gui.log";
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    static const QString osPath = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation).at(0);
#elif defined(Q_OS_WIN)
    static const QString osPath = QCoreApplication::applicationDirPath();
#elif defined(Q_OS_MAC)
    static const QString osPath = QStandardPaths::standardLocations(QStandardPaths::HomeLocation).at(0) + "/Library/Logs";
#else // linux + bsd
    static const QString osPath = QStandardPaths::standardLocations(QStandardPaths::HomeLocation).at(0);
#endif


// return the absolute path of the logfile
const QString getLogPath(const QString logPath)
{
    const QFileInfo fi(logPath);

    if(!logPath.isEmpty() && !fi.isDir())
        return fi.absoluteFilePath();
    else
        return osPath + "/" + default_name;
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

