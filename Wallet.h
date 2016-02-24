#ifndef WALLET_H
#define WALLET_H

#include <QObject>

struct WalletImpl;

class Wallet : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString seed READ getSeed)
public:
    explicit Wallet(QObject *parent = 0);
    QString getSeed() const;
    QString getSeedLanguage() const;
    void setSeedLaguage(const QString &lang);
signals:
public slots:

private:


    friend class WalletManager;
    WalletImpl * m_pimpl;


};

#endif // WALLET_H
