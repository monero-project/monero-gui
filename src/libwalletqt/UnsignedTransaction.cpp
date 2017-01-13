#include "UnsignedTransaction.h"
#include <QVector>
#include <QDebug>

UnsignedTransaction::Status UnsignedTransaction::status() const
{
    return static_cast<Status>(m_pimpl->status());
}

QString UnsignedTransaction::errorString() const
{
    return QString::fromStdString(m_pimpl->errorString());
}

quint64 UnsignedTransaction::amount(int index) const
{
    std::vector<uint64_t> arr = m_pimpl->amount();
    if(index > arr.size() - 1)
        return 0;
    return arr[index];
}

quint64 UnsignedTransaction::fee(int index) const
{
    std::vector<uint64_t> arr = m_pimpl->fee();
    if(index > arr.size() - 1)
        return 0;
    return arr[index];
}

quint64 UnsignedTransaction::mixin(int index) const
{
    std::vector<uint64_t> arr = m_pimpl->mixin();
    if(index > arr.size() - 1)
        return 0;
    return arr[index];
}

quint64 UnsignedTransaction::txCount() const
{
    return m_pimpl->txCount();
}

quint64 UnsignedTransaction::minMixinCount() const
{
    return m_pimpl->minMixinCount();
}

QString UnsignedTransaction::confirmationMessage() const
{
    return QString::fromStdString(m_pimpl->confirmationMessage());
}

QStringList UnsignedTransaction::paymentId() const
{
    QList<QString> list;
    for (const auto &t: m_pimpl->paymentId())
        list.append(QString::fromStdString(t));
    return list;
}

QStringList UnsignedTransaction::recipientAddress() const
{
    QList<QString> list;
    for (const auto &t: m_pimpl->recipientAddress())
        list.append(QString::fromStdString(t));
    return list;
}

bool UnsignedTransaction::sign(const QString &fileName) const
{
    if(!m_pimpl->sign(fileName.toStdString()))
        return false;
    // export key images
    return m_walletImpl->exportKeyImages(fileName.toStdString() + "_keyImages");
}

void UnsignedTransaction::setFilename(const QString &fileName)
{
    m_fileName = fileName;
}

UnsignedTransaction::UnsignedTransaction(Monero::UnsignedTransaction *pt, Monero::Wallet *walletImpl, QObject *parent)
    : QObject(parent), m_pimpl(pt), m_walletImpl(walletImpl)
{

}

UnsignedTransaction::~UnsignedTransaction()
{
    delete m_pimpl;
}
