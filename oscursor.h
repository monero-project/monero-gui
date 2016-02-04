#ifndef OSCURSOR_H
#define OSCURSOR_H


#include <QObject>
#include <QString>
#include <QPoint>
class OSCursor : public QObject
{
    Q_OBJECT
    //QObject();
public:
    //QObject(QObject* aParent);
    //OSCursor();
    explicit OSCursor(QObject *parent = 0);
    Q_INVOKABLE QPoint getPosition() const;
};

//OSCursor::OSCursor() : QObject(NULL){

//}


//Q_DECLARE_METATYPE(OSCursor)
#endif // OSCURSOR_H
