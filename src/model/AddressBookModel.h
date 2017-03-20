#ifndef ADDRESSBOOKMODEL_H
#define ADDRESSBOOKMODEL_H

#include <QAbstractListModel>

class AddressBook;

class AddressBookModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum AddressBookRowRole {
        AddressBookRole = Qt::UserRole + 1, // for the AddressBookRow object;
        AddressBookAddressRole,
        AddressBookDescriptionRole,
        AddressBookPaymentIdRole,
        AddressBookRowIdRole,
    };
    Q_ENUM(AddressBookRowRole)

    AddressBookModel(QObject *parent, AddressBook * addressBook);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    Q_INVOKABLE bool deleteRow(int row);
    Q_INVOKABLE int lookupPaymentID(const QString &payment_id) const;
    virtual QHash<int, QByteArray> roleNames() const  override;

public slots:
    void startReset();
    void endReset();

private:
    AddressBook * m_addressBook;
};

#endif // ADDRESSBOOKMODEL_H
