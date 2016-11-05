#ifndef DAEMONMANAGER_H
#define DAEMONMANAGER_H

#include <QObject>
#include <QUrl>
#include <QProcess>

class DaemonManager : public QObject
{
    Q_OBJECT

public:

    static DaemonManager * instance();

    Q_INVOKABLE bool start();
    Q_INVOKABLE bool stop();
    Q_INVOKABLE QString console() const;

    // return true if daemon process is started
    Q_INVOKABLE bool running() const;

signals:

    void daemonStarted(const QProcess &d);
    void daemonStopped();

public slots:
    void printOutput();
    void printError();

private:

    explicit DaemonManager(QObject *parent = 0);
    static DaemonManager * m_instance;
    QProcess *m_daemon;
    QString dConsole;

};

#endif // DAEMONMANAGER_H
