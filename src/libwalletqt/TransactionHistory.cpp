// Copyright (c) 2014-2024, The Monero Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#include "TransactionHistory.h"
#include "TransactionInfo.h"
#include <wallet/api/wallet2_api.h>

#include <QFile>
#include <QDebug>
#include <QReadLocker>
#include <QWriteLocker>
#include <QtGlobal>


bool TransactionHistory::transaction(int index, std::function<void (TransactionInfo &)> callback)
{
    QReadLocker locker(&m_lock);

    if (index < 0 || index >= m_tinfo.size()) {
        qCritical("%s: no transaction info for index %d", __FUNCTION__, index);
        qCritical("%s: there's %d transactions in backend", __FUNCTION__, m_pimpl->count());
        return false;
    }

    callback(*m_tinfo.value(index));
    return true;
}

//// XXX: not sure if this method really needed;
//TransactionInfo *TransactionHistory::transaction(const QString &id)
//{
//    return nullptr;
//}

void TransactionHistory::refresh(quint32 accountIndex)
{
#if QT_VERSION >= QT_VERSION_CHECK(5, 14, 0)
    QDateTime firstDateTime = QDate(2014, 4, 18).startOfDay();
#else
    QDateTime firstDateTime = QDateTime(QDate(2014, 4, 18)); // the genesis block
#endif
    QDateTime lastDateTime  = QDateTime::currentDateTime().addDays(1); // tomorrow (guard against jitter and timezones)

    emit refreshStarted();

    {
        QWriteLocker locker(&m_lock);

        qDeleteAll(m_tinfo);
        m_tinfo.clear();

        quint64 lastTxHeight = 0;
        m_locked = false;
        m_minutesToUnlock = 0;

        m_pimpl->refresh();
        for (const auto i : m_pimpl->getAll()) {
            if (i->subaddrAccount() != accountIndex) {
                continue;
            }

            m_tinfo.append(new TransactionInfo(i, this));

            const TransactionInfo *ti = m_tinfo.back();
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
}

quint64 TransactionHistory::count() const
{
    QReadLocker locker(&m_lock);

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
#if QT_VERSION >= QT_VERSION_CHECK(5, 14, 0)
    m_firstDateTime = QDate(2014, 4, 18).startOfDay();
#else
    m_firstDateTime  = QDateTime(QDate(2014, 4, 18)); // the genesis block
#endif
    m_lastDateTime = QDateTime::currentDateTime().addDays(1); // tomorrow (guard against jitter and timezones)
}

QString TransactionHistory::writeCSV(quint32 accountIndex, QString out)
{
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
    output << "blockHeight,epoch,date,direction,amount,atomicAmount,fee,txid,label,subaddrAccount,paymentId,description\n";

    QReadLocker locker(&m_lock);
    for (const auto &tx : m_pimpl->getAll()) {
        if (tx->subaddrAccount() != accountIndex) {
            continue;
        }

        TransactionInfo info(tx, this);

        // collect column data
        quint64 atomicAmount = info.atomicAmount();
        quint32 subaddrAccount = info.subaddrAccount();
        QString fee = info.fee();
        QString direction = QString("");
        TransactionInfo::Direction _direction = info.direction();
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
        QString label = info.label();
        label.remove(QChar('"'));  // reserved
        QString description = info.description();
        description.remove(QChar('"')); // reserved
        quint64 blockHeight = info.blockHeight();
        QDateTime timeStamp = info.timestamp();
        QString date = info.date() + " " + info.time();
        uint epoch = timeStamp.toTime_t();
        QString displayAmount = info.displayAmount();
        QString paymentId = info.paymentId();
        if(paymentId == "0000000000000000"){
            paymentId = "";
        }

        // format and write
        QString line = QString("%1,%2,%3,%4,%5,%6,%7,%8,\"%9\",%10,%11,\"%12\"\n")
            .arg(QString::number(blockHeight), QString::number(epoch), date)
            .arg(direction, displayAmount, QString::number(atomicAmount))
            .arg(info.fee(), info.hash(), label, QString::number(subaddrAccount))
            .arg(paymentId, description);
        output << line;
    }

    data.close();
    return fn;
}
