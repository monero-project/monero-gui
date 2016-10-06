#include "TransactionHistory.h"
#include "TransactionInfo.h"
#include <wallet/wallet2_api.h>

#include <QDebug>


TransactionInfo *TransactionHistory::transaction(int index)
{

    if (index < 0 || index >= m_tinfo.size()) {
        qCritical("%s: no transaction info for index %d", __FUNCTION__, index);
        qCritical("%s: there's %d transactions in backend", __FUNCTION__, m_pimpl->count());
        return nullptr;
    }
    return m_tinfo.at(index);
}

//// XXX: not sure if this method really needed;
//TransactionInfo *TransactionHistory::transaction(const QString &id)
//{
//    return nullptr;
//}

QList<TransactionInfo *> TransactionHistory::getAll() const
{
    // XXX this invalidates previously saved history that might be used by model
    emit refreshStarted();
    qDeleteAll(m_tinfo);
    m_tinfo.clear();
    TransactionHistory * parent = const_cast<TransactionHistory*>(this);
    for (const auto i : m_pimpl->getAll()) {
        TransactionInfo * ti = new TransactionInfo(i, parent);
        qDebug() << ti->hash();
        m_tinfo.append(ti);
    }
    emit refreshFinished();
    return m_tinfo;
}

void TransactionHistory::refresh()
{
    // rebuilding transaction list in wallet_api;
    m_pimpl->refresh();
    // copying list here and keep track on every item to avoid memleaks
    getAll();
}

quint64 TransactionHistory::count() const
{
    return m_tinfo.count();
}


TransactionHistory::TransactionHistory(Bitmonero::TransactionHistory *pimpl, QObject *parent)
    : QObject(parent), m_pimpl(pimpl)
{
    // this->refresh();
}
