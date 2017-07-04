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

#ifndef SUBADDRESS_H
#define SUBADDRESS_H

#include <wallet/api/wallet2_api.h>
#include <QObject>
#include <QList>
#include <QDateTime>

class Subaddress : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE QList<Monero::SubaddressRow*> getAll(bool update = false) const;
    Q_INVOKABLE Monero::SubaddressRow * getRow(int index) const;
    Q_INVOKABLE void addRow(quint32 accountIndex, const QString &label) const;
    Q_INVOKABLE void setLabel(quint32 accountIndex, quint32 addressIndex, const QString &label) const;
    Q_INVOKABLE void refresh(quint32 accountIndex) const;
    quint64 count() const;

signals:
    void refreshStarted() const;
    void refreshFinished() const;

public slots:

private:
    explicit Subaddress(Monero::Subaddress * subaddressImpl, QObject *parent);
    friend class Wallet;
    Monero::Subaddress * m_subaddressImpl;
    mutable QList<Monero::SubaddressRow*> m_rows;
};

#endif // SUBADDRESS_H
