#ifndef SUBADDRESSMODEL_H
#define SUBADDRESSMODEL_H

#include <QAbstractListModel>

class Subaddress;

class SubaddressModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum SubaddressRowRole {
        SubaddressAddressRole = Qt::UserRole + 1, // for the SubaddressRow object;
        SubaddressLabelRole,
    };
    Q_ENUM(SubaddressRowRole)

    SubaddressModel(QObject *parent, Subaddress *subaddress);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const  override;

public slots:
    void startReset();
    void endReset();

private:
    Subaddress *m_subaddress;
};

#endif // SUBADDRESSMODEL_H
