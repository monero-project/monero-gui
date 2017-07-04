#include "Subaddress.h"
#include <QDebug>

Subaddress::Subaddress(Monero::Subaddress *subaddressImpl, QObject *parent)
  : QObject(parent), m_subaddressImpl(subaddressImpl)
{
    qDebug(__FUNCTION__);
    getAll();
}

QList<Monero::SubaddressRow*> Subaddress::getAll(bool update)
{
    qDebug(__FUNCTION__);

    emit refreshStarted();

    if(update)
        m_rows.clear();

    if (m_rows.empty()){
        for (auto &row: m_subaddressImpl->getAll()) {
            m_rows.append(row);
        }
    }

    emit refreshFinished();
    return m_rows;
}

Monero::SubaddressRow * Subaddress::getRow(int index) const
{
    if (index < 0 || index >= m_rows.size())
        return nullptr;
    return m_rows.at(index);
}

void Subaddress::addRow(quint32 accountIndex, const QString &label)
{
    m_subaddressImpl->addRow(accountIndex, label.toStdString());
    getAll(true);
}

void Subaddress::setLabel(quint32 accountIndex, quint32 addressIndex, const QString &label)
{
    m_subaddressImpl->setLabel(accountIndex, addressIndex, label.toStdString());
    getAll(true);
}

void Subaddress::refresh(quint32 accountIndex)
{
    m_subaddressImpl->refresh(accountIndex);
    getAll(true);
}

quint64 Subaddress::count() const
{
    return m_rows.size();
}
