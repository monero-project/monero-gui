#ifndef PENDINGTRANSACTION_H
#define PENDINGTRANSACTION_H

#include <QObject>

#include <wallet/wallet2_api.h>

//namespace Bitmonero {
//class PendingTransaction;
//}

class PendingTransaction : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Status status READ status)
    Q_PROPERTY(QString errorString READ errorString)
    Q_PROPERTY(quint64 amount READ amount)
    Q_PROPERTY(quint64 dust READ dust)
    Q_PROPERTY(quint64 fee READ fee)
    Q_PROPERTY(QList<QString> txid READ txid)

public:
    enum Status {
        Status_Ok       = Bitmonero::PendingTransaction::Status_Ok,
        Status_Error    = Bitmonero::PendingTransaction::Status_Error
    };
    Q_ENUM(Status)

    enum Priority {
        Priority_Low    = Bitmonero::PendingTransaction::Priority_Low,
        Priority_Medium = Bitmonero::PendingTransaction::Priority_Medium,
        Priority_High   = Bitmonero::PendingTransaction::Priority_High
    };
    Q_ENUM(Priority)


    Status status() const;
    QString errorString() const;
    Q_INVOKABLE bool commit();
    quint64 amount() const;
    quint64 dust() const;
    quint64 fee() const;
    QList<QString> txid() const;
private:
    explicit PendingTransaction(Bitmonero::PendingTransaction * pt, QObject *parent = 0);

private:
    friend class Wallet;
    Bitmonero::PendingTransaction * m_pimpl;
};

#endif // PENDINGTRANSACTION_H
