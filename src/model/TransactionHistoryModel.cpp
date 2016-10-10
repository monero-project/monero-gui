#include "TransactionHistoryModel.h"
#include "TransactionHistory.h"
#include "TransactionInfo.h"

#include <QDateTime>


TransactionHistoryModel::TransactionHistoryModel(QObject *parent)
    : QAbstractListModel(parent), m_transactionHistory(nullptr)
{

}

void TransactionHistoryModel::setTransactionHistory(TransactionHistory *th)
{
    beginResetModel();
    m_transactionHistory = th;
    endResetModel();

    connect(m_transactionHistory, &TransactionHistory::refreshStarted,
            this, &TransactionHistoryModel::beginResetModel);
    connect(m_transactionHistory, &TransactionHistory::refreshFinished,
            this, &TransactionHistoryModel::endResetModel);

    emit transactionHistoryChanged();
}

TransactionHistory *TransactionHistoryModel::transactionHistory() const
{
    return m_transactionHistory;
}

QVariant TransactionHistoryModel::data(const QModelIndex &index, int role) const
{
    if (!m_transactionHistory) {
        return QVariant();
    }

    if (index.row() < 0 || (unsigned)index.row() >= m_transactionHistory->count()) {
        return QVariant();
    }

    TransactionInfo * tInfo = m_transactionHistory->transaction(index.row());


    Q_ASSERT(tInfo);
    if (!tInfo) {
        qCritical("%s: internal error: no transaction info for index %d", __FUNCTION__, index.row());
        return QVariant();
    }
    QVariant result;
    switch (role) {
    case TransactionRole:
        result = QVariant::fromValue(tInfo);
        break;
    case TransactionDirectionRole:
        result = QVariant::fromValue(tInfo->direction());
        break;
    case TransactionPendingRole:
        result = tInfo->isPending();
        break;
    case TransactionFailedRole:
        result = tInfo->isFailed();
        break;
    case TransactionAmountRole:
        result = tInfo->amount();
        break;
    case TransactionDisplayAmountRole:
        result = tInfo->displayAmount();
        break;
    case TransactionFeeRole:
        result = tInfo->fee();
        break;
    case TransactionBlockHeightRole:
        result = tInfo->blockHeight();
        break;
    case TransactionHashRole:
        result = tInfo->hash();
        break;
    case TransactionTimeStampRole:
        result = tInfo->timestamp();
        break;
    case TransactionPaymentIdRole:
        result = tInfo->paymentId();
        break;
    case TransactionIsOutRole:
        result = tInfo->direction() == TransactionInfo::Direction_Out;
        break;
    case TransactionDateRole:
        result = tInfo->date();
        break;
    case TransactionTimeRole:
        result = tInfo->time();
        break;
    }

    return result;
}

int TransactionHistoryModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_transactionHistory ? m_transactionHistory->count() : 0;
}

QHash<int, QByteArray> TransactionHistoryModel::roleNames() const
{
    QHash<int, QByteArray> roleNames = QAbstractListModel::roleNames();
    roleNames.insert(TransactionRole, "transaction");
    roleNames.insert(TransactionDirectionRole, "direction");
    roleNames.insert(TransactionPendingRole, "isPending");
    roleNames.insert(TransactionFailedRole, "isFailed");
    roleNames.insert(TransactionAmountRole, "amount");
    roleNames.insert(TransactionDisplayAmountRole, "displayAmount");
    roleNames.insert(TransactionFeeRole, "fee");
    roleNames.insert(TransactionBlockHeightRole, "blockHeight");
    roleNames.insert(TransactionHashRole, "hash");
    roleNames.insert(TransactionTimeStampRole, "timeStamp");
    roleNames.insert(TransactionPaymentIdRole, "paymentId");
    roleNames.insert(TransactionIsOutRole, "isOut");
    roleNames.insert(TransactionDateRole, "date");
    roleNames.insert(TransactionTimeRole, "time");
    return roleNames;
}


