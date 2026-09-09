#include "WhonixOS.h"

#include <QDebug>
#include <QProcess>

#include "utils.h"

#include <iostream>

bool WhonixOS::detect()
{
    const bool detected = fileExists("/usr/share/whonix/marker");

    return detected;
}

bool WhonixOS::detectQubes()
{
    const bool detected = fileExists("/usr/share/qubes/marker-vm");

    return detected;
}

QString WhonixOS::gatewayAddress(bool isQubes)
{
    if (!isQubes)
        return QStringLiteral("10.152.152.10");

    QProcess process;
    process.start(QStringLiteral("qubesdb-read"), QStringList() << QStringLiteral("/qubes-gateway"));

    if (!process.waitForStarted(2000)) {
        qWarning() << "Unable to start qubesdb-read for the Qubes-Whonix gateway address";
        return QString();
    }

    if (!process.waitForFinished(2000)) {
        process.kill();
        process.waitForFinished(2000);
        qWarning() << "Timed out reading the Qubes-Whonix gateway address";
        return QString();
    }

    if (process.exitStatus() != QProcess::NormalExit || process.exitCode() != 0) {
        qWarning() << "Unable to read the Qubes-Whonix gateway address";
        return QString();
    }

    return QString::fromUtf8(process.readAllStandardOutput()).trimmed();
}
