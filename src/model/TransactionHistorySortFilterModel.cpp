#include "TransactionHistorySortFilterModel.h"
#include "TransactionHistoryModel.h"

#include <QDebug>

namespace {
    /**
     * helper to extract scope value from filter
     */
    template <typename T>
    T scopeFilterValue(const QMap<int, QVariant> &filters, int role, int scopeIndex)
    {
        if (!filters.contains(role)) {
            return T();
        }
        return filters.value(role).toList().at(scopeIndex).value<T>();
    }

    /**
     * helper to setup scope value to filter
     */
    template <typename T>
    void setScopeFilterValue(QMap<int, QVariant> &filters, int role, int scopeIndex, const T &value)
    {
        QVariantList scopeFilter;

        if (filters.contains(role)) {
            scopeFilter = filters.value(role).toList();
        }
        while (scopeFilter.size() < 2) {
            scopeFilter.append(T());
        }
        scopeFilter[scopeIndex] = QVariant::fromValue(value);
        filters[role] = scopeFilter;
    }
}


TransactionHistorySortFilterModel::TransactionHistorySortFilterModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setDynamicSortFilter(true);
}

QString TransactionHistorySortFilterModel::searchFilter() const
{
    return m_searchString;
}

void TransactionHistorySortFilterModel::setSearchFilter(const QString &arg)
{
    if (searchFilter() != arg) {
        m_searchString = arg;
        emit searchFilterChanged();
        invalidateFilter();
    }
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
    return scopeFilterValue<QDate>(m_filterValues, TransactionHistoryModel::TransactionTimeStampRole, ScopeIndex::From);
}

void TransactionHistorySortFilterModel::setDateFromFilter(const QDate &date)
{
    if (date != dateFromFilter()) {
        setScopeFilterValue(m_filterValues, TransactionHistoryModel::TransactionTimeStampRole, ScopeIndex::From, date);
        emit dateFromFilterChanged();
        invalidateFilter();
    }
}

QDate TransactionHistorySortFilterModel::dateToFilter() const
{
    return scopeFilterValue<QDate>(m_filterValues, TransactionHistoryModel::TransactionTimeStampRole, ScopeIndex::To);
}

void TransactionHistorySortFilterModel::setDateToFilter(const QDate &date)
{
    if (date != dateToFilter()) {
        setScopeFilterValue(m_filterValues, TransactionHistoryModel::TransactionTimeStampRole, ScopeIndex::To, date);
        emit dateToFilterChanged();
        invalidateFilter();
    }
}

double TransactionHistorySortFilterModel::amountFromFilter() const
{
    return scopeFilterValue<double>(m_filterValues, TransactionHistoryModel::TransactionAmountRole, ScopeIndex::From);
}

void TransactionHistorySortFilterModel::setAmountFromFilter(double value)
{
    if (value != amountFromFilter()) {
        setScopeFilterValue(m_filterValues, TransactionHistoryModel::TransactionAmountRole, ScopeIndex::From, value);
        emit amountFromFilterChanged();
        invalidateFilter();
    }
}

double TransactionHistorySortFilterModel::amountToFilter() const
{
    return scopeFilterValue<double>(m_filterValues, TransactionHistoryModel::TransactionAmountRole, ScopeIndex::To);
}

void TransactionHistorySortFilterModel::setAmountToFilter(double value)
{
    if (value != amountToFilter()) {
        setScopeFilterValue(m_filterValues, TransactionHistoryModel::TransactionAmountRole, ScopeIndex::To, value);
        emit amountToFilterChanged();
        invalidateFilter();
    }
}

int TransactionHistorySortFilterModel::directionFilter() const
{
    return m_filterValues.value(TransactionHistoryModel::TransactionDirectionRole).value<TransactionInfo::Direction>();
}

void TransactionHistorySortFilterModel::setDirectionFilter(int value)
{
    if (value != directionFilter()) {
        m_filterValues[TransactionHistoryModel::TransactionDirectionRole] = QVariant::fromValue(value);
        emit directionFilterChanged();
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
                to = to.addDays(1); // including upperbound
                QDateTime timestamp = data.toDateTime();
                bool matchFrom = from.isNull() || timestamp.isNull() || timestamp >= from;
                bool matchTo = to.isNull() || timestamp.isNull() || timestamp <= to;
                result = matchFrom && matchTo;
            }
                break;
            case TransactionHistoryModel::TransactionAmountRole:
            {
                double from = amountFromFilter();
                double to = amountToFilter();
                double amount = data.toDouble();

                bool matchFrom = from <= 0 || amount  >= from;
                bool matchTo = to <= 0 || amount <= to;
                result = matchFrom && matchTo;
            }
                break;
            case TransactionHistoryModel::TransactionDirectionRole:
                result = directionFilter() == TransactionInfo::Direction_Both ? true
                                                  : data.toInt() == directionFilter();


                break;

            default:
                break;
            }


            if (!result) { // stop the loop once filter doesn't match
                break;
            }
        }
    }

    if (!result || m_searchString.isEmpty())
        return result;

    QVariant data = sourceModel()->data(index, TransactionHistoryModel::TransactionPaymentIdRole);
    if (data.toString().contains(m_searchString))
        return true;
    data = sourceModel()->data(index, TransactionHistoryModel::TransactionDisplayAmountRole);
    if (data.toString().contains(m_searchString))
        return true;
    data = sourceModel()->data(index, TransactionHistoryModel::TransactionBlockHeightRole);
    if (data.toString().contains(m_searchString))
        return true;
    data = sourceModel()->data(index, TransactionHistoryModel::TransactionFeeRole);
    if (data.toString().contains(m_searchString))
        return true;
    data = sourceModel()->data(index, TransactionHistoryModel::TransactionHashRole);
    if (data.toString().contains(m_searchString))
        return true;
    data = sourceModel()->data(index, TransactionHistoryModel::TransactionDateRole);
    if (data.toString().contains(m_searchString))
        return true;
    data = sourceModel()->data(index, TransactionHistoryModel::TransactionTimeRole);
    if (data.toString().contains(m_searchString))
        return true;

    return false;
}

bool TransactionHistorySortFilterModel::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
    return QSortFilterProxyModel::lessThan(source_left, source_right);
}
