#include "WalletManager.h"
#include "Wallet.h"
#include "wallet/wallet2_api.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QDebug>
#include <QUrl>



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
    // TODO: call the libwallet api here;

    Bitmonero::Wallet * w =  m_pimpl->openWallet(path.toStdString(), password.toStdString(), testnet);
    Wallet * wallet = new Wallet(w);
    return wallet;
}


Wallet *WalletManager::recoveryWallet(const QString &path, const QString &memo, bool testnet)
{
    Bitmonero::Wallet * w = m_pimpl->recoveryWallet(path.toStdString(), memo.toStdString(), testnet);
    Wallet * wallet = new Wallet(w);
    return wallet;
}


void WalletManager::closeWallet(Wallet *wallet)
{
    delete wallet;
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


WalletManager::WalletManager(QObject *parent) : QObject(parent)
{
    m_pimpl =  Bitmonero::WalletManagerFactory::getWalletManager();
}


