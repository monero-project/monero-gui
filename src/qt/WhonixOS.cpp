#include "WhonixOS.h"
#include "utils.h"

bool WhonixOS::detect()
{
    if (!fileExists("/usr/share/anon-ws-base-files/workstation"))
        return false;

#ifdef QT_DEBUG
    qDebug() << "Whonix OS detected";
#endif

    return true;
}
