#ifndef VIRTUALBOX_H
#define VIRTUALBOX_H

class VirtualBox
{
public:
    static bool detect();
    static bool detect3DAcceleration();

private:
    static bool m_cachedDetected;
    static bool m_cachedDetected3D;
    static bool m_detected;
    static bool m_detected3D;
};

#endif // VIRTUALBOX_H
