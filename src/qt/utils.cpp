#include <QtCore>

#include "utils.h"

bool fileExists(QString path) {
    QFileInfo check_file(path);
    if (check_file.exists() && check_file.isFile())
        return true;
    else
        return false;
}

QString getAccountName(){
    QString accountName = qgetenv("USER"); // mac/linux
    if (accountName.isEmpty())
        accountName = qgetenv("USERNAME"); // Windows
    if (accountName.isEmpty())
        accountName = "My monero Account";
    return accountName;
}
