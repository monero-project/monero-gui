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

#include <QRegExp>
#include <QMessageBox>
#include <QPixmap>
#include <QTranslator>
#include <QtNetwork>
#include <QTcpSocket>
#include <QtConcurrent/QtConcurrent>
#include <QFuture>
#include <QThread>

#include "I2PZero.h"
#include "qt/utils.h"

#ifdef OS_LINUX
QString I2PZero::pathConfig = QDir::homePath() + ".i2p-zero/base/router.config";
#else
QString I2PZero::pathConfig = QDir::homePath() + ".i2p-zero/base/router.config";
#endif

I2PZero::I2PZero(QString version, QObject *parent) : QObject(parent)
{
    this->m_version = version;
    this->m_timer = new QTimer(this);
    this->detect();
}

void I2PZero::detect(){
    QString err;
    QString pathApp = qApp->applicationDirPath();
    QStringList pathAppDirList = QDir(pathApp).entryList(QStringList() << "*i2p-zero-*", QDir::Dirs);

    if(pathAppDirList.count() == 0) {
        this->updateStatusConsole(QString("Could not find the i2p-zero directory in path \"%1\"").arg(pathApp), 1);
        this->changeState(0);
        return;
    }

    this->m_pathRoot = pathAppDirList.at(0);
    QFileInfo fi(QDir(pathApp), this->m_pathRoot);
    this->m_pathRoot = fi.absoluteFilePath();

#ifdef Q_OS_WIN
    this->m_pathJava = this->m_pathRoot + "\\router\\bin\\java.exe";
#elif defined(Q_OS_UNIX)
    this->m_pathJava = this->m_pathRoot + "/router/bin/java";
#endif

    this->updateStatusConsole(QString("Found i2p-zero: %1").arg(this->m_pathJava));

#ifdef Q_OS_WIN
    this->m_pathKeytool = this->m_pathRoot + "\\router\\bin\\keytool.exe";
#elif defined(Q_OS_UNIX)
    this->m_pathKeytool = this->m_pathRoot + "/router/bin/keytool";
#endif

    this->available = true;
}

bool I2PZero::running()
{
    QString resp = this->sendCommandString("version");
    return resp.startsWith("i2p-zero ");
}

bool I2PZero::start()
{
    QString err;
    if(this->m_state >= 2){
        this->updateStatusConsole("proc start error: already starting.");
        return false;
    }

    if(this->running()){
        this->changeState(3);
        this->startWatcher();
        return true;
    }

    // prepare command line arguments and pass to monerod
    QStringList arguments;
    arguments << "-cp";
    arguments << QString("%1/i2p.base/jbigi.jar").arg(this->m_pathRoot);
    arguments << "-m";
    arguments << "org.getmonero.i2p.zero";

    this->updateStatusConsole("proc starting: " + arguments.join(" "));

    this->m_i2p = new QProcess();
    this->changeState(2);

    connect(this->m_i2p, SIGNAL(readyReadStandardOutput()), this, SLOT(printOutput()));
    connect(this->m_i2p, SIGNAL(readyReadStandardError()), this, SLOT(printError()));

    bool started = this->m_i2p->startDetached(this->m_pathJava, arguments);
    connect(this->m_i2p, SIGNAL(stateChanged(QProcess::ProcessState)), this, SLOT(processStateChanged(QProcess::ProcessState)));

    if(!started) {
        this->updateStatusConsole("Daemon start error: " + this->m_i2p->errorString());
        this->changeState(0);
        return false;
    }

    this->startWatcher();
    return true;
}

void I2PZero::updateLoop()
{
    QString err;
    if(this->m_state <= 1){  // error, stop loop
        this->stop();
        return;
    }

    // Retrieve tunnel listing
    QString data = this->sendCommandString("all.list");
    if(data.isEmpty()){
        if(this->m_starting <= 2){
            this->m_starting += 1;
            return;
        }

        this->updateStatusConsole("Could not fetch tunnel listing: \"all.list\"", 1);
        this->changeState(0);
        return;
    }

    // Valid json document?
    QJsonDocument doc = QJsonDocument::fromJson(data.toUtf8());
    QString jsonString = doc.toJson(QJsonDocument::Indented);
    if (jsonString.isEmpty()){
        this->updateStatusConsole("Bad JSON", 1);
        this->changeState(0);
        return;
    }

    // Got tunnel(s)?
    QJsonObject docobj = doc.object();
    QJsonArray array = docobj["tunnels"].toArray();
    if(array.isEmpty()){
        this->createSocksPort();
        return;
    }

    // Got the right tunnel(s)?
    QList<TunnelStruct> list;
    foreach (const QJsonValue & value, array) {
        QJsonObject obj = value.toObject();

        TunnelStruct entry;
        entry.type = obj["type"].toString();
        entry.state = obj["state"].toString();
        entry.port = obj["port"].toString().toInt();  // ints are strings in I2PZero JSON
        list.append(entry);

        // detect socks port
        if (entry.port == this->m_i2pSocksPort && entry.type == "socks"){
            if(entry.state == "opening" && this->m_state != 4){
                this->changeState(4);
            } else if(entry.state == "open" && this->m_state != 5){
                this->changeState(5);
            }
        }
    }

    if(this->m_state == 3) {
        this->createSocksPort();
    }
}

