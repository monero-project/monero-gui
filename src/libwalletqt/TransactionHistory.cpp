#include "TransactionHistory.h"
#include "TransactionInfo.h"
#include <wallet/api/wallet2_api.h>

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

QList<TransactionInfo *> TransactionHistory::getAll(quint32 accountIndex) const
{
    // XXX this invalidates previously saved history that might be used by model
    emit refreshStarted();
    qDeleteAll(m_tinfo);
    m_tinfo.clear();

    QDateTime firstDateTime = QDateTime(QDate(2014, 4, 18)); // the genesis block
    QDateTime lastDateTime  = QDateTime::currentDateTime().addDays(1); // tomorrow (guard against jitter and timezones)
    quint64 lastTxHeight = 0;
    m_locked = false;
    m_minutesToUnlock = 0;
    TransactionHistory * parent = const_cast<TransactionHistory*>(this);
    for (const auto i : m_pimpl->getAll()) {
        TransactionInfo * ti = new TransactionInfo(i, parent);
        if (ti->subaddrAccount() != accountIndex) {
            delete ti;
            continue;
        }
        m_tinfo.append(ti);
        // looking for transactions timestamp scope
        if (ti->timestamp() >= lastDateTime) {
            lastDateTime = ti->timestamp();
        }
        if (ti->timestamp() <= firstDateTime) {
            firstDateTime = ti->timestamp();
        }
        quint64 requiredConfirmations = (ti->blockHeight() < ti->unlockTime()) ? ti->unlockTime() - ti->blockHeight() : 10;
        // store last tx height
        if (ti->confirmations() < requiredConfirmations && ti->blockHeight() >= lastTxHeight) {
            lastTxHeight = ti->blockHeight();
            // TODO: Fetch block time and confirmations needed from wallet2?
            m_minutesToUnlock = (requiredConfirmations - ti->confirmations()) * 2;
            m_locked = true;
        }

    }
    emit refreshFinished();

    if (m_firstDateTime != firstDateTime) {
        m_firstDateTime = firstDateTime;
        emit firstDateTimeChanged();
    }
    if (m_lastDateTime != lastDateTime) {
        m_lastDateTime = lastDateTime;
        emit lastDateTimeChanged();
    }

    return m_tinfo;
}

void TransactionHistory::refresh(quint32 accountIndex)
{
    // rebuilding transaction list in wallet_api;
    m_pimpl->refresh();
    // copying list here and keep track on every item to avoid memleaks
    getAll(accountIndex);
}

quint64 TransactionHistory::count() const
{
    return m_tinfo.count();
}

QDateTime TransactionHistory::firstDateTime() const
{
    return m_firstDateTime;
}

QDateTime TransactionHistory::lastDateTime() const
{
    return m_lastDateTime;
}

quint64 TransactionHistory::minutesToUnlock() const
{
    return m_minutesToUnlock;
}

bool TransactionHistory::TransactionHistory::locked() const
{
    return m_locked;
}


TransactionHistory::TransactionHistory(Monero::TransactionHistory *pimpl, QObject *parent)
    : QObject(parent), m_pimpl(pimpl), m_minutesToUnlock(0), m_locked(false)
{
    m_firstDateTime  = QDateTime(QDate(2014, 4, 18)); // the genesis block
    m_lastDateTime = QDateTime::currentDateTime().addDays(1); // tomorrow (guard against jitter and timezones)
}
