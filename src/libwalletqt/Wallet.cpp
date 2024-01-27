// Copyright (c) 2014-2024, The Monero Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#include "Wallet.h"

#include <chrono>
#include <stdexcept>
#include <string>
#include <thread>
#include <vector>

#include "PendingTransaction.h"
#include "UnsignedTransaction.h"
#include "TransactionHistory.h"
#include "AddressBook.h"
#include "Subaddress.h"
#include "SubaddressAccount.h"
#include "model/TransactionHistoryModel.h"
#include "model/TransactionHistorySortFilterModel.h"
#include "model/AddressBookModel.h"
#include "model/SubaddressModel.h"
#include "model/SubaddressAccountModel.h"
#include "wallet/api/wallet2_api.h"

#include <QFile>
#include <QDir>
#include <QDebug>
#include <QUrl>
#include <QTimer>
#include <QtConcurrent/QtConcurrent>
#include <QList>
#include <QVector>
#include <QMutexLocker>

#include "qt/ScopeGuard.h"

namespace {
    static const int DAEMON_BLOCKCHAIN_HEIGHT_CACHE_TTL_SECONDS = 5;
    static const int DAEMON_BLOCKCHAIN_TARGET_HEIGHT_CACHE_TTL_SECONDS = 30;
    static const int WALLET_CONNECTION_STATUS_CACHE_TTL_SECONDS = 5;

    static constexpr char ATTRIBUTE_SUBADDRESS_ACCOUNT[] ="gui.subaddress_account";
}

Wallet::Wallet(QObject * parent)
    : Wallet(nullptr, parent)
{
}

QString Wallet::getSeed() const
{
    return QString::fromStdString(m_walletImpl->seed());
}

QString Wallet::getSeedLanguage() const
{
    return QString::fromStdString(m_walletImpl->getSeedLanguage());
}

void Wallet::setSeedLanguage(const QString &lang)
{
    m_walletImpl->setSeedLanguage(lang.toStdString());
}

Wallet::Status Wallet::status() const
{
    return static_cast<Status>(m_walletImpl->status());
}

NetworkType::Type Wallet::nettype() const
{
    return static_cast<NetworkType::Type>(m_walletImpl->nettype());
}


void Wallet::updateConnectionStatusAsync()
{
    m_scheduler.run([this] {
        qDebug() << "updateConnectionStatusAsync current status:" << m_connectionStatus;
        if (m_connectionStatus == Wallet::ConnectionStatus_Disconnected)
        {
            setConnectionStatus(ConnectionStatus_Connecting);
        }
        ConnectionStatus newStatus = static_cast<ConnectionStatus>(m_walletImpl->connected());
        qDebug() << "Newest wallet status:" << newStatus;
        if (m_connectionStatus != newStatus)
        {
            setConnectionStatus(newStatus);
            if (newStatus == ConnectionStatus_Connected)
            {
                startRefresh();
            }
        }
        // Release lock
        m_connectionStatusRunning = false;
        m_connectionStatusTime.restart();
    });
}

Wallet::ConnectionStatus Wallet::connected(bool forceCheck)
{
    if (!m_initialized || m_initializing)
    {
        return ConnectionStatus_Connecting;
    }

    // cache connection status
    if (forceCheck || (m_connectionStatusTime.elapsed() / 1000 > m_connectionStatusTtl && !m_connectionStatusRunning) || m_connectionStatusTime.elapsed() > 30000) {
        qDebug() << "Checking connection status";
        m_connectionStatusRunning = true;
        updateConnectionStatusAsync();
    }

    return m_connectionStatus;
}

bool Wallet::disconnected() const
{
    return m_disconnected;
}

bool Wallet::refreshing() const
{
    return m_refreshing;
}

void Wallet::refreshingSet(bool value)
{
    if (m_refreshing.exchange(value) != value)
    {
        emit refreshingChanged();
    }
}

void Wallet::setConnectionStatus(ConnectionStatus value)
{
    if (m_connectionStatus == value)
    {
        return;
    }

    m_connectionStatus = value;
    emit connectionStatusChanged(value);

    bool disconnected = value != Wallet::ConnectionStatus_Connected;

    if (m_disconnected != disconnected)
    {
        m_disconnected = disconnected;
        emit disconnectedChanged();
    }
}

QString Wallet::getProxyAddress() const
{
    QMutexLocker locker(&m_proxyMutex);
    return m_proxyAddress;
}

void Wallet::setProxyAddress(QString address)
{
    m_scheduler.run([this, address] {
        {
            QMutexLocker locker(&m_proxyMutex);

            if (!m_walletImpl->setProxy(address.toStdString()))
            {
                qCritical() << "failed to set proxy" << address;
            }

            m_proxyAddress = address;
        }
        emit proxyAddressChanged();
    });
}

