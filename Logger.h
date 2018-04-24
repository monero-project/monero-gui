#ifndef LOGGER_H
#define LOGGER_H

#include <QObject>
#include "wallet/api/wallet2_api.h"

class Logger : public QObject
{
    Q_OBJECT

public:
    static Logger &Instance()
    {
        static Logger object;
        return object;
    }

    void easylogging(QtMsgType type, const QMessageLogContext &context, const QString &msg)
    {
        // context isn't used in release builds
        (void) context;
        static const std::string cat = "frontend";
        const std::string message = msg.toStdString();
        switch(type)
        {
            case QtDebugMsg: Monero::Wallet::debug(cat, message); break;
            case QtInfoMsg: Monero::Wallet::info(cat, message); break;
            case QtWarningMsg: Monero::Wallet::warning(cat, message); break;
            case QtCriticalMsg: Monero::Wallet::error(cat, message); break;
            case QtFatalMsg: Monero::Wallet::error(cat, message); break;
        }
    }
};

QString getLogPath(QString logPath);
void qtMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg);

#endif // LOGGER_H
