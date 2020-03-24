/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
****************************************************************************/
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


#ifndef MONEROSETTINGS_H
#define MONEROSETTINGS_H

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
public:
    explicit MoneroSettings(QObject *parent = nullptr);

    QString fileName() const;
    void setFileName(const QString &fileName);

public slots:
    void _q_propertyChanged();

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

    QHash<const char *, QVariant> m_changedProperties;
    QSettings *m_settings = NULL;
    QString m_fileName = QString("");
    bool m_initialized = false;
    int m_timerId = 0;
};

#endif // MONEROSETTINGS_H
