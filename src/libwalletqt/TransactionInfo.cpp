#include "TransactionInfo.h"
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

quint64 TransactionInfo::amount() const
{
    return m_pimpl->amount();
}

quint64 TransactionInfo::fee() const
{
    return m_pimpl->fee();

}

quint64 TransactionInfo::blockHeight() const
{
    return m_pimpl->blockHeight();
}

QString TransactionInfo::hash() const
{
    return QString::fromStdString(m_pimpl->hash());
}

QString TransactionInfo::timestamp()
{
    QString result = QDateTime::fromTime_t(m_pimpl->timestamp()).toString(Qt::ISODate);
    return result;
}

QString TransactionInfo::paymentId()
{
    return QString::fromStdString(m_pimpl->paymentId());
}

TransactionInfo::TransactionInfo(Bitmonero::TransactionInfo *pimpl, QObject *parent)
    : QObject(parent), m_pimpl(pimpl)
{

}