bool Wallet::synchronized() const
{
    return m_walletImpl->synchronized();
}

QString Wallet::errorString() const
{
    return QString::fromStdString(m_walletImpl->errorString());
}

bool Wallet::setPassword(const QString &password)
{
    return m_walletImpl->setPassword(password.toStdString());
}

QString Wallet::address(quint32 accountIndex, quint32 addressIndex) const
{
    return QString::fromStdString(m_walletImpl->address(accountIndex, addressIndex));
}

QString Wallet::path() const
{
    return QDir::toNativeSeparators(QString::fromStdString(m_walletImpl->path()));
}

void Wallet::storeAsync(const QJSValue &callback, const QString &path /* = "" */)
{
    const auto future = m_scheduler.run(
        [this, path] {
            QMutexLocker locker(&m_asyncMutex);

            return QJSValueList({m_walletImpl->store(path.toStdString())});
        },
        callback);
    if (!future.first)
    {
        QJSValue(callback).call(QJSValueList({false}));
    }
}

bool Wallet::init(const QString &daemonAddress, bool trustedDaemon, quint64 upperTransactionLimit, bool isRecovering, bool isRecoveringFromDevice, quint64 restoreHeight, const QString& proxyAddress)
{
    qDebug() << "init non async";
    if (isRecovering){
        qDebug() << "RESTORING";
        m_walletImpl->setRecoveringFromSeed(true);
    }
    if (isRecoveringFromDevice){
        qDebug() << "RESTORING FROM DEVICE";
        m_walletImpl->setRecoveringFromDevice(true);
    }
    if (isRecovering || isRecoveringFromDevice) {
        m_walletImpl->setRefreshFromBlockHeight(restoreHeight);
    }

    {
        QMutexLocker locker(&m_proxyMutex);

        if (!m_walletImpl->init(daemonAddress.toStdString(), upperTransactionLimit, m_daemonUsername.toStdString(), m_daemonPassword.toStdString(), false, false, proxyAddress.toStdString()))
        {
            return false;
        }


        m_proxyAddress = proxyAddress;
    }
    emit proxyAddressChanged();

    setTrustedDaemon(trustedDaemon);
    return true;
}

void Wallet::setDaemonLogin(const QString &daemonUsername, const QString &daemonPassword)
{
    // store daemon login
    m_daemonUsername = daemonUsername;
    m_daemonPassword = daemonPassword;
}

void Wallet::initAsync(
    const QString &daemonAddress,
    bool trustedDaemon /* = false */,
    quint64 upperTransactionLimit /* = 0 */,
    bool isRecovering /* = false */,
    bool isRecoveringFromDevice /* = false */,
    quint64 restoreHeight /* = 0 */,
    const QString &proxyAddress /* = "" */)
{
    qDebug() << "initAsync: " + daemonAddress;
    m_initializing = true;
    pauseRefresh();
    const auto future = m_scheduler.run([this, daemonAddress, trustedDaemon, upperTransactionLimit, isRecovering, isRecoveringFromDevice, restoreHeight, proxyAddress] {
        m_initialized = init(
            daemonAddress,
            trustedDaemon,
            upperTransactionLimit,
            isRecovering,
            isRecoveringFromDevice,
            restoreHeight,
            proxyAddress);
        m_initializing = false;
        if (m_initialized)
        {
            emit walletCreationHeightChanged();
            qDebug() << "init async finished: " + daemonAddress;
            connected(true);
        }
        else
        {
            qCritical() << "Failed to initialize the wallet";
        }
    });
    if (future.first)
    {
        setConnectionStatus(Wallet::ConnectionStatus_Connecting);
    }
}

bool Wallet::isHwBacked() const
{
    return m_walletImpl->getDeviceType() != Monero::Wallet::Device_Software;
}

bool Wallet::isLedger() const
{
    return m_walletImpl->getDeviceType() == Monero::Wallet::Device_Ledger;
}

bool Wallet::isTrezor() const
{
    return m_walletImpl->getDeviceType() == Monero::Wallet::Device_Trezor;
}

//! create a view only wallet
bool Wallet::createViewOnly(const QString &path, const QString &password) const
{
    // Create path
    QDir d = QFileInfo(path).absoluteDir();
    d.mkpath(d.absolutePath());
    return m_walletImpl->createWatchOnly(path.toStdString(),password.toStdString(),m_walletImpl->getSeedLanguage());
}

bool Wallet::connectToDaemon()
{
    return m_walletImpl->connectToDaemon();
}

void Wallet::setTrustedDaemon(bool arg)
{
    m_walletImpl->setTrustedDaemon(arg);
}

bool Wallet::viewOnly() const
{
    return m_walletImpl->watchOnly();
}

quint64 Wallet::balance() const
{
    return balance(m_currentSubaddressAccount);
}

