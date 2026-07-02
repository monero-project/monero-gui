#include "VirtualBox.h"

#include <QProcess>
#include <QStandardPaths>

bool VirtualBox::m_cachedDetected = false;
bool VirtualBox::m_cachedDetected3D = false;
bool VirtualBox::m_detected = false;
bool VirtualBox::m_detected3D = false;

bool VirtualBox::detect()
{
    if (m_cachedDetected)
        return m_detected;

#ifdef Q_OS_LINUX
    const QString detectVirtPath = QStandardPaths::findExecutable("systemd-detect-virt");
    if (detectVirtPath.isEmpty()) {
        m_detected = false;
        m_cachedDetected = true;
        return false;
    }

    QProcess process;
    process.start(detectVirtPath, QStringList() << "--vm");
    if (!process.waitForFinished(2000)) {
        m_detected = false;
        m_cachedDetected = true;
        return false;
    }

    const QString output = QString::fromUtf8(process.readAllStandardOutput()).trimmed().toLower();
    m_detected = output == "oracle";
#else
    m_detected = false;
#endif

    m_cachedDetected = true;
    return m_detected;
}

bool VirtualBox::detect3DAcceleration()
{
    if (m_cachedDetected3D)
        return m_detected3D;

#ifdef Q_OS_LINUX
    if (!detect()) {
        m_detected3D = false;
        m_cachedDetected3D = true;
        return false;
    }

    const QString glxInfoPath = QStandardPaths::findExecutable("glxinfo");
    if (glxInfoPath.isEmpty()) {
        m_detected3D = false;
        m_cachedDetected3D = true;
        return false;
    }

    QProcess process;
    process.start(glxInfoPath, QStringList());
    if (!process.waitForFinished(3000)) {
        m_detected3D = false;
        m_cachedDetected3D = true;
        return false;
    }

    const QString output = QString::fromUtf8(process.readAllStandardOutput()).toLower();
    m_detected3D = output.contains("opengl renderer string") && output.contains("svga3d");
#else
    m_detected3D = false;
#endif

    m_cachedDetected3D = true;
    return m_detected3D;
}
