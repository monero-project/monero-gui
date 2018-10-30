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
#include "PriceSourceSelectorModel.h"

#include <QDebug>


PriceSourceSelectorModel::PriceSourceSelectorModel(QObject *parent, QList<PriceSource*> available) :
    QAbstractListModel(parent), m_availablePriceSources(available)
{
}

QList<PriceSource*> PriceSourceSelectorModel::availablePriceSources() const
{
    return m_availablePriceSources;
}

QString PriceSourceSelectorModel::getLabelAt(int index) const
{
    QVariant var = this->data(this->index(index), PriceSourceLabelRole);
    if (var.isNull())
        return QString();
    return var.toString();
}

QVariant PriceSourceSelectorModel::data(const QModelIndex &index, int role) const
{
    if (m_availablePriceSources.empty()) {
        qWarning() << __FUNCTION__ << ": No available price sources configured!";
        return QVariant();
    }

    if (index.row() < 0 || index.row() >= m_availablePriceSources.count()) {
        qWarning() << __FUNCTION__ << ": Index " << index.row() <<" OOB for price source selection";
        return QVariant();
    }

    PriceSource * priceSource = m_availablePriceSources.at(index.row());
    Q_ASSERT(priceSource);
    if (!priceSource) {
        qWarning() << __FUNCTION__ << ": internal error: no priceSource for index " << index.row();
        return QVariant();
    }

    QVariant result;
    switch (role) {
    case PriceSourceRole:
        result = QVariant::fromValue(priceSource);
        break;
    case PriceSourceLabelRole:
    case PriceSourceSimpleDropdownRole:
        result = priceSource->label();
        break;
    case PriceSourceUrlRole:
        result = priceSource->baseUrl();
        break;
    case PriceSourceAvailableCurrenciesRole:
        result = QVariant::fromValue(priceSource->currenciesAvailable());
        break;
    default:
        result = priceSource->label();
        break;
    }
    return result;
}

int PriceSourceSelectorModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_availablePriceSources.count();
}

QHash<int, QByteArray> PriceSourceSelectorModel::roleNames() const
{
    static QHash<int, QByteArray> roleNames;
    if (roleNames.empty())
    {
        roleNames.insert(PriceSourceRole, "priceSource");
        roleNames.insert(PriceSourceLabelRole, "label");
        roleNames.insert(PriceSourceSimpleDropdownRole, "column1");
        roleNames.insert(PriceSourceUrlRole, "baseUrl");
        roleNames.insert(PriceSourceAvailableCurrenciesRole, "availableCurrencies");
    }
    return roleNames;
}
