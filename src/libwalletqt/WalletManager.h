#ifndef WALLETMANAGER_H
#define WALLETMANAGER_H

#include <QObject>
#include <QUrl>
#include <wallet/wallet2_api.h>

class Wallet;
namespace Bitmonero {
    class WalletManager;
}

class WalletManager : public QObject
{
    Q_OBJECT

public:
    enum LogLevel {
        LogLevel_Silent = Bitmonero::WalletManagerFactory::LogLevel_Silent,
        LogLevel_0 = Bitmonero::WalletManagerFactory::LogLevel_0,
        LogLevel_1 = Bitmonero::WalletManagerFactory::LogLevel_1,
        LogLevel_2 = Bitmonero::WalletManagerFactory::LogLevel_2,
        LogLevel_3 = Bitmonero::WalletManagerFactory::LogLevel_3,
        LogLevel_4 = Bitmonero::WalletManagerFactory::LogLevel_4,
        LogLevel_Min = Bitmonero::WalletManagerFactory::LogLevel_Min,
        LogLevel_Max = Bitmonero::WalletManagerFactory::LogLevel_Max,
    };

    static WalletManager * instance();
    // wizard: createWallet path;
    Q_INVOKABLE Wallet * createWallet(const QString &path, const QString &password,
                                      const QString &language, bool testnet = false);

    /*!
     * \brief openWallet - opens wallet by given path
     * \param path       - wallet filename
     * \param password   - wallet password. Empty string in wallet isn't password protected
     * \param testnet    - determines if we running testnet
     * \return wallet object pointer
     */
    Q_INVOKABLE Wallet * openWallet(const QString &path, const QString &password, bool testnet = false);

    /*!
     * \brief openWalletAsync - asynchronous version of "openWallet". Returns immediately. "walletOpened" signal
     *                          emitted when wallet opened;
     */
    Q_INVOKABLE void openWalletAsync(const QString &path, const QString &password, bool testnet = false);

    // wizard: recoveryWallet path; hint: internally it recorvers wallet and set password = ""
    Q_INVOKABLE Wallet * recoveryWallet(const QString &path, const QString &memo,
                                       bool testnet = false, quint64 restoreHeight = 0);

    /*!
     * \brief closeWallet - closes wallet and frees memory
     * \param wallet
     * \return wallet address
     */
    Q_INVOKABLE QString closeWallet(Wallet * wallet);

    /*!
     * \brief closeWalletAsync - asynchronous version of "closeWallet"
     * \param wallet - wallet pointer;
     */
    Q_INVOKABLE void closeWalletAsync(Wallet * wallet);

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


    //! since we can't call static method from QML, move it to this class
    Q_INVOKABLE QString displayAmount(quint64 amount) const;
    Q_INVOKABLE quint64 amountFromString(const QString &amount) const;
    Q_INVOKABLE quint64 amountFromDouble(double amount) const;
    Q_INVOKABLE quint64 maximumAllowedAmount() const;

    // QML JS engine doesn't support unsigned integers
    Q_INVOKABLE QString maximumAllowedAmountAsSting() const;

    // QML missing such functionality, implementing these helpers here
    Q_INVOKABLE QString urlToLocalPath(const QUrl &url) const;
    Q_INVOKABLE QUrl localPathToUrl(const QString &path) const;

    void setLogLevel(int logLevel);

signals:

    void walletOpened(Wallet * wallet);
    void walletClosed(const QString &walletAddress);

public slots:
private:

    explicit WalletManager(QObject *parent = 0);
    static WalletManager * m_instance;
    Bitmonero::WalletManager * m_pimpl;

};

#endif // WALLETMANAGER_H
