#ifndef WALLET_H
#define WALLET_H

#include <QObject>

class Wallet : public QObject
{
    Q_OBJECT
public:
    explicit Wallet(QObject *parent = 0);

signals:

public slots:
};

#endif // WALLET_H