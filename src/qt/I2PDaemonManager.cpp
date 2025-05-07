#include "I2PDaemonManager.h"
#include "MoneroSettings.h"

#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>
#include <QApplication>

I2PDaemonManager::I2PDaemonManager(QObject *parent)
    : QObject(parent)
    , m_process(std::make_unique<QProcess>())
    , m_ready(false)
{
    connect(m_process.get(), &QProcess::started, this, &I2PDaemonManager::handleProcessStarted);
    connect(m_process.get(), QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &I2PDaemonManager::handleProcessFinished);
    connect(m_process.get(), &QProcess::errorOccurred, this, &I2PDaemonManager::handleProcessError);
    connect(m_process.get(), &QProcess::readyReadStandardOutput, this, &I2PDaemonManager::handleProcessOutput);
    connect(m_process.get(), &QProcess::readyReadStandardError, this, &I2PDaemonManager::handleProcessOutput);

    m_statusCheckTimer.setInterval(2000); // Check every 2 seconds
    connect(&m_statusCheckTimer, &QTimer::timeout, this, &I2PDaemonManager::checkI2PStatus);
}

I2PDaemonManager::~I2PDaemonManager()
{
    if (running()) {
        stop();
    }
}

bool I2PDaemonManager::running() const
{
    return m_process->state() == QProcess::Running;
}

QString I2PDaemonManager::status() const
{
    return m_status;
}

bool I2PDaemonManager::ready() const
{
    return m_ready;
}

bool I2PDaemonManager::start()
{
    if (running()) {
        return true;
    }

    if (!initializeI2PConfig()) {
        emit error(tr("Failed to initialize I2P configuration"));
        return false;
    }

    QString i2pPath = getI2PPath();
    if (i2pPath.isEmpty()) {
        emit error(tr("I2P daemon executable not found"));
        return false;
    }

    QStringList arguments;
    arguments << "--conf=" + getI2PDataPath() + "/i2pd.conf";
    arguments << "--datadir=" + getI2PDataPath();
    
    m_process->setWorkingDirectory(getI2PDataPath());
    m_process->start(i2pPath, arguments);

    updateStatus(tr("Starting I2P daemon..."));
    m_statusCheckTimer.start();
    
    return true;
}

bool I2PDaemonManager::stop()
{
    if (!running()) {
        return true;
    }

    m_statusCheckTimer.stop();
    m_process->terminate();
    
    if (!m_process->waitForFinished(5000)) {
        m_process->kill();
    }

    updateStatus(tr("I2P daemon stopped"));
    m_ready = false;
    emit readyChanged();
    
    return true;
}

bool I2PDaemonManager::restart()
{
    stop();
    return start();
}

void I2PDaemonManager::handleProcessStarted()
{
    updateStatus(tr("I2P daemon started"));
    emit runningChanged();
}

void I2PDaemonManager::handleProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    m_statusCheckTimer.stop();
    m_ready = false;
    emit readyChanged();
    emit runningChanged();

    if (exitStatus == QProcess::CrashExit) {
        updateStatus(tr("I2P daemon crashed"));
        emit error(tr("I2P daemon crashed"));
    } else if (exitCode != 0) {
        updateStatus(tr("I2P daemon exited with code %1").arg(exitCode));
        emit error(tr("I2P daemon exited with code %1").arg(exitCode));
    } else {
        updateStatus(tr("I2P daemon stopped"));
    }
}

void I2PDaemonManager::handleProcessError(QProcess::ProcessError error)
{
    QString errorMessage;
    switch (error) {
        case QProcess::FailedToStart:
            errorMessage = tr("Failed to start I2P daemon");
            break;
        case QProcess::Crashed:
            errorMessage = tr("I2P daemon crashed");
            break;
        case QProcess::Timedout:
            errorMessage = tr("I2P daemon process timed out");
            break;
        case QProcess::WriteError:
            errorMessage = tr("Error writing to I2P daemon");
            break;
        case QProcess::ReadError:
            errorMessage = tr("Error reading from I2P daemon");
            break;
        default:
            errorMessage = tr("Unknown error with I2P daemon");
            break;
    }
    
    updateStatus(errorMessage);
    emit this->error(errorMessage);
}

void I2PDaemonManager::handleProcessOutput()
{
    QString output = QString::fromUtf8(m_process->readAllStandardOutput());
    QString error = QString::fromUtf8(m_process->readAllStandardError());

    if (!output.isEmpty()) {
        qDebug() << "I2P daemon output:" << output;
    }
    if (!error.isEmpty()) {
        qDebug() << "I2P daemon error:" << error;
    }

    // Check for initialization messages
    if (output.contains("SAM bridge running") || output.contains("HTTP proxy running")) {
        m_ready = true;
        emit readyChanged();
        updateStatus(tr("I2P daemon ready"));
    }
}

void I2PDaemonManager::checkI2PStatus()
{
    // TODO: Implement proper I2P status check via SAM API
    if (!m_ready && running()) {
        // Simple check - if process is running for more than 10 seconds, assume it's ready
        static int checks = 0;
        if (++checks >= 5) {
            m_ready = true;
            emit readyChanged();
            updateStatus(tr("I2P daemon ready"));
            m_statusCheckTimer.stop();
        }
    }
}

bool I2PDaemonManager::initializeI2PConfig()
{
    QString configPath = getI2PDataPath();
    QDir().mkpath(configPath);

    QFile configFile(configPath + "/i2pd.conf");
    if (!configFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        return false;
    }

    // Basic i2pd configuration
    QTextStream out(&configFile);
    out << "log = file\n";
    out << "logfile = " << QDir::toNativeSeparators(configPath + "/i2pd.log") << "\n";
    out << "loglevel = info\n\n";
    
    out << "[http]\n";
    out << "enabled = true\n";
    out << "address = 127.0.0.1\n";
    out << "port = 7070\n\n";

    out << "[sam]\n";
    out << "enabled = true\n";
    out << "address = 127.0.0.1\n";
    out << "port = 7656\n\n";

    out << "[tunnels.monero]\n";
    out << "type = client\n";
    out << "address = 127.0.0.1\n";
    out << "port = 18081\n";
    out << "destination = monero.i2p\n";
    out << "inbound.length = " << MoneroSettings::instance()->i2pInboundQuantity() << "\n";
    out << "outbound.length = " << MoneroSettings::instance()->i2pOutboundQuantity() << "\n";
    out << "inbound.quantity = 3\n";
    out << "outbound.quantity = 3\n";

    configFile.close();
    return true;
}

QString I2PDaemonManager::getI2PPath() const
{
#ifdef WITH_I2P
    // Use bundled i2pd binary
    QString appPath = QApplication::applicationDirPath();
#ifdef Q_OS_WIN
    return appPath + "/i2pd.exe";
#else
    return appPath + "/i2pd";
#endif
#else
    // Fall back to system i2pd if not bundled
#ifdef Q_OS_WIN
    return "i2pd.exe";
#else
    return "i2pd";
#endif
#endif
}

QString I2PDaemonManager::getI2PDataPath() const
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/i2p";
}

void I2PDaemonManager::updateStatus(const QString &status)
{
    if (m_status != status) {
        m_status = status;
        emit statusChanged();
    }
} 