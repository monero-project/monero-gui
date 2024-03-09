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

#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QMap>
#include <QDebug>
#include <QUrl>
#include <QtConcurrent/QtConcurrent>
#include <QMutex>
#include <QMutexLocker>
#include <QString>
#include "libwalletqt/WalletManager.h"
#include "NetworkType.h"
#include "qt/utils.h"
#include "main/oshelper.h"

#include "KeysFiles.h"


WalletKeysFiles::WalletKeysFiles(const QFileInfo &info, quint8 networkType, QString address)
    : m_fileName(info.fileName())
    , m_modified(info.lastModified().toSecsSinceEpoch())
    , m_path(QDir::toNativeSeparators(info.filePath()))
    , m_networkType(networkType)
    , m_address(std::move(address))
{
}

QString WalletKeysFiles::fileName() const
{
    return m_fileName;
}

qint64 WalletKeysFiles::modified() const
{
    return m_modified;
}

QString WalletKeysFiles::address() const
{
    return m_address;
}

QString WalletKeysFiles::path() const
{
    return m_path;
}

quint8 WalletKeysFiles::networkType() const
{
    return m_networkType;
}


WalletKeysFilesModel::WalletKeysFilesModel(QObject *parent)
    : QAbstractListModel(parent)
{
    this->m_walletKeysFilesModelProxy.setSourceModel(this);
    this->m_walletKeysFilesModelProxy.setSortRole(WalletKeysFilesModel::ModifiedRole);
    this->m_walletKeysFilesModelProxy.setDynamicSortFilter(true);
    this->m_walletKeysFilesModelProxy.sort(0, Qt::DescendingOrder);
}

QSortFilterProxyModel *WalletKeysFilesModel::proxyModel()
{
    return &m_walletKeysFilesModelProxy;
}

void WalletKeysFilesModel::clear()
{
    beginResetModel();
    m_walletKeyFiles.clear();
    endResetModel();
}

void WalletKeysFilesModel::refresh(const QString &moneroAccountsDir)
{
    this->clear();
    this->findWallets(moneroAccountsDir);
}

void WalletKeysFilesModel::findWallets(const QString &moneroAccountsDir)
{
    QDirIterator it(moneroAccountsDir, QDirIterator::Subdirectories);
    while (it.hasNext())
    {
        it.next();

        QFileInfo keysFileinfo = it.fileInfo();

        constexpr const char keysFileExtension[] = "keys";
        if (!keysFileinfo.isFile() || keysFileinfo.suffix() != keysFileExtension)
        {
            continue;
        }

        QString wallet(keysFileinfo.path() + QDir::separator() + keysFileinfo.completeBaseName());
        auto networkTypeAndAddress = OSHelper::getNetworkTypeAndAddressFromFile(wallet);
        quint8 networkType = networkTypeAndAddress.first;
        QString address = networkTypeAndAddress.second;

        this->addWalletKeysFile(WalletKeysFiles(wallet, networkType, std::move(address)));
    }
}

void WalletKeysFilesModel::addWalletKeysFile(const WalletKeysFiles &walletKeysFile)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_walletKeyFiles << walletKeysFile;
    endInsertRows();
}

int WalletKeysFilesModel::rowCount(const QModelIndex & parent) const {
    Q_UNUSED(parent);
    return m_walletKeyFiles.count();
}

QVariant WalletKeysFilesModel::data(const QModelIndex & index, int role) const {
    if (index.row() < 0 || index.row() >= m_walletKeyFiles.count())
        return QVariant();

    const WalletKeysFiles &walletKeyFile = m_walletKeyFiles[index.row()];
    if (role == FileNameRole)
        return walletKeyFile.fileName();
    if (role == ModifiedRole)
        return walletKeyFile.modified();
    else if (role == PathRole)
        return walletKeyFile.path();
    else if (role == NetworkTypeRole)
        return static_cast<uint>(walletKeyFile.networkType());
    else if (role == AddressRole)
        return walletKeyFile.address();
    return QVariant();
}

QHash<int, QByteArray> WalletKeysFilesModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[FileNameRole] = "fileName";
    roles[ModifiedRole] = "modified";
    roles[PathRole] = "path";
    roles[NetworkTypeRole] = "networktype";
    roles[AddressRole] = "address";
    return roles;
}
