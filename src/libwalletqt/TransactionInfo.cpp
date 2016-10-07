#include "TransactionInfo.h"
#include "WalletManager.h"

#include <QDateTime>

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

TransactionInfo::TransactionInfo(Bitmonero::TransactionInfo *pimpl, QObject *parent)
    : QObject(parent), m_pimpl(pimpl)
{

}
