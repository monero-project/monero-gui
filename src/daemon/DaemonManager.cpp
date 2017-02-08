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


    qDebug() << "starting monerod " + m_monerod;
    qDebug() << "With command line arguments " << m_monerod;

    m_daemon = new QProcess();
    initialized = true;

    // Connect output slots
    connect (m_daemon, SIGNAL(readyReadStandardOutput()), this, SLOT(printOutput()));
    connect (m_daemon, SIGNAL(readyReadStandardError()), this, SLOT(printError()));

    // Start monerod
    m_daemon->start(m_monerod, arguments);
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

bool DaemonManager::sendCommand(const QString &cmd,bool testnet)
{
    // If daemon is started by GUI - interactive mode
    if (initialized && running()) {
        m_daemon->write(cmd.toUtf8() +"\n");
        return true;
    }

    // else send external command
    QProcess p;
    QString external_cmd = m_monerod + " " + cmd;

    // Add nestnet flag if needed
    if (testnet)
        external_cmd += " --testnet";
    external_cmd += "\n";

    p.start(external_cmd);
    bool started = p.waitForFinished(-1);
    QString p_stdout = p.readAllStandardOutput();
    qDebug() << p_stdout;
    emit daemonConsoleUpdated(p_stdout);

    return started;
}

DaemonManager::DaemonManager(QObject *parent)
    : QObject(parent)
{

    // Platform depetent path to monerod
#ifdef Q_OS_WIN
    m_monerod = QApplication::applicationDirPath() + "/monerod.exe";
#elif defined(Q_OS_UNIX)
    m_monerod = QApplication::applicationDirPath() + "/monerod";
#endif

    if (m_monerod.length() == 0) {
        qCritical() << "no daemon binary defined for current platform";
        m_has_daemon = false;
    }
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
