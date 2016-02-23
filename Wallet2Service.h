#ifndef WALLET2SERVICE_H
#define WALLET2SERVICE_H

#include <QObject>

class Wallet2Service : public QObject
{
    Q_OBJECT
public:
    explicit Wallet2Service(QObject *parent = 0);

signals:

public slots:
};

#endif // WALLET2SERVICE_H