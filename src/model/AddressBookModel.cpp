#include "AddressBookModel.h"
#include "AddressBook.h"
#include <QDebug>
#include <QHash>
#include <wallet/wallet2_api.h>

AddressBookModel::AddressBookModel(QObject *parent, AddressBook *addressBook)
    : QAbstractListModel(parent) , m_addressBook(addressBook)
{
    qDebug(__FUNCTION__);
    connect(m_addressBook,SIGNAL(refreshStarted()),this,SLOT(startReset()));
    connect(m_addressBook,SIGNAL(refreshFinished()),this,SLOT(endReset()));

}

void AddressBookModel::startReset(){
    qDebug(__FUNCTION__);
    beginResetModel();
}
void AddressBookModel::endReset(){
    qDebug(__FUNCTION__);
    endResetModel();
}

int AddressBookModel::rowCount(const QModelIndex &parent) const
{
    return m_addressBook->count();
}

QVariant AddressBookModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    if (index.row() < 0 || (unsigned)index.row() >= m_addressBook->count()) {
        return QVariant();
    }

    Monero::AddressBookRow * ar = m_addressBook->getRow(index.row());

    QVariant result = "";
    switch (role) {
    case AddressBookAddressRole:
        result = QString::fromStdString(ar->getAddress());
        break;
    case AddressBookDescriptionRole:
        result = QString::fromStdString(ar->getDescription());
        break;
    case AddressBookPaymentIdRole:
        result = QString::fromStdString(ar->getPaymentId());
        break;
    case AddressBookRowIdRole:
        // Qt doesnt support size_t overload type casting
        result.setValue(ar->getRowId());
        break;
    }

    return result;
}

bool AddressBookModel::deleteRow(int row)
{
    m_addressBook->deleteRow(row);
}

int AddressBookModel::lookupPaymentID(const QString &payment_id) const
{
    return m_addressBook->lookupPaymentID(payment_id);
}

QHash<int, QByteArray> AddressBookModel::roleNames() const
{
    QHash<int, QByteArray> roleNames = QAbstractListModel::roleNames();
    roleNames.insert(AddressBookAddressRole, "address");
    roleNames.insert(AddressBookPaymentIdRole, "paymentId");
    roleNames.insert(AddressBookDescriptionRole, "description");
    roleNames.insert(AddressBookRowIdRole, "rowId");


    return roleNames;
}
