#ifndef IPC_H
#define IPC_H

#include <QtCore>
#include <QLocalServer>
#include <qt/utils.h>

class IPC : public QObject
{
Q_OBJECT
public:
    IPC(QObject *parent = 0) : QObject(parent) {}
    QFileInfo socketFile() const { return m_socketFile; }
    Q_INVOKABLE QString queuedCmd() { return m_queuedCmd; }
    void SetQueuedCmd(const QString cmdString) { m_queuedCmd = cmdString; }

public slots:
    void bind();
    void handleConnection();
    bool saveCommand(QString cmdString);
    bool saveCommand(const QUrl &url);
    void parseCommand(QString cmdString);
    void parseCommand(const QUrl &url);
    void emitUriHandler(QString uriString);

signals:
    void uriHandler(QString uriString);

private:
    QLocalServer *m_server;
    QString m_queuedCmd;
    QFileInfo m_socketFile = QFileInfo(QString(QDir::tempPath() + "/xmr-gui_%2.sock").arg(getAccountName()));
};

#endif // IPC_H