quint64 Wallet::balance(quint32 accountIndex) const
{
    return m_walletImpl->balance(accountIndex);
}

quint64 Wallet::balanceAll() const
{
    return m_walletImpl->balanceAll();
}

quint64 Wallet::unlockedBalance() const
{
    return unlockedBalance(m_currentSubaddressAccount);
}

quint64 Wallet::unlockedBalance(quint32 accountIndex) const
{
    return m_walletImpl->unlockedBalance(accountIndex);
}

quint64 Wallet::unlockedBalanceAll() const
{
    return m_walletImpl->unlockedBalanceAll();
}

quint32 Wallet::currentSubaddressAccount() const
{
    return m_currentSubaddressAccount;
}
void Wallet::switchSubaddressAccount(quint32 accountIndex)
{
    if (accountIndex < numSubaddressAccounts())
    {
        m_currentSubaddressAccount = accountIndex;
        if (!setCacheAttribute(ATTRIBUTE_SUBADDRESS_ACCOUNT, QString::number(m_currentSubaddressAccount)))
        {
            qWarning() << "failed to set " << ATTRIBUTE_SUBADDRESS_ACCOUNT << " cache attribute";
        }
        m_subaddress->refresh(m_currentSubaddressAccount);
        m_history->refresh(m_currentSubaddressAccount);
        emit currentSubaddressAccountChanged();
    }
}
void Wallet::addSubaddressAccount(const QString& label)
{
    m_walletImpl->addSubaddressAccount(label.toStdString());
    switchSubaddressAccount(numSubaddressAccounts() - 1);
}
quint32 Wallet::numSubaddressAccounts() const
{
    return m_walletImpl->numSubaddressAccounts();
}
quint32 Wallet::numSubaddresses(quint32 accountIndex) const
{
    return m_walletImpl->numSubaddresses(accountIndex);
}
void Wallet::addSubaddress(const QString& label)
{
    m_walletImpl->addSubaddress(currentSubaddressAccount(), label.toStdString());
}
QString Wallet::getSubaddressLabel(quint32 accountIndex, quint32 addressIndex) const
{
    return QString::fromStdString(m_walletImpl->getSubaddressLabel(accountIndex, addressIndex));
}
void Wallet::setSubaddressLabel(quint32 accountIndex, quint32 addressIndex, const QString &label)
{
    m_walletImpl->setSubaddressLabel(accountIndex, addressIndex, label.toStdString());
    emit currentSubaddressAccountChanged();
}
void Wallet::deviceShowAddressAsync(quint32 accountIndex, quint32 addressIndex, const QString &paymentId)
{
    m_scheduler.run([this, accountIndex, addressIndex, paymentId] {
        m_walletImpl->deviceShowAddress(accountIndex, addressIndex, paymentId.toStdString());
        emit deviceShowAddressShowed();
    });
}

void Wallet::refreshHeightAsync()
{
    m_scheduler.run([this] {
        quint64 daemonHeight;
        QPair<bool, QFuture<void>> daemonHeightFuture = m_scheduler.run([this, &daemonHeight] {
            daemonHeight = daemonBlockChainHeight();
        });
        if (!daemonHeightFuture.first)
        {
            return;
        }

        quint64 targetHeight;
        QPair<bool, QFuture<void>> targetHeightFuture = m_scheduler.run([this, &targetHeight] {
            targetHeight = daemonBlockChainTargetHeight();
        });
        if (!targetHeightFuture.first)
        {
            return;
        }

        quint64 walletHeight = blockChainHeight();
        daemonHeightFuture.second.waitForFinished();
        targetHeightFuture.second.waitForFinished();

        emit heightRefreshed(walletHeight, daemonHeight, targetHeight);
    });
}

quint64 Wallet::blockChainHeight() const
{
    return m_walletImpl->blockChainHeight();
}

quint64 Wallet::daemonBlockChainHeight() const
{
    // cache daemon blockchain height for some time (60 seconds by default)

    if (m_daemonBlockChainHeight == 0
            || m_daemonBlockChainHeightTime.elapsed() / 1000 > m_daemonBlockChainHeightTtl) {
        m_daemonBlockChainHeight = m_walletImpl->daemonBlockChainHeight();
        m_daemonBlockChainHeightTime.restart();
    }
    return m_daemonBlockChainHeight;
}

quint64 Wallet::daemonBlockChainTargetHeight() const
{
    if (m_daemonBlockChainTargetHeight <= 1
            || m_daemonBlockChainTargetHeightTime.elapsed() / 1000 > m_daemonBlockChainTargetHeightTtl) {
        m_daemonBlockChainTargetHeight = m_walletImpl->daemonBlockChainTargetHeight();

        // Target height is set to 0 if daemon is synced.
        // Use current height from daemon when target height < current height
        if (m_daemonBlockChainTargetHeight < m_daemonBlockChainHeight){
            m_daemonBlockChainTargetHeight = m_daemonBlockChainHeight;
        }
        m_daemonBlockChainTargetHeightTime.restart();
    }

    return m_daemonBlockChainTargetHeight;
}

