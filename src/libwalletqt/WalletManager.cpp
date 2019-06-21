// Copyright (c) 2014-2019, The Monero Project
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

#include "WalletManager.h"
#include "Wallet.h"
#include "wallet/api/wallet2_api.h"
#include "zxcvbn-c/zxcvbn.h"
#include "QRCodeImageProvider.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QDebug>
#include <QUrl>
#include <QtConcurrent/QtConcurrent>
#include <QMutex>
#include <QMutexLocker>
#include <QString>

class WalletPassphraseListenerImpl : public  Monero::WalletListener
{
public:
  WalletPassphraseListenerImpl(WalletManager * mgr): m_mgr(mgr), m_wallet(nullptr) {}

  virtual void moneySpent(const std::string &txId, uint64_t amount) override { (void)txId; (void)amount; };
  virtual void moneyReceived(const std::string &txId, uint64_t amount) override { (void)txId; (void)amount; };
  virtual void unconfirmedMoneyReceived(const std::string &txId, uint64_t amount) override { (void)txId; (void)amount; };
  virtual void newBlock(uint64_t height) override { (void) height; };
  virtual void updated() override {};
  virtual void refreshed() override {};

  virtual Monero::optional<std::string> onDevicePassphraseRequest(bool on_device) override
  {
      qDebug() << __FUNCTION__;
      if (on_device) return Monero::optional<std::string>();

      m_mgr->onWalletPassphraseNeeded(m_wallet);

      if (m_mgr->m_passphrase_abort)
      {
        throw std::runtime_error("Passphrase entry abort");
      }

      auto tmpPass = m_mgr->m_passphrase.toStdString();
      m_mgr->m_passphrase = QString::null;

      return Monero::optional<std::string>(tmpPass);
  }

  virtual void onDeviceButtonRequest(uint64_t code) override
  {
    emit m_mgr->deviceButtonRequest(code);
  }

  virtual void onDeviceButtonPressed() override
  {
    emit m_mgr->deviceButtonPressed();
  }

  virtual void onSetWallet(Monero::Wallet * wallet) override
  {
      qDebug() << __FUNCTION__;
      m_wallet = wallet;
  }

private:
  WalletManager * m_mgr;
  Monero::Wallet * m_wallet;
};

WalletManager * WalletManager::m_instance = nullptr;

WalletManager *WalletManager::instance()
{
    if (!m_instance) {
        m_instance = new WalletManager;
    }

    return m_instance;
}

Wallet *WalletManager::createWallet(const QString &path, const QString &password,
                                    const QString &language, NetworkType::Type nettype, quint64 kdfRounds)
{
    QMutexLocker locker(&m_mutex);
    if (m_currentWallet) {
        qDebug() << "Closing open m_currentWallet" << m_currentWallet;
        delete m_currentWallet;
    }
    Monero::Wallet * w = m_pimpl->createWallet(path.toStdString(), password.toStdString(),
                                                  language.toStdString(), static_cast<Monero::NetworkType>(nettype), kdfRounds);
    m_currentWallet  = new Wallet(w);
    return m_currentWallet;
}

Wallet *WalletManager::openWallet(const QString &path, const QString &password, NetworkType::Type nettype, quint64 kdfRounds)
{
    QMutexLocker locker(&m_mutex);
    WalletPassphraseListenerImpl tmpListener(this);

    if (m_currentWallet) {
        qDebug() << "Closing open m_currentWallet" << m_currentWallet;
        delete m_currentWallet;
    }
    qDebug("%s: opening wallet at %s, nettype = %d ",
           __PRETTY_FUNCTION__, qPrintable(path), nettype);

    Monero::Wallet * w =  m_pimpl->openWallet(path.toStdString(), password.toStdString(), static_cast<Monero::NetworkType>(nettype), kdfRounds, &tmpListener);
    w->setListener(nullptr);

    qDebug("%s: opened wallet: %s, status: %d", __PRETTY_FUNCTION__, w->address(0, 0).c_str(), w->status());
    m_currentWallet  = new Wallet(w);

    // move wallet to the GUI thread. Otherwise it wont be emitting signals
    if (m_currentWallet->thread() != qApp->thread()) {
        m_currentWallet->moveToThread(qApp->thread());
    }

    return m_currentWallet;
}

void WalletManager::openWalletAsync(const QString &path, const QString &password, NetworkType::Type nettype, quint64 kdfRounds)
{
    QFuture<Wallet*> future = QtConcurrent::run(this, &WalletManager::openWallet,
                                        path, password, nettype, kdfRounds);
    QFutureWatcher<Wallet*> * watcher = new QFutureWatcher<Wallet*>();

    connect(watcher, &QFutureWatcher<Wallet*>::finished,
            this, [this, watcher]() {
        QFuture<Wallet*> future = watcher->future();
        watcher->deleteLater();
        emit walletOpened(future.result());
    });
    watcher->setFuture(future);
}


