#include <QtCore>
#include <QMetaObject>
#include <QSettings>
#include <QFileInfo>
#include <QDir>
#include <QJSValue>
#include <QFile>
#include "qt/MoneroSettings.h"

// Initialize static member
MoneroSettings *MoneroSettings::m_instance = nullptr;

MoneroSettings::MoneroSettings(QObject *parent) :
    QObject(parent)
{
    m_instance = this;
}

MoneroSettings *MoneroSettings::instance()
{
    return m_instance;
}

void MoneroSettings::load()
{
    const QMetaObject *mo = this->metaObject();
    const int offset = mo->propertyOffset();
    const int count = mo->propertyCount();

    for (int i = offset; i < count; ++i) {
        QMetaProperty property = mo->property(i);
        const QVariant previousValue = readProperty(property);
        const QVariant currentValue = this->m_settings->value(property.name(), previousValue);

        if (!currentValue.isNull() && (!previousValue.isValid()
                                       || (currentValue.canConvert(previousValue.type()) && previousValue != currentValue))) {
            property.write(this, currentValue);
        }

        if (!this->m_settings->contains(property.name()))
            this->_q_propertyChanged();

        if (!this->m_initialized && property.hasNotifySignal()) {
            static const int propertyChangedIndex = mo->indexOfSlot("_q_propertyChanged()");
            int signalIndex = property.notifySignalIndex();
            QMetaObject::connect(this, signalIndex, this, propertyChangedIndex);
        }
    }
}

void MoneroSettings::_q_propertyChanged()
{
    const QMetaObject *mo = this->metaObject();
    const int offset = mo->propertyOffset();
    const int count = mo->propertyCount();
    for (int i = offset; i < count; ++i) {
        const QMetaProperty &property = mo->property(i);
        const QVariant value = readProperty(property);
        this->m_changedProperties.insert(property.name(), value);
    }

    if (this->m_timerId != 0)
        this->killTimer(this->m_timerId);
    this->m_timerId = this->startTimer(settingsWriteDelay);
}

QVariant MoneroSettings::readProperty(const QMetaProperty &property) const
{
    QVariant var = property.read(this);
    if (var.userType() == qMetaTypeId<QJSValue>())
        var = var.value<QJSValue>().toVariant();
    return var;
}

void MoneroSettings::init()
{
    if (!this->m_initialized) {
        this->m_settings = portableConfigExists() ? portableSettings() : unportableSettings();
        this->load();
        this->m_initialized = true;
        emit portableChanged();
    }
}

void MoneroSettings::reset()
{
    if (this->m_initialized && this->m_settings && !this->m_changedProperties.isEmpty())
        this->store();
    if (this->m_settings)
        this->m_settings.reset();
}

void MoneroSettings::store()
{
    if (!m_writable) return;

    QHash<const char *, QVariant>::const_iterator it = this->m_changedProperties.constBegin();
    while (it != this->m_changedProperties.constEnd()) {
        this->m_settings->setValue(it.key(), it.value());
        ++it;
    }
    this->m_changedProperties.clear();
}

bool MoneroSettings::portable() const
{
    return this->m_settings && this->m_settings->fileName() == portableFilePath();
}

bool MoneroSettings::portableConfigExists()
{
    QFileInfo info(portableFilePath());
    return info.exists() && info.isFile();
}

QString MoneroSettings::portableFilePath()
{
    static QString filename(QDir(portableFolderName()).absoluteFilePath("settings.ini"));
    return filename;
}

QString MoneroSettings::portableFolderName()
{
    return "monero-storage";
}

std::unique_ptr<QSettings> MoneroSettings::portableSettings() const
{
    return std::unique_ptr<QSettings>(new QSettings(portableFilePath(), QSettings::IniFormat));
}

std::unique_ptr<QSettings> MoneroSettings::unportableSettings() const
{
    if (this->m_fileName.isEmpty()) {
        return std::unique_ptr<QSettings>(new QSettings());
    }
    return std::unique_ptr<QSettings>(new QSettings(this->m_fileName, QSettings::IniFormat));
}

