#include "TransactionHistorySortFilterModel.h"
#include "TransactionHistoryModel.h"

#include <QDebug>

TransactionHistorySortFilterModel::TransactionHistorySortFilterModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{

}

QString TransactionHistorySortFilterModel::paymentIdFilter() const
{

}

void TransactionHistorySortFilterModel::setPaymentIdFilter(const QString &arg)
{

}

void TransactionHistorySortFilterModel::sort(int column, Qt::SortOrder order)
{
    QSortFilterProxyModel::sort(column, order);
}

bool TransactionHistorySortFilterModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{

    if (source_row < 0 || source_row >= sourceModel()->rowCount()) {
        return false;
    }

    QModelIndex index = sourceModel()->index(source_row, 0, source_parent);
    if (!index.isValid()) {
        return false;
    }

    bool result = true;

    for (int role : m_filterValues.keys()) {
        if (m_filterValues.contains(role)) {
            QVariant data = sourceModel()->data(index, role);
            result = data.toString().contains(m_filterValues.value(role).toString());
            if (result)
                break;
        }
    }

    return result;
}

bool TransactionHistorySortFilterModel::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
    return QSortFilterProxyModel::lessThan(source_left, source_right);
}

QVariant TransactionHistorySortFilterModel::filterValue(int role)
{
    return m_filterValues.value(role);
}

void TransactionHistorySortFilterModel::setFilterValue(int role, const QVariant &filterValue)
{
    m_filterValues[role] = filterValue;
}