Wallet *WalletManager::recoveryWallet(const QString &path, const QString &memo, NetworkType::Type nettype, quint64 restoreHeight, quint64 kdfRounds)
{
    QMutexLocker locker(&m_mutex);
    if (m_currentWallet) {
        qDebug() << "Closing open m_currentWallet" << m_currentWallet;
        delete m_currentWallet;
    }
    Monero::Wallet * w = m_pimpl->recoveryWallet(path.toStdString(), "", memo.toStdString(), static_cast<Monero::NetworkType>(nettype), restoreHeight, kdfRounds);
    m_currentWallet = new Wallet(w);
    return m_currentWallet;
}

Wallet *WalletManager::createWalletFromKeys(const QString &path, const QString &language, NetworkType::Type nettype,
                                            const QString &address, const QString &viewkey, const QString &spendkey,
                                            quint64 restoreHeight, quint64 kdfRounds)
{
    QMutexLocker locker(&m_mutex);
    if (m_currentWallet) {
        qDebug() << "Closing open m_currentWallet" << m_currentWallet;
        delete m_currentWallet;
        m_currentWallet = NULL;
    }
    Monero::Wallet * w = m_pimpl->createWalletFromKeys(path.toStdString(), "", language.toStdString(), static_cast<Monero::NetworkType>(nettype), restoreHeight,
                                                       address.toStdString(), viewkey.toStdString(), spendkey.toStdString(), kdfRounds);
    m_currentWallet = new Wallet(w);
    return m_currentWallet;
}

Wallet *WalletManager::createWalletFromDevice(const QString &path, const QString &password, NetworkType::Type nettype,
                                              const QString &deviceName, quint64 restoreHeight, const QString &subaddressLookahead)
{
    QMutexLocker locker(&m_mutex);
    WalletPassphraseListenerImpl tmpListener(this);

    if (m_currentWallet) {
        qDebug() << "Closing open m_currentWallet" << m_currentWallet;
        delete m_currentWallet;
        m_currentWallet = NULL;
    }
    Monero::Wallet * w = m_pimpl->createWalletFromDevice(path.toStdString(), password.toStdString(), static_cast<Monero::NetworkType>(nettype),
                                                         deviceName.toStdString(), restoreHeight, subaddressLookahead.toStdString(), 1, &tmpListener);
    w->setListener(nullptr);

    m_currentWallet = new Wallet(w);

    // move wallet to the GUI thread. Otherwise it wont be emitting signals
    if (m_currentWallet->thread() != qApp->thread()) {
        m_currentWallet->moveToThread(qApp->thread());
    }

    return m_currentWallet;
}


void WalletManager::createWalletFromDeviceAsync(const QString &path, const QString &password, NetworkType::Type nettype,
                                                const QString &deviceName, quint64 restoreHeight, const QString &subaddressLookahead)
{
  auto lmbd = [=](){
    return this->createWalletFromDevice(path, password, nettype, deviceName, restoreHeight, subaddressLookahead);
  };

  QFuture<Wallet *> future = QtConcurrent::run(lmbd);

  QFutureWatcher<Wallet *> * watcher = new QFutureWatcher<Wallet *>();

  connect(watcher, &QFutureWatcher<Wallet *>::finished,
          this, [this, watcher]() {
        QFuture<Wallet *> future = watcher->future();
        watcher->deleteLater();
        emit walletCreated(future.result());
      });
  watcher->setFuture(future);
}

QString WalletManager::closeWallet()
{
    QMutexLocker locker(&m_mutex);
    QString result;
    if (m_currentWallet) {
        result = m_currentWallet->address(0, 0);
        delete m_currentWallet;
    } else {
        qCritical() << "Trying to close non existing wallet " << m_currentWallet;
        result = "0";
    }
    return result;
}

void WalletManager::closeWalletAsync()
{
    QFuture<QString> future = QtConcurrent::run(this, &WalletManager::closeWallet);
    QFutureWatcher<QString> * watcher = new QFutureWatcher<QString>();

    connect(watcher, &QFutureWatcher<QString>::finished,
            this, [this, watcher]() {
       QFuture<QString> future = watcher->future();
       watcher->deleteLater();
       emit walletClosed(future.result());
    });
    watcher->setFuture(future);
}

