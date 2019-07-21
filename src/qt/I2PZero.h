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

#ifndef I2PZERO_H
#define I2PZERO_H

#include <QCoreApplication>
#include <QtNetwork>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QDebug>

class I2PZero : public QObject
{
Q_OBJECT
public:
    I2PZero(QString version, QObject *parent = nullptr);
    ~I2PZero();
    void detect();

    //  0: Error
    //  1: Idle
    //  2: Booting
    //  3: Running
    //  4: Tunnel configured
    //  5: Ready
    static QString pathConfig;  // location to i2p cfg

    Q_PROPERTY(int state MEMBER m_state NOTIFY stateChanged)
    Q_PROPERTY(QString m_stateDescription MEMBER m_stateDescription NOTIFY stateDescriptionChanged)
    Q_PROPERTY(QString errorString MEMBER m_errorString NOTIFY errorStringChanged)
    Q_PROPERTY(bool available MEMBER available NOTIFY availableChanged)
    Q_PROPERTY(QString statusConsole MEMBER m_statusConsole NOTIFY statusConsoleChanged)

public slots:
    Q_INVOKABLE bool start();
    Q_INVOKABLE bool stop();

    //void gotJSON();
    void printOutput();
    void printError();
    void processStateChanged(QProcess::ProcessState m_state);

signals:
    void availableChanged() const;
    void errorStringChanged() const;
    void stateChanged() const;
    void stateDescriptionChanged() const;
    void i2pConsoleUpdated(QString message) const;
    void statusConsoleChanged() const;

private:
    bool running();

    bool createSocksPort();
    bool createServerPort();

    QString sendCommandString(const QString &cmd);

    void updateLoop();
    void changeState(int m_state);
    void startWatcher();

    void updateStatusConsole(QString message, int status);
    void updateStatusConsole(QString message);

    int m_starting = 0;
    bool available = false;
    QTimer *m_timer = nullptr;
    QProcess *m_i2p = nullptr;

    int m_state = 0;
    QString m_stateDescription = QString("Idle");

    QString m_version;
    int m_i2pSocksPort = 31338;
    int m_i2pServerPort = 31339;

    QString m_pathRoot;
    QString m_pathKeytool;
    QString m_pathJava;

    QString m_errorString;
    QString m_statusConsole;
};

struct TunnelStruct {
    int port;
    QString state;
    QString type;
};

#endif // I2PZERO_H
