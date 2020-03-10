#ifndef PRICES_H
#define PRICES_H

#include <QCoreApplication>
#include <QtNetwork>

#include "FutureScheduler.h"

class Prices : public QObject
{
Q_OBJECT
public:
    Prices(QObject *parent = nullptr);

public:
    Q_INVOKABLE void getJSON(const QString url) const;

private:
    void gotError(const QString &message) const;

signals:
    void priceJsonReceived(QVariantMap document) const;
    void priceJsonError(QString message) const;

private:
    mutable FutureScheduler m_scheduler;
};

#endif // PRICES_H
