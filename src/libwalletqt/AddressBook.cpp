// Copyright (c) 2014-2019, The Monero Project
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

#include "AddressBook.h"
#include <QDebug>

AddressBook::AddressBook(Monero::AddressBook *abImpl,QObject *parent)
  : QObject(parent), m_addressBookImpl(abImpl)
{
    qDebug(__FUNCTION__);
    getAll();
}

QString AddressBook::errorString() const
{
    return QString::fromStdString(m_addressBookImpl->errorString());
}

int AddressBook::errorCode() const
{
    return m_addressBookImpl->errorCode();
}

QList<Monero::AddressBookRow*> AddressBook::getAll(bool update) const
{
    qDebug(__FUNCTION__);

    emit refreshStarted();

    if(update)
        m_rows.clear();

    if (m_rows.empty()){
        for (auto &abr: m_addressBookImpl->getAll()) {
            m_rows.append(abr);
        }
    }

    emit refreshFinished();
    return m_rows;

}

Monero::AddressBookRow * AddressBook::getRow(int index) const
{
    return m_rows.at(index);
}

bool AddressBook::addRow(const QString &address, const QString &payment_id, const QString &description) const
{
    //  virtual bool addRow(const std::string &dst_addr , const std::string &payment_id, const std::string &description) = 0;
    bool r = m_addressBookImpl->addRow(address.toStdString(), payment_id.toStdString(), description.toStdString());

    if(r)
        getAll(true);

    return r;
}

bool AddressBook::deleteRow(int rowId) const
{
    bool r = m_addressBookImpl->deleteRow(rowId);

    // Fetch new data from wallet2.
    getAll(true);

    return r;
}

quint64 AddressBook::count() const
{
    return m_rows.size();
}

int AddressBook::lookupPaymentID(const QString &payment_id) const
{
    return m_addressBookImpl->lookupPaymentID(payment_id.toStdString());
}
