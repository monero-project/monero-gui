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
        TransactionFeeRole,
        TransactionBlockHeightRole,
        TransactionHashRole,
        TransactionTimeStampRole,
        TransactionPaymentIdRole
    };

    TransactionHistoryModel(QObject * parent = 0);
    void setTransactionHistory(TransactionHistory * th);
    TransactionHistory * transactionHistory() const;

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
