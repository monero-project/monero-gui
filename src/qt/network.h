#pragma once

#include <QCoreApplication>
#include <QtNetwork>

#include "FutureScheduler.h"

class Network : public QObject
{
    Q_OBJECT
public:
    Network(QObject *parent = nullptr);

public:
    Q_INVOKABLE void get(const QString &url, const QJSValue &callback, const QString &contentType = {}) const;
    Q_INVOKABLE void getJSON(const QString &url, const QJSValue &callback) const;

private:
    mutable FutureScheduler m_scheduler;
};
