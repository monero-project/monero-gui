#ifndef WHONIXOS_H
#define WHONIXOS_H

#include <QString>

class WhonixOS
{
public:
    static bool detect();
    static bool detectQubes();
    static QString gatewayAddress(bool isQubes);
};

#endif // WHONIXOS_H
