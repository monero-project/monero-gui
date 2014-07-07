#ifndef FILTER_H
#define FILTER_H

#include <QObject>

class filter : public QObject
{
    Q_OBJECT

private:
    bool m_ctrlPressed;

public:
    explicit filter(QObject *parent = 0);

protected:
    bool eventFilter(QObject *obj, QEvent *ev);

signals:
    void ctrlPressed();
    void ctrlReleased();
};

#endif // FILTER_H
