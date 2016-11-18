#include "Wallet.h"
#include "PendingTransaction.h"
#include "TransactionHistory.h"
#include "model/TransactionHistoryModel.h"
#include "model/TransactionHistorySortFilterModel.h"
#include "wallet/wallet2_api.h"

#include <QFile>
#include <QDir>
#include <QDebug>
#include <QUrl>
#include <QTimer>
#include <QtConcurrent/QtConcurrent>

namespace {
    static const int DAEMON_BLOCKCHAIN_HEIGHT_CACHE_TTL_SECONDS = 10;
    static const int DAEMON_BLOCKCHAIN_TARGET_HEIGHT_CACHE_TTL_SECONDS = 60;
}

class WalletListenerImpl : public  Bitmonero::WalletListener
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

    virtual void newBlock(uint64_t height)
    {
        // qDebug() << __FUNCTION__;
        emit m_wallet->newBlock(height);
    }

    virtual void updated()
    {
        qDebug() << __FUNCTION__;
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

Wallet::ConnectionStatus Wallet::connected() const
{
    return static_cast<ConnectionStatus>(m_walletImpl->connected());
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

bool Wallet::store(const QString &path)
{
    return m_walletImpl->store(path.toStdString());
}

bool Wallet::init(const QString &daemonAddress, quint64 upperTransactionLimit, bool isRecovering, quint64 restoreHeight)
{
    return m_walletImpl->init(daemonAddress.toStdString(), upperTransactionLimit);
}

void Wallet::initAsync(const QString &daemonAddress, quint64 upperTransactionLimit, bool isRecovering, quint64 restoreHeight)
{
    if (isRecovering){
        qDebug() << "RESTORING";
        m_walletImpl->setRecoveringFromSeed(true);
        m_walletImpl->setRefreshFromBlockHeight(restoreHeight);
    }
    m_walletImpl->initAsync(daemonAddress.toStdString(), upperTransactionLimit);
}

bool Wallet::connectToDaemon()
{
    return m_walletImpl->connectToDaemon();
}

void Wallet::setTrustedDaemon(bool arg)
{
    m_walletImpl->setTrustedDaemon(arg);
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

    if (m_daemonBlockChainTargetHeight == 0
            || m_daemonBlockChainTargetHeightTime.elapsed() / 1000 > m_daemonBlockChainTargetHeightTtl) {
        m_daemonBlockChainTargetHeight = m_walletImpl->daemonBlockChainTargetHeight();
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

PendingTransaction *Wallet::createTransaction(const QString &dst_addr, const QString &payment_id,
                                              quint64 amount, quint32 mixin_count,
                                              PendingTransaction::Priority priority)
{
    Bitmonero::PendingTransaction * ptImpl = m_walletImpl->createTransaction(
                dst_addr.toStdString(), payment_id.toStdString(), amount, mixin_count,
                static_cast<Bitmonero::PendingTransaction::Priority>(priority));
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
    watcher->setFuture(future);
    connect(watcher, &QFutureWatcher<PendingTransaction*>::finished,
            this, [this, watcher,dst_addr,payment_id,mixin_count]() {
        QFuture<PendingTransaction*> future = watcher->future();
        watcher->deleteLater();
        emit transactionCreated(future.result(),dst_addr,payment_id,mixin_count);
    });
}

PendingTransaction *Wallet::createTransactionAll(const QString &dst_addr, const QString &payment_id,
                                                 quint32 mixin_count, PendingTransaction::Priority priority)
{
    Bitmonero::PendingTransaction * ptImpl = m_walletImpl->createTransaction(
                dst_addr.toStdString(), payment_id.toStdString(), Bitmonero::optional<uint64_t>(), mixin_count,
                static_cast<Bitmonero::PendingTransaction::Priority>(priority));
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
    watcher->setFuture(future);
    connect(watcher, &QFutureWatcher<PendingTransaction*>::finished,
            this, [this, watcher,dst_addr,payment_id,mixin_count]() {
        QFuture<PendingTransaction*> future = watcher->future();
        watcher->deleteLater();
        emit transactionCreated(future.result(),dst_addr,payment_id,mixin_count);
    });
}

PendingTransaction *Wallet::createSweepUnmixableTransaction()
{
    Bitmonero::PendingTransaction * ptImpl = m_walletImpl->createSweepUnmixableTransaction();
    PendingTransaction * result = new PendingTransaction(ptImpl, this);
    return result;
}

void Wallet::createSweepUnmixableTransactionAsync()
{
    QFuture<PendingTransaction*> future = QtConcurrent::run(this, &Wallet::createSweepUnmixableTransaction);
    QFutureWatcher<PendingTransaction*> * watcher = new QFutureWatcher<PendingTransaction*>();
    watcher->setFuture(future);
    connect(watcher, &QFutureWatcher<PendingTransaction*>::finished,
            this, [this, watcher]() {
        QFuture<PendingTransaction*> future = watcher->future();
        watcher->deleteLater();
        emit transactionCreated(future.result(),"","",0);
    });
}

void Wallet::disposeTransaction(PendingTransaction *t)
{
    m_walletImpl->disposeTransaction(t->m_pimpl);
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


QString Wallet::generatePaymentId() const
{
    return QString::fromStdString(Bitmonero::Wallet::genPaymentId());
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

Wallet::Wallet(Bitmonero::Wallet *w, QObject *parent)
    : QObject(parent)
    , m_walletImpl(w)
    , m_history(nullptr)
    , m_historyModel(nullptr)
    , m_daemonBlockChainHeight(0)
    , m_daemonBlockChainHeightTtl(DAEMON_BLOCKCHAIN_HEIGHT_CACHE_TTL_SECONDS)
    , m_daemonBlockChainTargetHeight(0)
    , m_daemonBlockChainTargetHeightTtl(DAEMON_BLOCKCHAIN_TARGET_HEIGHT_CACHE_TTL_SECONDS)
{
    m_history = new TransactionHistory(m_walletImpl->history(), this);
    m_walletImpl->setListener(new WalletListenerImpl(this));
}

Wallet::~Wallet()
{
    qDebug("~Wallet: Closing wallet");
    delete m_history;
    Bitmonero::WalletManagerFactory::getWalletManager()->closeWallet(m_walletImpl);
}
