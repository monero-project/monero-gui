#include "Wallet.h"
#include "PendingTransaction.h"
#include "UnsignedTransaction.h"
#include "TransactionHistory.h"
#include "AddressBook.h"
#include "model/TransactionHistoryModel.h"
#include "model/TransactionHistorySortFilterModel.h"
#include "model/AddressBookModel.h"
#include "wallet/wallet2_api.h"

#include <QFile>
#include <QDir>
#include <QDebug>
#include <QUrl>
#include <QTimer>
#include <QtConcurrent/QtConcurrent>
#include <QList>
#include <QVector>
#include <QMutex>
#include <QMutexLocker>

namespace {
    static const int DAEMON_BLOCKCHAIN_HEIGHT_CACHE_TTL_SECONDS = 5;
    static const int DAEMON_BLOCKCHAIN_TARGET_HEIGHT_CACHE_TTL_SECONDS = 30;
    static const int WALLET_CONNECTION_STATUS_CACHE_TTL_SECONDS = 5;
}

class WalletListenerImpl : public  Monero::WalletListener
{
public:
    WalletListenerImpl(Wallet * w)
        : m_wallet(w)
    {

    }

    virtual void moneySpent(const std::string &txId, uint64_t amount)
    {
        qDebug() << __FUNCTION__;
        emit m_wallet->moneySpent(QString::fromStdString(txId), amount);
    }


    virtual void moneyReceived(const std::string &txId, uint64_t amount)
    {
        qDebug() << __FUNCTION__;
        emit m_wallet->moneyReceived(QString::fromStdString(txId), amount);
    }

    virtual void unconfirmedMoneyReceived(const std::string &txId, uint64_t amount)
    {
        qDebug() << __FUNCTION__;
        emit m_wallet->unconfirmedMoneyReceived(QString::fromStdString(txId), amount);
    }

    virtual void newBlock(uint64_t height)
    {
        // qDebug() << __FUNCTION__;
        emit m_wallet->newBlock(height, m_wallet->daemonBlockChainTargetHeight());
    }

    virtual void updated()
    {
        emit m_wallet->updated();
    }

    // called when wallet refreshed by background thread or explicitly
    virtual void refreshed()
    {
        qDebug() << __FUNCTION__;
        emit m_wallet->refreshed();
    }

private:
    Wallet * m_wallet;
};

Wallet::Wallet(QObject * parent)
    : Wallet(nullptr, parent)
{
}

QString Wallet::getSeed() const
{
    return QString::fromStdString(m_walletImpl->seed());
}

QString Wallet::getSeedLanguage() const
{
    return QString::fromStdString(m_walletImpl->getSeedLanguage());
}

void Wallet::setSeedLanguage(const QString &lang)
{
    m_walletImpl->setSeedLanguage(lang.toStdString());
}

Wallet::Status Wallet::status() const
{
    return static_cast<Status>(m_walletImpl->status());
}

bool Wallet::testnet() const
{
    return m_walletImpl->testnet();
}


void Wallet::updateConnectionStatusAsync()
{
    QFuture<Monero::Wallet::ConnectionStatus> future = QtConcurrent::run(m_walletImpl, &Monero::Wallet::connected);
    QFutureWatcher<Monero::Wallet::ConnectionStatus> *connectionWatcher = new QFutureWatcher<Monero::Wallet::ConnectionStatus>();

    connect(connectionWatcher, &QFutureWatcher<Monero::Wallet::ConnectionStatus>::finished, [=]() {
        QFuture<Monero::Wallet::ConnectionStatus> future = connectionWatcher->future();
        connectionWatcher->deleteLater();
        ConnectionStatus newStatus = static_cast<ConnectionStatus>(future.result());
        if (newStatus != m_connectionStatus || !m_initialized) {
            m_initialized = true;
            m_connectionStatus = newStatus;
            qDebug() << "NEW STATUS " << newStatus;
            emit connectionStatusChanged(newStatus);
        }
        // Release lock
        m_connectionStatusRunning = false;
    });
    connectionWatcher->setFuture(future);
}

