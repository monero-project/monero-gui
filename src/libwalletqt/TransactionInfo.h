#ifndef TRANSACTIONINFO_H
#define TRANSACTIONINFO_H

#include <QObject>
#include <wallet/wallet2_api.h>

class TransactionInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Direction direction READ direction)
    Q_PROPERTY(bool isPending READ isPending)
    Q_PROPERTY(bool isFailed READ isFailed)
    Q_PROPERTY(quint64 amount READ amount)
    Q_PROPERTY(quint64 fee READ fee)
    Q_PROPERTY(quint64 blockHeight READ blockHeight)
    Q_PROPERTY(QString hash READ hash)
    Q_PROPERTY(QString timestamp READ timestamp)
    Q_PROPERTY(QString paymentId READ paymentId)

public:
    enum Direction {
        Direction_In  =  Bitmonero::TransactionInfo::Direction_In,
        Direction_Out =  Bitmonero::TransactionInfo::Direction_Out
    };

//   TODO: implement as separate class;

//    struct Transfer {
//        Transfer(uint64_t _amount, const std::string &address);
//        const uint64_t amount;
//        const std::string address;
//    };
    Direction  direction() const;
    bool isPending() const;
    bool isFailed() const;
    quint64 amount() const;
    quint64 fee() const;
    quint64 blockHeight() const;
    //! transaction_id
    QString hash() const;
    QString timestamp();
    QString paymentId();

    // TODO: implement it
    //! only applicable for output transactions
    // virtual const std::vector<Transfer> & transfers() const = 0;
private:
    explicit TransactionInfo(Bitmonero::TransactionInfo * pimpl, QObject *parent = 0);
private:
    friend class TransactionHistory;
    Bitmonero::TransactionInfo * m_pimpl;
};

#endif // TRANSACTIONINFO_H
