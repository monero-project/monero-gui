#include "WalletManager.h"
#include "Wallet.h"
#include "wallet/wallet2_api.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QDebug>
#include <QUrl>
#include <QtConcurrent/QtConcurrent>
#include <QMutex>
#include <QMutexLocker>

WalletManager * WalletManager::m_instance = nullptr;

WalletManager *WalletManager::instance()
{
    if (!m_instance) {
        m_instance = new WalletManager;
    }

    return m_instance;
}

Wallet *WalletManager::createWallet(const QString &path, const QString &password,
                                    const QString &language, bool testnet)
{
    QMutexLocker locker(&m_mutex);
    if (m_currentWallet) {
        qDebug() << "Closing open m_currentWallet" << m_currentWallet;
        delete m_currentWallet;
    }
    Monero::Wallet * w = m_pimpl->createWallet(path.toStdString(), password.toStdString(),
                                                  language.toStdString(), testnet);
    m_currentWallet  = new Wallet(w);
    return m_currentWallet;
}

Wallet *WalletManager::openWallet(const QString &path, const QString &password, bool testnet)
{
    QMutexLocker locker(&m_mutex);
    if (m_currentWallet) {
        qDebug() << "Closing open m_currentWallet" << m_currentWallet;
        delete m_currentWallet;
    }
    qDebug("%s: opening wallet at %s, testnet = %d ",
           __PRETTY_FUNCTION__, qPrintable(path), testnet);

    Monero::Wallet * w =  m_pimpl->openWallet(path.toStdString(), password.toStdString(), testnet);
    qDebug("%s: opened wallet: %s, status: %d", __PRETTY_FUNCTION__, w->address().c_str(), w->status());
    m_currentWallet  = new Wallet(w);

    // move wallet to the GUI thread. Otherwise it wont be emitting signals
    if (m_currentWallet->thread() != qApp->thread()) {
        m_currentWallet->moveToThread(qApp->thread());
    }

    return m_currentWallet;
}

void WalletManager::openWalletAsync(const QString &path, const QString &password, bool testnet)
{
    QFuture<Wallet*> future = QtConcurrent::run(this, &WalletManager::openWallet,
                                        path, password, testnet);
    QFutureWatcher<Wallet*> * watcher = new QFutureWatcher<Wallet*>();
    watcher->setFuture(future);
    connect(watcher, &QFutureWatcher<Wallet*>::finished,
            this, [this, watcher]() {
        QFuture<Wallet*> future = watcher->future();
        watcher->deleteLater();
        emit walletOpened(future.result());
    });
}


Wallet *WalletManager::recoveryWallet(const QString &path, const QString &memo, bool testnet, quint64 restoreHeight)
{
    QMutexLocker locker(&m_mutex);
    if (m_currentWallet) {
        qDebug() << "Closing open m_currentWallet" << m_currentWallet;
        delete m_currentWallet;
    }
    Monero::Wallet * w = m_pimpl->recoveryWallet(path.toStdString(), memo.toStdString(), testnet, restoreHeight);
    m_currentWallet = new Wallet(w);
    return m_currentWallet;
}


QString WalletManager::closeWallet()
{
    QMutexLocker locker(&m_mutex);
    QString result;
    if (m_currentWallet) {
        result = m_currentWallet->address();
        delete m_currentWallet;
    } else {
        qCritical() << "Trying to close non existing wallet " << m_currentWallet;
        result = "0";
    }
    return result;
}

void WalletManager::closeWalletAsync()
{
    QFuture<QString> future = QtConcurrent::run(this, &WalletManager::closeWallet);
    QFutureWatcher<QString> * watcher = new QFutureWatcher<QString>();
    watcher->setFuture(future);

    connect(watcher, &QFutureWatcher<QString>::finished,
            this, [this, watcher]() {
       QFuture<QString> future = watcher->future();
       watcher->deleteLater();
       emit walletClosed(future.result());
    });
}

bool WalletManager::walletExists(const QString &path) const
{
    return m_pimpl->walletExists(path.toStdString());
}

QStringList WalletManager::findWallets(const QString &path)
{
    std::vector<std::string> found_wallets = m_pimpl->findWallets(path.toStdString());
    QStringList result;
    for (const auto &w : found_wallets) {
        result.append(QString::fromStdString(w));
    }
    return result;
}

QString WalletManager::errorString() const
{
    return tr("Unknown error");
}

bool WalletManager::moveWallet(const QString &src, const QString &dst)
{
    return true;
}


QString WalletManager::walletLanguage(const QString &locale)
{
    return "English";
}

quint64 WalletManager::maximumAllowedAmount() const
{
    return Monero::Wallet::maximumAllowedAmount();
}

QString WalletManager::maximumAllowedAmountAsSting() const
{
    return WalletManager::displayAmount(WalletManager::maximumAllowedAmount());
}



QString WalletManager::displayAmount(quint64 amount) const
{
    return QString::fromStdString(Monero::Wallet::displayAmount(amount));
}

quint64 WalletManager::amountFromString(const QString &amount) const
{
    return Monero::Wallet::amountFromString(amount.toStdString());
}

quint64 WalletManager::amountFromDouble(double amount) const
{
    return Monero::Wallet::amountFromDouble(amount);
}

bool WalletManager::paymentIdValid(const QString &payment_id) const
{
    return Monero::Wallet::paymentIdValid(payment_id.toStdString());
}

bool WalletManager::addressValid(const QString &address, bool testnet) const
{
    return Monero::Wallet::addressValid(address.toStdString(), testnet);
}

QString WalletManager::paymentIdFromAddress(const QString &address, bool testnet) const
{
    return QString::fromStdString(Monero::Wallet::paymentIdFromAddress(address.toStdString(), testnet));
}

QString WalletManager::checkPayment(const QString &address, const QString &txid, const QString &txkey, const QString &daemon_address) const
{
    uint64_t received = 0, height = 0;
    std::string error = "";
    bool ret = m_pimpl->checkPayment(address.toStdString(), txid.toStdString(), txkey.toStdString(), daemon_address.toStdString(), received, height, error);
    // bypass qml being unable to pass structures without preposterous complexity
    std::string result = std::string(ret ? "true" : "false") + "|" + QString::number(received).toStdString() + "|" + QString::number(height).toStdString() + "|" + error;
    return QString::fromStdString(result);
}

void WalletManager::setDaemonAddress(const QString &address)
{
    m_pimpl->setDaemonAddress(address.toStdString());
}

bool WalletManager::connected() const
{
    return m_pimpl->connected();
}

quint64 WalletManager::networkDifficulty() const
{
    return m_pimpl->networkDifficulty();
}

quint64 WalletManager::blockchainHeight() const
{
    return m_pimpl->blockchainHeight();
}

quint64 WalletManager::blockchainTargetHeight() const
{
    return m_pimpl->blockchainTargetHeight();
}

double WalletManager::miningHashRate() const
{
    return m_pimpl->miningHashRate();
}

void WalletManager::setLogLevel(int logLevel)
{
    Monero::WalletManagerFactory::setLogLevel(logLevel);
}

QString WalletManager::urlToLocalPath(const QUrl &url) const
{
    return QDir::toNativeSeparators(url.toLocalFile());
}

QUrl WalletManager::localPathToUrl(const QString &path) const
{
    return QUrl::fromLocalFile(path);
}

WalletManager::WalletManager(QObject *parent) : QObject(parent)
{
    m_pimpl =  Monero::WalletManagerFactory::getWalletManager();
}
