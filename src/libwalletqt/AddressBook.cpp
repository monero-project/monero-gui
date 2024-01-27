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

#include "AddressBook.h"
#include <QDebug>

AddressBook::AddressBook(Monero::AddressBook *abImpl,QObject *parent)
  : QObject(parent), m_addressBookImpl(abImpl)
{
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

void AddressBook::getAll()
{
    emit refreshStarted();

    {
        QWriteLocker locker(&m_lock);

        m_addresses.clear();
        m_rows.clear();
        for (auto &abr: m_addressBookImpl->getAll()) {
            m_addresses.insert(QString::fromStdString(abr->getAddress()), m_rows.size());
            m_rows.append(abr);
        }
    }

    emit refreshFinished();
}

bool AddressBook::getRow(int index, std::function<void (Monero::AddressBookRow &)> callback) const
{
    QReadLocker locker(&m_lock);

    if (index < 0 || index >= m_rows.size())
    {
        return false;
    }

    callback(*m_rows.value(index));
    return true;
}

bool AddressBook::addRow(const QString &address, const QString &payment_id, const QString &description)
{
    //  virtual bool addRow(const std::string &dst_addr , const std::string &payment_id, const std::string &description) = 0;
    bool result;

    {
        QWriteLocker locker(&m_lock);

        result = m_addressBookImpl->addRow(address.toStdString(), payment_id.toStdString(), description.toStdString());
    }

    if (result)
    {
        getAll();
    }

    return result;
}

bool AddressBook::deleteRow(int rowId)
{
    bool result;

    {
        QWriteLocker locker(&m_lock);

        result = m_addressBookImpl->deleteRow(rowId);
    }

    // Fetch new data from wallet2.
    if (result)
    {
        getAll();
    }

    return result;
}

quint64 AddressBook::count() const
{
    QReadLocker locker(&m_lock);

    return m_rows.size();
}

QString AddressBook::getDescription(const QString &address) const
{
    QReadLocker locker(&m_lock);

    const QMap<QString, size_t>::const_iterator it = m_addresses.find(address);
    if (it == m_addresses.end())
    {
        return {};
    }
    return QString::fromStdString(m_rows.value(*it)->getDescription());
}

void AddressBook::setDescription(int index, const QString &description)
{
     bool result;

     {
         QWriteLocker locker(&m_lock);

         result = m_addressBookImpl->setDescription(index, description.toStdString());
     }

     if (result)
     {
         getAll();
     }
 }
