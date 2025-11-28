/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
****************************************************************************/
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


#ifndef MONEROSETTINGS_H
#define MONEROSETTINGS_H

#include <memory>
#include <QtQml/qqmlparserstatus.h>
#include <QGuiApplication>
#include <QClipboard>
#include <QObject>
#include <QDebug>
#include <qsettings.h>
#include <QStringList>

static const int settingsWriteDelay = 500; // ms

class MoneroSettings : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(QString fileName READ fileName WRITE setFileName FINAL)
    Q_PROPERTY(bool portable READ portable NOTIFY portableChanged)
    Q_PROPERTY(QString portableFolderName READ portableFolderName CONSTANT)
    Q_PROPERTY(QString i2pConnectionMethod READ i2pConnectionMethod WRITE setI2pConnectionMethod NOTIFY i2pConnectionMethodChanged)
    Q_PROPERTY(QStringList i2pTrustedNodes READ i2pTrustedNodes WRITE setI2pTrustedNodes NOTIFY i2pTrustedNodesChanged)
    Q_PROPERTY(int anonymityNetwork READ anonymityNetwork WRITE setAnonymityNetwork NOTIFY anonymityNetworkChanged)
    Q_PROPERTY(QString i2pAddress READ i2pAddress WRITE setI2pAddress NOTIFY i2pAddressChanged)

public:
    explicit MoneroSettings(QObject *parent = nullptr);
    static MoneroSettings *instance(); // Singleton

    QString fileName() const;
    void setFileName(const QString &fileName);
    Q_INVOKABLE bool setPortable(bool enabled);
    Q_INVOKABLE void setWritable(bool enabled);

    bool i2pEnabled() const;
    void setI2pEnabled(bool enabled);

    QString i2pConnectionMethod() const;
    void setI2pConnectionMethod(const QString &value);

    QStringList i2pTrustedNodes() const;
    void setI2pTrustedNodes(const QStringList &value);

    int anonymityNetwork() const;
    void setAnonymityNetwork(int value);
    QString i2pAddress() const;
    void setI2pAddress(const QString &value);

    static QString portableFolderName();
    static bool portableConfigExists();

public slots:
    void _q_propertyChanged();

signals:
    void portableChanged();
    void i2pEnabledChanged();
    void i2pConnectionMethodChanged();
    void i2pTrustedNodesChanged();
    void anonymityNetworkChanged();
    void i2pAddressChanged();

protected:
    void timerEvent(QTimerEvent *event) override;
    void classBegin() override;
    void componentComplete() override;

private:
    QVariant readProperty(const QMetaProperty &property) const;
    void init();
    void reset();
    void load();
    void store();

    bool portable() const;
    static QString portableFilePath();
    std::unique_ptr<QSettings> portableSettings() const;
    std::unique_ptr<QSettings> unportableSettings() const;
    void swap(std::unique_ptr<QSettings> newSettings);

    QHash<const char *, QVariant> m_changedProperties;
    std::unique_ptr<QSettings> m_settings;
    QString m_fileName = QString("");
    bool m_initialized = false;
    bool m_writable = true;
    int m_timerId = 0;

    static MoneroSettings *m_instance;

    QString m_i2pConnectionMethod;
    QStringList m_i2pTrustedNodes;
    int m_anonymityNetwork = 0;
    QString m_i2pAddress;
};

#endif // MONEROSETTINGS_H
