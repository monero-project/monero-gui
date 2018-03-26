#ifndef DAEMONMANAGER_H
#define DAEMONMANAGER_H

#include <QObject>
#include <QUrl>
#include <QProcess>
#include <QVariantMap>
#include "NetworkType.h"

class DaemonManager : public QObject
{
    Q_OBJECT

public:

    static DaemonManager * instance(const QStringList *args);

    Q_INVOKABLE bool start(const QString &flags, NetworkType::Type nettype, const QString &dataDir = "", const QString &bootstrapNodeAddress = "");
    Q_INVOKABLE bool stop(NetworkType::Type nettype);

    // return true if daemon process is started
    Q_INVOKABLE bool running(NetworkType::Type nettype) const;
    // Send daemon command from qml and prints output in console window.
    Q_INVOKABLE bool sendCommand(const QString &cmd, NetworkType::Type nettype) const;
    Q_INVOKABLE void exit();
    Q_INVOKABLE QVariantMap validateDataDir(const QString &dataDir) const;

private:

    bool sendCommand(const QString &cmd, NetworkType::Type nettype, QString &message) const;
    bool startWatcher(NetworkType::Type nettype) const;
    bool stopWatcher(NetworkType::Type nettype) const;
signals:
    void daemonStarted() const;
    void daemonStopped() const;
    void daemonStartFailure() const;
    void daemonConsoleUpdated(QString message) const;

public slots:
    void printOutput();
    void printError();
    void stateChanged(QProcess::ProcessState state);

private:
    explicit DaemonManager(QObject *parent = 0);
    static DaemonManager * m_instance;
    static QStringList m_clArgs;
    QProcess *m_daemon;
    bool initialized = false;
    QString m_monerod;
    bool m_has_daemon = true;
    bool m_app_exit = false;

};

#endif // DAEMONMANAGER_H