bool I2PZero::createSocksPort()
{
    QString err;
    this->updateStatusConsole(QString("Creating socks port %1").arg(this->m_i2pSocksPort));

    if(this->sendCommandString(QString("socks.create %1").arg(this->m_i2pSocksPort)) != "OK") {
        this->updateStatusConsole(QString("Failed to execute \"socks.create %1\"").arg(this->m_i2pSocksPort), 1);
        this->changeState(0);
        return false;
    }

    this->changeState(4);
    return true;
}

QString I2PZero::sendCommandString(const QString &cmd)
{
    QTcpSocket socket;
    socket.connectToHost("127.0.0.1", 8051);
    if (!socket.waitForConnected(1000)) {
        this->updateStatusConsole("Timeout connecting to 127.0.0.1:8051", 1);
        return "";
    }

    socket.write(QByteArray(QString("%1%2").arg(cmd, "\n").toUtf8()));
    socket.waitForBytesWritten(1000);

    QByteArray array;
    while(!array.contains('\n')) {
        socket.waitForReadyRead();
        array += socket.readAll();
    }

    QString cmdString = QTextCodec::codecForMib(106)->toUnicode(array);  // UTF-8
    return cmdString.trimmed();
}

void I2PZero::startWatcher()
{
    if(!this->m_timer->isActive()) {
        connect(this->m_timer, &QTimer::timeout, this, QOverload<>::of(&I2PZero::updateLoop));
        this->m_timer->start(3000);
        this->updateStatusConsole("Watcher started");
    }
}

bool I2PZero::stop()
{
    this->updateStatusConsole("Stopping");

    if(this->m_timer != nullptr && this->m_timer->isActive()) {
        this->m_timer->stop();
        this->m_timer->disconnect();
    }

    if(this->m_i2p != nullptr && this->m_i2p->pid() > 0){
        this->m_i2p->kill();
        delete this->m_i2p;
        this->m_i2p = nullptr;
    }

    if(this->m_state != 0)
        this->changeState(1);

    return true;
}

void I2PZero::processStateChanged(QProcess::ProcessState state)
{
    this->updateStatusConsole("proc state change: " + state);
    if (state == QProcess::NotRunning) {
        this->changeState(1);
    }
}

void I2PZero::printOutput()
{
    QByteArray byteArray = this->m_i2p->readAllStandardOutput();
    QStringList strLines = QString(byteArray).split("\n");

    foreach (QString line, strLines) {
        emit i2pConsoleUpdated(line);
        this->updateStatusConsole(QString("proc stdout: %1").arg(line));
    }
}

void I2PZero::printError()
{
    QByteArray byteArray = this->m_i2p->readAllStandardError();
    QStringList strLines = QString(byteArray).split("\n");

    foreach (QString line, strLines) {
        emit i2pConsoleUpdated(line);
        this->updateStatusConsole(QString("proc stderr: %1").arg(line), 1);
    }
}

/**
    I2P status console for QML
    @param message: string
    @param status: 0: debug, 1: error
    @return
*/
void I2PZero::updateStatusConsole(QString message, int status)
{
    QString msg = QString("I2PZero: %1").arg(message);
    if(status == 0) qDebug() << msg;
    else if(status == 1) {
        this->m_errorString = message;
        qCritical() << msg;
    };
    this->m_statusConsole += QString("[+] %1\n").arg(message);
    emit statusConsoleChanged();
}

void I2PZero::updateStatusConsole(QString message)
{
    return this->updateStatusConsole(std::move(message), 0);
}

void I2PZero::changeState(int state){
    this->m_state = state;
    emit stateChanged();

    switch(state) {
        case 0:
            this->m_stateDescription = QString("Error");
            this->m_starting = 0;
            break;
        case 1:
            this->m_stateDescription = QString("Idle");
            break;
        case 2:
            this->m_stateDescription = QString("Booting");
            break;
        case 3:
            this->m_stateDescription = QString("Running");
            break;
        case 4:
            this->m_stateDescription = QString("Tunnel configured");
            break;
        case 5:
            this->m_stateDescription = QString("Ready");
            break;
        default:
            break;
    }

    this->updateStatusConsole(this->m_stateDescription);
}

I2PZero::~I2PZero()
{
    int i = 0;
}
