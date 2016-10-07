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
    Q_PROPERTY(double amountFromFilter READ amountFromFilter WRITE setAmountFromFilter NOTIFY amountFromFilterChanged)
    Q_PROPERTY(double amountToFilter READ amountToFilter WRITE setAmountToFilter NOTIFY amountToFilterChanged)
    Q_PROPERTY(TransactionHistory * transactionHistory READ transactionHistory)

public:
    TransactionHistorySortFilterModel(QObject * parent = nullptr);
    //! filtering by payment id
    QString paymentIdFilter() const;
    void setPaymentIdFilter(const QString &arg);

    //! filtering by date (lower bound)
    QDate dateFromFilter() const;
    void setDateFromFilter(const QDate &date);

    //! filtering by to date (upper bound)
    QDate dateToFilter() const;
    void setDateToFilter(const QDate &date);

    //! filtering by amount (lower bound)
    double amountFromFilter() const;
    void setAmountFromFilter(double value);

    //! filtering by amount (upper bound)
    double amountToFilter() const;
    void setAmountToFilter(double value);


    Q_INVOKABLE void sort(int column, Qt::SortOrder order);
    TransactionHistory * transactionHistory() const;

signals:
    void paymentIdFilterChanged();
    void dateFromFilterChanged();
    void dateToFilterChanged();
    void amountFromFilterChanged();
    void amountToFilterChanged();

protected:
    // QSortFilterProxyModel overrides
    virtual bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;
    virtual bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const;


private:
    enum ScopeIndex {
        From = 0,
        To   = 1
    };

    QVariant filterValue(int role);
    void setFilterValue(int role, const QVariant &filterValue);
    QDate dateFromToFilter(ScopeIndex index) const;
    void setDateFromToFilter(ScopeIndex index, const QDate &value);
//    double amountFromToFilter(ScopeIndex index) const;
//    void setAmountFromToFilter(ScopeIndex index, double value);



private:
    QMap<int, QVariant> m_filterValues;
};

#endif // TRANSACTIONHISTORYSORTFILTERMODEL_H
