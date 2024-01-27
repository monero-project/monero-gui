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

#include "UnsignedTransaction.h"
#include <QVector>
#include <QDebug>

UnsignedTransaction::Status UnsignedTransaction::status() const
{
    return static_cast<Status>(m_pimpl->status());
}

QString UnsignedTransaction::errorString() const
{
    return QString::fromStdString(m_pimpl->errorString());
}

quint64 UnsignedTransaction::amount(size_t index) const
{
    std::vector<uint64_t> arr = m_pimpl->amount();
    if(index > arr.size() - 1)
        return 0;
    return arr[index];
}

quint64 UnsignedTransaction::fee(size_t index) const
{
    std::vector<uint64_t> arr = m_pimpl->fee();
    if(index > arr.size() - 1)
        return 0;
    return arr[index];
}

quint64 UnsignedTransaction::mixin(size_t index) const
{
    std::vector<uint64_t> arr = m_pimpl->mixin();
    if(index > arr.size() - 1)
        return 0;
    return arr[index];
}

quint64 UnsignedTransaction::txCount() const
{
    return m_pimpl->txCount();
}

quint64 UnsignedTransaction::minMixinCount() const
{
    return m_pimpl->minMixinCount();
}

QString UnsignedTransaction::confirmationMessage() const
{
    return QString::fromStdString(m_pimpl->confirmationMessage());
}

QStringList UnsignedTransaction::paymentId() const
{
    QList<QString> list;
    for (const auto &t: m_pimpl->paymentId())
        list.append(QString::fromStdString(t));
    return list;
}

QStringList UnsignedTransaction::recipientAddress() const
{
    QList<QString> list;
    for (const auto &t: m_pimpl->recipientAddress())
        list.append(QString::fromStdString(t));
    return list;
}

bool UnsignedTransaction::sign(const QString &fileName) const
{
    if(!m_pimpl->sign(fileName.toStdString()))
        return false;
    // export key images
    return m_walletImpl->exportKeyImages(fileName.toStdString() + "_keyImages");
}

void UnsignedTransaction::setFilename(const QString &fileName)
{
    m_fileName = fileName;
}

UnsignedTransaction::UnsignedTransaction(Monero::UnsignedTransaction *pt, Monero::Wallet *walletImpl, QObject *parent)
    : QObject(parent), m_pimpl(pt), m_walletImpl(walletImpl)
{

}

UnsignedTransaction::~UnsignedTransaction()
{
    delete m_pimpl;
}
