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

#include "oshelper.h"

#include <unordered_set>

#include <QCoreApplication>
#include <QGuiApplication>
#include <QFileDialog>
#include <QScreen>
#include <QStandardPaths>
#include <QTemporaryFile>
#include <QWindow>
#include <QDir>
#include <QDebug>
#include <QDesktopServices>
#include <QFileInfo>
#include <QString>
#include <QUrl>
#ifdef Q_OS_MAC
#include "qt/macoshelper.h"
#endif
#ifdef Q_OS_WIN
#include <shlobj.h>
#include <windows.h>
#endif
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
#include <X11/XKBlib.h>
#undef Bool
#undef KeyPress
#undef KeyRelease
#undef FocusIn
#undef FocusOut
// #undef those Xlib #defines that conflict with QEvent::Type enum
#include "qt/utils.h"
#endif

#include "QR-Code-scanner/Decoder.h"
#include "qt/ScopeGuard.h"
#include "NetworkType.h"

namespace
{

QPixmap screenshot()
{
    std::unordered_set<QWindow *> hidden;
    const QWindowList windows = QGuiApplication::allWindows();
    for (QWindow *window : windows)
    {
        if (window->isVisible())
        {
            hidden.emplace(window);
            window->hide();
        }
    }
    const auto unhide = sg::make_scope_guard([&hidden]() {
        for (QWindow *window : hidden)
        {
            window->show();
        }
    });

    return QGuiApplication::primaryScreen()->grabWindow(0);
}

} // namespace

#if defined(Q_OS_WIN)
bool openFolderAndSelectItem(const QString &filePath)
{
    struct scope {
        ~scope() { ::CoTaskMemFree(pidl); }
        PIDLIST_ABSOLUTE pidl = nullptr;
    } scope;

    SFGAOF flags;
    HRESULT result = ::SHParseDisplayName(filePath.toStdWString().c_str(), nullptr, &scope.pidl, 0, &flags);
    if (result != S_OK)
    {
        qWarning() << "SHParseDisplayName failed" << result << "file path" << filePath;
        return false;
    }

    result = ::SHOpenFolderAndSelectItems(scope.pidl, 0, nullptr, 0);
    if (result != S_OK)
    {
        qWarning() << "SHOpenFolderAndSelectItems failed" << result << "file path" << filePath;
        return false;
    }

    return true;
}
#endif

OSHelper::OSHelper(QObject *parent) : QObject(parent)
{

}

void OSHelper::createDesktopEntry() const
{
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    registerXdgMime();
#endif
}

QString OSHelper::downloadLocation() const
{
    return QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
}

QList<QString> OSHelper::grabQrCodesFromScreen() const
{
    QList<QString> codes;

    try
    {
        const QImage image = screenshot().toImage();
        const std::vector<std::string> decoded = QrDecoder().decode(image);
        std::for_each(decoded.begin(), decoded.end(), [&codes](const std::string &code) {
            codes.push_back(QString::fromStdString(code));
        });
    }
    catch (const std::exception &e)
    {
        qWarning() << e.what();
    }

    return codes;
}

bool OSHelper::openFile(const QString &filePath) const
{
    QString canonicalFilePath = QFileInfo(filePath).canonicalFilePath();
    QUrl url = QUrl::fromLocalFile(canonicalFilePath);
    if (!url.isValid())
    {
        qWarning() << "Malformed file path" << canonicalFilePath << url.errorString();
        return false;
    }
    return QDesktopServices::openUrl(url);
}

bool OSHelper::openContainingFolder(const QString &filePath) const
{
    QString canonicalFilePath = QFileInfo(filePath).canonicalFilePath();
#if defined(Q_OS_WIN)
    if (openFolderAndSelectItem(QDir::toNativeSeparators(canonicalFilePath)))
    {
        return true;
    }
#elif defined(Q_OS_MAC)
    if (MacOSHelper::openFolderAndSelectItem(QUrl::fromLocalFile(canonicalFilePath)))
    {
        return true;
    }
#endif

    QUrl url = QUrl::fromLocalFile(QFileInfo(filePath).canonicalPath());
    if (!url.isValid())
    {
        qWarning() << "Malformed file path" << canonicalFilePath << url.errorString();
        return false;
    }
    return QDesktopServices::openUrl(url);
}

