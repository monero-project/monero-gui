#include "VirtualBox.h"
#include <QProcess>
#include <QDebug>

bool VirtualBox::cachedDetected = false;
bool VirtualBox::cachedDetected3DAcceleration = false;
bool VirtualBox::detectCache = false;
bool VirtualBox::detect3DAccelerationCache = false;

bool VirtualBox::detect() {
    if (cachedDetected) return detectCache;

    try {
        QProcess process;
    
        process.start("systemd-detect-virt", QStringList());
        process.waitForFinished();
        
        QString output = process.readAllStandardOutput().trimmed();
        bool found = output == "oracle";
    
#ifdef QT_DEBUG
        if (found)
            qDebug() << "VirtualBox VM detected";
#endif
    
        detectCache = found;
        cachedDetected = true;
    
        return found;
    }
    catch (const std::exception& e) {
        qWarning() << "An error occurred while checking virtualization: " << e.what();
        detectCache = false;
        cachedDetected = true;
        return false;
    }
}

bool VirtualBox::detect3DAcceleration() {
    if (cachedDetected3DAcceleration) return detect3DAccelerationCache;
    if (!detect()) { 
        detect3DAccelerationCache = false;
        cachedDetected3DAcceleration = true;
        return false;
    }

    try {
        QProcess process;

        process.start("sh", QStringList() << "-c" << "glxinfo | grep 'OpenGL renderer'");
        process.waitForFinished();
    
        bool found = process.readAllStandardOutput().trimmed().contains("SVGA3D");
    
#ifdef QT_DEBUG
        if (found)
            qDebug() << "VirtualBox 3D acceleration detected";
#endif
    
        detect3DAccelerationCache = found;
        cachedDetected3DAcceleration = true;
    
        return found;
    }
    catch (const std::exception& e) {
        qWarning() << "An error occurred while hardware acceleration: " << e.what();
        detect3DAccelerationCache = false;
        cachedDetected3DAcceleration = true;
        return false;
    }

}
