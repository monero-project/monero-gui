#ifndef TRANSFER_H
#define TRANSFER_H

#include <wallet/wallet2_api.h>
#include <QObject>

class Transfer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(quint64 amount READ amount)
    Q_PROPERTY(QString address READ address)
private:
    explicit Transfer(uint64_t _amount, const QString &_address,  QObject *parent = 0): m_amount(_amount), m_address(_address), QObject(parent) {};
private:
    friend class TransactionInfo;
    qint64 m_amount;
    QString m_address;

public:
    qint64 amount(){ return m_amount; }
    QString address(){ return m_address; };

};
// in order to wrap it to QVariant
Q_DECLARE_METATYPE(Transfer*)


#endif // TRANSACTIONINFO_H