bool Wallet::exportKeyImages(const QString& path, bool all)
{
    return m_walletImpl->exportKeyImages(path.toStdString(), all);
}

bool Wallet::importKeyImages(const QString& path)
{
    return m_walletImpl->importKeyImages(path.toStdString());
}

bool Wallet::exportOutputs(const QString& path, bool all) {
    return m_walletImpl->exportOutputs(path.toStdString(), all);
}

bool Wallet::importOutputs(const QString& path) {
    return m_walletImpl->importOutputs(path.toStdString());
}

bool Wallet::scanTransactions(const QVector<QString> &txids)
{
    std::vector<std::string> c;
    for (const auto &v : txids)
    {
        c.push_back(v.toStdString());
    }
    return m_walletImpl->scanTransactions(c);
}

bool Wallet::refresh(bool historyAndSubaddresses /* = true */)
{
    refreshingSet(true);
    const auto cleanup = sg::make_scope_guard([this]() noexcept {
        refreshingSet(false);
    });

    {
        QMutexLocker locker(&m_asyncMutex);

        bool result = m_walletImpl->refresh();
        if (historyAndSubaddresses)
        {
            m_history->refresh(currentSubaddressAccount());
            m_subaddress->refresh(currentSubaddressAccount());
            m_subaddressAccount->getAll();
        }
        if (result)
            emit updated();
        return result;
    }
}

void Wallet::startRefresh()
{
    qDebug() << "Starting refresh";
    m_refreshEnabled = true;
    m_refreshNow = true;
}

void Wallet::pauseRefresh()
{
    qDebug() << "Pausing refresh";
    m_refreshEnabled = false;
}

PendingTransaction *Wallet::createTransaction(
    const QVector<QString> &destinationAddresses,
    const QString &payment_id,
    const QVector<QString> &destinationAmounts,
    quint32 mixin_count,
    PendingTransaction::Priority priority)
{
    std::vector<std::string> destinations;
    for (const auto &address : destinationAddresses) {
        destinations.push_back(address.toStdString());
    }
    std::vector<uint64_t> amounts;
    for (const auto &amount : destinationAmounts) {
        amounts.push_back(Monero::Wallet::amountFromString(amount.toStdString()));
    }
    std::set<uint32_t> subaddr_indices;
    Monero::PendingTransaction *ptImpl = m_walletImpl->createTransactionMultDest(
        destinations,
        payment_id.toStdString(),
        amounts,
        mixin_count,
        static_cast<Monero::PendingTransaction::Priority>(priority),
        currentSubaddressAccount(),
        subaddr_indices);
    PendingTransaction *result = new PendingTransaction(ptImpl, 0);
    return result;
}

void Wallet::createTransactionAsync(
    const QVector<QString> &destinationAddresses,
    const QString &payment_id,
    const QVector<QString> &destinationAmounts,
    quint32 mixin_count,
    PendingTransaction::Priority priority)
{
    m_scheduler.run([this, destinationAddresses, payment_id, destinationAmounts, mixin_count, priority] {
        PendingTransaction *tx = createTransaction(destinationAddresses, payment_id, destinationAmounts, mixin_count, priority);
        emit transactionCreated(tx, destinationAddresses, payment_id, mixin_count);
    });
}

PendingTransaction *Wallet::createTransactionAll(const QString &dst_addr, const QString &payment_id,
                                                 quint32 mixin_count, PendingTransaction::Priority priority)
{
    std::set<uint32_t> subaddr_indices;
    Monero::PendingTransaction * ptImpl = m_walletImpl->createTransaction(
                dst_addr.toStdString(), payment_id.toStdString(), Monero::optional<uint64_t>(), mixin_count,
                static_cast<Monero::PendingTransaction::Priority>(priority), currentSubaddressAccount(), subaddr_indices);
    PendingTransaction * result = new PendingTransaction(ptImpl, this);
    return result;
}

void Wallet::createTransactionAllAsync(const QString &dst_addr, const QString &payment_id,
                               quint32 mixin_count,
                               PendingTransaction::Priority priority)
{
    m_scheduler.run([this, dst_addr, payment_id, mixin_count, priority] {
        PendingTransaction *tx = createTransactionAll(dst_addr, payment_id, mixin_count, priority);
        emit transactionCreated(tx, {dst_addr}, payment_id, mixin_count);
    });
}

PendingTransaction *Wallet::createSweepUnmixableTransaction()
{
    Monero::PendingTransaction * ptImpl = m_walletImpl->createSweepUnmixableTransaction();
    PendingTransaction * result = new PendingTransaction(ptImpl, this);
    return result;
}

