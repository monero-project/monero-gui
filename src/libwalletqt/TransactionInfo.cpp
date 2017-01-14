#include "TransactionInfo.h"
#include "WalletManager.h"
#include "Transfer.h"
#include <QDateTime>
#include <QDebug>

TransactionInfo::Direction TransactionInfo::direction() const
{
    return static_cast<Direction>(m_pimpl->direction());
}

bool TransactionInfo::isPending() const
{
    return m_pimpl->isPending();
}

bool TransactionInfo::isFailed() const
{
    return m_pimpl->isFailed();
}


double TransactionInfo::amount() const
{
    // there's no unsigned uint64 for JS, so better use double
    return WalletManager::instance()->displayAmount(m_pimpl->amount()).toDouble();
}

quint64 TransactionInfo::atomicAmount() const
{
    return m_pimpl->amount();
}

QString TransactionInfo::displayAmount() const
{
    return WalletManager::instance()->displayAmount(m_pimpl->amount());
}

QString TransactionInfo::fee() const
{
    return WalletManager::instance()->displayAmount(m_pimpl->fee());
}

quint64 TransactionInfo::blockHeight() const
{
    return m_pimpl->blockHeight();
}

quint64 TransactionInfo::confirmations() const
{
    return m_pimpl->confirmations();
}

QString TransactionInfo::hash() const
{
    return QString::fromStdString(m_pimpl->hash());
}

QDateTime TransactionInfo::timestamp() const
{
    QDateTime result = QDateTime::fromTime_t(m_pimpl->timestamp());
    return result;
}

QString TransactionInfo::date() const
{
    return timestamp().date().toString(Qt::ISODate);
}

QString TransactionInfo::time() const
{
    return timestamp().time().toString(Qt::ISODate);
}

QString TransactionInfo::paymentId() const
{
    return QString::fromStdString(m_pimpl->paymentId());
}

QString TransactionInfo::destinations_formatted() const
{
    QString destinations;
    for (auto const& t: transfers()) {
        if (!destinations.isEmpty())
          destinations += "<br> ";
        destinations +=  WalletManager::instance()->displayAmount(t->amount()) + ": " + t->address();
    }
    return destinations;
}

QList<Transfer*> TransactionInfo::transfers() const
{
    if (!m_transfers.isEmpty()) {
        return m_transfers;
    }

    for(auto const& t: m_pimpl->transfers()) {
        TransactionInfo * parent = const_cast<TransactionInfo*>(this);
        Transfer * transfer = new Transfer(t.amount, QString::fromStdString(t.address), parent);
        m_transfers.append(transfer);
    }
    return m_transfers;
}

TransactionInfo::TransactionInfo(Monero::TransactionInfo *pimpl, QObject *parent)
    : QObject(parent), m_pimpl(pimpl)
{

}
