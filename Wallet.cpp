#include "Wallet.h"
#include <QFile>
#include <QDir>
#include <QDebug>
#include <QUrl>

namespace {
    QString TEST_SEED = "bound class paint gasp task soul forgot past pleasure physical circle "
                        " appear shore bathroom glove women crap busy beauty bliss idea give needle burden";

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

}

struct WalletImpl
{

    QString basename() const;
    void setBasename(const QString &name);

    QString keysName() const;
    QString addressName() const;

//  Bitmonero::Wallet * m_walletImpl;
    QString m_basename;
    QString m_seed;
    QString m_password;
    QString m_language;

    static QString keysName(const QString &basename);
    static QString addressName(const QString &basename);

};


QString WalletImpl::basename() const
{
    return m_basename;
}

void WalletImpl::setBasename(const QString &name)
{
    m_basename = name;
}

QString WalletImpl::keysName() const
{
    return keysName(m_basename);
}

QString WalletImpl::addressName() const
{
    return addressName(m_basename);
}

QString WalletImpl::keysName(const QString &basename)
{
    return basename + ".keys";
}

QString WalletImpl::addressName(const QString &basename)
{
    return basename + ".address.txt";
}


Wallet::Wallet(QObject *parent)
    : QObject(parent)
{

}

QString Wallet::getSeed() const
{
    return m_pimpl->m_seed;
}

QString Wallet::getSeedLanguage() const
{
    return "English";
}

//void Wallet::setSeedLaguage(const QString &lang)
//{
//    // TODO: call libwallet's appropriate method
//}

bool Wallet::setPassword(const QString &password)
{
   // set/change password implies:
   // recovery wallet with existing path, seed and lang
    qDebug("%s: recovering wallet with path=%s, seed=%s, lang=%s and new password=%s",
           __FUNCTION__,
           qPrintable(this->getBasename()),
           qPrintable(this->getSeed()),
           qPrintable(this->getSeedLanguage()),
           qPrintable(password));
    return true;
}

QString Wallet::getPassword() const
{
    return m_pimpl->m_password;
}

bool Wallet::rename(const QString &name)
{

    QString dst = QUrl(name).toLocalFile();

    if (dst.isEmpty())
        dst = name;

    qDebug("%s: renaming '%s' to '%s'",
           __FUNCTION__,
           qPrintable(m_pimpl->basename()),
           qPrintable(dst));

    QString walletKeysFile = m_pimpl->keysName();
    QString walletAddressFile = m_pimpl->addressName();

    QString dstWalletKeysFile = WalletImpl::keysName(dst);
    QString dstWalletAddressFile = WalletImpl::addressName(dst);

    QFile walletFile(this->getBasename());

    if (!walletFile.rename(dst)) {
        qWarning("Error renaming file: '%s' to '%s' : (%s)",
                 qPrintable(m_pimpl->basename()),
                 qPrintable(dst),
                 qPrintable(walletFile.errorString()));
        return false;
    }
    QFile::rename(walletKeysFile, dstWalletKeysFile);
    QFile::rename(walletAddressFile, dstWalletAddressFile);

    bool result = QFile::exists(dst) && QFile::exists(dstWalletKeysFile)
            && QFile::exists(dstWalletAddressFile);

    if (result) {
        m_pimpl->m_basename = dst;
    }

    return result;
}

QString Wallet::getBasename() const
{
    return m_pimpl->basename();
}

int Wallet::error() const
{
    return 0;
}

QString Wallet::errorString() const
{
    return m_pimpl->m_seed;
}

Wallet::Wallet(const QString &path, const QString &password, const QString &language)
{
    m_pimpl = new WalletImpl;
    m_pimpl->m_basename = path;
    m_pimpl->m_password = password;
    m_pimpl->m_language = language;
    m_pimpl->m_seed = TEST_SEED;

    // Create dummy files for testing
    QFileInfo fi(path);
    QDir tempDir;
    tempDir.mkpath(fi.absolutePath());
    createFileWrapper(m_pimpl->basename());
    createFileWrapper(m_pimpl->keysName());
    createFileWrapper(m_pimpl->addressName());
}



