#include "TransactionHistory.h"
#include "TransactionInfo.h"
#include <wallet/wallet2_api.h>


int TransactionHistory::count() const
{
    return m_pimpl->count();
}

TransactionInfo *TransactionHistory::transaction(int index)
{
    // box up Bitmonero::TransactionInfo
    Bitmonero::TransactionInfo * impl = m_pimpl->transaction(index);
    TransactionInfo * result = new TransactionInfo(impl, this);
    return result;
}

TransactionInfo *TransactionHistory::transaction(const QString &id)
{
    // box up Bitmonero::TransactionInfo
    Bitmonero::TransactionInfo * impl = m_pimpl->transaction(id.toStdString());
    TransactionInfo * result = new TransactionInfo(impl, this);
    return result;
}

QList<TransactionInfo *> TransactionHistory::getAll() const
{
    qDeleteAll(m_tinfo);
    m_tinfo.clear();
    TransactionHistory * parent = const_cast<TransactionHistory*>(this);
    for (const auto i : m_pimpl->getAll()) {
        TransactionInfo * ti = new TransactionInfo(i, parent);
        m_tinfo.append(ti);
    }
    return m_tinfo;
}

void TransactionHistory::refresh()
{
    // XXX this invalidates previously saved history that might be used by clients
    m_pimpl->refresh();
    emit invalidated();
}

TransactionHistory::TransactionHistory(Bitmonero::TransactionHistory *pimpl, QObject *parent)
    : QObject(parent), m_pimpl(pimpl)
{

}
