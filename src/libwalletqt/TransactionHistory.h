#ifndef TRANSACTIONHISTORY_H
#define TRANSACTIONHISTORY_H

#include <QObject>
#include <QList>
#include <QDateTime>

namespace Bitmonero {
class TransactionHistory;
}

class TransactionInfo;

class TransactionHistory : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count)
    Q_PROPERTY(QDateTime firstDateTime READ firstDateTime NOTIFY firstDateTimeChanged)
    Q_PROPERTY(QDateTime lastDateTime READ lastDateTime NOTIFY lastDateTimeChanged)

public:
    Q_INVOKABLE TransactionInfo *transaction(int index);
    // Q_INVOKABLE TransactionInfo * transaction(const QString &id);
    Q_INVOKABLE QList<TransactionInfo*> getAll() const;
    Q_INVOKABLE void refresh();
    quint64 count() const;
    QDateTime firstDateTime() const;
    QDateTime lastDateTime() const;

signals:
    void refreshStarted() const;
    void refreshFinished() const;
    void firstDateTimeChanged() const;
    void lastDateTimeChanged() const;

public slots:


private:
    explicit TransactionHistory(Bitmonero::TransactionHistory * pimpl, QObject *parent = 0);

private:
    friend class Wallet;

    Bitmonero::TransactionHistory * m_pimpl;
    mutable QList<TransactionInfo*> m_tinfo;
    mutable QDateTime   m_firstDateTime;
    mutable QDateTime   m_lastDateTime;

};

#endif // TRANSACTIONHISTORY_H
