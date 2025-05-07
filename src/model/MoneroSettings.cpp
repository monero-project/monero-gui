#include "MoneroSettings.h"

MoneroSettings::MoneroSettings(QObject *parent)
    : QObject(parent)
    , m_settings("monero-project", "monero-core")
{
    // Initialize I2P settings
    m_useI2P = false;
    m_useBuiltInI2P = true;
    m_i2pAddress = "127.0.0.1";
    m_i2pPort = 7656;
    m_i2pMixedMode = false;
    m_i2pTunnelLength = 3;

    // Load I2P settings with defaults
    m_useI2P = m_settings.value("useI2P", false).toBool();
    m_useBuiltInI2P = m_settings.value("useBuiltInI2P", true).toBool();
    m_i2pAddress = m_settings.value("i2pAddress", "127.0.0.1").toString();
    m_i2pPort = m_settings.value("i2pPort", 7656).toInt();
    m_i2pMixedMode = m_settings.value("i2pMixedMode", true).toBool();
    m_i2pTunnelLength = m_settings.value("i2pTunnelLength", 3).toInt();
}

MoneroSettings::~MoneroSettings()
{
    // Save settings on destruction
    m_settings.setValue("useI2P", m_useI2P);
    m_settings.setValue("useBuiltInI2P", m_useBuiltInI2P);
    m_settings.setValue("i2pAddress", m_i2pAddress);
    m_settings.setValue("i2pPort", m_i2pPort);
    m_settings.setValue("i2pMixedMode", m_i2pMixedMode);
    m_settings.setValue("i2pTunnelLength", m_i2pTunnelLength);
}

MoneroSettings* MoneroSettings::instance()
{
    static MoneroSettings instance;
    return &instance;
}

// I2P settings getters and setters
bool MoneroSettings::useI2P() const
{
    return m_useI2P;
}

void MoneroSettings::setUseI2P(bool useI2P)
{
    if (m_useI2P == useI2P)
        return;
    
    m_useI2P = useI2P;
    m_settings.setValue("useI2P", useI2P);
    emit useI2PChanged();
}

bool MoneroSettings::useBuiltInI2P() const
{
    return m_useBuiltInI2P;
}

void MoneroSettings::setUseBuiltInI2P(bool useBuiltInI2P)
{
    if (m_useBuiltInI2P == useBuiltInI2P)
        return;
    
    m_useBuiltInI2P = useBuiltInI2P;
    m_settings.setValue("useBuiltInI2P", useBuiltInI2P);
    emit useBuiltInI2PChanged();
}

QString MoneroSettings::i2pAddress() const
{
    return m_i2pAddress;
}

void MoneroSettings::setI2PAddress(const QString &address)
{
    if (m_i2pAddress == address)
        return;
    
    m_i2pAddress = address;
    m_settings.setValue("i2pAddress", address);
    emit i2pAddressChanged();
}

int MoneroSettings::i2pPort() const
{
    return m_i2pPort;
}

void MoneroSettings::setI2PPort(int port)
{
    if (m_i2pPort == port)
        return;
    
    m_i2pPort = port;
    m_settings.setValue("i2pPort", port);
    emit i2pPortChanged();
}

bool MoneroSettings::i2pMixedMode() const
{
    return m_i2pMixedMode;
}

void MoneroSettings::setI2PMixedMode(bool mixedMode)
{
    if (m_i2pMixedMode == mixedMode)
        return;
    
    m_i2pMixedMode = mixedMode;
    m_settings.setValue("i2pMixedMode", mixedMode);
    emit i2pMixedModeChanged();
}

int MoneroSettings::i2pTunnelLength() const
{
    return m_i2pTunnelLength;
}

void MoneroSettings::setI2PTunnelLength(int length)
{
    if (m_i2pTunnelLength == length)
        return;
    
    m_i2pTunnelLength = length;
    m_settings.setValue("i2pTunnelLength", length);
    emit i2pTunnelLengthChanged();
} 