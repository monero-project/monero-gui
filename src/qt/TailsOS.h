#ifndef TAILSOS_H
#define TAILSOS_H

#include <QApplication>


class TailsOS
{
public:
    TailsOS();
    static bool detect();
    static bool detectDataPersistence();
    static bool detectDotPersistence();

    static void showDataPersistenceDisabledWarning();
    static void askPersistence();

    static bool usePersistence;
};

#endif // TAILSOS_H
