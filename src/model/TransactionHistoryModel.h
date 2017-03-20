#ifndef TRANSACTIONHISTORYMODEL_H
#define TRANSACTIONHISTORYMODEL_H

#include <QAbstractListModel>

class TransactionHistory;
class TransactionInfo;

/**
 * @brief The TransactionHistoryModel class - read-only list model for Transaction History
 */

class TransactionHistoryModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(TransactionHistory * transactionHistory READ transactionHistory WRITE setTransactionHistory NOTIFY transactionHistoryChanged)

public:
    enum TransactionInfoRole {
        TransactionRole = Qt::UserRole + 1, // for the TransactionInfo object;
        TransactionDirectionRole,
        TransactionPendingRole,
        TransactionFailedRole,
        TransactionAmountRole,
        TransactionDisplayAmountRole,
        TransactionFeeRole,
        TransactionBlockHeightRole,
        TransactionConfirmationsRole,
        TransactionHashRole,
        TransactionTimeStampRole,
        TransactionPaymentIdRole,
        // extra role (alias) for TransactionDirectionRole (as UI currently wants just boolean "out")
        TransactionIsOutRole,
        // extra roles for date and time (as UI wants date and time separately)
        TransactionDateRole,
        TransactionTimeRole,
        TransactionAtomicAmountRole,
        // only for outgoing
        TransactionDestinationsRole
    };
    Q_ENUM(TransactionInfoRole)

    TransactionHistoryModel(QObject * parent = 0);
    void setTransactionHistory(TransactionHistory * th);
    TransactionHistory * transactionHistory() const;
    /**
     * @brief dateFrom - returns firstmost transaction datetime
     * @return
     */
    QDateTime firstDateTime() const;

    /**
     * @brief dateTo - returns lastmost transaction datetime
     * @return
     */
    QDateTime lastDateTime() const;



    /// QAbstractListModel
    virtual QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const override;
    virtual int rowCount(const QModelIndex & parent = QModelIndex()) const override;
    virtual QHash<int, QByteArray> roleNames() const  override;

signals:
    void transactionHistoryChanged();

private:
    TransactionHistory * m_transactionHistory;
};

#endif // TRANSACTIONHISTORYMODEL_H
