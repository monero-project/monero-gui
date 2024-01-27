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

#include "WalletManager.h"
#include "Wallet.h"
#include "wallet/api/wallet2_api.h"
#include "zxcvbn-c/zxcvbn.h"
#include "QRCodeImageProvider.h"
#include <QClipboard>
#include <QGuiApplication>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QDebug>
#include <QUrl>
#include <QtConcurrent/QtConcurrent>
#include <QMutex>
#include <QMutexLocker>
#include <QString>

#include "qt/updater.h"
#include "qt/ScopeGuard.h"

class WalletPassphraseListenerImpl : public  Monero::WalletListener, public PassphraseReceiver
{
public:
  WalletPassphraseListenerImpl(WalletManager * mgr): m_mgr(mgr), m_phelper(mgr) {}

  virtual void moneySpent(const std::string &txId, uint64_t amount) override { (void)txId; (void)amount; };
  virtual void moneyReceived(const std::string &txId, uint64_t amount) override { (void)txId; (void)amount; };
  virtual void unconfirmedMoneyReceived(const std::string &txId, uint64_t amount) override { (void)txId; (void)amount; };
  virtual void newBlock(uint64_t height) override { (void) height; };
  virtual void updated() override {};
  virtual void refreshed() override {};

  virtual void onPassphraseEntered(const QString &passphrase, bool enter_on_device, bool entry_abort) override
  {
      qDebug() << __FUNCTION__;
      m_phelper.onPassphraseEntered(passphrase, enter_on_device, entry_abort);
  }

  virtual Monero::optional<std::string> onDevicePassphraseRequest(bool & on_device) override
  {
      qDebug() << __FUNCTION__;
      return m_phelper.onDevicePassphraseRequest(on_device);
  }

  virtual void onDeviceButtonRequest(uint64_t code) override
  {
      qDebug() << __FUNCTION__;
      emit m_mgr->deviceButtonRequest(code);
  }

  virtual void onDeviceButtonPressed() override
  {
      qDebug() << __FUNCTION__;
      emit m_mgr->deviceButtonPressed();
  }

private:
  WalletManager * m_mgr;
  PassphraseHelper m_phelper;
};

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
    m_mutex_passphraseReceiver.lock();
    m_passphraseReceiver = &tmpListener;
    m_mutex_passphraseReceiver.unlock();
    const auto cleanup = sg::make_scope_guard([this]() noexcept {
        QMutexLocker passphrase_locker(&m_mutex_passphraseReceiver);
        this->m_passphraseReceiver = nullptr;
    });

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
    m_scheduler.run([this, path, password, nettype, kdfRounds] {
        emit walletOpened(openWallet(path, password, nettype, kdfRounds));
    });
}


Wallet *WalletManager::recoveryWallet(const QString &path, const QString &seed, const QString &seed_offset, NetworkType::Type nettype, quint64 restoreHeight, quint64 kdfRounds)
{
    QMutexLocker locker(&m_mutex);
    if (m_currentWallet) {
        qDebug() << "Closing open m_currentWallet" << m_currentWallet;
        delete m_currentWallet;
    }
    Monero::Wallet * w = m_pimpl->recoveryWallet(path.toStdString(), "", seed.toStdString(), static_cast<Monero::NetworkType>(nettype), restoreHeight, kdfRounds, seed_offset.toStdString());
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
                                              const QString &deviceName, quint64 restoreHeight, const QString &subaddressLookahead, quint64 kdfRounds)
{
    QMutexLocker locker(&m_mutex);
    WalletPassphraseListenerImpl tmpListener(this);
    m_mutex_passphraseReceiver.lock();
    m_passphraseReceiver = &tmpListener;
    m_mutex_passphraseReceiver.unlock();
    const auto cleanup = sg::make_scope_guard([this]() noexcept {
        QMutexLocker passphrase_locker(&m_mutex_passphraseReceiver);
        this->m_passphraseReceiver = nullptr;
    });

    if (m_currentWallet) {
        qDebug() << "Closing open m_currentWallet" << m_currentWallet;
        delete m_currentWallet;
        m_currentWallet = NULL;
    }
    Monero::Wallet * w = m_pimpl->createWalletFromDevice(path.toStdString(), password.toStdString(), static_cast<Monero::NetworkType>(nettype),
                                                         deviceName.toStdString(), restoreHeight, subaddressLookahead.toStdString(), kdfRounds, &tmpListener);
    w->setListener(nullptr);

    m_currentWallet = new Wallet(w);

    // move wallet to the GUI thread. Otherwise it wont be emitting signals
    if (m_currentWallet->thread() != qApp->thread()) {
        m_currentWallet->moveToThread(qApp->thread());
    }

    return m_currentWallet;
}


