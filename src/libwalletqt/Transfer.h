#ifndef TRANSFER_H
#define TRANSFER_H

#include <wallet/api/wallet2_api.h>
#include <QObject>

class Transfer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(quint64 amount READ amount)
    Q_PROPERTY(QString address READ address)
private:
    explicit Transfer(uint64_t _amount, const QString &_address,  QObject *parent = 0): QObject(parent), m_amount(_amount), m_address(_address) {};
private:
    friend class TransactionInfo;
    quint64 m_amount;
    QString m_address;
public:
    quint64 amount() const { return m_amount; }
    QString address() const { return m_address; }

};

#endif // TRANSACTIONINFO_H
