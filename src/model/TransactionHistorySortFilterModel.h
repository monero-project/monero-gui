// Copyright (c) 2014-2024, The Monero Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#ifndef TRANSACTIONHISTORYSORTFILTERMODEL_H
#define TRANSACTIONHISTORYSORTFILTERMODEL_H

#include "TransactionInfo.h"

#include <QSortFilterProxyModel>
#include <QMap>
#include <QVariant>
#include <QDate>


class TransactionHistory;

class TransactionHistorySortFilterModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QString searchFilter READ searchFilter WRITE setSearchFilter NOTIFY searchFilterChanged)
    Q_PROPERTY(QString paymentIdFilter READ paymentIdFilter WRITE setPaymentIdFilter NOTIFY paymentIdFilterChanged)
    Q_PROPERTY(QDate dateFromFilter READ dateFromFilter WRITE setDateFromFilter NOTIFY dateFromFilterChanged)
    Q_PROPERTY(QDate dateToFilter READ dateToFilter WRITE setDateToFilter NOTIFY dateToFilterChanged)
    Q_PROPERTY(double amountFromFilter READ amountFromFilter WRITE setAmountFromFilter NOTIFY amountFromFilterChanged)
    Q_PROPERTY(double amountToFilter READ amountToFilter WRITE setAmountToFilter NOTIFY amountToFilterChanged)
    Q_PROPERTY(int directionFilter READ directionFilter WRITE setDirectionFilter NOTIFY directionFilterChanged)

    Q_PROPERTY(TransactionHistory * transactionHistory READ transactionHistory)

public:
    TransactionHistorySortFilterModel(QObject * parent = nullptr);
    //! filtering by string search
    QString searchFilter() const;
    void setSearchFilter(const QString &arg);

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

    //! filtering by direction
    int directionFilter() const;
    void setDirectionFilter(int value);

    Q_INVOKABLE void sort(int column, Qt::SortOrder order);
    TransactionHistory * transactionHistory() const;

signals:
    void searchFilterChanged();
    void paymentIdFilterChanged();
    void dateFromFilterChanged();
    void dateToFilterChanged();
    void amountFromFilterChanged();
    void amountToFilterChanged();
    void directionFilterChanged();

protected:
    // QSortFilterProxyModel overrides
    virtual bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;
    virtual bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const;


private:
    enum ScopeIndex {
        From = 0,
        To   = 1
    };

private:
    QMap<int, QVariant> m_filterValues;
    QString m_searchString;
};

#endif // TRANSACTIONHISTORYSORTFILTERMODEL_H
