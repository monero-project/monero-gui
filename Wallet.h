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

    //! returns mnemonic seed
    Q_INVOKABLE QString getSeed() const;

    //! returns seed language
    Q_INVOKABLE QString getSeedLanguage() const;


    //! changes the password using existing parameters (path, seed, seed lang)
    Q_INVOKABLE bool setPassword(const QString &password);
    //! returns curret wallet password
    Q_INVOKABLE QString getPassword() const;

    //! renames/moves wallet files
    Q_INVOKABLE bool rename(const QString &name);

    //! returns current wallet name (basename, as wallet consists of several files)
    Q_INVOKABLE QString getBasename() const;

    Q_INVOKABLE int error() const;
    Q_INVOKABLE QString errorString() const;

private:
    Wallet(const QString &path, const QString &password, const QString &language);

private:
    friend class WalletManager;
    //! pimpl wrapper for libwallet;
    WalletImpl * m_pimpl;
};

#endif // WALLET_H
