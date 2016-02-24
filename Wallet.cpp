#include "Wallet.h"

struct WalletImpl
{
    // TODO
};



Wallet::Wallet(QObject *parent)
    : QObject(parent)
{

}


QString Wallet::getSeed() const
{
    return "bound class paint gasp task soul forgot past pleasure physical circle "
           " appear shore bathroom glove women crap busy beauty bliss idea give needle burden";
}

QString Wallet::getSeedLanguage() const
{
    return "English";
}

void Wallet::setSeedLaguage(const QString &lang)
{
    // TODO;
}
