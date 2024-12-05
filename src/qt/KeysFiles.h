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

#ifndef KEYSFILES_H
#define KEYSFILES_H

#include <qqmlcontext.h>
#include "libwalletqt/WalletManager.h"
#include "NetworkType.h"
#include <QtCore>

class WalletKeysFiles
{
public:
    WalletKeysFiles(const QFileInfo &info, quint8 networkType, QString address);

    QString fileName() const;
    qint64 modified() const;
    QString path() const;
    quint8 networkType() const;
    QString address() const;

private:
    QString m_fileName;
    qint64 m_modified;
    QString m_path;
    quint8 m_networkType;
    QString m_address;
};

class WalletKeysFilesModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QSortFilterProxyModel *proxyModel READ proxyModel NOTIFY proxyModelChanged)

public:
    enum KeysFilesRoles {
        FileNameRole = Qt::UserRole + 1,
        ModifiedRole,
        PathRole,
        NetworkTypeRole,
        AddressRole
    };

    WalletKeysFilesModel(QObject *parent = 0);

    Q_INVOKABLE void refresh(const QString &moneroAccountsDir);
    Q_INVOKABLE void clear();

    void findWallets(const QString &moneroAccountsDir);
    void addWalletKeysFile(const WalletKeysFiles &walletKeysFile);
    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    QHash<int, QByteArray> roleNames() const;

private:
    QSortFilterProxyModel *proxyModel();

protected:

signals:
    void proxyModelChanged() const;

private:
    QList<WalletKeysFiles> m_walletKeyFiles;

    QSortFilterProxyModel m_walletKeysFilesModelProxy;
};

#endif // KEYSFILES_H