void Wallet::createSweepUnmixableTransactionAsync()
{
    m_scheduler.run([this] {
        PendingTransaction *tx = createSweepUnmixableTransaction();
        emit transactionCreated(tx, {""}, "", 0);
    });
}

UnsignedTransaction * Wallet::loadTxFile(const QString &fileName)
{
    qDebug() << "Trying to sign " << fileName;
    Monero::UnsignedTransaction * ptImpl = m_walletImpl->loadUnsignedTx(fileName.toStdString());
    UnsignedTransaction * result = new UnsignedTransaction(ptImpl, m_walletImpl, this);
    return result;
}

bool Wallet::submitTxFile(const QString &fileName) const
{
    qDebug() << "Trying to submit " << fileName;
    if (!m_walletImpl->submitTransaction(fileName.toStdString()))
        return false;
    // import key images
    return m_walletImpl->importKeyImages(fileName.toStdString() + "_keyImages");
}

void Wallet::commitTransactionAsync(PendingTransaction *t)
{
    m_scheduler.run([this, t] {
        auto txIdList = t->txid();  // retrieve before commit
        emit transactionCommitted(t->commit(), t, txIdList);
    });
}

void Wallet::disposeTransaction(PendingTransaction *t)
{
    m_walletImpl->disposeTransaction(t->m_pimpl);
    delete t;
}

void Wallet::disposeTransaction(UnsignedTransaction *t)
{
    delete t;
}

void Wallet::estimateTransactionFeeAsync(
    const QVector<QString> &destinationAddresses,
    const QVector<quint64> &amounts,
    PendingTransaction::Priority priority,
    const QJSValue &callback)
{
    m_scheduler.run(
        [this, destinationAddresses, amounts, priority] {
            if (destinationAddresses.size() != amounts.size())
            {
                return QJSValueList({""});
            }

            std::vector<std::pair<std::string, uint64_t>> destinations;
            destinations.reserve(destinationAddresses.size());
            for (size_t index = 0; index < destinationAddresses.size(); ++index)
            {
                destinations.emplace_back(std::make_pair(destinationAddresses[index].toStdString(), amounts[index]));
            }

            const uint64_t fee = m_walletImpl->estimateTransactionFee(
                destinations,
                static_cast<Monero::PendingTransaction::Priority>(priority));
            return QJSValueList({QString::fromStdString(Monero::Wallet::displayAmount(fee))});
        },
        callback);
}

TransactionHistory *Wallet::history() const
{
    return m_history;
}

TransactionHistorySortFilterModel *Wallet::historyModel() const
{
    if (!m_historyModel) {
        Wallet * w = const_cast<Wallet*>(this);
        m_historyModel = new TransactionHistoryModel(w);
        m_historyModel->setTransactionHistory(this->history());
        m_historySortFilterModel = new TransactionHistorySortFilterModel(w);
        m_historySortFilterModel->setSourceModel(m_historyModel);
        m_historySortFilterModel->setSortRole(TransactionHistoryModel::TransactionBlockHeightRole);
        m_historySortFilterModel->sort(0, Qt::DescendingOrder);
    }

    return m_historySortFilterModel;
}

AddressBook *Wallet::addressBook() const
{
    return m_addressBook;
}

AddressBookModel *Wallet::addressBookModel() const
{

    if (!m_addressBookModel) {
        Wallet * w = const_cast<Wallet*>(this);
        m_addressBookModel = new AddressBookModel(w,m_addressBook);
    }

    return m_addressBookModel;
}

Subaddress *Wallet::subaddress()
{
    return m_subaddress;
}

SubaddressModel *Wallet::subaddressModel()
{
    if (!m_subaddressModel) {
        m_subaddressModel = new SubaddressModel(this, m_subaddress);
    }
    return m_subaddressModel;
}

SubaddressAccount *Wallet::subaddressAccount() const
{
    return m_subaddressAccount;
}

SubaddressAccountModel *Wallet::subaddressAccountModel() const
{
    if (!m_subaddressAccountModel) {
        Wallet * w = const_cast<Wallet*>(this);
        m_subaddressAccountModel = new SubaddressAccountModel(w,m_subaddressAccount);
    }
    return m_subaddressAccountModel;
}

QString Wallet::generatePaymentId() const
{
    return QString::fromStdString(Monero::Wallet::genPaymentId());
}

QString Wallet::integratedAddress(const QString &paymentId) const
{
    return QString::fromStdString(m_walletImpl->integratedAddress(paymentId.toStdString()));
}

QString Wallet::getCacheAttribute(const QString &key) const {
    return QString::fromStdString(m_walletImpl->getCacheAttribute(key.toStdString()));
}

