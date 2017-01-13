#ifndef TRANSACTIONHISTORY_H
#define TRANSACTIONHISTORY_H

#include <QObject>
#include <QList>
#include <QDateTime>

namespace Monero {
class TransactionHistory;
}

class TransactionInfo;

class TransactionHistory : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count)
    Q_PROPERTY(QDateTime firstDateTime READ firstDateTime NOTIFY firstDateTimeChanged)
    Q_PROPERTY(QDateTime lastDateTime READ lastDateTime NOTIFY lastDateTimeChanged)
    Q_PROPERTY(int minutesToUnlock READ minutesToUnlock)
    Q_PROPERTY(bool locked READ locked)

public:
    Q_INVOKABLE TransactionInfo *transaction(int index);
    // Q_INVOKABLE TransactionInfo * transaction(const QString &id);
    Q_INVOKABLE QList<TransactionInfo*> getAll() const;
    Q_INVOKABLE void refresh();
    quint64 count() const;
    QDateTime firstDateTime() const;
    QDateTime lastDateTime() const;
    quint64 minutesToUnlock() const;
    bool locked() const;

signals:
    void refreshStarted() const;
    void refreshFinished() const;
    void firstDateTimeChanged() const;
    void lastDateTimeChanged() const;

public slots:


private:
    explicit TransactionHistory(Monero::TransactionHistory * pimpl, QObject *parent = 0);

private:
    friend class Wallet;
    Monero::TransactionHistory * m_pimpl;
    mutable QList<TransactionInfo*> m_tinfo;
    mutable QDateTime   m_firstDateTime;
    mutable QDateTime   m_lastDateTime;
    mutable int m_minutesToUnlock;
    // history contains locked transfers
    mutable bool m_locked;

};

#endif // TRANSACTIONHISTORY_H
