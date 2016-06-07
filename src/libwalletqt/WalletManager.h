#ifndef WALLETMANAGER_H
#define WALLETMANAGER_H

#include <QObject>

class Wallet;
namespace Bitmonero {
    class WalletManager;
}

class WalletManager : public QObject
{
    Q_OBJECT
public:
    static WalletManager * instance();
    // wizard: createWallet path;
    Q_INVOKABLE Wallet * createWallet(const QString &path, const QString &password,
                                      const QString &language, bool testnet = false);
    // just for future use
    Q_INVOKABLE Wallet * openWallet(const QString &path, const QString &password, bool testnet = false);

    // wizard: recoveryWallet path; hint: internally it recorvers wallet and set password = ""
    Q_INVOKABLE Wallet * recoveryWallet(const QString &path, const QString &memo,
                                       bool testnet = false);

    //! utils: close wallet to free memory
    Q_INVOKABLE void closeWallet(Wallet * wallet);

    //! checks is given filename is a wallet;
    Q_INVOKABLE bool walletExists(const QString &path) const;

    //! returns list with wallet's filenames, if found by given path
    Q_INVOKABLE QStringList findWallets(const QString &path);

    //! returns error description in human language
    Q_INVOKABLE QString errorString() const;


    // wizard: both "create" and "recovery" paths.
    // TODO: probably move it to "Wallet" interface
    Q_INVOKABLE bool moveWallet(const QString &src, const QString &dst);
    //! returns libwallet language name for given locale
    Q_INVOKABLE QString walletLanguage(const QString &locale);

signals:

public slots:

private:

    explicit WalletManager(QObject *parent = 0);
    static WalletManager * m_instance;
    Bitmonero::WalletManager * m_pimpl;

};

#endif // WALLETMANAGER_H
