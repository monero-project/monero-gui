import QtQuick 6.6

QtObject {
    id: object
    default property alias children: object.__children

    property list<QtObject> __children: [QtObject {}]
}
