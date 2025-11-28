#include <QCoreApplication>
#include "I2PNodeManager.h"
#include "qt/MoneroSettings.h"
#include <QDir>
#include <QDebug>
#include <QFileInfo>
#include <cstring>

// Helper function to securely wipe memory
// This prevents the password from remaining in memory after use
static void secureWipe(QByteArray &data) {
    if (!data.isEmpty()) {
        // Use volatile pointer to prevent compiler optimization
        volatile char *ptr = data.data();
        size_t size = data.size();
        // Zero out the memory
        memset(const_cast<char*>(ptr), 0, size);
        
        // Memory barrier to ensure writes complete before clearing
        // This prevents compiler from optimizing away the memset
#ifdef __GNUC__
        asm volatile("" ::: "memory");
#elif defined(_MSC_VER)
        _ReadWriteBarrier();
#endif
    }
    data.clear();
}

I2PNodeManager::I2PNodeManager(QObject *parent)
    : QObject(parent), m_process(new QProcess(this))
{
    m_status = "Ready";
    m_trustedNodes << "rb752hk56y2k32wh6q7356566q65555555555555555555.b32.i2p:18081";
    m_trustedNodes << "monerow.org.b32.i2p:18081";
    m_trustedNodes << "plowsof.b32.i2p:18081";

    connect(m_process, &QProcess::readyReadStandardOutput, this, &I2PNodeManager::onProcessOutput);
    connect(m_process, &QProcess::readyReadStandardError, this, &I2PNodeManager::onProcessOutput);
    connect(m_process, static_cast<void(QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished),
            this, &I2PNodeManager::onProcessFinished);
    connect(m_process, &QProcess::errorOccurred, this, &I2PNodeManager::handleProcessError);
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
    if (m_process->state() != QProcess::Running) {
        return;
    }
    
    // Convert to QByteArray immediately to minimize QString lifetime
    QByteArray passwordBytes = pw.toUtf8();
    passwordBytes.append('\n');
    
    // Send password to process
    m_process->write(passwordBytes);
    
    // Securely wipe the password from memory
    secureWipe(passwordBytes);
    
    // Note: QString 'pw' parameter will be destroyed when function returns,
    // but QString uses copy-on-write, so we can't guarantee immediate wiping.
    // The QByteArray copy is wiped above, which is the most we can do safely.
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

void I2PNodeManager::startNode(bool useDocker)
{
    if (m_process->state() != QProcess::NotRunning) {
        qDebug() << "process already running, ignoring start request";
        return;
    }

    // iOS and Android cannot execute shell scripts due to platform restrictions
#if defined(Q_OS_IOS) || defined(Q_OS_ANDROID)
    setStatus("Error: Not supported on mobile");
    emit nodeCreationFinished(false, "I2P node hosting is not available on mobile platforms. Please connect to a remote node.");
    return;
#endif

    setStatus("Initializing...");

    QString appDir = QCoreApplication::applicationDirPath();
    
    // Platform-specific script extension
#ifdef Q_OS_WIN
    QString scriptExt = ".bat";
    QString baseScriptName = useDocker ? "create_i2p_node_docker" : "create_i2p_node";
    QString scriptName = baseScriptName + scriptExt;
#else
    QString scriptExt = ".sh";
    QString baseScriptName = useDocker ? "create_i2p_node_docker" : "create_i2p_node";
    QString scriptName = baseScriptName + scriptExt;
#endif

    // Build search paths using QDir for cross-platform compatibility
    QStringList searchPaths;
    QDir appDirObj(appDir);
    QString sep = QDir::separator();
    
    // Standard location: appDir/scripts/
    searchPaths << appDirObj.filePath("scripts" + sep + scriptName);
    
    // Parent directory: ../scripts/
    searchPaths << appDirObj.filePath(".." + sep + "scripts" + sep + scriptName);
    
    // macOS Bundle: ../../../scripts/ (for .app bundles)
    // Note: Q_OS_MACOS includes both macOS and iOS, but we check for iOS separately above
#if defined(Q_OS_MACOS) && !defined(Q_OS_IOS)
    searchPaths << appDirObj.filePath(".." + sep + ".." + sep + ".." + sep + "scripts" + sep + scriptName);
#endif

    QString scriptPath;
    for (const QString &path : searchPaths) {
        QFileInfo fileInfo(path);
        if (fileInfo.exists() && fileInfo.isFile()) {
            scriptPath = QDir::toNativeSeparators(fileInfo.absoluteFilePath());
            break;
        }
    }

    if (scriptPath.isEmpty()) {
        qDebug() << "Error: Could not find I2P script. Checked paths:" << searchPaths;
        setStatus("Error: Script not found");
        emit nodeCreationFinished(false, "Could not locate I2P startup script.");
        return;
    }

    qDebug() << "Launching I2P script found at:" << scriptPath;
    
    // Platform-specific script execution
#ifdef Q_OS_WIN
    // On Windows, execute .bat files directly or use cmd.exe
    // Note: If using bash scripts on Windows, you'd need Git Bash or WSL
    m_process->start("cmd.exe", QStringList() << "/c" << scriptPath);
#elif defined(Q_OS_IOS) || defined(Q_OS_ANDROID)
    // Mobile platforms cannot execute shell scripts (handled above, but defensive check)
    setStatus("Error: Not supported");
    emit nodeCreationFinished(false, "Script execution not available on mobile platforms.");
    return;
#else
    // On Unix-like systems (Linux, macOS), use bash
    m_process->start("/bin/bash", QStringList() << scriptPath);
#endif
}

void I2PNodeManager::stopNode()
{
    if (m_process->state() == QProcess::NotRunning) return;

    qDebug() << "stopping node process...";
    setStatus("Stopping...");

    m_process->terminate();
    if (!m_process->waitForFinished(3000)) {
        m_process->kill();
    }
}

void I2PNodeManager::onProcessOutput()
{
    QByteArray data = m_process->readAllStandardOutput();
    QByteArray errorData = m_process->readAllStandardError();

    QString output = QString::fromLocal8Bit(data + errorData).trimmed();
    QStringList lines = output.split("\n");

    for (const QString &line : lines) {
        if (line.trimmed().isEmpty()) continue;
        qDebug() << "I2P Script:" << line;

        if (line.contains("password", Qt::CaseInsensitive) && line.contains("sudo", Qt::CaseInsensitive)) {
            emit passwordRequested("Administrative privileges required to start I2P service");
        }

        if (line.startsWith("STATUS:")) {
            setStatus(line.mid(7).trimmed());
        }
    }
}

void I2PNodeManager::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    bool success = (exitCode == 0 && exitStatus == QProcess::NormalExit);
    if (success) {
        setStatus("Ready");
        m_connected = true;
        emit nodeCreationFinished(true, "I2P Router started successfully");
    } else {
        setStatus("Error: Stopped unexpectedly");
        m_connected = false;
        emit nodeCreationFinished(false, "I2P Router process failed");
    }
    emit connectedChanged();
}

void I2PNodeManager::handleProcessError(QProcess::ProcessError error) {
    Q_UNUSED(error);
    setStatus("Process Error");
    emit nodeCreationFinished(false, "Failed to launch I2P script");
}