bool Wallet::setCacheAttribute(const QString &key, const QString &val)
{
    return m_walletImpl->setCacheAttribute(key.toStdString(), val.toStdString());
}

bool Wallet::setUserNote(const QString &txid, const QString &note)
{
  return m_walletImpl->setUserNote(txid.toStdString(), note.toStdString());
}

QString Wallet::getUserNote(const QString &txid) const
{
  return QString::fromStdString(m_walletImpl->getUserNote(txid.toStdString()));
}

QString Wallet::getTxKey(const QString &txid) const
{
  return QString::fromStdString(m_walletImpl->getTxKey(txid.toStdString()));
}

void Wallet::getTxKeyAsync(const QString &txid, const QJSValue &callback)
{
    m_scheduler.run([this, txid] {
        return QJSValueList({txid, getTxKey(txid)});
    }, callback);
}

QString Wallet::checkTxKey(const QString &txid, const QString &tx_key, const QString &address)
{
    uint64_t received;
    bool in_pool;
    uint64_t confirmations;
    bool success = m_walletImpl->checkTxKey(txid.toStdString(), tx_key.toStdString(), address.toStdString(), received, in_pool, confirmations);
    std::string result = std::string(success ? "true" : "false") + "|" + QString::number(received).toStdString() + "|" + std::string(in_pool ? "true" : "false") + "|" + QString::number(confirmations).toStdString();
    return QString::fromStdString(result);
}

QString Wallet::getTxProof(const QString &txid, const QString &address, const QString &message) const
{
    std::string result = m_walletImpl->getTxProof(txid.toStdString(), address.toStdString(), message.toStdString());
    if (result.empty())
        result = "error|" + m_walletImpl->errorString();
    return QString::fromStdString(result);
}

void Wallet::getTxProofAsync(const QString &txid, const QString &address, const QString &message, const QJSValue &callback)
{
    m_scheduler.run([this, txid, address, message] {
        return QJSValueList({txid, getTxProof(txid, address, message)});
    }, callback);
}

QString Wallet::checkTxProof(const QString &txid, const QString &address, const QString &message, const QString &signature)
{
    bool good;
    uint64_t received;
    bool in_pool;
    uint64_t confirmations;
    bool success = m_walletImpl->checkTxProof(txid.toStdString(), address.toStdString(), message.toStdString(), signature.toStdString(), good, received, in_pool, confirmations);
    std::string result = std::string(success ? "true" : "false") + "|" + std::string(good ? "true" : "false") + "|" + QString::number(received).toStdString() + "|" + std::string(in_pool ? "true" : "false") + "|" + QString::number(confirmations).toStdString();
    return QString::fromStdString(result);
}

Q_INVOKABLE QString Wallet::getSpendProof(const QString &txid, const QString &message) const
{
    std::string result = m_walletImpl->getSpendProof(txid.toStdString(), message.toStdString());
    if (result.empty())
        result = "error|" + m_walletImpl->errorString();
    return QString::fromStdString(result);
}

void Wallet::getSpendProofAsync(const QString &txid, const QString &message, const QJSValue &callback)
{
    m_scheduler.run([this, txid, message] {
        return QJSValueList({txid, getSpendProof(txid, message)});
    }, callback);
}

Q_INVOKABLE QString Wallet::checkSpendProof(const QString &txid, const QString &message, const QString &signature) const
{
    bool good;
    bool success = m_walletImpl->checkSpendProof(txid.toStdString(), message.toStdString(), signature.toStdString(), good);
    std::string result = std::string(success ? "true" : "false") + "|" + std::string(!success ? m_walletImpl->errorString() : good ? "true" : "false");
    return QString::fromStdString(result);
}

Q_INVOKABLE QString Wallet::getReserveProof(bool all, quint32 account_index, quint64 amount, const QString &message) const
{
    qDebug("Generating reserve proof");
    std::string result = m_walletImpl->getReserveProof(all, account_index, amount, message.toStdString());
    if (result.empty())
        result = "error|" + m_walletImpl->errorString();
    return QString::fromStdString(result);
}

Q_INVOKABLE QString Wallet::checkReserveProof(const QString &address, const QString &message, const QString &signature) const
{
    bool good;
    uint64_t total;
    uint64_t spent;
    bool success = m_walletImpl->checkReserveProof(address.toStdString(), message.toStdString(), signature.toStdString(), good, total, spent);
    std::string result = std::string(success ? "true" : "false") + "|" + std::string(good ? "true" : "false") + "|" + QString::number(total).toStdString() + "|" + QString::number(spent).toStdString();
    return QString::fromStdString(result);
}

