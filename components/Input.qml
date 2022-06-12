// Copyright (c) 2014-2018, The Monero Project
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

import QtQuick.Controls 2.0
import QtQuick 2.9

import "../components" as MoneroComponents

TextField {
    id: textField
    font.family: MoneroComponents.Style.fontRegular.name
    font.pixelSize: 18
    font.bold: true
    horizontalAlignment: TextInput.AlignLeft
    selectByMouse: true
    color: MoneroComponents.Style.defaultFontColor
    selectionColor: MoneroComponents.Style.textSelectionColor
    selectedTextColor: MoneroComponents.Style.textSelectedColor

    background: Rectangle {
        color: "transparent"
    }

    MoneroComponents.ContextMenu {
        cursorShape: Qt.IBeamCursor
        onCut: textField.cut();
        onCopy: textField.copy();
        onPaste: {
            var previoustextFieldLength = textField.length
            var previousCursorPosition = textField.cursorPosition;
            textField.paste();
            textField.forceActiveFocus()
            textField.cursorPosition = previousCursorPosition + (textField.length - previoustextFieldLength);
        }
        onRemove: textField.remove(selectionStart, selectionEnd);
        onSelectAll: textField.selectAll();
    }
}
