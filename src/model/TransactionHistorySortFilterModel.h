#ifndef TRANSACTIONHISTORYSORTFILTERMODEL_H
#define TRANSACTIONHISTORYSORTFILTERMODEL_H


#include <QSortFilterProxyModel>
#include <QMap>
#include <QVariant>


class TransactionHistorySortFilterModel: public QSortFilterProxyModel
{
Q_OBJECT
public:
    TransactionHistorySortFilterModel(QObject * parent = nullptr);
    QString paymentIdFilter() const;
    void setPaymentIdFilter(const QString &arg);


    Q_INVOKABLE void sort(int column, Qt::SortOrder order);
protected:
    // QSortFilterProxyModel overrides
    virtual bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;
    virtual bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const;


private:
    QVariant filterValue(int role);
    void setFilterValue(int role, const QVariant &filterValue);

private:
    QMap<int, QVariant> m_filterValues;
};

#endif // TRANSACTIONHISTORYSORTFILTERMODEL_H
