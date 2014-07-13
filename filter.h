#ifndef FILTER_H
#define FILTER_H

#include <QObject>

class filter : public QObject
{
    Q_OBJECT
private:
    bool m_tabPressed;

public:
    explicit filter(QObject *parent = 0);

protected:
    bool eventFilter(QObject *obj, QEvent *ev);

signals:
    void sequencePressed(const QVariant &o, const QVariant &seq);
    void sequenceReleased(const QVariant &o, const QVariant &seq);
    void mousePressed(const QVariant &o, const QVariant &x, const QVariant &y);
    void mouseReleased(const QVariant &o, const QVariant &x, const QVariant &y);
};

#endif // FILTER_H
