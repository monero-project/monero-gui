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
