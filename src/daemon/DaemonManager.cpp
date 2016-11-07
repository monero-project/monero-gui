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
QStringList DaemonManager::clArgs;

DaemonManager *DaemonManager::instance(QStringList args)
{
    if (!m_instance) {
        m_instance = new DaemonManager;
        // store command line arguments for later use
        clArgs = args;
        clArgs.removeFirst();
    }

    return m_instance;
}

bool DaemonManager::start()
{

    //
    QString process;
#ifdef Q_OS_WIN
    process = QApplication::applicationDirPath() + "/monerod.exe";
#elif defined(Q_OS_UNIX)
    process = QApplication::applicationDirPath() + "/monerod";
#endif

    if(process.length() == 0) {
        qDebug() << "no daemon binary defined for current platform";
        return false;
    }


    // prepare command line arguments and pass to monerod
    QStringList arguments;
    foreach (const QString &str, clArgs) {
          qDebug() << QString(" [%1] ").arg(str);
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

    if(!started){
        qDebug() << "Daemon start error: " + m_daemon->errorString();
    } else {
        emit daemonStarted();
    }

    return started;
}

bool DaemonManager::stop()
{
    if(initialized){
        qDebug() << "stopping daemon";
        m_daemon->terminate();
        // Wait until stopped. Max 10 seconds
        bool stopped = m_daemon->waitForFinished(10000);
        if(stopped) emit daemonStopped();
        return stopped;
    }

    return true;
}

void DaemonManager::printOutput()
{
    QByteArray byteArray = m_daemon->readAllStandardOutput();
    QStringList strLines = QString(byteArray).split("\n");

    foreach (QString line, strLines){
        emit daemonConsoleUpdated(line);
        qDebug() << "Daemon: " + line;
    }
}

void DaemonManager::printError()
{
    QByteArray byteArray = m_daemon->readAllStandardError();
    QStringList strLines = QString(byteArray).split("\n");

    foreach (QString line, strLines){
        emit daemonConsoleUpdated(line);
        qDebug() << "Daemon ERROR: " + line;
    }
}

bool DaemonManager::running() const
{
    if(initialized){
        qDebug() << m_daemon->state();
        qDebug() << QProcess::NotRunning;

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
}
