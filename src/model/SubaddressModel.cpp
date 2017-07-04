#include "SubaddressModel.h"
#include "Subaddress.h"
#include <QDebug>
#include <QHash>
#include <wallet/api/wallet2_api.h>

SubaddressModel::SubaddressModel(QObject *parent, Subaddress *subaddress)
    : QAbstractListModel(parent), m_subaddress(subaddress)
{
    qDebug(__FUNCTION__);
    connect(m_subaddress,SIGNAL(refreshStarted()),this,SLOT(startReset()));
    connect(m_subaddress,SIGNAL(refreshFinished()),this,SLOT(endReset()));

}

void SubaddressModel::startReset(){
    qDebug(__FUNCTION__);
    beginResetModel();
}
void SubaddressModel::endReset(){
    qDebug(__FUNCTION__);
    endResetModel();
}

int SubaddressModel::rowCount(const QModelIndex &parent) const
{
    return m_subaddress->count();
}

QVariant SubaddressModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || (unsigned)index.row() >= m_subaddress->count())
        return {};

    Monero::SubaddressRow * sr = m_subaddress->getRow(index.row());

    QVariant result = "";
    switch (role) {
    case SubaddressAddressRole:
        result = QString::fromStdString(sr->getAddress());
        break;
    case SubaddressLabelRole:
        result = index.row() == 0 ? tr("Primary address") : QString::fromStdString(sr->getLabel());
        break;
    }

    return result;
}

QHash<int, QByteArray> SubaddressModel::roleNames() const
{
    static QHash<int, QByteArray> roleNames;
    if (roleNames.empty())
    {
        roleNames.insert(SubaddressAddressRole, "address");
        roleNames.insert(SubaddressLabelRole, "label");
    }
    return roleNames;
}
