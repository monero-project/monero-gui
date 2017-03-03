#ifndef MAINAPP_H
#define MAINAPP_H
#include <QApplication>

class MainApp : public QApplication
{
    Q_OBJECT
public:
    MainApp(int &argc, char** argv) : QApplication(argc, argv) {};
private:
    bool event(QEvent *e);
signals:
    void closing();
};

#endif // MAINAPP_H


