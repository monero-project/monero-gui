#include "I2PManager.h"
#include <QSettings>
#include <QCoreApplication>
#include <QFileInfo>
#include "libwalletqt/WalletManager.h"
#include <QNetworkProxy>
#include <QUrl>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>   

static QString scriptPath()
{
    return QCoreApplication::applicationDirPath() + "/i2p/create_i2p_node.sh";
}

I2PManager::I2PManager(QObject *parent) : QObject(parent)
{
    // load persisted settings
    QSettings s;
    s.beginGroup("i2p");
    m_enabled = s.value("enabled", false).toBool();
    m_connectionMode = s.value("mode", "remote-only").toString();
    s.endGroup();

    // default seeds if list empty
    m_trustedNodes = QStringList {
        "core5hzivg4v5ttxbor4a3haja6dssksqsmiootlptnsrfsgwqqa.b32.i2p:18089",
        "dsc7fyzzultm7y6pmx2avu6tze3usc7d27nkbzs5qwuujplxcmzq.b32.i2p:18089",
        "sel36x6fibfzujwvt4hf5gxolz6kd3jpvbjqg6o3ud2xtionyl2q.b32.i2p:18089",
        "yht4tm2slhyue42zy5p2dn3sft2ffjjrpuy7oc2lpbhifcidml4q.b32.i2p:18089"
    };
    emit trustedNodesChanged();

    if (m_enabled)
        refreshStatus();
}

void I2PManager::setEnabled(bool v)
{
    if (m_enabled == v)
        return;
    m_enabled = v;
    emit enabledChanged();
    QSettings s;
    s.beginGroup("i2p");
    s.setValue("enabled", m_enabled);
    s.endGroup();

    if (!m_enabled) {
        m_connected = false;
        emit connectedChanged();
        stopScript();
        setStatus(tr("I2P disabled"));
    } else {
        refreshStatus();
    }
}

void I2PManager::setConnectionMode(const QString &mode)
{
    if (m_connectionMode == mode)
        return;
    m_connectionMode = mode;
    QSettings s;
    s.beginGroup("i2p");
    s.setValue("mode", m_connectionMode);
    s.endGroup();
    emit connectionModeChanged();
}

void I2PManager::refreshStatus()
{
    if (!m_enabled) {
        setStatus(tr("I2P disabled"));
        m_connected = false;
        emit connectedChanged();
        return;
    }
    if (m_connected)
        setStatus(tr("Connected to I2P"));
    else
        setStatus(tr("I2P enabled, waiting for node setup…"));
}

void I2PManager::startCreateNode()
{
    if (!m_enabled)
        setEnabled(true);
    if (m_process)
        return;
    startScript();
}

void I2PManager::cancelCreateNode()
{
    stopScript();
    setStatus(tr("Node setup cancelled"));
}

void I2PManager::providePassword(const QString &pw)
{
    if (!m_process || !m_waitingForPassword)
        return;
    QByteArray line = pw.toUtf8();
    line.append('\n');
    m_process->write(line);
   // m_process->flush(); <-- no flush function?
    m_waitingForPassword = false;
}

void I2PManager::startScript()
{
    const QString sp = scriptPath();
    if (!QFileInfo::exists(sp)) {
        setStatus(tr("I2P setup script not found: %1").arg(sp));
        emit nodeCreationFinished(false, status());
        return;
    }
    
    // Ensure script is executable
    QFile::setPermissions(sp, QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner |
                             QFile::ReadGroup | QFile::ExeGroup |
                             QFile::ReadOther | QFile::ExeOther);
    
    m_process = new QProcess(this);
    m_process->setProgram("sudo");
    m_process->setArguments(QStringList() << "-S" << "bash" << sp);
    m_process->setProcessChannelMode(QProcess::MergedChannels);
    connect(m_process, &QProcess::readyReadStandardOutput,
            this, &I2PManager::handleProcessOutput);
    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &I2PManager::handleProcessFinished);
    connect(m_process, &QProcess::errorOccurred,
            this, &I2PManager::handleProcessError);

    emit nodeCreationStarted();
    setStatus(tr("Starting I2P node setup…"));
    m_process->start();
    // Password will be provided via providePassword() when PASSWORD_PROMPT is received
}

