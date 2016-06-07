#include "Wallet.h"
#include "wallet/wallet2_api.h"

#include <QFile>
#include <QDir>
#include <QDebug>
#include <QUrl>

namespace {


}


QString Wallet::getSeed() const
{
    return QString::fromStdString(m_walletImpl->seed());
}

QString Wallet::getSeedLanguage() const
{
    return QString::fromStdString(m_walletImpl->getSeedLanguage());
}

int Wallet::status() const
{
    return m_walletImpl->status();
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



Wallet::Wallet(Bitmonero::Wallet *w, QObject *parent)
    : QObject(parent), m_walletImpl(w)
{

}

Wallet::~Wallet()
{
    Bitmonero::WalletManagerFactory::getWalletManager()->closeWallet(m_walletImpl);
}
