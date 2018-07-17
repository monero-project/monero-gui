#ifndef WALLET_H
#define WALLET_H

#include <QObject>
#include <QTime>
#include <QMutex>
#include <QList>
#include <QtConcurrent/QtConcurrent>

#include "wallet/api/wallet2_api.h" // we need to have an access to the Monero::Wallet::Status enum here;
#include "PendingTransaction.h" // we need to have an access to the PendingTransaction::Priority enum here;
#include "UnsignedTransaction.h"
#include "NetworkType.h"

namespace Monero {
    class Wallet; // forward declaration
}


class TransactionHistory;
class TransactionHistoryModel;
class TransactionHistorySortFilterModel;
class AddressBook;
class AddressBookModel;
class Subaddress;
class SubaddressModel;

class Wallet : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString seed READ getSeed)
    Q_PROPERTY(QString seedLanguage READ getSeedLanguage)
    Q_PROPERTY(Status status READ status)
    Q_PROPERTY(NetworkType::Type nettype READ nettype)
//    Q_PROPERTY(ConnectionStatus connected READ connected)
    Q_PROPERTY(quint32 currentSubaddressAccount READ currentSubaddressAccount)
    Q_PROPERTY(bool synchronized READ synchronized)
    Q_PROPERTY(QString errorString READ errorString)
    Q_PROPERTY(TransactionHistory * history READ history)
    Q_PROPERTY(QString paymentId READ paymentId WRITE setPaymentId)
    Q_PROPERTY(TransactionHistorySortFilterModel * historyModel READ historyModel NOTIFY historyModelChanged)
    Q_PROPERTY(QString path READ path)
    Q_PROPERTY(AddressBookModel * addressBookModel READ addressBookModel)
    Q_PROPERTY(AddressBook * addressBook READ addressBook)
    Q_PROPERTY(SubaddressModel * subaddressModel READ subaddressModel)
    Q_PROPERTY(Subaddress * subaddress READ subaddress)
    Q_PROPERTY(bool viewOnly READ viewOnly)
    Q_PROPERTY(QString secretViewKey READ getSecretViewKey)
    Q_PROPERTY(QString publicViewKey READ getPublicViewKey)
    Q_PROPERTY(QString secretSpendKey READ getSecretSpendKey)
    Q_PROPERTY(QString publicSpendKey READ getPublicSpendKey)
    Q_PROPERTY(QString daemonLogPath READ getDaemonLogPath CONSTANT)
    Q_PROPERTY(quint64 walletCreationHeight READ getWalletCreationHeight WRITE setWalletCreationHeight NOTIFY walletCreationHeightChanged)

