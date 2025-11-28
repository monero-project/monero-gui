#ifndef WALLETMANAGER_H
#define WALLETMANAGER_H

#include <QVariant>
#include <QObject>
#include <QUrl>
#include <wallet/api/wallet2_api.h>
#include <QMutex>
#include <QPointer>
#include <QWaitCondition>
#include "qt/FutureScheduler.h"
#include "NetworkType.h"
#include "PassphraseHelper.h"

class Wallet;
namespace Monero {
struct WalletManager;
}

class WalletManager : public QObject, public PassprasePrompter
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ connected)
    Q_PROPERTY(QString proxyAddress READ proxyAddress WRITE setProxyAddress NOTIFY proxyAddressChanged)

public:
    explicit WalletManager(QObject *parent = 0);
    ~WalletManager();

    enum LogLevel {
        LogLevel_Silent = Monero::WalletManagerFactory::LogLevel_Silent,
        LogLevel_0 = Monero::WalletManagerFactory::LogLevel_0,
        LogLevel_1 = Monero::WalletManagerFactory::LogLevel_1,
        LogLevel_2 = Monero::WalletManagerFactory::LogLevel_2,
        LogLevel_3 = Monero::WalletManagerFactory::LogLevel_3,
        LogLevel_4 = Monero::WalletManagerFactory::LogLevel_4,
        LogLevel_Min = Monero::WalletManagerFactory::LogLevel_Min,
        LogLevel_Max = Monero::WalletManagerFactory::LogLevel_Max,
    };

    Q_INVOKABLE Wallet * createWallet(const QString &path, const QString &password,
                                     const QString &language, NetworkType::Type nettype = NetworkType::MAINNET, quint64 kdfRounds = 1);
    Q_INVOKABLE Wallet * openWallet(const QString &path, const QString &password, NetworkType::Type nettype = NetworkType::MAINNET, quint64 kdfRounds = 1);
    Q_INVOKABLE void openWalletAsync(const QString &path, const QString &password, NetworkType::Type nettype = NetworkType::MAINNET, quint64 kdfRounds = 1);
    Q_INVOKABLE Wallet * recoveryWallet(const QString &path, const QString &seed, const QString &seed_offset,
                                       NetworkType::Type nettype = NetworkType::MAINNET, quint64 restoreHeight = 0, quint64 kdfRounds = 1);
    Q_INVOKABLE Wallet * createWalletFromKeys(const QString &path, const QString &language, NetworkType::Type nettype, const QString &address, const QString &viewkey, const QString &spendkey = "", quint64 restoreHeight = 0, quint64 kdfRounds = 1);
    Q_INVOKABLE Wallet * createWalletFromDevice(const QString &path, const QString &password, NetworkType::Type nettype, const QString &deviceName, quint64 restoreHeight = 0, const QString &subaddressLookahead = "", quint64 kdfRounds = 1);
    Q_INVOKABLE void createWalletFromDeviceAsync(const QString &path, const QString &password, NetworkType::Type nettype, const QString &deviceName, quint64 restoreHeight = 0, const QString &subaddressLookahead = "", quint64 kdfRounds = 1);
    Q_INVOKABLE QString closeWallet();
    Q_INVOKABLE void closeWalletAsync(const QJSValue& callback);
    Q_INVOKABLE bool walletExists(const QString &path) const;
    Q_INVOKABLE QStringList findWallets(const QString &path);
    Q_INVOKABLE QString errorString() const;
    Q_INVOKABLE static QString displayAmount(quint64 amount);
    Q_INVOKABLE static quint64 amountFromString(const QString &amount);
    Q_INVOKABLE quint64 amountFromDouble(double amount) const;
    Q_INVOKABLE static QString amountsSumFromStrings(const QVector<QString> &amounts);
    Q_INVOKABLE static quint64 maximumAllowedAmount();
    Q_INVOKABLE QString maximumAllowedAmountAsString() const;
    Q_INVOKABLE bool paymentIdValid(const QString &payment_id) const;
    Q_INVOKABLE bool addressValid(const QString &address, NetworkType::Type nettype) const;
    Q_INVOKABLE bool keyValid(const QString &key, const QString &address, bool isViewKey, NetworkType::Type nettype) const;
    Q_INVOKABLE QString paymentIdFromAddress(const QString &address, NetworkType::Type nettype) const;
    Q_INVOKABLE void setDaemonAddressAsync(const QString &address);
    Q_INVOKABLE bool connected() const;
    Q_INVOKABLE quint64 networkDifficulty() const;
    Q_INVOKABLE quint64 blockchainHeight() const;
    Q_INVOKABLE quint64 blockchainTargetHeight() const;
    Q_INVOKABLE double miningHashRate() const;
    Q_INVOKABLE bool localDaemonSynced() const;
    Q_INVOKABLE bool isDaemonLocal(const QString &daemon_address) const;
    Q_INVOKABLE void miningStatusAsync();
    Q_INVOKABLE bool startMining(const QString &address, quint32 threads, bool backgroundMining, bool ignoreBattery);
    Q_INVOKABLE bool stopMining();
    Q_INVOKABLE QString urlToLocalPath(const QUrl &url) const;
    Q_INVOKABLE QUrl localPathToUrl(const QString &path) const;
    Q_INVOKABLE void setLogLevel(int logLevel);
    Q_INVOKABLE void setLogCategories(const QString &categories);
    Q_INVOKABLE quint64 add(quint64 x, quint64 y) const { return x + y; }
    Q_INVOKABLE quint64 sub(quint64 x, quint64 y) const { return x - y; }
    Q_INVOKABLE qint64 addi(qint64 x, qint64 y) const { return x + y; }
    Q_INVOKABLE qint64 subi(qint64 x, qint64 y) const { return x - y; }
    Q_INVOKABLE double getPasswordStrength(const QString &password) const;
    Q_INVOKABLE QString resolveOpenAlias(const QString &address) const;
    Q_INVOKABLE bool parse_uri(const QString &uri, QString &address, QString &payment_id, uint64_t &amount, QString &tx_description, QString &recipient_name, QVector<QString> &unknown_parameters, QString &error) const;
    Q_INVOKABLE QVariantMap parse_uri_to_object(const QString &uri) const;
    Q_INVOKABLE QString make_uri(const QString &address, const quint64 &amount = 0, const QString &tx_description = "", const QString &recipient_name = "") const;
    Q_INVOKABLE bool saveQrCode(const QString &, const QString &) const;
    Q_INVOKABLE void saveQrCodeToClipboard(const QString &) const;
    Q_INVOKABLE void checkUpdatesAsync(const QString &software, const QString &subdir, const QString &buildTag, const QString &version);
    Q_INVOKABLE QString checkUpdates(const QString &software, const QString &subdir) const;
    Q_INVOKABLE bool clearWalletCache(const QString &fileName) const;
    Q_INVOKABLE void onPassphraseEntered(const QString &passphrase, bool enter_on_device, bool entry_abort=false);
    virtual void onWalletPassphraseNeeded(bool on_device) override;

    QString proxyAddress() const;
    void setProxyAddress(QString address);

signals:
    void walletOpened(Wallet * wallet);
    void walletCreated(Wallet * wallet);
    void walletPassphraseNeeded(bool onDevice);
    void deviceButtonRequest(quint64 buttonCode);
    void deviceButtonPressed();
    void checkUpdatesComplete(const QString &version, const QString &downloadUrl, const QString &hash, const QString &firstSigner, const QString &secondSigner) const;
    void miningStatus(bool isMining) const;
    void proxyAddressChanged() const;

public slots:
    void onI2pSettingsChanged();

private:
    friend class WalletPassphraseListenerImpl;
    bool isMining() const;
    static WalletManager * m_instance;
    Monero::WalletManager * m_pimpl;
    mutable QMutex m_mutex;
    QPointer<Wallet> m_currentWallet;
    PassphraseReceiver * m_passphraseReceiver;
    QMutex m_mutex_passphraseReceiver;
    QString m_proxyAddress;
    mutable QMutex m_proxyMutex;
    FutureScheduler m_scheduler;
};

#endif // WALLETMANAGER_H