bool WalletManager::walletExists(const QString &path) const
{
    return m_pimpl->walletExists(path.toStdString());
}

QStringList WalletManager::findWallets(const QString &path)
{
    std::vector<std::string> found_wallets = m_pimpl->findWallets(path.toStdString());
    QStringList result;
    for (const auto &w : found_wallets) {
        result.append(QString::fromStdString(w));
    }
    return result;
}

QString WalletManager::errorString() const
{
    return tr("Unknown error");
}

quint64 WalletManager::maximumAllowedAmount() const
{
    return Monero::Wallet::maximumAllowedAmount();
}

QString WalletManager::maximumAllowedAmountAsSting() const
{
    return WalletManager::displayAmount(WalletManager::maximumAllowedAmount());
}

QString WalletManager::displayAmount(quint64 amount) const
{
    return QString::fromStdString(Monero::Wallet::displayAmount(amount));
}

quint64 WalletManager::amountFromString(const QString &amount) const
{
    return Monero::Wallet::amountFromString(amount.toStdString());
}

quint64 WalletManager::amountFromDouble(double amount) const
{
    return Monero::Wallet::amountFromDouble(amount);
}

bool WalletManager::paymentIdValid(const QString &payment_id) const
{
    return Monero::Wallet::paymentIdValid(payment_id.toStdString());
}

bool WalletManager::addressValid(const QString &address, NetworkType::Type nettype) const
{
    return Monero::Wallet::addressValid(address.toStdString(), static_cast<Monero::NetworkType>(nettype));
}

bool WalletManager::keyValid(const QString &key, const QString &address, bool isViewKey,  NetworkType::Type nettype) const
{
    std::string error;
    if(!Monero::Wallet::keyValid(key.toStdString(), address.toStdString(), isViewKey, static_cast<Monero::NetworkType>(nettype), error)){
        qDebug() << QString::fromStdString(error);
        return false;
    }
    return true;
}

QString WalletManager::paymentIdFromAddress(const QString &address, NetworkType::Type nettype) const
{
    return QString::fromStdString(Monero::Wallet::paymentIdFromAddress(address.toStdString(), static_cast<Monero::NetworkType>(nettype)));
}

void WalletManager::setDaemonAddressAsync(const QString &address)
{
    QtConcurrent::run([this, address] {
        m_pimpl->setDaemonAddress(address.toStdString());
    });
}

bool WalletManager::connected() const
{
    return m_pimpl->connected();
}

quint64 WalletManager::networkDifficulty() const
{
    return m_pimpl->networkDifficulty();
}

quint64 WalletManager::blockchainHeight() const
{
    return m_pimpl->blockchainHeight();
}

quint64 WalletManager::blockchainTargetHeight() const
{
    return m_pimpl->blockchainTargetHeight();
}

double WalletManager::miningHashRate() const
{
    return m_pimpl->miningHashRate();
}

bool WalletManager::isMining() const
{
    {
        QMutexLocker locker(&m_mutex);
        if (m_currentWallet == nullptr || !m_currentWallet->connected())
        {
            return false;
        }
    }

    return m_pimpl->isMining();
}

void WalletManager::miningStatusAsync() const
{
    QtConcurrent::run([this] {
        emit miningStatus(isMining());
    });
}

bool WalletManager::startMining(const QString &address, quint32 threads, bool backgroundMining, bool ignoreBattery)
{
    if(threads == 0)
        threads = 1;
    return m_pimpl->startMining(address.toStdString(), threads, backgroundMining, ignoreBattery);
}

bool WalletManager::stopMining()
{
    return m_pimpl->stopMining();
}

bool WalletManager::localDaemonSynced() const
{
    return blockchainHeight() > 1 && blockchainHeight() >= blockchainTargetHeight();
}

bool WalletManager::isDaemonLocal(const QString &daemon_address) const
{
    return Monero::Utils::isAddressLocal(daemon_address.toStdString());
}

QString WalletManager::resolveOpenAlias(const QString &address) const
{
    bool dnssec_valid = false;
    std::string res = m_pimpl->resolveOpenAlias(address.toStdString(), dnssec_valid);
    res = std::string(dnssec_valid ? "true" : "false") + "|" + res;
    return QString::fromStdString(res);
}
bool WalletManager::parse_uri(const QString &uri, QString &address, QString &payment_id, uint64_t &amount, QString &tx_description, QString &recipient_name, QVector<QString> &unknown_parameters, QString &error) const
{
    QMutexLocker locker(&m_mutex);
    if (m_currentWallet)
        return m_currentWallet->parse_uri(uri, address, payment_id, amount, tx_description, recipient_name, unknown_parameters, error);
    return false;
}