public:


    enum Status {
        Status_Ok       = Monero::Wallet::Status_Ok,
        Status_Error    = Monero::Wallet::Status_Error,
        Status_Critical = Monero::Wallet::Status_Critical
    };

    Q_ENUM(Status)

    enum ConnectionStatus {
        ConnectionStatus_Connected       = Monero::Wallet::ConnectionStatus_Connected,
        ConnectionStatus_Disconnected    = Monero::Wallet::ConnectionStatus_Disconnected,
        ConnectionStatus_WrongVersion    = Monero::Wallet::ConnectionStatus_WrongVersion
    };

    Q_ENUM(ConnectionStatus)

    //! returns mnemonic seed
    QString getSeed() const;

    //! returns seed language
    QString getSeedLanguage() const;

    //! set seed language
    Q_INVOKABLE void setSeedLanguage(const QString &lang);

    //! returns last operation's status
    Status status() const;

    //! returns network type of the wallet.
    NetworkType::Type nettype() const;

    //! returns whether the wallet is connected, and version status
    Q_INVOKABLE ConnectionStatus connected(bool forceCheck = false);
    void updateConnectionStatusAsync();

    //! returns true if wallet was ever synchronized
    bool synchronized() const;


    //! returns last operation's error message
    QString errorString() const;

    //! changes the password using existing parameters (path, seed, seed lang)
    Q_INVOKABLE bool setPassword(const QString &password);

    //! returns wallet's public address
    Q_INVOKABLE QString address(quint32 accountIndex, quint32 addressIndex) const;

    //! returns wallet file's path
    QString path() const;

    //! saves wallet to the file by given path
    //! empty path stores in current location
    Q_INVOKABLE bool store(const QString &path = "");

    //! initializes wallet
    Q_INVOKABLE bool init(const QString &daemonAddress, quint64 upperTransactionLimit = 0, bool isRecovering = false, quint64 restoreHeight = 0);

    //! initializes wallet asynchronously
    Q_INVOKABLE void initAsync(const QString &daemonAddress, quint64 upperTransactionLimit = 0, bool isRecovering = false, quint64 restoreHeight = 0);

    // Set daemon rpc user/pass
    Q_INVOKABLE void setDaemonLogin(const QString &daemonUsername = "", const QString &daemonPassword = "");

    //! create a view only wallet
    Q_INVOKABLE bool createViewOnly(const QString &path, const QString &password) const;

    //! connects to daemon
    Q_INVOKABLE bool connectToDaemon();

    //! indicates id daemon is trusted
    Q_INVOKABLE void setTrustedDaemon(bool arg);

    //! returns balance
    Q_INVOKABLE quint64 balance(quint32 accountIndex) const;
    Q_INVOKABLE quint64 balanceAll() const;

    //! returns unlocked balance
    Q_INVOKABLE quint64 unlockedBalance(quint32 accountIndex) const;
    Q_INVOKABLE quint64 unlockedBalanceAll() const;

    //! account/address management
    quint32 currentSubaddressAccount() const;
    Q_INVOKABLE void switchSubaddressAccount(quint32 accountIndex);
    Q_INVOKABLE void addSubaddressAccount(const QString& label);
    Q_INVOKABLE quint32 numSubaddressAccounts() const;
    Q_INVOKABLE quint32 numSubaddresses(quint32 accountIndex) const;
    Q_INVOKABLE void addSubaddress(const QString& label);
    Q_INVOKABLE QString getSubaddressLabel(quint32 accountIndex, quint32 addressIndex) const;
    Q_INVOKABLE void setSubaddressLabel(quint32 accountIndex, quint32 addressIndex, const QString &label);

    //! returns if view only wallet
    Q_INVOKABLE bool viewOnly() const;

    //! returns current wallet's block height
    //! (can be less than daemon's blockchain height when wallet sync in progress)
    Q_INVOKABLE quint64 blockChainHeight() const;

    //! returns daemon's blockchain height
    Q_INVOKABLE quint64 daemonBlockChainHeight() const;

    //! returns daemon's blockchain target height
    Q_INVOKABLE quint64 daemonBlockChainTargetHeight() const;

    //! export/import key images
    Q_INVOKABLE bool exportKeyImages(const QString& path);
    Q_INVOKABLE bool importKeyImages(const QString& path);

    //! refreshes the wallet
    Q_INVOKABLE bool refresh();

    //! refreshes the wallet asynchronously
    Q_INVOKABLE void refreshAsync();

    //! setup auto-refresh interval in seconds
    Q_INVOKABLE void setAutoRefreshInterval(int seconds);

    //! return auto-refresh interval in seconds
    Q_INVOKABLE int autoRefreshInterval() const;

    // pause/resume refresh
    Q_INVOKABLE void startRefresh() const;
    Q_INVOKABLE void pauseRefresh() const;

    //! creates transaction
    Q_INVOKABLE PendingTransaction * createTransaction(const QString &dst_addr, const QString &payment_id,
                                                       quint64 amount, quint32 mixin_count,
                                                       PendingTransaction::Priority priority);

    //! creates async transaction
    Q_INVOKABLE void createTransactionAsync(const QString &dst_addr, const QString &payment_id,
                                            quint64 amount, quint32 mixin_count,
                                            PendingTransaction::Priority priority);

    //! creates transaction with all outputs
    Q_INVOKABLE PendingTransaction * createTransactionAll(const QString &dst_addr, const QString &payment_id,
                                                       quint32 mixin_count, PendingTransaction::Priority priority);

    //! creates async transaction with all outputs
    Q_INVOKABLE void createTransactionAllAsync(const QString &dst_addr, const QString &payment_id,
                                               quint32 mixin_count, PendingTransaction::Priority priority);

    //! creates sweep unmixable transaction
    Q_INVOKABLE PendingTransaction * createSweepUnmixableTransaction();

    //! creates async sweep unmixable transaction
    Q_INVOKABLE void createSweepUnmixableTransactionAsync();

    //! Sign a transfer from file
    Q_INVOKABLE UnsignedTransaction * loadTxFile(const QString &fileName);

    //! Submit a transfer from file
    Q_INVOKABLE bool submitTxFile(const QString &fileName) const;


    //! deletes transaction and frees memory
    Q_INVOKABLE void disposeTransaction(PendingTransaction * t);

    //! deletes unsigned transaction and frees memory
    Q_INVOKABLE void disposeTransaction(UnsignedTransaction * t);

    //! returns transaction history
    TransactionHistory * history() const;

    //! returns transaction history model
    TransactionHistorySortFilterModel *historyModel() const;

    //! returns Address book
    AddressBook *addressBook() const;

    //! returns adress book model
    AddressBookModel *addressBookModel() const;

    //! returns subaddress
    Subaddress *subaddress();

    //! returns subadress model
    SubaddressModel *subaddressModel();

    //! generate payment id
    Q_INVOKABLE QString generatePaymentId() const;

    //! integrated address
    Q_INVOKABLE QString integratedAddress(const QString &paymentId) const;

    //! signing a message
    Q_INVOKABLE QString signMessage(const QString &message, bool filename = false) const;

    //! verify a signed message
    Q_INVOKABLE bool verifySignedMessage(const QString &message, const QString &address, const QString &signature, bool filename = false) const;

    //! Parse URI
    Q_INVOKABLE bool parse_uri(const QString &uri, QString &address, QString &payment_id, uint64_t &amount, QString &tx_description, QString &recipient_name, QVector<QString> &unknown_parameters, QString &error);

    //! saved payment id
    QString paymentId() const;

    void setPaymentId(const QString &paymentId);

    Q_INVOKABLE bool setUserNote(const QString &txid, const QString &note);
    Q_INVOKABLE QString getUserNote(const QString &txid) const;
    Q_INVOKABLE QString getTxKey(const QString &txid) const;
    Q_INVOKABLE QString checkTxKey(const QString &txid, const QString &tx_key, const QString &address);
    Q_INVOKABLE QString getTxProof(const QString &txid, const QString &address, const QString &message) const;
    Q_INVOKABLE QString checkTxProof(const QString &txid, const QString &address, const QString &message, const QString &signature);
    Q_INVOKABLE QString getSpendProof(const QString &txid, const QString &message) const;
    Q_INVOKABLE QString checkSpendProof(const QString &txid, const QString &message, const QString &signature) const;
    // Rescan spent outputs
    Q_INVOKABLE bool rescanSpent();

    // check if fork rules should be used
    Q_INVOKABLE bool useForkRules(quint8 version, quint64 earlyBlocks = 0) const;

    //! Get wallet keys
    QString getSecretViewKey() const {return QString::fromStdString(m_walletImpl->secretViewKey());}
    QString getPublicViewKey() const {return QString::fromStdString(m_walletImpl->publicViewKey());}
    QString getSecretSpendKey() const {return QString::fromStdString(m_walletImpl->secretSpendKey());}
    QString getPublicSpendKey() const {return QString::fromStdString(m_walletImpl->publicSpendKey());}

    quint64 getWalletCreationHeight() const {return m_walletImpl->getRefreshFromBlockHeight();}
    void setWalletCreationHeight(quint64 height);

    QString getDaemonLogPath() const;
    QString getWalletLogPath() const;

    // Blackalled outputs
    Q_INVOKABLE bool blackballOutput(const QString &pubkey);
    Q_INVOKABLE bool blackballOutputs(const QList<QString> &pubkeys, bool add);
    Q_INVOKABLE bool blackballOutputs(const QString &filename, bool add);
    Q_INVOKABLE bool unblackballOutput(const QString &pubkey);

    // Rings
    Q_INVOKABLE QString getRing(const QString &key_image);
    Q_INVOKABLE QString getRings(const QString &txid);
    Q_INVOKABLE bool setRing(const QString &key_image, const QString &ring, bool relative);

    // key reuse mitigation options
    Q_INVOKABLE void segregatePreForkOutputs(bool segregate);
    Q_INVOKABLE void segregationHeight(quint64 height);
    Q_INVOKABLE void keyReuseMitigation2(bool mitigation);

    // TODO: setListenter() when it implemented in API