QString Wallet::signMessage(const QString &message, bool filename) const
{
  if (filename) {
    QFile file(message);
    uchar *data = NULL;

    try {
      if (!file.open(QIODevice::ReadOnly))
        return "";
      quint64 size = file.size();
      if (size == 0) {
        file.close();
        return QString::fromStdString(m_walletImpl->signMessage(std::string()));
      }
      data = file.map(0, size);
      if (!data) {
        file.close();
        return "";
      }
      std::string signature = m_walletImpl->signMessage(std::string(reinterpret_cast<const char*>(data), size));
      file.unmap(data);
      file.close();
      return QString::fromStdString(signature);
    }
    catch (const std::exception &e) {
      if (data)
        file.unmap(data);
      file.close();
      return "";
    }
  }
  else {
    return QString::fromStdString(m_walletImpl->signMessage(message.toStdString()));
  }
}

bool Wallet::verifySignedMessage(const QString &message, const QString &address, const QString &signature, bool filename) const
{
  if (filename) {
    QFile file(message);
    uchar *data = NULL;

    try {
      if (!file.open(QIODevice::ReadOnly))
        return false;
      quint64 size = file.size();
      if (size == 0) {
        file.close();
        return m_walletImpl->verifySignedMessage(std::string(), address.toStdString(), signature.toStdString());
      }
      data = file.map(0, size);
      if (!data) {
        file.close();
        return false;
      }
      bool ret = m_walletImpl->verifySignedMessage(std::string(reinterpret_cast<const char*>(data), size), address.toStdString(), signature.toStdString());
      file.unmap(data);
      file.close();
      return ret;
    }
    catch (const std::exception &e) {
      if (data)
        file.unmap(data);
      file.close();
      return false;
    }
  }
  else {
    return m_walletImpl->verifySignedMessage(message.toStdString(), address.toStdString(), signature.toStdString());
  }
}
bool Wallet::parse_uri(const QString &uri, QString &address, QString &payment_id, uint64_t &amount, QString &tx_description, QString &recipient_name, QVector<QString> &unknown_parameters, QString &error)
{
   std::string s_address, s_payment_id, s_tx_description, s_recipient_name, s_error;
   std::vector<std::string> s_unknown_parameters;
   bool res= m_walletImpl->parse_uri(uri.toStdString(), s_address, s_payment_id, amount, s_tx_description, s_recipient_name, s_unknown_parameters, s_error);
   if(res)
   {
       address = QString::fromStdString(s_address);
       payment_id = QString::fromStdString(s_payment_id);
       tx_description = QString::fromStdString(s_tx_description);
       recipient_name = QString::fromStdString(s_recipient_name);
       for( const auto &p : s_unknown_parameters )
           unknown_parameters.append(QString::fromStdString(p));
   }
   error = QString::fromStdString(s_error);
   return res;
}

QString Wallet::make_uri(const QString &address, const quint64 &amount, const QString &tx_description, const QString &recipient_name) const
{
    std::string error;
    return QString::fromStdString(m_walletImpl->make_uri(address.toStdString(), "", amount, tx_description.toStdString(), recipient_name.toStdString(), error));
}

bool Wallet::rescanSpent()
{
    QMutexLocker locker(&m_asyncMutex);

    return m_walletImpl->rescanSpent();
}

bool Wallet::useForkRules(quint8 required_version, quint64 earlyBlocks) const
{
    if(m_connectionStatus == Wallet::ConnectionStatus_Disconnected)
        return false;
    try {
        return m_walletImpl->useForkRules(required_version,earlyBlocks);
    } catch (const std::exception &e) {
        qDebug() << e.what();
        return false;
    }
}

void Wallet::setWalletCreationHeight(quint64 height)
{
    m_walletImpl->setRefreshFromBlockHeight(height);
    emit walletCreationHeightChanged();
}

QString Wallet::getDaemonLogPath() const
{
    return QString::fromStdString(m_walletImpl->getDefaultDataDir()) + "/bitmonero.log";
}

QString Wallet::getRing(const QString &key_image)
{
    std::vector<uint64_t> cring;
    if (!m_walletImpl->getRing(key_image.toStdString(), cring))
        return "";
    QString ring = "";
    for (uint64_t out: cring)
    {
        if (!ring.isEmpty())
            ring = ring + " ";
	QString s;
	s.setNum(out);
        ring = ring + s;
    }
    return ring;
}

QString Wallet::getRings(const QString &txid)
{
    std::vector<std::pair<std::string, std::vector<uint64_t>>> crings;
    if (!m_walletImpl->getRings(txid.toStdString(), crings))
        return "";
    QString ring = "";
    for (const auto &cring: crings)
    {
        if (!ring.isEmpty())
            ring = ring + "|";
        ring = ring + QString::fromStdString(cring.first) + " absolute";
        for (uint64_t out: cring.second)
        {
            ring = ring + " ";
	    QString s;
	    s.setNum(out);
            ring = ring + s;
        }
    }
    return ring;
}

