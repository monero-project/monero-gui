#ifndef SUBADDRESS_H
#define SUBADDRESS_H

#include <wallet/api/wallet2_api.h>
#include <QObject>
#include <QList>
#include <QDateTime>

class Subaddress : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE QList<Monero::SubaddressRow*> getAll(bool update = false) const;
    Q_INVOKABLE Monero::SubaddressRow * getRow(int index) const;
    Q_INVOKABLE void addRow(quint32 accountIndex, const QString &label) const;
    Q_INVOKABLE void setLabel(quint32 accountIndex, quint32 addressIndex, const QString &label) const;
    Q_INVOKABLE void refresh(quint32 accountIndex) const;
    quint64 count() const;

signals:
    void refreshStarted() const;
    void refreshFinished() const;

public slots:

private:
    explicit Subaddress(Monero::Subaddress * subaddressImpl, QObject *parent);
    friend class Wallet;
    Monero::Subaddress * m_subaddressImpl;
    mutable QList<Monero::SubaddressRow*> m_rows;
};

#endif // SUBADDRESS_H
