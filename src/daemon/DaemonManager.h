#ifndef DAEMONMANAGER_H
#define DAEMONMANAGER_H

#include <QObject>
#include <QUrl>
#include <QProcess>

class DaemonManager : public QObject
{
    Q_OBJECT

public:

    static DaemonManager * instance(QStringList args);

    Q_INVOKABLE bool start();
    Q_INVOKABLE bool stop();

    // return true if daemon process is started
    Q_INVOKABLE bool running() const;

signals:
    void daemonStarted();
    void daemonStopped();
    void daemonConsoleUpdated(QString message);

public slots:
    void printOutput();
    void printError();
    void closing();
    void stateChanged(QProcess::ProcessState state);

private:

    explicit DaemonManager(QObject *parent = 0);
    static DaemonManager * m_instance;
    static QStringList clArgs;
    QProcess *m_daemon;
    bool initialized = false;

};

#endif // DAEMONMANAGER_H
