#ifndef VIRTUALBOX_H
#define VIRTUALBOX_H

#include <QApplication>


class VirtualBox
{
public:
    VirtualBox();
    static bool detect();
    static bool detect3DAcceleration();

private:
    static bool cachedDetected;
    static bool cachedDetected3DAcceleration;
    static bool detectCache;
    static bool detect3DAccelerationCache;
};

#endif // VIRTUALBOX_H
