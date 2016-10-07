#ifndef TRANSACTIONHISTORYSORTFILTERMODEL_H
#define TRANSACTIONHISTORYSORTFILTERMODEL_H


#include <QSortFilterProxyModel>
#include <QMap>
#include <QVariant>
#include <QDate>

class TransactionHistory;

class TransactionHistorySortFilterModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QString paymentIdFilter READ paymentIdFilter WRITE setPaymentIdFilter NOTIFY paymentIdFilterChanged)
    Q_PROPERTY(QDate dateFromFilter READ dateFromFilter WRITE setDateFromFilter NOTIFY dateFromFilterChanged)
    Q_PROPERTY(QDate dateToFilter READ dateToFilter WRITE setDateToFilter NOTIFY dateToFilterChanged)
    Q_PROPERTY(TransactionHistory * transactionHistory READ transactionHistory)

public:
    TransactionHistorySortFilterModel(QObject * parent = nullptr);
    QString paymentIdFilter() const;
    void setPaymentIdFilter(const QString &arg);
    QDate dateFromFilter() const;
    void setDateFromFilter(const QDate &date);
    QDate dateToFilter() const;
    void setDateToFilter(const QDate &date);


    Q_INVOKABLE void sort(int column, Qt::SortOrder order);
    TransactionHistory * transactionHistory() const;

signals:
    void paymentIdFilterChanged();
    void dateFromFilterChanged();
    void dateToFilterChanged();

protected:
    // QSortFilterProxyModel overrides
    virtual bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;
    virtual bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const;


private:
    enum DateScopeIndex {
        From = 0,
        To   = 1
    };

    QVariant filterValue(int role);
    void setFilterValue(int role, const QVariant &filterValue);
    QDate dateFromToFilter(DateScopeIndex index) const;
    void setDateFromToFilter(DateScopeIndex index, const QDate &value);

private:
    QMap<int, QVariant> m_filterValues;
};

#endif // TRANSACTIONHISTORYSORTFILTERMODEL_H
