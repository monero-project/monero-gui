#ifndef CLIPBOARDADAPTER_H
#define CLIPBOARDADAPTER_H

#include <QGuiApplication>
#include <QClipboard>
#include <QObject>

class clipboardAdapter : public QObject
{
    Q_OBJECT
public:
    explicit clipboardAdapter(QObject *parent = 0);
    Q_INVOKABLE void setText(const QString &text);

private:
    QClipboard *m_pClipboard;
};

#endif // CLIPBOARDADAPTER_H