void I2PManager::stopScript()
{
    if (!m_process)
        return;
    if (m_process->state() != QProcess::NotRunning) {
        m_process->kill();
        m_process->waitForFinished(2000);
    }
    m_process->deleteLater();
    m_process = nullptr;
    m_waitingForPassword = false;
}

void I2PManager::handleProcessOutput()
{
    const QByteArray out = m_process->readAllStandardOutput();
    const QString text = QString::fromUtf8(out);
    const auto lines = text.split('\n', Qt::SkipEmptyParts);
    for (QString line : lines) {
        line = line.trimmed();
        if (line.startsWith("STATUS:CONNECTED")) {
            m_connected = true;
            emit connectedChanged();
            setStatus(tr("Connected to I2P"));
        } else if (line.startsWith("STATUS:")) {
            setStatus(line.mid(QStringLiteral("STATUS:").size()));
        } else if (line.startsWith("PASSWORD_PROMPT:")) {
            const QString reason = line.mid(QStringLiteral("PASSWORD_PROMPT:").size());
            m_waitingForPassword = true;
            emit passwordRequested(reason);
        } else if (line.startsWith("TRUSTED_NODE:")) {
            const QString node = line.mid(QStringLiteral("TRUSTED_NODE:").size());
            if (!node.isEmpty() && !m_trustedNodes.contains(node)) {
                m_trustedNodes.append(node);
                emit trustedNodesChanged();
            }
        }
    }
}

void I2PManager::handleProcessFinished(int code, QProcess::ExitStatus)
{
    bool ok = (code == 0);
    if (ok && m_connected)
        setStatus(tr("I2P node created and connected"));
    else if (ok)
        setStatus(tr("I2P setup finished (check logs)"));
    else
        setStatus(tr("I2P setup failed (exit code %1)").arg(code));
    emit nodeCreationFinished(ok, m_status);
    stopScript();
}

void I2PManager::handleProcessError(QProcess::ProcessError)
{
    setStatus(tr("I2P setup process error"));
}

bool I2PManager::i2pStatus() const
{
    // Check if I2P connection is active by attempting RPC call through I2P proxy
    if (!m_networkManager) {
        const_cast<I2PManager*>(this)->m_networkManager = new QNetworkAccessManager(const_cast<I2PManager*>(this));
    }
    
    QNetworkRequest request(QUrl("http://127.0.0.1:18089/json_rpc"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    
    QNetworkProxy proxy;
    proxy.setType(QNetworkProxy::Socks5Proxy);
    proxy.setHostName("127.0.0.1");
    proxy.setPort(4447);
    
    m_networkManager->setProxy(proxy);
    
    QJsonObject json;
    json["jsonrpc"] = "2.0";
    json["id"] = "0";
    json["method"] = "get_info";
    QJsonDocument doc(json);
    
    QNetworkReply *reply = m_networkManager->post(request, doc.toJson());
    
    // For synchronous check, wait briefly (in practice, make this async)
    // This is a simplified implementation
    if (reply->waitForReadyRead(2000)) {
        bool success = (reply->error() == QNetworkReply::NoError);
        reply->deleteLater();
        return success;
    }
    
    reply->deleteLater();
    return false;
}

void I2PManager::setProxyForI2p()
{
    // Set proxy in WalletManager
    WalletManager *walletManager = WalletManager::instance();
    if (walletManager) {
        walletManager->setProxyAddress("127.0.0.1:4447");
        qDebug() << "I2P proxy set to 127.0.0.1:4447";
    }
    
    // Update connection status
    if (m_enabled) {
        refreshStatus();
    }
}