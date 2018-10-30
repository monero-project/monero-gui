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
#ifndef PRICESOURCESELECTORMODEL_H
#define PRICESOURCESELECTORMODEL_H

#include <QAbstractListModel>
#include <QObject>

#include "PriceSource.h"

class PriceSourceSelectorModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QList<PriceSource*> availablePriceSources READ availablePriceSources NOTIFY availablePriceSourcesChanged)
public:
    enum PriceSourceViewRole {
        PriceSourceRole =  Qt::UserRole + 1,
        PriceSourceLabelRole,
        PriceSourceSimpleDropdownRole,
        PriceSourceUrlRole,
        PriceSourceAvailableCurrenciesRole
    };
    Q_ENUM(PriceSourceViewRole)
    explicit PriceSourceSelectorModel(QObject * parent = nullptr, QList<PriceSource*> available = QList<PriceSource*>());
    QList<PriceSource*> availablePriceSources() const;

    Q_INVOKABLE QString getLabelAt(int index) const;

    virtual QVariant data(const QModelIndex & index, int role) const override;
    virtual int rowCount(const QModelIndex & parent = QModelIndex()) const override;
    virtual QHash<int, QByteArray> roleNames() const  override;

signals:
    void availablePriceSourcesChanged() const;

private:
    friend class PriceManager;
    QList<PriceSource*> m_availablePriceSources;
};

#endif // PRICESOURCESELECTORMODEL_H
