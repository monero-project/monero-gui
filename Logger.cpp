#include <QStandardPaths>
#include <QFileInfo>
#include <QString>
#include <QDir>
#include "Logger.h"

QString getLogPath(QString logPath)
{
    static const QString logName = "monero-wallet-gui.log";
    QFileInfo fi(logPath);
    QDir logdir(logPath);
    if(!logPath.isEmpty() && fi.isDir() && fi.isWritable())
        return logdir.canonicalPath() + "/" + logName;
    else
#ifdef Q_OS_MAC
        return QStandardPaths::standardLocations(QStandardPaths::HomeLocation).at(0) + "/Library/Logs/" + logName;
#elif defined(Q_OS_LINUX)
        return QStandardPaths::standardLocations(QStandardPaths::HomeLocation).at(0) + "/" + logName;
#else
        return QCoreApplication::applicationDirPath() + "/" + logName;
#endif
}

void qtMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    Logger &logger = Logger::Instance();
    logger.easylogging(type, context, msg);
}

