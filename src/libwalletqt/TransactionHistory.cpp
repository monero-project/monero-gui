#include "TransactionHistory.h"
#include "TransactionInfo.h"
#include <wallet/api/wallet2_api.h>

#include <QFile>
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

QString TransactionHistory::writeCSV(quint32 accountIndex, QString out)
{
    QList<TransactionInfo *> history = this->getAll(accountIndex);
    if(history.count() < 1){
        return QString("");
    }

    // construct filename
    qint64 now = QDateTime::currentDateTime().currentMSecsSinceEpoch();
    QString fn = QString(QString("%1/monero-txs_%2.csv").arg(out, QString::number(now / 1000)));

    // open file
    QFile data(fn);
    if(!data.open(QFile::WriteOnly | QFile::Truncate)){
        return QString("");
    }

    // write header
    QTextStream output(&data);
    output << "blockHeight,epoch,date,direction,amount,atomicAmount,fee,txid,label,subaddrAccount,paymentId\n";

    foreach(const TransactionInfo *info, history)
    {
        // collect column data
        double amount = info->amount();
        quint64 atomicAmount = info->atomicAmount();
        quint32 subaddrAccount = info->subaddrAccount();
        QString fee = info->fee();
        QString direction = QString("");
        TransactionInfo::Direction _direction = info->direction();
        if(_direction == TransactionInfo::Direction_In)
        {
            direction = QString("in");
        }
        else if(_direction == TransactionInfo::Direction_Out){
            direction = QString("out");
        }
        else {
            continue;  // skip TransactionInfo::Direction_Both
        }
        QString label = info->label();
        label.remove(QChar('"'));  // reserved
        quint64 blockHeight = info->blockHeight();
        QDateTime timeStamp = info->timestamp();
        QString date = info->date() + " " + info->time();
        uint epoch = timeStamp.toTime_t();
        QString displayAmount = info->displayAmount();
        QString paymentId = info->paymentId();
        if(paymentId == "0000000000000000"){
            paymentId = "";
        }

        // format and write
        QString line = QString("%1,%2,%3,%4,%5,%6,%7,%8,\"%9\",%10,%11\n")
            .arg(QString::number(blockHeight), QString::number(epoch), date)
            .arg(direction, QString::number(amount), QString::number(atomicAmount))
            .arg(info->fee(), info->hash(), label, QString::number(subaddrAccount))
            .arg(paymentId);
        output << line;
    }

    data.close();
    return fn;
}