Wallet::ConnectionStatus Wallet::connected(bool forceCheck)
{
    // cache connection status
    if (forceCheck || !m_initialized || (m_connectionStatusTime.elapsed() / 1000 > m_connectionStatusTtl && !m_connectionStatusRunning) || m_connectionStatusTime.elapsed() > 30000) {
        qDebug() << "Checking connection status";
        m_connectionStatusRunning = true;
        m_connectionStatusTime.restart();
        updateConnectionStatusAsync();
    }

    return m_connectionStatus;
}

bool Wallet::synchronized() const
{
    return m_walletImpl->synchronized();
}

QString Wallet::errorString() const
{
    return QString::fromStdString(m_walletImpl->errorString());
}

bool Wallet::setPassword(const QString &password)
{
    return m_walletImpl->setPassword(password.toStdString());
}

QString Wallet::address() const
{
    return QString::fromStdString(m_walletImpl->address());
}

QString Wallet::path() const
{
    return QString::fromStdString(m_walletImpl->path());
}

bool Wallet::store(const QString &path)
{
    return m_walletImpl->store(path.toStdString());
}

bool Wallet::init(const QString &daemonAddress, quint64 upperTransactionLimit, bool isRecovering, quint64 restoreHeight)
{
    qDebug() << "init non async";
    if (isRecovering){
        qDebug() << "RESTORING";
        m_walletImpl->setRecoveringFromSeed(true);
        m_walletImpl->setRefreshFromBlockHeight(restoreHeight);
    }
    m_walletImpl->init(daemonAddress.toStdString(), upperTransactionLimit, m_daemonUsername.toStdString(), m_daemonPassword.toStdString());
    return true;
}

void Wallet::setDaemonLogin(const QString &daemonUsername, const QString &daemonPassword)
{
    // store daemon login
    m_daemonUsername = daemonUsername;
    m_daemonPassword = daemonPassword;
}

void Wallet::initAsync(const QString &daemonAddress, quint64 upperTransactionLimit, bool isRecovering, quint64 restoreHeight)
{
    qDebug() << "initAsync: " + daemonAddress;
    // Change status to disconnected if connected
    if(m_connectionStatus != Wallet::ConnectionStatus_Disconnected) {
        m_connectionStatus = Wallet::ConnectionStatus_Disconnected;
        emit connectionStatusChanged(m_connectionStatus);
    }

    QFuture<bool> future = QtConcurrent::run(this, &Wallet::init,
                                  daemonAddress, upperTransactionLimit, isRecovering, restoreHeight);
    QFutureWatcher<bool> * watcher = new QFutureWatcher<bool>();

    connect(watcher, &QFutureWatcher<bool>::finished,
            this, [this, watcher, daemonAddress, upperTransactionLimit, isRecovering, restoreHeight]() {
        QFuture<bool> future = watcher->future();
        watcher->deleteLater();
        if(future.result()){
            qDebug() << "init async finished - starting refresh";
            connected(true);
            m_walletImpl->startRefresh();

        }
    });
    watcher->setFuture(future);
}

//! create a view only wallet
bool Wallet::createViewOnly(const QString &path, const QString &password) const
{
    // Create path
    QDir d = QFileInfo(path).absoluteDir();
    d.mkpath(d.absolutePath());
    return m_walletImpl->createWatchOnly(path.toStdString(),password.toStdString(),m_walletImpl->getSeedLanguage());
}

bool Wallet::connectToDaemon()
{
    return m_walletImpl->connectToDaemon();
}

void Wallet::setTrustedDaemon(bool arg)
{
    m_walletImpl->setTrustedDaemon(arg);
}

bool Wallet::viewOnly() const
{
    return m_walletImpl->watchOnly();
}

quint64 Wallet::balance() const
{
    return m_walletImpl->balance();
}

quint64 Wallet::unlockedBalance() const
{
    return m_walletImpl->unlockedBalance();
}

quint64 Wallet::blockChainHeight() const
{
    return m_walletImpl->blockChainHeight();
}

quint64 Wallet::daemonBlockChainHeight() const
{
    // cache daemon blockchain height for some time (60 seconds by default)

    if (m_daemonBlockChainHeight == 0
            || m_daemonBlockChainHeightTime.elapsed() / 1000 > m_daemonBlockChainHeightTtl) {
        m_daemonBlockChainHeight = m_walletImpl->daemonBlockChainHeight();
        m_daemonBlockChainHeightTime.restart();
    }
    return m_daemonBlockChainHeight;
}

