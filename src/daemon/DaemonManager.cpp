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

DaemonManager *DaemonManager::instance()
{
    if (!m_instance) {
        m_instance = new DaemonManager;
    }

    return m_instance;
}

bool DaemonManager::start()
{
    QString        program = QApplication::applicationDirPath() + "/monerod";
    qDebug() << "starting monerod " + program;
    QStringList arguments;

    m_daemon = new QProcess();

    connect (m_daemon, SIGNAL(readyReadStandardOutput()), this, SLOT(printOutput()));
    connect (m_daemon, SIGNAL(readyReadStandardError()), this, SLOT(printError()));


    m_daemon->start(program);
    bool started =  m_daemon->waitForStarted();

    if(!started){
        qDebug() << "Daemon start error: " + m_daemon->errorString();
    }

    return started;
}

bool DaemonManager::stop()
{
    return true;
}

void DaemonManager::printOutput()
{
    QByteArray byteArray = m_daemon->readAllStandardOutput();
    QStringList strLines = QString(byteArray).split("\n");

    foreach (QString line, strLines){
       // dConsole.append(line+"\n");
        qDebug() << "Daemon: " + line;
    }
}

void DaemonManager::printError()
{
    QByteArray byteArray = m_daemon->readAllStandardError();
    QStringList strLines = QString(byteArray).split("\n");

    foreach (QString line, strLines){
       // dConsole.append(line+"\n");
        qDebug() << "Daemon ERROR: " + line;
    }
}

bool DaemonManager::running() const
{
    return m_daemon && m_daemon->state() > QProcess::NotRunning;
}

QString DaemonManager::console() const
{
    return dConsole;
}


DaemonManager::DaemonManager(QObject *parent)
    : QObject(parent)
{

}

