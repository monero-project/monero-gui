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

bool DaemonManager::start(const QString &flags, bool testnet)
{
    // prepare command line arguments and pass to monerod
    QStringList arguments;
    arguments << "--detach";
    if(testnet)
        arguments << "--testnet";

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
    bool started = m_daemon->startDetached(m_monerod, arguments);

    // add state changed listener
    connect(m_daemon,SIGNAL(stateChanged(QProcess::ProcessState)),this,SLOT(stateChanged(QProcess::ProcessState)));

    if (!started) {
        qDebug() << "Daemon start error: " + m_daemon->errorString();
    } else {
        emit daemonStarted();
    }

    return started;
}

bool DaemonManager::stop(bool testnet)
{
    QString message;
    bool stopped = sendCommand("exit",testnet,message);
    qDebug() << message;
    if(stopped)
        emit daemonStopped();
    return stopped;
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

bool DaemonManager::running(bool testnet) const
{ 
    QString status;
    sendCommand("status",testnet, status);
    qDebug() << status;
    // `./monerod status` returns BUSY when syncing.
    // Treat busy as connected, until fixed upstream.
    if (status.contains("Height:") || status.contains("BUSY") ) {
        emit daemonStarted();
        return true;
    }
    emit daemonStopped();
    return false;
}
bool DaemonManager::sendCommand(const QString &cmd,bool testnet) const
{
    QString message;
    return sendCommand(cmd, testnet, message);
}

bool DaemonManager::sendCommand(const QString &cmd,bool testnet, QString &message) const
{
    QProcess p;
    QString external_cmd = m_monerod + " " + cmd;
    qDebug() << "sending external cmd: " << external_cmd;

    // Add testnet flag if needed
    if (testnet)
        external_cmd += " --testnet";
    external_cmd += "\n";

    p.start(external_cmd);

    bool started = p.waitForFinished(-1);
    message = p.readAllStandardOutput();
    emit daemonConsoleUpdated(message);
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
