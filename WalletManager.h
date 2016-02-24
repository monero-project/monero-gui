#ifndef WALLETMANAGER_H
#define WALLETMANAGER_H

#include <QObject>

class Wallet;

class WalletManager : public QObject
{
    Q_OBJECT
public:
    static WalletManager * instance();
    Q_INVOKABLE Wallet * createWallet(const QString &path, const QString &password,
                                      const QString &language);
    Q_INVOKABLE Wallet * openWallet(const QString &path, const QString &language);
    Q_INVOKABLE bool moveWallet(const QString &src, const QString &dst);

signals:

public slots:

private:
    explicit WalletManager(QObject *parent = 0);
    static WalletManager * m_instance;

};

#endif // WALLETMANAGER_H