quint64 Wallet::daemonBlockChainTargetHeight() const
{
    if (m_daemonBlockChainTargetHeight <= 1
            || m_daemonBlockChainTargetHeightTime.elapsed() / 1000 > m_daemonBlockChainTargetHeightTtl) {
        m_daemonBlockChainTargetHeight = m_walletImpl->daemonBlockChainTargetHeight();

        // Target height is set to 0 if daemon is synced.
        // Use current height from daemon when target height < current height
        if (m_daemonBlockChainTargetHeight < m_daemonBlockChainHeight){
            m_daemonBlockChainTargetHeight = m_daemonBlockChainHeight;
        }
        m_daemonBlockChainTargetHeightTime.restart();
    }

    return m_daemonBlockChainTargetHeight;
}

bool Wallet::refresh()
{
    bool result = m_walletImpl->refresh();
    m_history->refresh();
    if (result)
        emit updated();
    return result;
}

void Wallet::refreshAsync()
{
    qDebug() << "refresh async";
    m_walletImpl->refreshAsync();
}

void Wallet::setAutoRefreshInterval(int seconds)
{
    m_walletImpl->setAutoRefreshInterval(seconds);
}

int Wallet::autoRefreshInterval() const
{
    return m_walletImpl->autoRefreshInterval();
}

void Wallet::startRefresh() const
{
    m_walletImpl->startRefresh();
}

void Wallet::pauseRefresh() const
{
    m_walletImpl->pauseRefresh();
}

PendingTransaction *Wallet::createTransaction(const QString &dst_addr, const QString &payment_id,
                                              quint64 amount, quint32 mixin_count,
                                              PendingTransaction::Priority priority)
{
    Monero::PendingTransaction * ptImpl = m_walletImpl->createTransaction(
                dst_addr.toStdString(), payment_id.toStdString(), amount, mixin_count,
                static_cast<Monero::PendingTransaction::Priority>(priority));
    PendingTransaction * result = new PendingTransaction(ptImpl,0);
    return result;
}

void Wallet::createTransactionAsync(const QString &dst_addr, const QString &payment_id,
                               quint64 amount, quint32 mixin_count,
                               PendingTransaction::Priority priority)
{
    QFuture<PendingTransaction*> future = QtConcurrent::run(this, &Wallet::createTransaction,
                                  dst_addr, payment_id,amount, mixin_count, priority);
    QFutureWatcher<PendingTransaction*> * watcher = new QFutureWatcher<PendingTransaction*>();

    connect(watcher, &QFutureWatcher<PendingTransaction*>::finished,
            this, [this, watcher,dst_addr,payment_id,mixin_count]() {
        QFuture<PendingTransaction*> future = watcher->future();
        watcher->deleteLater();
        emit transactionCreated(future.result(),dst_addr,payment_id,mixin_count);
    });
    watcher->setFuture(future);
}

PendingTransaction *Wallet::createTransactionAll(const QString &dst_addr, const QString &payment_id,
                                                 quint32 mixin_count, PendingTransaction::Priority priority)
{
    Monero::PendingTransaction * ptImpl = m_walletImpl->createTransaction(
                dst_addr.toStdString(), payment_id.toStdString(), Monero::optional<uint64_t>(), mixin_count,
                static_cast<Monero::PendingTransaction::Priority>(priority));
    PendingTransaction * result = new PendingTransaction(ptImpl, this);
    return result;
}

void Wallet::createTransactionAllAsync(const QString &dst_addr, const QString &payment_id,
                               quint32 mixin_count,
                               PendingTransaction::Priority priority)
{
    QFuture<PendingTransaction*> future = QtConcurrent::run(this, &Wallet::createTransactionAll,
                                  dst_addr, payment_id, mixin_count, priority);
    QFutureWatcher<PendingTransaction*> * watcher = new QFutureWatcher<PendingTransaction*>();

    connect(watcher, &QFutureWatcher<PendingTransaction*>::finished,
            this, [this, watcher,dst_addr,payment_id,mixin_count]() {
        QFuture<PendingTransaction*> future = watcher->future();
        watcher->deleteLater();
        emit transactionCreated(future.result(),dst_addr,payment_id,mixin_count);
    });
    watcher->setFuture(future);
}

