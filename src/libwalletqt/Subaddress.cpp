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

#include "Subaddress.h"
#include <QDebug>

Subaddress::Subaddress(Monero::Subaddress *subaddressImpl, QObject *parent)
  : QObject(parent), m_subaddressImpl(subaddressImpl)
{
    getAll();
}

void Subaddress::getAll() const
{
    emit refreshStarted();

    {
        QWriteLocker locker(&m_lock);

        m_rows.clear();
        for (auto &row: m_subaddressImpl->getAll()) {
            m_rows.append(row);
        }
    }

    emit refreshFinished();
}

bool Subaddress::getRow(int index, std::function<void (Monero::SubaddressRow &row)> callback) const
{
    QReadLocker locker(&m_lock);

    if (index < 0 || index >= m_rows.size())
    {
        return false;
    }

    callback(*m_rows.value(index));
    return true;
}

void Subaddress::addRow(quint32 accountIndex, const QString &label) const
{
    m_subaddressImpl->addRow(accountIndex, label.toStdString());
    getAll();
}

void Subaddress::setLabel(quint32 accountIndex, quint32 addressIndex, const QString &label) const
{
    m_subaddressImpl->setLabel(accountIndex, addressIndex, label.toStdString());
    getAll();
}

void Subaddress::refresh(quint32 accountIndex) const
{
    try
    {
        m_subaddressImpl->refresh(accountIndex);
    }
    catch (const std::exception &e)
    {
        qCritical() << "Failed to refresh account" << accountIndex << "subaddresses:" << e.what();
    }
    getAll();
}

quint64 Subaddress::count() const
{
    QReadLocker locker(&m_lock);

    return m_rows.size();
}
