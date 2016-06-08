#include "Wallet.h"
#include "PendingTransaction.h"
#include "TransactionHistory.h"
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

void Wallet::setSeedLanguage(const QString &lang)
{
    m_walletImpl->setSeedLanguage(lang.toStdString());
}

Wallet::Status Wallet::status() const
{
    return static_cast<Status>(m_walletImpl->status());
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

bool Wallet::init(const QString &daemonAddress, quint64 upperTransactionLimit)
{
    return m_walletImpl->init(daemonAddress.toStdString(), upperTransactionLimit);
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

bool Wallet::refresh()
{
    return m_walletImpl->refresh();
}

PendingTransaction *Wallet::createTransaction(const QString &dst_addr, quint64 amount)
{
    Bitmonero::PendingTransaction * ptImpl = m_walletImpl->createTransaction(
                dst_addr.toStdString(), amount);
    PendingTransaction * result = new PendingTransaction(ptImpl, this);
    return result;
}

void Wallet::disposeTransaction(PendingTransaction *t)
{
    m_walletImpl->disposeTransaction(t->m_pimpl);
    delete t;
}

TransactionHistory *Wallet::history()
{
    if (!m_history) {
        Bitmonero::TransactionHistory * impl = m_walletImpl->history();
        m_history = new TransactionHistory(impl, this);
    }
    return m_history;
}



Wallet::Wallet(Bitmonero::Wallet *w, QObject *parent)
    : QObject(parent), m_walletImpl(w), m_history(nullptr)
{

}

Wallet::~Wallet()
{
    Bitmonero::WalletManagerFactory::getWalletManager()->closeWallet(m_walletImpl);
}