PendingTransaction *Wallet::createSweepUnmixableTransaction()
{
    Monero::PendingTransaction * ptImpl = m_walletImpl->createSweepUnmixableTransaction();
    PendingTransaction * result = new PendingTransaction(ptImpl, this);
    return result;
}

void Wallet::createSweepUnmixableTransactionAsync()
{
    QFuture<PendingTransaction*> future = QtConcurrent::run(this, &Wallet::createSweepUnmixableTransaction);
    QFutureWatcher<PendingTransaction*> * watcher = new QFutureWatcher<PendingTransaction*>();

    connect(watcher, &QFutureWatcher<PendingTransaction*>::finished,
            this, [this, watcher]() {
        QFuture<PendingTransaction*> future = watcher->future();
        watcher->deleteLater();
        emit transactionCreated(future.result(),"","",0);
    });
    watcher->setFuture(future);
}

UnsignedTransaction * Wallet::loadTxFile(const QString &fileName)
{
    qDebug() << "Trying to sign " << fileName;
    Monero::UnsignedTransaction * ptImpl = m_walletImpl->loadUnsignedTx(fileName.toStdString());
    UnsignedTransaction * result = new UnsignedTransaction(ptImpl, m_walletImpl, this);
    return result;
}

bool Wallet::submitTxFile(const QString &fileName) const
{
    qDebug() << "Trying to submit " << fileName;
    if (!m_walletImpl->submitTransaction(fileName.toStdString()))
        return false;
    // import key images
    return m_walletImpl->importKeyImages(fileName.toStdString() + "_keyImages");
}

void Wallet::disposeTransaction(PendingTransaction *t)
{
    m_walletImpl->disposeTransaction(t->m_pimpl);
    delete t;
}

void Wallet::disposeTransaction(UnsignedTransaction *t)
{
    delete t;
}

TransactionHistory *Wallet::history() const
{
    return m_history;
}

TransactionHistorySortFilterModel *Wallet::historyModel() const
{
    if (!m_historyModel) {
        Wallet * w = const_cast<Wallet*>(this);
        m_historyModel = new TransactionHistoryModel(w);
        m_historyModel->setTransactionHistory(this->history());
        m_historySortFilterModel = new TransactionHistorySortFilterModel(w);
        m_historySortFilterModel->setSourceModel(m_historyModel);
    }

    return m_historySortFilterModel;
}

AddressBook *Wallet::addressBook() const
{
    return m_addressBook;
}

AddressBookModel *Wallet::addressBookModel() const
{

    if (!m_addressBookModel) {
        Wallet * w = const_cast<Wallet*>(this);
        m_addressBookModel = new AddressBookModel(w,m_addressBook);
    }

    return m_addressBookModel;
}


QString Wallet::generatePaymentId() const
{
    return QString::fromStdString(Monero::Wallet::genPaymentId());
}

QString Wallet::integratedAddress(const QString &paymentId) const
{
    return QString::fromStdString(m_walletImpl->integratedAddress(paymentId.toStdString()));
}

QString Wallet::paymentId() const
{
    return m_paymentId;
}

void Wallet::setPaymentId(const QString &paymentId)
{
    m_paymentId = paymentId;
}

bool Wallet::setUserNote(const QString &txid, const QString &note)
{
  return m_walletImpl->setUserNote(txid.toStdString(), note.toStdString());
}

QString Wallet::getUserNote(const QString &txid) const
{
  return QString::fromStdString(m_walletImpl->getUserNote(txid.toStdString()));
}

QString Wallet::getTxKey(const QString &txid) const
{
  return QString::fromStdString(m_walletImpl->getTxKey(txid.toStdString()));
}

QString Wallet::signMessage(const QString &message, bool filename) const
{
  if (filename) {
    QFile file(message);
    uchar *data = NULL;

    try {
      if (!file.open(QIODevice::ReadOnly))
        return "";
      quint64 size = file.size();
      if (size == 0) {
        file.close();
        return QString::fromStdString(m_walletImpl->signMessage(std::string()));
      }
      data = file.map(0, size);
      if (!data) {
        file.close();
        return "";
      }
      std::string signature = m_walletImpl->signMessage(std::string((const char*)data, size));
      file.unmap(data);
      file.close();
      return QString::fromStdString(signature);
    }
    catch (const std::exception &e) {
      if (data)
        file.unmap(data);
      file.close();
      return "";
    }
  }
  else {
    return QString::fromStdString(m_walletImpl->signMessage(message.toStdString()));
  }
}

