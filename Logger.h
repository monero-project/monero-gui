#ifndef LOGGER_H
#define LOGGER_H

const QString getLogPath(const QString logPath);
void messageHandler(QtMsgType type, const QMessageLogContext &context, const QString &message);

#endif // LOGGER_H

