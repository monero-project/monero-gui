#include "SubaddressAccount.h"
#include <QDebug>

SubaddressAccount::SubaddressAccount(Monero::SubaddressAccount *subaddressAccountImpl, QObject *parent)
  : QObject(parent), m_subaddressAccountImpl(subaddressAccountImpl)
{
    qDebug(__FUNCTION__);
    getAll();
}

QList<Monero::SubaddressAccountRow*> SubaddressAccount::getAll(bool update)
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
    if (index < 0 || index >= m_rows.size())
        return nullptr;
    return m_rows.at(index);
}

void SubaddressAccount::addRow(const QString &label)
{
    m_subaddressAccountImpl->addRow(label.toStdString());
    getAll(true);
}

void SubaddressAccount::setLabel(quint32 accountIndex, const QString &label)
{
    m_subaddressAccountImpl->setLabel(accountIndex, label.toStdString());
    getAll(true);
}

void SubaddressAccount::refresh()
{
    m_subaddressAccountImpl->refresh();
    getAll(true);
}

quint64 SubaddressAccount::count() const
{
    return m_rows.size();
}