void WalletManager::createWalletFromDeviceAsync(const QString &path, const QString &password, NetworkType::Type nettype,
                                                const QString &deviceName, quint64 restoreHeight, const QString &subaddressLookahead, quint64 kdfRounds)
{
    m_scheduler.run([this, path, password, nettype, deviceName, restoreHeight, subaddressLookahead, kdfRounds] {
        Wallet *wallet = createWalletFromDevice(path, password, nettype, deviceName, restoreHeight, subaddressLookahead, kdfRounds);
        emit walletCreated(wallet);
    });
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

void WalletManager::closeWalletAsync(const QJSValue& callback)
{
    m_scheduler.run([this] {
        return QJSValueList({closeWallet()});
    }, callback);
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

quint64 WalletManager::maximumAllowedAmount()
{
    return Monero::Wallet::maximumAllowedAmount();
}

QString WalletManager::maximumAllowedAmountAsString() const
{
    return WalletManager::displayAmount(WalletManager::maximumAllowedAmount());
}

QString WalletManager::displayAmount(quint64 amount)
{
    return QString::fromStdString(Monero::Wallet::displayAmount(amount));
}

quint64 WalletManager::amountFromString(const QString &amount)
{
    return Monero::Wallet::amountFromString(amount.toStdString());
}

quint64 WalletManager::amountFromDouble(double amount) const
{
    return Monero::Wallet::amountFromDouble(amount);
}

QString WalletManager::amountsSumFromStrings(const QVector<QString> &amounts)
{
    quint64 sum = 0;
    for (const auto &amountString : amounts)
    {
        const quint64 amount = amountFromString(amountString);
        sum = sum + std::min(maximumAllowedAmount() - sum, amount);
    }
    return QString::number(sum);
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
    m_scheduler.run([this, address] {
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

void WalletManager::miningStatusAsync()
{
    m_scheduler.run([this] {
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
    return daemon_address.isEmpty() ? false : Monero::Utils::isAddressLocal(daemon_address.toStdString());
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
        result.insert("amount", amount > 0 ? displayAmount(amount) : "");
        result.insert("tx_description", tx_description);
        result.insert("recipient_name", recipient_name);

        QVariantMap extra_parameters;
        if (unknown_parameters.size() > 0)
        {
            for (const QString &item : unknown_parameters)
            {
                const auto parsed_item = item.splitRef("=");
                if (parsed_item.size() == 2)
                {
                    extra_parameters.insert(parsed_item[0].toString(), parsed_item[1].toString());
                }
            }
        }
        result.insert("extra_parameters", extra_parameters);
    } else {
        result.insert("error", !error.isEmpty() ? error : tr("Unknown error"));
    }

    return result;
}

QString WalletManager::make_uri(const QString &address, const quint64 &amount, const QString &tx_description, const QString &recipient_name) const
{
    QMutexLocker locker(&m_mutex);
    if (m_currentWallet)
        return m_currentWallet->make_uri(address, amount, tx_description, recipient_name);
    return "";
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

bool WalletManager::saveQrCode(const QString &code, const QString &path) const
{
    QSize size;
    return QRCodeImageProvider::genQrImage(code, &size).scaled(size.expandedTo(QSize(240, 240)), Qt::KeepAspectRatio).save(path, "PNG", 100);
}

void WalletManager::saveQrCodeToClipboard(const QString &code) const
{
    QClipboard *clipboard = QGuiApplication::clipboard();
    QSize size;
    clipboard->setImage(QRCodeImageProvider::genQrImage(code, &size).scaled(size.expandedTo(QSize(240, 240)), Qt::KeepAspectRatio), QClipboard::Clipboard);
    clipboard->setImage(QRCodeImageProvider::genQrImage(code, &size).scaled(size.expandedTo(QSize(240, 240)), Qt::KeepAspectRatio), QClipboard::Selection);
}

void WalletManager::checkUpdatesAsync(
    const QString &software,
    const QString &subdir,
    const QString &buildTag,
    const QString &version)
{
    m_scheduler.run([this, software, subdir, buildTag, version] {
        const auto updateInfo = Monero::WalletManager::checkUpdates(
            software.toStdString(),
            subdir.toStdString(),
            buildTag.toStdString().c_str(),
            version.toStdString().c_str());
        if (!std::get<0>(updateInfo))
        {
            return;
        }

        const QString version = QString::fromStdString(std::get<1>(updateInfo));
        const QByteArray hashFromDns = QByteArray::fromHex(QString::fromStdString(std::get<2>(updateInfo)).toUtf8());
        const QString downloadUrl = QString::fromStdString(std::get<4>(updateInfo));

        try
        {
            const QString binaryFilename = QUrl(downloadUrl).fileName();
            QPair<QString, QString> signers;
            const QString signedHash = Updater().fetchSignedHash(binaryFilename, hashFromDns, signers).toHex();

            qInfo() << "Update found" << version << downloadUrl << "hash" << signedHash << "signed by" << signers;
            emit checkUpdatesComplete(version, downloadUrl, signedHash, signers.first, signers.second);
        }
        catch (const std::exception &e)
        {
            qCritical() << "Failed to fetch and verify signed hash:" << e.what();
        }
    });
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

WalletManager::WalletManager(QObject *parent)
    : QObject(parent)
    , m_passphraseReceiver(nullptr)
    , m_scheduler(this)
{
    m_pimpl =  Monero::WalletManagerFactory::getWalletManager();
}

WalletManager::~WalletManager()
{
    m_scheduler.shutdownWaitForFinished();
}

void WalletManager::onWalletPassphraseNeeded(bool on_device)
{
    emit this->walletPassphraseNeeded(on_device);
}

void WalletManager::onPassphraseEntered(const QString &passphrase, bool enter_on_device, bool entry_abort)
{
    QMutexLocker locker(&m_mutex_passphraseReceiver);
    if (m_passphraseReceiver != nullptr)
    {
        m_passphraseReceiver->onPassphraseEntered(passphrase, enter_on_device, entry_abort);
    }
}

QString WalletManager::proxyAddress() const
{
    QMutexLocker locker(&m_proxyMutex);
    return m_proxyAddress;
}

void WalletManager::setProxyAddress(QString address)
{
    m_scheduler.run([this, address] {
        {
            QMutexLocker locker(&m_proxyMutex);

            if (!m_pimpl->setProxy(address.toStdString()))
            {
                qCritical() << "Failed to set proxy address" << address;
            }

            m_proxyAddress = std::move(address);
        }
        emit proxyAddressChanged();
    });
}
