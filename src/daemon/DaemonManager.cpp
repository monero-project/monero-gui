#include "DaemonManager.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QDebug>
#include <QUrl>
#include <QtConcurrent/QtConcurrent>
#include <QApplication>
#include <QProcess>

DaemonManager * DaemonManager::m_instance = nullptr;
QStringList DaemonManager::m_clArgs;

DaemonManager *DaemonManager::instance(const QStringList *args)
{
    if (!m_instance) {
        m_instance = new DaemonManager;
        // store command line arguments for later use
        m_clArgs = *args;
        m_clArgs.removeFirst();
    }

    return m_instance;
}

bool DaemonManager::start(const QString &flags)
{
    //
    QString process;
#ifdef Q_OS_WIN
    process = QApplication::applicationDirPath() + "/monerod.exe";
#elif defined(Q_OS_UNIX)
    process = QApplication::applicationDirPath() + "/monerod";
#endif

    if (process.length() == 0) {
        qDebug() << "no daemon binary defined for current platform";
        return false;
    }


    // prepare command line arguments and pass to monerod
    QStringList arguments;
    foreach (const QString &str, m_clArgs) {
          qDebug() << QString(" [%1] ").arg(str);
          if (!str.isEmpty())
            arguments << str;
    }

    // Custom startup flags for daemon
    foreach (const QString &str, flags.split(" ")) {
          qDebug() << QString(" [%1] ").arg(str);
          if (!str.isEmpty())
            arguments << str;
    }


    qDebug() << "starting monerod " + process;
    qDebug() << "With command line arguments " << arguments;

    m_daemon = new QProcess();
    initialized = true;

    // Connect output slots
    connect (m_daemon, SIGNAL(readyReadStandardOutput()), this, SLOT(printOutput()));
    connect (m_daemon, SIGNAL(readyReadStandardError()), this, SLOT(printError()));

    // Start monerod
    m_daemon->start(process,arguments);
    bool started =  m_daemon->waitForStarted();

    // add state changed listener
    connect(m_daemon,SIGNAL(stateChanged(QProcess::ProcessState)),this,SLOT(stateChanged(QProcess::ProcessState)));

    if (!started) {
        qDebug() << "Daemon start error: " + m_daemon->errorString();
    } else {
        emit daemonStarted();
    }

    return started;
}

bool DaemonManager::stop()
{
    if (initialized) {
        qDebug() << "stopping daemon";
        // we can't use QProcess::terminate() on windows console process
        // write exit command to stdin
        m_daemon->write("exit\n");
    }

    return true;
}

void DaemonManager::stateChanged(QProcess::ProcessState state)
{
    qDebug() << "STATE CHANGED: " << state;
    if (state == QProcess::NotRunning) {
        emit daemonStopped();
    }
}

void DaemonManager::printOutput()
{
    QByteArray byteArray = m_daemon->readAllStandardOutput();
    QStringList strLines = QString(byteArray).split("\n");

    foreach (QString line, strLines) {
        emit daemonConsoleUpdated(line);
        qDebug() << "Daemon: " + line;
    }
}

void DaemonManager::printError()
{
    QByteArray byteArray = m_daemon->readAllStandardError();
    QStringList strLines = QString(byteArray).split("\n");

    foreach (QString line, strLines) {
        emit daemonConsoleUpdated(line);
        qDebug() << "Daemon ERROR: " + line;
    }
}

bool DaemonManager::running() const
{
    if (initialized) {
        qDebug() << m_daemon->state();
        qDebug() << QProcess::NotRunning;
       // m_daemon->write("status\n");
        return m_daemon->state() > QProcess::NotRunning;
    }
    return false;
}

DaemonManager::DaemonManager(QObject *parent)
    : QObject(parent)
{

}

void DaemonManager::closing()
{
    qDebug() << __FUNCTION__;
    stop();
    // Wait for daemon to stop before exiting (max 10 secs)
    if (initialized) {
        m_daemon->waitForFinished(10000);
    }
}
