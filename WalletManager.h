#ifndef WALLETMANAGER_H
#define WALLETMANAGER_H

#include <QObject>

class Wallet;

class WalletManager : public QObject
{
    Q_OBJECT
public:
    static WalletManager * instance();
    // wizard: createWallet path;
    Q_INVOKABLE Wallet * createWallet(const QString &path, const QString &password,
                                      const QString &language);
    // just for future use
    Q_INVOKABLE Wallet * openWallet(const QString &path, const QString &language,
                                    const QString &password);

    // wizard: recoveryWallet path; hint: internally it recorvers wallet and set password = ""
    Q_INVOKABLE Wallet * recoveryWallet(const QString &path, const QString &memo,
                                       const QString &language);

    // wizard: both "create" and "recovery" paths.
    // TODO: probably move it to "Wallet" interface
    Q_INVOKABLE bool moveWallet(const QString &src, const QString &dst);

    //! utils: close wallet to free memory
    Q_INVOKABLE void closeWallet(Wallet * wallet);

    //! returns libwallet language name for given locale
    Q_INVOKABLE QString walletLanguage(const QString &locale);

    //! returns last error happened in WalletManager
    Q_INVOKABLE int error() const;

    //! returns error description in human language
    Q_INVOKABLE QString errorString() const;
signals:

public slots:

private:
    explicit WalletManager(QObject *parent = 0);
    static WalletManager * m_instance;
};

#endif // WALLETMANAGER_H
