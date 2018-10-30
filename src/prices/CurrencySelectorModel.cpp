// Copyright (c) 2018, The Monero Project
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
#include "CurrencySelectorModel.h"

#include <QDebug>

CurrencySelectorModel::CurrencySelectorModel(QObject *parent) :
    QAbstractListModel(parent)
{
    m_availableCurrencies = QList<Currency*>();
}

QList<Currency*> CurrencySelectorModel::availableCurrencies() const
{
    return m_availableCurrencies;
}

QString CurrencySelectorModel::getLabelAt(int index) const
{
    QVariant var = this->data(this->index(index), CurrencyLabelRole);
    if (var.isNull())
        return QString();
    return var.toString();
}

QVariant CurrencySelectorModel::data(const QModelIndex &index, int role) const
{
    if (m_availableCurrencies.empty()) {
        qWarning() << __FUNCTION__ << ": Available currencies are empty.";
        return QVariant();
    }
    if (index.row() < 0 || index.row() >= m_availableCurrencies.count()) {
        qWarning() << __FUNCTION__ << ": Currency index " << index.row() << " is OOB.";
        return QVariant();
    }

    Currency * currency = m_availableCurrencies.at(index.row());
    if (!currency) {
        qCritical() << __FUNCTION__ << ": internal error: no currency info for index " << index.row();
        return QVariant();
    }

    QVariant result;
    switch (role) {
    case CurrencyRole:
        result = QVariant::fromValue(currency);
        break;
    case CurrencyLabelRole:
    case CurrencySimpleDropdownRole:
        result = currency->label();
        break;
    case CurrencySymbolRole:
        result = currency->symbol();
        break;
    default:
        result = currency->label();
        break;
    }

    return result;
}

int CurrencySelectorModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_availableCurrencies.count();
}

QHash<int, QByteArray> CurrencySelectorModel::roleNames() const
{
    static QHash<int, QByteArray> roleNames;
    if (roleNames.empty())
    {
        roleNames.insert(CurrencyRole, "currency");
        roleNames.insert(CurrencyLabelRole, "label");
        roleNames.insert(CurrencySymbolRole, "symbol");
        roleNames.insert(CurrencySimpleDropdownRole, "column1");
    }
    return roleNames;
}

void CurrencySelectorModel::setAvailableCurrencies(QList<Currency*> currencies)
{
    beginResetModel();
    m_availableCurrencies = QList<Currency*>(currencies);
    endResetModel();
    emit availableCurrenciesChanged();
}
