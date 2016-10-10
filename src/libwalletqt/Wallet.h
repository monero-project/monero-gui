#ifndef WALLET_H
#define WALLET_H

#include <QObject>
#include <QTime>

#include "wallet/wallet2_api.h" // we need to have an access to the Bitmonero::Wallet::Status enum here;
#include "PendingTransaction.h" // we need to have an access to the PendingTransaction::Priority enum here;

namespace Bitmonero {
    class Wallet; // forward declaration
}


class TransactionHistory;
class TransactionHistoryModel;
class TransactionHistorySortFilterModel;

class Wallet : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString seed READ getSeed)
    Q_PROPERTY(QString seedLanguage READ getSeedLanguage)
    Q_PROPERTY(Status status READ status)
    Q_PROPERTY(bool connected READ connected)
    Q_PROPERTY(bool synchronized READ synchronized)
    Q_PROPERTY(QString errorString READ errorString)
    Q_PROPERTY(QString address READ address)
    Q_PROPERTY(quint64 balance READ balance)
    Q_PROPERTY(quint64 unlockedBalance READ unlockedBalance)
    Q_PROPERTY(TransactionHistory * history READ history)
    Q_PROPERTY(QString paymentId READ paymentId WRITE setPaymentId)
    Q_PROPERTY(TransactionHistorySortFilterModel * historyModel READ historyModel NOTIFY historyModelChanged)

public:


    enum Status {
        Status_Ok       = Bitmonero::Wallet::Status_Ok,
        Status_Error    = Bitmonero::Wallet::Status_Error
    };

    Q_ENUM(Status)

    //! returns mnemonic seed
    QString getSeed() const;

    //! returns seed language
    QString getSeedLanguage() const;

    //! set seed language
    Q_INVOKABLE void setSeedLanguage(const QString &lang);

    //! returns last operation's status
    Status status() const;

    //! returns true if wallet connected
    bool connected() const;

    //! returns true if wallet was ever synchronized
    bool synchronized() const;


    //! returns last operation's error message
    QString errorString() const;

    //! changes the password using existing parameters (path, seed, seed lang)
    Q_INVOKABLE bool setPassword(const QString &password);

    //! returns wallet's public address
    QString address() const;

    //! saves wallet to the file by given path
    Q_INVOKABLE bool store(const QString &path);

    //! initializes wallet
    Q_INVOKABLE bool init(const QString &daemonAddress, quint64 upperTransactionLimit);

    //! initializes wallet asynchronously
    Q_INVOKABLE void initAsync(const QString &daemonAddress, quint64 upperTransactionLimit);

    //! connects to daemon
    Q_INVOKABLE bool connectToDaemon();

    //! indicates id daemon is trusted
    Q_INVOKABLE void setTrustedDaemon(bool arg);

    //! returns balance
    Q_INVOKABLE quint64 balance() const;

    //! returns unlocked balance
    Q_INVOKABLE quint64 unlockedBalance() const;

    //! returns current wallet's block height
    //! (can be less than daemon's blockchain height when wallet sync in progress)
    Q_INVOKABLE quint64 blockChainHeight() const;

    //! returns daemon's blockchain height
    Q_INVOKABLE quint64 daemonBlockChainHeight() const;

    //! returns daemon's blockchain target height
    Q_INVOKABLE quint64 daemonBlockChainTargetHeight() const;

    //! refreshes the wallet
    Q_INVOKABLE bool refresh();

    //! refreshes the wallet asynchronously
    Q_INVOKABLE void refreshAsync();

    //! setup auto-refresh interval in seconds
    Q_INVOKABLE void setAutoRefreshInterval(int seconds);

    //! return auto-refresh interval in seconds
    Q_INVOKABLE int autoRefreshInterval() const;

    //! creates transaction
    Q_INVOKABLE PendingTransaction * createTransaction(const QString &dst_addr, const QString &payment_id,
                                                       quint64 amount, quint32 mixin_count,
                                                       PendingTransaction::Priority priority);
    //! deletes transaction and frees memory
    Q_INVOKABLE void disposeTransaction(PendingTransaction * t);

    //! returns transaction history
    TransactionHistory * history() const;

    //! returns transaction history model
    TransactionHistorySortFilterModel *historyModel() const;

    //! generate payment id
    Q_INVOKABLE QString generatePaymentId() const;

    //! integrated address
    Q_INVOKABLE QString integratedAddress(const QString &paymentId) const;


    //! saved payment id
    QString paymentId() const;

    void setPaymentId(const QString &paymentId);

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
    void newBlock(quint64 height);
    void historyModelChanged() const;


private:
    Wallet(QObject * parent = nullptr);
    Wallet(Bitmonero::Wallet *w, QObject * parent = 0);
    ~Wallet();
private:
    friend class WalletManager;
    friend class WalletListenerImpl;
    //! libwallet's
    Bitmonero::Wallet * m_walletImpl;
    // history lifetime managed by wallet;
    TransactionHistory * m_history;
    // Used for UI history view
    mutable TransactionHistoryModel * m_historyModel;
    mutable TransactionHistorySortFilterModel * m_historySortFilterModel;
    QString m_paymentId;
    mutable QTime   m_daemonBlockChainHeightTime;
    mutable quint64 m_daemonBlockChainHeight;
    int     m_daemonBlockChainHeightTtl;
    mutable quint64 m_daemonBlockChainTargetHeight;
};



#endif // WALLET_H
