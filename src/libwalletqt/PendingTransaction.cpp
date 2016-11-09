#include "PendingTransaction.h"


PendingTransaction::Status PendingTransaction::status() const
{
    return static_cast<Status>(m_pimpl->status());
}

QString PendingTransaction::errorString() const
{
    return QString::fromStdString(m_pimpl->errorString());
}

bool PendingTransaction::commit()
{
    return m_pimpl->commit();
}

quint64 PendingTransaction::amount() const
{
    return m_pimpl->amount();
}

quint64 PendingTransaction::dust() const
{
    return m_pimpl->dust();
}

quint64 PendingTransaction::fee() const
{
    return m_pimpl->fee();
}

QList<QString> PendingTransaction::txid() const
{
    QList<QString> list;
    std::vector<std::string> txid = m_pimpl->txid();
    for (const auto &t: txid)
        list.append(QString::fromStdString(t));
    return list;
}

PendingTransaction::PendingTransaction(Bitmonero::PendingTransaction *pt, QObject *parent)
    : QObject(parent), m_pimpl(pt)
{

}
