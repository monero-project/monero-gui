#ifndef SUBADDRESSACCOUNT_H
#define SUBADDRESSACCOUNT_H

#include <wallet/wallet2_api.h>
#include <QObject>
#include <QList>
#include <QDateTime>

class SubaddressAccount : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE QList<Monero::SubaddressAccountRow*> getAll(bool update = false);
    Q_INVOKABLE Monero::SubaddressAccountRow * getRow(int index) const;
    Q_INVOKABLE void addRow(const QString &label);
    Q_INVOKABLE void setLabel(quint32 accountIndex, const QString &label);
    Q_INVOKABLE void refresh();
    quint64 count() const;

signals:
    void refreshStarted() const;
    void refreshFinished() const;

public slots:

private:
    explicit SubaddressAccount(Monero::SubaddressAccount * subaddressAccountImpl, QObject *parent);
    friend class Wallet;
    Monero::SubaddressAccount * m_subaddressAccountImpl;
    QList<Monero::SubaddressAccountRow*> m_rows;
};

#endif // SUBADDRESSACCOUNT_H