bool Wallet::setRing(const QString &key_image, const QString &ring, bool relative)
{
    std::vector<uint64_t> cring;
    QStringList strOuts = ring.split(" ");
    foreach(QString str, strOuts)
    {
        uint64_t out;
	bool ok;
	out = str.toULong(&ok);
	if (ok)
            cring.push_back(out);
    }
    return m_walletImpl->setRing(key_image.toStdString(), cring, relative);
}

void Wallet::segregatePreForkOutputs(bool segregate)
{
    m_walletImpl->segregatePreForkOutputs(segregate);
}

void Wallet::segregationHeight(quint64 height)
{
    m_walletImpl->segregationHeight(height);
}

void Wallet::keyReuseMitigation2(bool mitigation)
{
    m_walletImpl->keyReuseMitigation2(mitigation);
}

void Wallet::onWalletPassphraseNeeded(bool on_device)
{
    emit this->walletPassphraseNeeded(on_device);
}

void Wallet::onPassphraseEntered(const QString &passphrase, bool enter_on_device, bool entry_abort)
{
    if (m_walletListener != nullptr)
    {
        m_walletListener->onPassphraseEntered(passphrase, enter_on_device, entry_abort);
    }
}

Wallet::Wallet(Monero::Wallet *w, QObject *parent)
    : QObject(parent)
    , m_walletImpl(w)
    , m_history(new TransactionHistory(m_walletImpl->history(), this))
    , m_historyModel(nullptr)
    , m_addressBook(new AddressBook(m_walletImpl->addressBook(), this))
    , m_addressBookModel(nullptr)
    , m_daemonBlockChainHeight(0)
    , m_daemonBlockChainHeightTtl(DAEMON_BLOCKCHAIN_HEIGHT_CACHE_TTL_SECONDS)
    , m_daemonBlockChainTargetHeight(0)
    , m_daemonBlockChainTargetHeightTtl(DAEMON_BLOCKCHAIN_TARGET_HEIGHT_CACHE_TTL_SECONDS)
    , m_connectionStatus(Wallet::ConnectionStatus_Disconnected)
    , m_connectionStatusTtl(WALLET_CONNECTION_STATUS_CACHE_TTL_SECONDS)
    , m_disconnected(true)
    , m_initialized(false)
    , m_initializing(false)
    , m_currentSubaddressAccount(0)
    , m_subaddress(new Subaddress(m_walletImpl->subaddress(), this))
    , m_subaddressModel(nullptr)
    , m_subaddressAccount(new SubaddressAccount(m_walletImpl->subaddressAccount(), this))
    , m_subaddressAccountModel(nullptr)
    , m_refreshNow(false)
    , m_refreshEnabled(false)
    , m_refreshing(false)
    , m_scheduler(this)
{
    m_walletListener = new WalletListenerImpl(this);
    m_walletImpl->setListener(m_walletListener);
    m_currentSubaddressAccount = getCacheAttribute(ATTRIBUTE_SUBADDRESS_ACCOUNT).toUInt();
    // start cache timers
    m_connectionStatusTime.start();
    m_daemonBlockChainHeightTime.start();
    m_daemonBlockChainTargetHeightTime.start();
    m_connectionStatusRunning = false;
    m_daemonUsername = "";
    m_daemonPassword = "";

    startRefreshThread();
}

Wallet::~Wallet()
{
    qDebug("~Wallet: Closing wallet");

    pauseRefresh();
    m_walletImpl->stop();
    m_scheduler.shutdownWaitForFinished();

    //Monero::WalletManagerFactory::getWalletManager()->closeWallet(m_walletImpl);
    if(status() == Status_Critical)
        qDebug("Not storing wallet cache");
    else if( m_walletImpl->store(""))
        qDebug("Wallet cache stored successfully");
    else
        qDebug("Error storing wallet cache");
    delete m_walletImpl;
    m_walletImpl = NULL;
    delete m_walletListener;
    m_walletListener = NULL;
    qDebug("m_walletImpl deleted");
}

void Wallet::startRefreshThread()
{
    const auto future = m_scheduler.run([this] {
        constexpr const std::chrono::seconds refreshInterval{10};
        constexpr const std::chrono::milliseconds intervalResolution{100};

        auto last = std::chrono::steady_clock::now();
        while (!m_scheduler.stopping())
        {
            if (m_refreshEnabled)
            {
                const auto now = std::chrono::steady_clock::now();
                const auto elapsed = now - last;
                if (elapsed >= refreshInterval || m_refreshNow)
                {
                    refresh(false);
                    last = std::chrono::steady_clock::now();
                    m_refreshNow = false;
                }
            }

            std::this_thread::sleep_for(intervalResolution);
        }
    });
    if (!future.first)
    {
        throw std::runtime_error("failed to start auto refresh thread");
    }
}
