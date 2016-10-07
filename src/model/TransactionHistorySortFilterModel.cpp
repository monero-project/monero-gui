#include "TransactionHistorySortFilterModel.h"
#include "TransactionHistoryModel.h"

#include <QDebug>

TransactionHistorySortFilterModel::TransactionHistorySortFilterModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setDynamicSortFilter(true);
}

QString TransactionHistorySortFilterModel::paymentIdFilter() const
{
    return m_filterValues.value(TransactionHistoryModel::TransactionPaymentIdRole).toString();
}

void TransactionHistorySortFilterModel::setPaymentIdFilter(const QString &arg)
{
    if (paymentIdFilter() != arg) {
        m_filterValues[TransactionHistoryModel::TransactionPaymentIdRole] = arg;
        emit paymentIdFilterChanged();
        invalidateFilter();
    }
}

QDate TransactionHistorySortFilterModel::dateFromFilter() const
{
    return dateFromToFilter(From);
}

void TransactionHistorySortFilterModel::setDateFromFilter(const QDate &date)
{
    if (date != dateFromFilter()) {
        setDateFromToFilter(From, date);
        emit dateFromFilterChanged();
        invalidateFilter();
    }
}

QDate TransactionHistorySortFilterModel::dateToFilter() const
{
    return dateFromToFilter(To);
}

void TransactionHistorySortFilterModel::setDateToFilter(const QDate &date)
{
    if (date != dateToFilter()) {
        setDateFromToFilter(To, date);
        emit dateFromFilterChanged();
        invalidateFilter();
    }
}

void TransactionHistorySortFilterModel::sort(int column, Qt::SortOrder order)
{
    QSortFilterProxyModel::sort(column, order);
}

TransactionHistory *TransactionHistorySortFilterModel::transactionHistory() const
{
    const TransactionHistoryModel * model = static_cast<const TransactionHistoryModel*> (sourceModel());
    return model->transactionHistory();
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

    // iterating through filters
    for (int role : m_filterValues.keys()) {
        if (m_filterValues.contains(role)) {
            QVariant data = sourceModel()->data(index, role);
            switch (role) {
            case TransactionHistoryModel::TransactionPaymentIdRole:
                result = data.toString().contains(paymentIdFilter());
                break;
            case TransactionHistoryModel::TransactionTimeStampRole:
            {
                QDateTime from = QDateTime(dateFromFilter());
                QDateTime to   = QDateTime(dateToFilter());
                QDateTime timestamp = data.toDateTime();
                bool matchFrom = from.isNull() || timestamp.isNull() || timestamp >= from;
                bool matchTo = to.isNull() || timestamp.isNull() || timestamp <= to;
                result = matchFrom && matchTo;
            }
            default:
                break;
            }
            if (!result) // stop the loop once filter doesn't match
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

QDate TransactionHistorySortFilterModel::dateFromToFilter(TransactionHistorySortFilterModel::DateScopeIndex index) const
{
    int role = TransactionHistoryModel::TransactionTimeStampRole;
    if (!m_filterValues.contains(role)) {
        return QDate();
    }
    return m_filterValues.value(role).toList().at(index).toDate();
}

void TransactionHistorySortFilterModel::setDateFromToFilter(TransactionHistorySortFilterModel::DateScopeIndex index, const QDate &value)
{
    QVariantList scopeFilter;
    int role = TransactionHistoryModel::TransactionTimeStampRole;
    if (m_filterValues.contains(role)) {
        scopeFilter = m_filterValues.value(role).toList();
    }
    while (scopeFilter.size() < 2) {
        scopeFilter.append(QDate());
    }
    scopeFilter[index] = QVariant::fromValue(value);
    m_filterValues[role] = scopeFilter;
}
