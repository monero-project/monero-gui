#include "WalletManager.h"
#include "Wallet.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QDebug>
#include <QUrl>

WalletManager * WalletManager::m_instance = nullptr;


namespace {
    bool createFileWrapper(const QString &filename)
    {
        QFile file(filename);
        // qDebug("%s: about to create file: %s", __FUNCTION__, qPrintable(filename));
        bool result = file.open(QIODevice::WriteOnly);
        if (!result ){
            qWarning("%s: error creating file '%s' : '%s'",
                     __FUNCTION__,
                     qPrintable(filename),
                     qPrintable(file.errorString()));
        }
        return result;
    }
}


WalletManager *WalletManager::instance()
{
    if (!m_instance) {
        m_instance = new WalletManager;
    }

    return m_instance;
}

Wallet *WalletManager::createWallet(const QString &path, const QString &password,
                                    const QString &language)
{
    Wallet * wallet = new Wallet(this);
    // Create dummy files for testing
    QFileInfo fi(path);
    QDir tempDir;
    tempDir.mkpath(fi.absolutePath());
    createFileWrapper(path);
    createFileWrapper(path + ".keys");
    createFileWrapper(path + ".address.txt");
    return wallet;
}

Wallet *WalletManager::openWallet(const QString &path, const QString &language)
{
    return nullptr;
}

bool WalletManager::moveWallet(const QString &src, const QString &dst_)
{
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

WalletManager::WalletManager(QObject *parent) : QObject(parent)
{

}


