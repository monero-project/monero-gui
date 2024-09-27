#ifndef URREGISTER_H
#define URREGISTER_H


class QQmlApplicationEngine;

namespace OtsUr {
    void registerTypes();
    void setupContext(QQmlApplicationEngine &engine);
    void setupCamera(QQmlApplicationEngine &engine);
}

#endif // URREGISTER_H
