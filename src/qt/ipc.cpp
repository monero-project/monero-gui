#include <QCoreApplication>
#include <QLocalSocket>
#include <QLocalServer>
#include <QtNetwork>
#include <QDebug>

#include "ipc.h"
#include "utils.h"

// Start listening for incoming IPC commands on UDS (Unix) or named pipe (Windows)
void IPC::bind(){
    QString path = QString(this->m_socketFile.absoluteFilePath());
    qDebug() << path;

    this->m_server = new QLocalServer(this);
    this->m_server->setSocketOptions(QLocalServer::UserAccessOption);

    bool restarted = false;
    if(!this->m_server->listen(path)){
        // On Unix if the server crashes without closing listen will fail with AddressInUseError.
        // To create a new server the file should be removed. On Windows two local servers can listen
        // to the same pipe at the same time, but any connections will go to one of the server.
#ifdef Q_OS_UNIX
        qDebug() << QString("Unable to start IPC server in \"%1\": \"%2\". Retrying.").arg(path).arg(this->m_server->errorString());
        if(this->m_socketFile.exists()){
            QFile file(path);
            file.remove();

            if(this->m_server->listen(path)){
                restarted = true;
            }
        }
#endif
        if(!restarted)
            qDebug() << QString("Unable to start IPC server in \"%1\": \"%2\".").arg(path).arg(this->m_server->errorString());
    }

    connect(this->m_server, &QLocalServer::newConnection, this, &IPC::handleConnection);
}

// Process incoming IPC command. First check if monero-wallet-gui is
// already running. If it is, send it to that instance instead, if not,
// queue the command for later use inside our QML engine. Returns true
// when queued, false if sent to another instance, at which point we can
// kill the current process.
bool IPC::saveCommand(QString cmdString){
    qDebug() << QString("saveCommand called: %1").arg(cmdString);

    QLocalSocket ls;
    QByteArray buffer;
    buffer = buffer.append(cmdString);
    QString socketFilePath = this->socketFile().filePath();

    ls.connectToServer(socketFilePath, QIODevice::WriteOnly);
    if(ls.waitForConnected(1000)){
        ls.write(buffer);
        if (!ls.waitForBytesWritten(1000)){
            qDebug() << QString("Could not send command \"%1\" over IPC %2: \"%3\"").arg(cmdString, socketFilePath, ls.errorString());
            return false;
        }

        qDebug() << QString("Sent command \"%1\" over IPC \"%2\"").arg(cmdString, socketFilePath);
        return false;
    }

    if(ls.isOpen())
        ls.disconnectFromServer();

    // Queue for later
    this->SetQueuedCmd(cmdString);
    return true;
}

bool IPC::saveCommand(const QUrl &url){;
    this->saveCommand(url.toString());
}

void IPC::handleConnection(){
    QLocalSocket *clientConnection = this->m_server->nextPendingConnection();
    connect(clientConnection, &QLocalSocket::disconnected,
            clientConnection, &QLocalSocket::deleteLater);

    clientConnection->waitForReadyRead(2);
    QByteArray cmdArray = clientConnection->readAll();
    QString cmdString = QTextCodec::codecForMib(106)->toUnicode(cmdArray);  // UTF-8
    qDebug() << cmdString;

    this->parseCommand(cmdString);

    clientConnection->close();
    delete clientConnection;
}

void IPC::parseCommand(const QUrl &url){
    this->parseCommand(url.toString());
}

void IPC::parseCommand(QString cmdString){
    if(cmdString.contains(reURI)){
        this->emitUriHandler(cmdString);
    }
}

void IPC::emitUriHandler(QString uriString){
    emit uriHandler(uriString);
}
