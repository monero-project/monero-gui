#include "I2PNodeManager.h"
#include "qt/MoneroSettings.h"
#include <QCoreApplication>
#include <QDir>

I2PNodeManager::I2PNodeManager(QObject *parent)
I2PNodeManager::I2PNodeManager(QObject *parent)
    : QObject(parent), m_process(new QProcess(this)), m_running(false)
{
    m_status = "ready.";

    // --- TRUSTED REMOTE NODES (RPC) ---
    // These are for users who DONT want to run a local node.
    // They connect directly to these via I2P proxy.
    m_remoteNodes << "rb752hk56y2k32wh6q7356566q65555555555555555555.b32.i2p:18081"; // SethForPrivacy
    m_remoteNodes << "monerow.org.b32.i2p:18081"; // MoneroWorld
    m_remoteNodes << "plowsof.b32.i2p:18081"; // Plowsof

    connect(m_process, &QProcess::readyReadStandardOutput, this, &I2PNodeManager::onProcessOutput);
    connect(m_process, &QProcess::readyReadStandardError, this, &I2PNodeManager::onProcessOutput);
    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &I2PNodeManager::onProcessFinished);
}

void I2PNodeManager::startNode(bool useDocker)
{
    // ... (Keep the rest of your existing startNode logic here) ...
    if (m_process->state() != QProcess::NotRunning) {
        qDebug() << "process already running, ignoring start request";
        return;
    }

    m_status = "initializing...";
    emit statusChanged();

    QString binDir = QCoreApplication::applicationDirPath();
    QString scriptName = useDocker ? "create_i2p_node_docker.sh" : "create_i2p_node.sh";
    QString scriptPath = binDir + "/scripts/" + scriptName;

    qDebug() << "launching i2p script:" << scriptPath;

    m_process->start("/bin/bash", QStringList() << scriptPath);

    m_running = true;
    emit isRunningChanged();
}

void I2PNodeManager::stopNode()
{
    // ... (Keep your existing stopNode logic here) ...
    if (m_process->state() == QProcess::NotRunning) return;

    qDebug() << "stopping node process...";
    m_status = "stopping...";
    emit statusChanged();
    m_process->terminate();
    if (!m_process->waitForFinished(3000)) {
        m_process->kill();
    }
}

void I2PNodeManager::onProcessOutput()
{
    // ... (Keep your existing output logic here) ...
    QByteArray data = m_process->readAllStandardOutput();
    QString output = QString::fromLocal8Bit(data).trimmed();

    QStringList lines = output.split("\n");
    for (const QString &line : lines) {
        if (line.startsWith("STATUS:")) {
            m_status = line.mid(7).trimmed();
            emit statusChanged();
            qDebug() << "I2P:" << m_status;
        }
    }
}

void I2PNodeManager::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    // ... (Keep your existing finished logic here) ...
    qDebug() << "i2p script finished code:" << exitCode;
    m_running = false;
    emit isRunningChanged();

    if (exitCode == 0) {
        m_status = "stopped.";
    } else {
        m_status = "error: node stopped unexpectedly";
    }
    emit statusChanged();
}

void I2PNodeManager::setEnabled(bool enabled) {
    if (m_enabled == enabled) return;
    m_enabled = enabled;
    emit enabledChanged();
}

void I2PNodeManager::setConnectionMode(const QString &mode) {
    if (m_connectionMode == mode) return;
    m_connectionMode = mode;
    emit connectionModeChanged();
}

void I2PNodeManager::setStatus(const QString &s) {
    if (m_status == s) return;
    m_status = s;
    emit statusChanged();
}

void I2PNodeManager::refreshStatus() {
    if (m_process->state() == QProcess::Running) {
        setStatus("Running");
        m_connected = true;
    } else {
        setStatus("Stopped");
        m_connected = false;
    }
    emit connectedChanged();
}

void I2PNodeManager::startCreateNode() {
    emit nodeCreationStarted();
    startNode(false);
}

void I2PNodeManager::cancelCreateNode() {
    stopNode();
    emit nodeCreationFinished(false, "User cancelled");
}

void I2PNodeManager::providePassword(const QString &pw) {
    if (m_process->state() == QProcess::Running) {
        m_process->write((pw + "\n").toUtf8());
    }
}

bool I2PNodeManager::i2pStatus() const {
    return m_connected;
}

void I2PNodeManager::setProxyForI2p() {
    MoneroSettings *settings = MoneroSettings::instance();
    if (settings) {
        settings->setI2pEnabled(true);
        settings->setI2pAddress("127.0.0.1:4447");
    }
}

void I2PNodeManager::handleProcessError(QProcess::ProcessError error) {
    setStatus("Process Error");
    emit nodeCreationFinished(false, "Failed to launch I2P script");
}
void I2PNodeManager::setEnabled(bool enabled) {
    if (m_enabled == enabled) return;
    m_enabled = enabled;
    emit enabledChanged();
}

void I2PNodeManager::setConnectionMode(const QString &mode) {
    if (m_connectionMode == mode) return;
    m_connectionMode = mode;
    emit connectionModeChanged();
}

void I2PNodeManager::setStatus(const QString &s) {
    if (m_status == s) return;
    m_status = s;
    emit statusChanged();
}

void I2PNodeManager::refreshStatus() {
    if (m_process->state() == QProcess::Running) {
        setStatus("Running");
        m_connected = true;
    } else {
        setStatus("Stopped");
        m_connected = false;
    }
    emit connectedChanged();
}

void I2PNodeManager::startCreateNode() {
    emit nodeCreationStarted();
    startNode(false);
}

void I2PNodeManager::cancelCreateNode() {
    stopNode();
    emit nodeCreationFinished(false, "User cancelled");
}

void I2PNodeManager::providePassword(const QString &pw) {
    if (m_process->state() == QProcess::Running) {
        m_process->write((pw + "\n").toUtf8());
    }
}

bool I2PNodeManager::i2pStatus() const {
    return m_connected;
}

#include "qt/MoneroSettings.h"
void I2PNodeManager::setProxyForI2p() {
    MoneroSettings *settings = MoneroSettings::instance();
    if (settings) {
        settings->setI2pEnabled(true);
        settings->setI2pAddress("127.0.0.1:4447");
    }
}

void I2PNodeManager::handleProcessError(QProcess::ProcessError error) {
    setStatus("Process Error");
    emit nodeCreationFinished(false, "Failed to launch I2P script");
}
