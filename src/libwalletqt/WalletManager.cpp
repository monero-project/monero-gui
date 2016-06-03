#include "WalletManager.h"
#include "Wallet.h"
#include "wallet/wallet2_api.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QDebug>
#include <QUrl>

WalletManager * WalletManager::m_instance = nullptr;





WalletManager *WalletManager::instance()
{
    if (!m_instance) {
        m_instance = new WalletManager;
    }
    // Checking linkage (doesn't work, TODO: have every dependencies linked statically into libwallet)
    Bitmonero::WalletManager * wallet_manager_impl = Bitmonero::WalletManagerFactory::getWalletManager();

    return m_instance;
}

Wallet *WalletManager::createWallet(const QString &path, const QString &password,
                                    const QString &language)
{
    QFileInfo fi(path);
    if (fi.exists()) {
        qCritical("%s: already exists", __FUNCTION__);
        // TODO: set error and error string
        // return nullptr;
    }
    Wallet * wallet = new Wallet(path, password, language);
    return wallet;
}

Wallet *WalletManager::openWallet(const QString &path, const QString &language, const QString &password)
{
    QFileInfo fi(path);
    if (fi.exists()) {
        qCritical("%s: not exists", __FUNCTION__);
        // TODO: set error and error string
        // return nullptr;
    }
    // TODO: call the libwallet api here;
    Wallet * wallet = new Wallet(path, password, language);

    return wallet;
}

Wallet *WalletManager::recoveryWallet(const QString &path, const QString &memo, const QString &language)
{
    // TODO: call the libwallet api here;

    return nullptr;
}

bool WalletManager::moveWallet(const QString &src, const QString &dst_)
{
    // TODO: move this to libwallet;
    QFile walletFile(src);
    if (!walletFile.exists()) {
        qWarning("%s: source file [%s] doesn't exits", __FUNCTION__,
                 qPrintable(src));
        return false;
    }
    QString dst = QUrl(dst_).toLocalFile();
    QString walletKeysFile = src + ".keys";
    QString walletAddressFile = src + ".address.txt";

    QString dstWalletKeysFile = dst + ".keys";
    QString dstWalletAddressFile = dst + ".address.txt";

    if (!walletFile.rename(dst)) {
        qWarning("Error renaming file: '%s' to '%s' : (%s)",
                 qPrintable(src),
                 qPrintable(dst),
                 qPrintable(walletFile.errorString()));
        return false;
    }
    QFile::rename(walletKeysFile, dstWalletKeysFile);
    QFile::rename(walletAddressFile, dstWalletAddressFile);

    return QFile::exists(dst) && QFile::exists(dstWalletKeysFile)
            && QFile::exists(dstWalletAddressFile);
}

void WalletManager::closeWallet(Wallet *wallet)
{
    delete wallet;
}

QString WalletManager::walletLanguage(const QString &locale)
{
    return "English";
}

int WalletManager::error() const
{
    return 0;
}

QString WalletManager::errorString() const
{
    return tr("Unknown error");
}

WalletManager::WalletManager(QObject *parent) : QObject(parent)
{

}


