#include "SubaddressAccount.h"
#include <QDebug>

SubaddressAccount::SubaddressAccount(Monero::SubaddressAccount *subaddressAccountImpl, QObject *parent)
  : QObject(parent), m_subaddressAccountImpl(subaddressAccountImpl)
{
    qDebug(__FUNCTION__);
    getAll();
}

QList<Monero::SubaddressAccountRow*> SubaddressAccount::getAll(bool update) const
{
    qDebug(__FUNCTION__);

    emit refreshStarted();

    if(update)
        m_rows.clear();

    if (m_rows.empty()){
        for (auto &row: m_subaddressAccountImpl->getAll()) {
            m_rows.append(row);
        }
    }

    emit refreshFinished();
    return m_rows;
}

Monero::SubaddressAccountRow * SubaddressAccount::getRow(int index) const
{
    return m_rows.at(index);
}

void SubaddressAccount::addRow(const QString &label) const
{
    m_subaddressAccountImpl->addRow(label.toStdString());
    getAll(true);
}

void SubaddressAccount::setLabel(quint32 accountIndex, const QString &label) const
{
    m_subaddressAccountImpl->setLabel(accountIndex, label.toStdString());
    getAll(true);
}

void SubaddressAccount::refresh() const
{
    m_subaddressAccountImpl->refresh();
    getAll(true);
}

quint64 SubaddressAccount::count() const
{
    return m_rows.size();
}
