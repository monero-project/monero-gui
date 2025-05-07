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


#ifndef MONERO_GUI_MONEROSETTINGS_H
#define MONERO_GUI_MONEROSETTINGS_H

#include <memory>

#include <QtQml/qqmlparserstatus.h>
#include <QGuiApplication>
#include <QClipboard>
#include <QObject>
#include <QDebug>
#include <qsettings.h>

static const int settingsWriteDelay = 500; // ms

class MoneroSettings : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(QString fileName READ fileName WRITE setFileName FINAL)
    Q_PROPERTY(bool portable READ portable NOTIFY portableChanged)
    Q_PROPERTY(QString portableFolderName READ portableFolderName CONSTANT)
    Q_PROPERTY(bool useI2P READ useI2P WRITE setUseI2P NOTIFY useI2PChanged)
    Q_PROPERTY(bool useBuiltInI2P READ useBuiltInI2P WRITE setUseBuiltInI2P NOTIFY useBuiltInI2PChanged)
    Q_PROPERTY(QString i2pAddress READ i2pAddress WRITE setI2PAddress NOTIFY i2pAddressChanged)
    Q_PROPERTY(int i2pPort READ i2pPort WRITE setI2PPort NOTIFY i2pPortChanged)
    Q_PROPERTY(QString i2pInboundQuantity READ i2pInboundQuantity WRITE setI2PInboundQuantity NOTIFY i2pInboundQuantityChanged)
    Q_PROPERTY(QString i2pOutboundQuantity READ i2pOutboundQuantity WRITE setI2POutboundQuantity NOTIFY i2pOutboundQuantityChanged)
    Q_PROPERTY(bool i2pMixedMode READ i2pMixedMode WRITE setI2PMixedMode NOTIFY i2pMixedModeChanged)

public:
    explicit MoneroSettings(QObject *parent = nullptr);

    QString fileName() const;
    void setFileName(const QString &fileName);
    Q_INVOKABLE bool setPortable(bool enabled);
    Q_INVOKABLE void setWritable(bool enabled);

    static QString portableFolderName();
    static bool portableConfigExists();

    bool useI2P() const;
    void setUseI2P(bool useI2P);

    bool useBuiltInI2P() const;
    void setUseBuiltInI2P(bool useBuiltInI2P);

    QString i2pAddress() const;
    void setI2PAddress(const QString &address);

    int i2pPort() const;
    void setI2PPort(int port);

    QString i2pInboundQuantity() const;
    void setI2PInboundQuantity(const QString &quantity);

    QString i2pOutboundQuantity() const;
    void setI2POutboundQuantity(const QString &quantity);

    bool i2pMixedMode() const;
    void setI2PMixedMode(bool mixedMode);

public slots:
    void _q_propertyChanged();

signals:
    void portableChanged() const;
    void useI2PChanged();
    void useBuiltInI2PChanged();
    void i2pAddressChanged();
    void i2pPortChanged();
    void i2pInboundQuantityChanged();
    void i2pOutboundQuantityChanged();
    void i2pMixedModeChanged();

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
    bool m_useI2P;
    bool m_useBuiltInI2P;
    QString m_i2pAddress;
    int m_i2pPort;
    QString m_i2pInboundQuantity;
    QString m_i2pOutboundQuantity;
    bool m_i2pMixedMode;
};

#endif // MONERO_GUI_MONEROSETTINGS_H