bool Wallet::verifySignedMessage(const QString &message, const QString &address, const QString &signature, bool filename) const
{
  if (filename) {
    QFile file(message);
    uchar *data = NULL;

    try {
      if (!file.open(QIODevice::ReadOnly))
        return false;
      quint64 size = file.size();
      if (size == 0) {
        file.close();
        return m_walletImpl->verifySignedMessage(std::string(), address.toStdString(), signature.toStdString());
      }
      data = file.map(0, size);
      if (!data) {
        file.close();
        return false;
      }
      bool ret = m_walletImpl->verifySignedMessage(std::string((const char*)data, size), address.toStdString(), signature.toStdString());
      file.unmap(data);
      file.close();
      return ret;
    }
    catch (const std::exception &e) {
      if (data)
        file.unmap(data);
      file.close();
      return false;
    }
  }
  else {
    return m_walletImpl->verifySignedMessage(message.toStdString(), address.toStdString(), signature.toStdString());
  }
}
bool Wallet::parse_uri(const QString &uri, QString &address, QString &payment_id, uint64_t &amount, QString &tx_description, QString &recipient_name, QVector<QString> &unknown_parameters, QString &error)
{
   std::string s_address, s_payment_id, s_tx_description, s_recipient_name, s_error;
   std::vector<std::string> s_unknown_parameters;
   bool res= m_walletImpl->parse_uri(uri.toStdString(), s_address, s_payment_id, amount, s_tx_description, s_recipient_name, s_unknown_parameters, s_error);
   if(res)
   {
       address = QString::fromStdString(s_address);
       payment_id = QString::fromStdString(s_payment_id);
       tx_description = QString::fromStdString(s_tx_description);
       recipient_name = QString::fromStdString(s_recipient_name);
       for( const auto &p : s_unknown_parameters )
           unknown_parameters.append(QString::fromStdString(p));
   }
   error = QString::fromStdString(s_error);
   return res;
}

bool Wallet::rescanSpent()
{
    return m_walletImpl->rescanSpent();
}

bool Wallet::useForkRules(quint8 required_version, quint64 earlyBlocks) const
{
    if(m_connectionStatus == Wallet::ConnectionStatus_Disconnected)
        return false;
    try {
        return m_walletImpl->useForkRules(required_version,earlyBlocks);
    } catch (const std::exception &e) {
        qDebug() << e.what();
        return false;
    }
}

Wallet::Wallet(Monero::Wallet *w, QObject *parent)
    : QObject(parent)
    , m_walletImpl(w)
    , m_history(nullptr)
    , m_historyModel(nullptr)
    , m_addressBook(nullptr)
    , m_addressBookModel(nullptr)
    , m_daemonBlockChainHeight(0)
    , m_daemonBlockChainHeightTtl(DAEMON_BLOCKCHAIN_HEIGHT_CACHE_TTL_SECONDS)
    , m_daemonBlockChainTargetHeight(0)
    , m_daemonBlockChainTargetHeightTtl(DAEMON_BLOCKCHAIN_TARGET_HEIGHT_CACHE_TTL_SECONDS)
    , m_connectionStatusTtl(WALLET_CONNECTION_STATUS_CACHE_TTL_SECONDS)
{
    m_history = new TransactionHistory(m_walletImpl->history(), this);
    m_addressBook = new AddressBook(m_walletImpl->addressBook(), this);
    m_walletImpl->setListener(new WalletListenerImpl(this));
    m_connectionStatus = Wallet::ConnectionStatus_Disconnected;
    // start cache timers
    m_connectionStatusTime.restart();
    m_daemonBlockChainHeightTime.restart();
    m_daemonBlockChainTargetHeightTime.restart();
    m_initialized = false;
    m_connectionStatusRunning = false;
    m_daemonUsername = "";
    m_daemonPassword = "";
}

Wallet::~Wallet()
{
    qDebug("~Wallet: Closing wallet");

    delete m_history;
    m_history = NULL;
    //Monero::WalletManagerFactory::getWalletManager()->closeWallet(m_walletImpl);
    delete m_walletImpl;
    m_walletImpl = NULL;
    qDebug("m_walletImpl deleted");
}
