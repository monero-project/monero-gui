#include "SubaddressAccountModel.h"
#include "SubaddressAccount.h"
#include <QDebug>
#include <QHash>
#include <wallet/api/wallet2_api.h>

SubaddressAccountModel::SubaddressAccountModel(QObject *parent, SubaddressAccount *subaddressAccount)
    : QAbstractListModel(parent), m_subaddressAccount(subaddressAccount)
{
    qDebug(__FUNCTION__);
    connect(m_subaddressAccount,SIGNAL(refreshStarted()),this,SLOT(startReset()));
    connect(m_subaddressAccount,SIGNAL(refreshFinished()),this,SLOT(endReset()));
}

void SubaddressAccountModel::startReset(){
    qDebug("SubaddressAccountModel::startReset");
    beginResetModel();
}
void SubaddressAccountModel::endReset(){
    qDebug("SubaddressAccountModel::endReset");
    endResetModel();
}

int SubaddressAccountModel::rowCount(const QModelIndex &parent) const
{
    return m_subaddressAccount->count();
}

QVariant SubaddressAccountModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || (unsigned)index.row() >= m_subaddressAccount->count())
        return {};

    Monero::SubaddressAccountRow * sr = m_subaddressAccount->getRow(index.row());

    QVariant result = "";
    switch (role) {
    case SubaddressAccountAddressRole:
        result = QString::fromStdString(sr->getAddress());
        break;
    case SubaddressAccountLabelRole:
        result = QString::fromStdString(sr->getLabel());
        break;
    case SubaddressAccountBalanceRole:
        result = QString::fromStdString(sr->getBalance());
        break;
    case SubaddressAccountUnlockedBalanceRole:
        result = QString::fromStdString(sr->getUnlockedBalance());
        break;
    }

    return result;
}

QHash<int, QByteArray> SubaddressAccountModel::roleNames() const
{
    static QHash<int, QByteArray> roleNames;
    if (roleNames.empty())
    {
        roleNames.insert(SubaddressAccountAddressRole, "address");
        roleNames.insert(SubaddressAccountLabelRole, "label");
        roleNames.insert(SubaddressAccountBalanceRole, "balance");
        roleNames.insert(SubaddressAccountUnlockedBalanceRole, "unlockedBalance");
    }
    return roleNames;
}