QVariantMap WalletManager::parse_uri_to_object(const QString &uri) const
{
    QString address;
    QString payment_id;
    uint64_t amount = 0;
    QString tx_description;
    QString recipient_name;
    QVector<QString> unknown_parameters;
    QString error;

    QVariantMap result;
    if (this->parse_uri(uri, address, payment_id, amount, tx_description, recipient_name, unknown_parameters, error)) {
        result.insert("address", address);
        result.insert("payment_id", payment_id);
        result.insert("amount", amount > 0 ? this->displayAmount(amount) : "");
        result.insert("tx_description", tx_description);
        result.insert("recipient_name", recipient_name);
    } else {
        result.insert("error", error);
    }
    
    return result;
}

void WalletManager::setLogLevel(int logLevel)
{
    Monero::WalletManagerFactory::setLogLevel(logLevel);
}

void WalletManager::setLogCategories(const QString &categories)
{
    Monero::WalletManagerFactory::setLogCategories(categories.toStdString());
}

QString WalletManager::urlToLocalPath(const QUrl &url) const
{
    return QDir::toNativeSeparators(url.toLocalFile());
}

QUrl WalletManager::localPathToUrl(const QString &path) const
{
    return QUrl::fromLocalFile(path);
}

#ifndef DISABLE_PASS_STRENGTH_METER
double WalletManager::getPasswordStrength(const QString &password) const
{
    static const char *local_dict[] = {
        "monero", "fluffypony", NULL
    };

    if (!ZxcvbnInit("zxcvbn.dict")) {
        fprintf(stderr, "Failed to open zxcvbn.dict\n");
        return 0.0;
    }
    double e = ZxcvbnMatch(password.toStdString().c_str(), local_dict, NULL);
    ZxcvbnUnInit();
    return e;
}
#endif

bool WalletManager::saveQrCode(const QString &code, const QString &path) const
{
    QSize size;
    // 240 <=> mainLayout.qrCodeSize (Receive.qml)
    return QRCodeImageProvider::genQrImage(code, &size).scaled(size.expandedTo(QSize(240, 240)), Qt::KeepAspectRatio).save(path, "PNG", 100);
}

void WalletManager::checkUpdatesAsync(const QString &software, const QString &subdir) const
{
    QFuture<QString> future = QtConcurrent::run(this, &WalletManager::checkUpdates,
                                        software, subdir);
    QFutureWatcher<QString> * watcher = new QFutureWatcher<QString>();
    connect(watcher, &QFutureWatcher<Wallet*>::finished,
            this, [this, watcher]() {
        QFuture<QString> future = watcher->future();
        watcher->deleteLater();
        qDebug() << "Checking for updates - done";
        emit checkUpdatesComplete(future.result());
    });
    watcher->setFuture(future);
}



QString WalletManager::checkUpdates(const QString &software, const QString &subdir) const
{
  qDebug() << "Checking for updates";
  const std::tuple<bool, std::string, std::string, std::string, std::string> result = Monero::WalletManager::checkUpdates(software.toStdString(), subdir.toStdString());
  if (!std::get<0>(result))
    return QString("");
  return QString::fromStdString(std::get<1>(result) + "|" + std::get<2>(result) + "|" + std::get<3>(result) + "|" + std::get<4>(result));
}

bool WalletManager::clearWalletCache(const QString &wallet_path) const
{

    QString fileName = wallet_path;
    // Make sure wallet file is not .keys
    fileName.replace(".keys","");
    QFile walletCache(fileName);
    QString suffix = ".old_cache";
    QString newFileName = fileName + suffix;

    // create unique file name
    for (int i = 1; QFile::exists(newFileName); i++) {
       newFileName = QString("%1%2.%3").arg(fileName).arg(suffix).arg(i);
    }

    return walletCache.rename(newFileName);
}

WalletManager::WalletManager(QObject *parent) : QObject(parent)
{
    m_pimpl =  Monero::WalletManagerFactory::getWalletManager();
}

void WalletManager::onWalletPassphraseNeeded(Monero::Wallet *)
{
    m_mutex_pass.lock();
    m_passphrase_abort = false;
    emit this->walletPassphraseNeeded();

    m_cond_pass.wait(&m_mutex_pass);
    m_mutex_pass.unlock();
}

void WalletManager::onPassphraseEntered(const QString &passphrase, bool entry_abort)
{
    m_mutex_pass.lock();
    m_passphrase = passphrase;
    m_passphrase_abort = entry_abort;

    m_cond_pass.wakeAll();
    m_mutex_pass.unlock();
}