void MoneroSettings::swap(std::unique_ptr<QSettings> newSettings)
{
    const QMetaObject *mo = this->metaObject();
    const int count = mo->propertyCount();
    for (int offset = mo->propertyOffset(); offset < count; ++offset) {
        const QMetaProperty &property = mo->property(offset);
        const QVariant value = readProperty(property);
        newSettings->setValue(property.name(), value);
    }

    this->m_settings.swap(newSettings);
    this->m_settings->sync();
    emit portableChanged();
}

void MoneroSettings::setFileName(const QString &fileName)
{
    if (fileName != this->m_fileName) {
        this->reset();
        this->m_fileName = fileName;
        if (this->m_initialized)
            this->load();
    }
}

QString MoneroSettings::fileName() const
{
    return this->m_fileName;
}

bool MoneroSettings::setPortable(bool enabled)
{
    std::unique_ptr<QSettings> newSettings = enabled ? portableSettings() : unportableSettings();
    if (newSettings->status() != QSettings::NoError) return false;

    setWritable(true);
    swap(std::move(newSettings));

    if (!enabled) {
        QFile::remove(portableFilePath());
    }
    return true;
}

void MoneroSettings::setWritable(bool enabled)
{
    m_writable = enabled;
}

bool MoneroSettings::i2pEnabled() const
{
    return m_settings ? m_settings->value("i2pEnabled", false).toBool() : false;
}

void MoneroSettings::setI2pEnabled(bool enabled)
{
    if (!m_settings) return;
    bool current = m_settings->value("i2pEnabled", false).toBool();
    if (current == enabled) return;
    m_settings->setValue("i2pEnabled", enabled);
    emit i2pEnabledChanged();
}

QString MoneroSettings::i2pConnectionMethod() const
{
    return m_settings ? m_settings->value("i2pConnectionMethod", "auto").toString() : QString("auto");
}

void MoneroSettings::setI2pConnectionMethod(const QString &method)
{
    if (!m_settings) return;
    QString current = m_settings->value("i2pConnectionMethod", "auto").toString();
    if (current == method) return;
    m_settings->setValue("i2pConnectionMethod", method);
    emit i2pConnectionMethodChanged();
}

QStringList MoneroSettings::i2pTrustedNodes() const
{
    return m_settings ? m_settings->value("i2pTrustedNodes").toStringList() : QStringList();
}

void MoneroSettings::setI2pTrustedNodes(const QStringList &nodes)
{
    if (!m_settings) return;
    QStringList current = m_settings->value("i2pTrustedNodes").toStringList();
    if (current == nodes) return;
    m_settings->setValue("i2pTrustedNodes", nodes);
    emit i2pTrustedNodesChanged();
}

int MoneroSettings::anonymityNetwork() const
{
    return m_settings ? m_settings->value("anonymityNetwork", 0).toInt() : 0;
}

void MoneroSettings::setAnonymityNetwork(int value)
{
    if (!m_settings) return;
    int current = m_settings->value("anonymityNetwork", 0).toInt();
    if (current == value) return;
    m_settings->setValue("anonymityNetwork", value);
    emit anonymityNetworkChanged();
}

QString MoneroSettings::i2pAddress() const
{
    return m_settings ? m_settings->value("i2pAddress", "").toString() : QString("");
}

void MoneroSettings::setI2pAddress(const QString &address)
{
    if (!m_settings) return;
    QString current = m_settings->value("i2pAddress", "").toString();
    if (current == address) return;
    m_settings->setValue("i2pAddress", address);
    emit i2pAddressChanged();
}

void MoneroSettings::timerEvent(QTimerEvent *event)
{
    if (event->timerId() == this->m_timerId) {
        killTimer(this->m_timerId);
        this->m_timerId = 0;
        this->store();
    }
    QObject::timerEvent(event);
}

void MoneroSettings::componentComplete()
{
    this->init();
}

void MoneroSettings::classBegin()
{
}