QString OSHelper::openSaveFileDialog(const QString &title, const QString &folder, const QString &filename) const
{
    const QString hint = (folder.isEmpty() ? "" : folder + QDir::separator()) + filename;
    return QFileDialog::getSaveFileName(nullptr, title, hint);
}

QString OSHelper::temporaryFilename() const
{
    QString tempFileName;
    {
        QTemporaryFile f;
        f.open();
        tempFileName = f.fileName();
    }
    return tempFileName;
}

bool OSHelper::removeTemporaryWallet(const QString &fileName) const
{
    // Temporary files should be deleted automatically by default, in case they wouldn't, we delete them manually as well
    bool cache_deleted = QFile::remove(fileName);
    bool address_deleted = QFile::remove(fileName + ".address.txt");
    bool keys_deleted = QFile::remove(fileName +".keys");

    return cache_deleted && address_deleted && keys_deleted;
}

// https://stackoverflow.com/a/3006934
bool OSHelper::isCapsLock() const
{
    // platform dependent method of determining if CAPS LOCK is on
#if defined(Q_OS_WIN) // MS Windows version
    return GetKeyState(VK_CAPITAL) == 1;
#elif defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID) // X11 version
    Display * d = XOpenDisplay((char*)0);
    bool caps_state = false;
    if (d) {
        unsigned n;
        XkbGetIndicatorState(d, XkbUseCoreKbd, &n);
        caps_state = (n & 0x01) == 1;
        XCloseDisplay(d);
    }
    return caps_state;
#elif defined(Q_OS_MAC)
    return MacOSHelper::isCapsLock();
#endif
    return false;
}

QString OSHelper::temporaryPath() const
{
    return QDir::tempPath();
}

bool OSHelper::installed() const
{
#ifdef Q_OS_WIN
    static constexpr const wchar_t installKey[] =
        L"SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Monero GUI Wallet_is1";
    static constexpr const wchar_t installValue[] = L"InstallLocation";

    DWORD size;
    LSTATUS status =
        ::RegGetValueW(HKEY_LOCAL_MACHINE, installKey, installValue, RRF_RT_REG_SZ, nullptr, nullptr, &size);
    if (status == ERROR_FILE_NOT_FOUND)
    {
        return false;
    }
    if (status != ERROR_SUCCESS)
    {
        qCritical() << "RegGetValueW failed (get size)" << status;
        return false;
    }

    std::wstring installLocation;
    installLocation.resize(size / sizeof(std::wstring::value_type));
    size = installLocation.size() * sizeof(std::wstring::value_type);
    status = ::RegGetValueW(
        HKEY_LOCAL_MACHINE,
        installKey,
        installValue,
        RRF_RT_REG_SZ,
        nullptr,
        &installLocation[0],
        &size);
    if (status != ERROR_SUCCESS)
    {
        qCritical() << "RegGetValueW Failed (read)" << status;
        return false;
    }

    const QDir installDir(QString(reinterpret_cast<const QChar *>(&installLocation[0])));
    return installDir == QDir(QCoreApplication::applicationDirPath());
#else
    return false;
#endif
}

std::pair<quint8, QString> OSHelper::getNetworkTypeAndAddressFromFile(const QString &wallet)
{
    quint8 networkType = NetworkType::MAINNET;
    QString address = QString("");
    // attempt to retreive wallet address
    if(QFile::exists(wallet + ".address.txt")){
        QFile file(wallet + ".address.txt");
        file.open(QFile::ReadOnly | QFile::Text);
        QString _address = QString(file.readAll());
        if(!_address.isEmpty()){
            address = _address;
            if(address.startsWith("5") || address.startsWith("7")){
                networkType = NetworkType::STAGENET;
            } else if(address.startsWith("9") || address.startsWith("B")){
                networkType = NetworkType::TESTNET;
            }
        }

        file.close();
    }
    return std::make_pair(networkType, address);
}

quint8 OSHelper::getNetworkTypeFromFile(const QString &keysPath) const
{
    QString walletPath = keysPath;
    if(keysPath.endsWith(".keys")){
        walletPath = keysPath.mid(0,keysPath.length()-5);
    }
    return getNetworkTypeAndAddressFromFile(walletPath).first;
}

void OSHelper::openSeedTemplate() const
{
    QFile::copy(":/wizard/template.pdf", QDir::tempPath() + "/seed_template.pdf");
    openFile(QDir::tempPath() + "/seed_template.pdf");
}
