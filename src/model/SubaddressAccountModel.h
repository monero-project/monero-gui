#ifndef SUBADDRESSACCOUNTMODEL_H
#define SUBADDRESSACCOUNTMODEL_H

#include <QAbstractListModel>

class SubaddressAccount;

class SubaddressAccountModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum SubaddressAccountRowRole {
        SubaddressAccountRole = Qt::UserRole + 1, // for the SubaddressAccountRow object;
        SubaddressAccountAddressRole,
        SubaddressAccountLabelRole,
        SubaddressAccountBalanceRole,
        SubaddressAccountUnlockedBalanceRole,
    };
    Q_ENUM(SubaddressAccountRowRole)

    SubaddressAccountModel(QObject *parent, SubaddressAccount *subaddressAccount);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const  override;

public slots:
    void startReset();
    void endReset();

private:
    SubaddressAccount *m_subaddressAccount;
};

#endif // SUBADDRESSACCOUNTMODEL_H