signals:
    // emitted on every event happened with wallet
    // (money sent/received, new block)
    void updated();

    // emitted when refresh process finished (could take a long time)
    // signalling only after we
    void refreshed();

    void moneySpent(const QString &txId, quint64 amount);
    void moneyReceived(const QString &txId, quint64 amount);
    void unconfirmedMoneyReceived(const QString &txId, quint64 amount);
    void newBlock(quint64 height, quint64 targetHeight);
    void historyModelChanged() const;
    void walletCreationHeightChanged();

    // emitted when transaction is created async
    void transactionCreated(PendingTransaction * transaction, QString address, QString paymentId, quint32 mixinCount);

    void connectionStatusChanged(ConnectionStatus status) const;

private:
    Wallet(QObject * parent = nullptr);
    Wallet(Monero::Wallet *w, QObject * parent = 0);
    ~Wallet();
private:
    friend class WalletManager;
    friend class WalletListenerImpl;
    //! libwallet's
    Monero::Wallet * m_walletImpl;
    // history lifetime managed by wallet;
    TransactionHistory * m_history;
    // Used for UI history view
    mutable TransactionHistoryModel * m_historyModel;
    mutable TransactionHistorySortFilterModel * m_historySortFilterModel;
    QString m_paymentId;
    mutable QTime   m_daemonBlockChainHeightTime;
    mutable quint64 m_daemonBlockChainHeight;
    int     m_daemonBlockChainHeightTtl;
    mutable QTime   m_daemonBlockChainTargetHeightTime;
    mutable quint64 m_daemonBlockChainTargetHeight;
    int     m_daemonBlockChainTargetHeightTtl;
    mutable ConnectionStatus m_connectionStatus;
    int     m_connectionStatusTtl;
    mutable QTime   m_connectionStatusTime;
    mutable bool    m_initialized;
    uint32_t m_currentSubaddressAccount;
    AddressBook * m_addressBook;
    mutable AddressBookModel * m_addressBookModel;
    Subaddress * m_subaddress;
    mutable SubaddressModel * m_subaddressModel;
    QMutex m_connectionStatusMutex;
    bool m_connectionStatusRunning;
    QString m_daemonUsername;
    QString m_daemonPassword;
    Monero::WalletListener *m_walletListener;
};



#endif // WALLET_H
