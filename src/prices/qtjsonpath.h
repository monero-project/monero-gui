// Copyright (c) 2018, The Monero Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#ifndef QTJSONPATH_H
#define QTJSONPATH_H


#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QStringList>
#include <QString>
#include <QVariant>

/**
 * Taken from lib-qt-qml-tricks (https://github.com/Cavewhere/lib-qt-qml-tricks)
 */

class QtJsonPath {
public:
    explicit QtJsonPath (QJsonValue & jsonVal) {
        QJsonObject jsonObj = jsonVal.toObject ();
        if (!jsonObj.isEmpty ()) {
            initWithNode (jsonObj);
        }
        else {
            QJsonArray jsonArray = jsonVal.toArray ();
            if (!jsonArray.isEmpty ()) {
                initWithNode (jsonArray);
            }
            else { }
        }
    }

    explicit QtJsonPath (QJsonObject & jsonObj) {
        initWithNode (jsonObj);
    }

    explicit QtJsonPath (QJsonArray & jsonArray) {
        initWithNode (jsonArray);
    }

    explicit QtJsonPath (QJsonDocument & jsonDoc) {
        QJsonObject jsonObj = jsonDoc.object ();
        if (!jsonObj.isEmpty ()) {
            initWithNode (jsonObj);
        }
        else {
            QJsonArray jsonArray = jsonDoc.array ();
            if (!jsonArray.isEmpty ()) {
                initWithNode (jsonArray);
            }
            else { }
        }
    }

    QVariant getValue (QString path, QVariant fallback = QVariant ()) const {
        QVariant ret;
        QStringList list = path.split ('/', QString::SkipEmptyParts);
        if (!list.empty () && !m_rootNode.isUndefined () && !m_rootNode.isNull ()) {
            QJsonValue currNode = m_rootNode;
            bool error = false;
            int len = list.size ();
            for (int depth = 0; (depth < len) && (!error); depth++) {
                QString part = list.at (depth);
                bool isNum = false;
                int index = part.toInt (&isNum, 10);
                if (isNum) { // NOTE : array subpath
                    if (currNode.isArray ()) {
                        QJsonArray arrayNode = currNode.toArray ();
                        if (index < arrayNode.size ()) {
                            currNode = arrayNode.at (index);
                        }
                        else { error = true; }
                    }
                    else { error = true; }
                }
                else { // NOTE : object subpath
                    if (currNode.isObject ()) {
                        QJsonObject objNode = currNode.toObject ();
                        if (objNode.contains (part)) {
                            currNode = objNode.value (part);
                        }
                        else { error = true; }
                    }
                    else { error = true; }
                }
            }
            ret = (!error ? currNode.toVariant () : fallback);
        }
        return ret;
    }

protected:
    void initWithNode (QJsonValue jsonNode) {
        m_rootNode = jsonNode;
    }

private:
    QJsonValue m_rootNode;
};

#endif // QTJSONPATH_H
