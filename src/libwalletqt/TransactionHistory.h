#ifndef TRANSACTIONHISTORY_H
#define TRANSACTIONHISTORY_H

#include <QObject>
#include <QList>

namespace Bitmonero {
class TransactionHistory;
}

class TransactionInfo;

class TransactionHistory : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count)

public:
    int count() const;
    Q_INVOKABLE TransactionInfo *transaction(int index);
    Q_INVOKABLE TransactionInfo * transaction(const QString &id);
    Q_INVOKABLE QList<TransactionInfo*> getAll() const;
    Q_INVOKABLE void refresh();

signals:
    void invalidated();

public slots:


private:
    explicit TransactionHistory(Bitmonero::TransactionHistory * pimpl, QObject *parent = 0);

private:
    friend class Wallet;

    Bitmonero::TransactionHistory * m_pimpl;
    mutable QList<TransactionInfo*> m_tinfo;

};

#endif // TRANSACTIONHISTORY_H
