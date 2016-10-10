#include "WalletManager.h"
#include "Wallet.h"
#include "wallet/wallet2_api.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QDebug>
#include <QUrl>
#include <QtConcurrent/QtConcurrent>

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
    Bitmonero::Wallet * w = m_pimpl->createWallet(path.toStdString(), password.toStdString(),
                                                  language.toStdString(), testnet);
    Wallet * wallet = new Wallet(w);
    return wallet;
}

Wallet *WalletManager::openWallet(const QString &path, const QString &password, bool testnet)
{
    qDebug("%s: opening wallet at %s, testnet = %d ",
           __PRETTY_FUNCTION__, qPrintable(path), testnet);

    Bitmonero::Wallet * w =  m_pimpl->openWallet(path.toStdString(), password.toStdString(), testnet);
    qDebug("%s: opened wallet: %s, status: %d", __PRETTY_FUNCTION__, w->address().c_str(), w->status());
    Wallet * wallet = new Wallet(w);

    // move wallet to the GUI thread. Otherwise it wont be emitting signals
    if (wallet->thread() != qApp->thread()) {
        wallet->moveToThread(qApp->thread());
    }

    return wallet;
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
    Bitmonero::Wallet * w = m_pimpl->recoveryWallet(path.toStdString(), memo.toStdString(), testnet, restoreHeight);
    Wallet * wallet = new Wallet(w);
    return wallet;
}


QString WalletManager::closeWallet(Wallet *wallet)
{
    QString result = wallet->address();
    delete wallet;
    return result;
}

void WalletManager::closeWalletAsync(Wallet *wallet)
{
    QFuture<QString> future = QtConcurrent::run(this, &WalletManager::closeWallet,
                                                wallet);
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
    return Bitmonero::Wallet::maximumAllowedAmount();
}

QString WalletManager::maximumAllowedAmountAsSting() const
{
    return WalletManager::displayAmount(WalletManager::maximumAllowedAmount());
}



QString WalletManager::displayAmount(quint64 amount) const
{
    return QString::fromStdString(Bitmonero::Wallet::displayAmount(amount));
}

quint64 WalletManager::amountFromString(const QString &amount) const
{
    return Bitmonero::Wallet::amountFromString(amount.toStdString());
}

quint64 WalletManager::amountFromDouble(double amount) const
{
    return Bitmonero::Wallet::amountFromDouble(amount);
}

void WalletManager::setLogLevel(int logLevel)
{
    Bitmonero::WalletManagerFactory::setLogLevel(logLevel);
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
    m_pimpl =  Bitmonero::WalletManagerFactory::getWalletManager();
}
