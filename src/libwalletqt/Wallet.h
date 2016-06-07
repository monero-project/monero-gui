#ifndef WALLET_H
#define WALLET_H

#include <QObject>

namespace Bitmonero {
    class Wallet; // forward declaration
}
class Wallet : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString seed READ getSeed)
public:
    enum Status {
        Status_Ok = 0,
        Status_Error = 1
    };

    //! returns mnemonic seed
    Q_INVOKABLE QString getSeed() const;

    //! returns seed language
    Q_INVOKABLE QString getSeedLanguage() const;

    //! returns last operation's status
    Q_INVOKABLE int status() const;

    //! returns last operation's error message
    Q_INVOKABLE QString errorString() const;

    //! changes the password using existing parameters (path, seed, seed lang)
    Q_INVOKABLE bool setPassword(const QString &password);

    //! returns wallet's public address
    Q_INVOKABLE QString address() const;

    //! saves wallet to the file by given path
    Q_INVOKABLE bool store(const QString &path);



private:
    Wallet(Bitmonero::Wallet *w, QObject * parent = 0);
    ~Wallet();

private:
    friend class WalletManager;
    //! libwallet's
    Bitmonero::Wallet * m_walletImpl;
};

#endif // WALLET_H
