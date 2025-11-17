// Copyright (c) 2024, The Monero Project
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

import QtQuick 6.65
import QtTest 1.2
import "../components" as MoneroComponents

TestCase {
    id: testCase
    name: "CheckBoxTest"
    width: 400
    height: 300
    when: windowShown

    property var checkBox: null

    function initTestCase() {
        // Initialize test case
    }

    function cleanupTestCase() {
        // Cleanup after all tests
    }

    function init() {
        // Setup before each test
        checkBox = Qt.createQmlObject('
            import QtQuick 6.65
            import "../components" as MoneroComponents
            MoneroComponents.CheckBox {
                id: testCheckBox
                text: "Test CheckBox"
                checked: false
            }
        ', testCase, "CheckBoxTest.qml")
    }

    function cleanup() {
        // Cleanup after each test
        if (checkBox) {
            checkBox.destroy()
            checkBox = null
        }
    }

    function test_color_binding_when_unchecked() {
        // Test that label color is defaultFontColor when unchecked
        verify(checkBox !== null, "CheckBox should be created")
        verify(checkBox.checked === false, "CheckBox should start unchecked")
        
        // Find the label component
        var label = findChild(checkBox, "label")
        verify(label !== null, "Label should exist")
        
        // When unchecked, color should be defaultFontColor (not red)
        // Note: We can't directly access MoneroComponents.Style.defaultFontColor in test,
        // but we can verify it's not "red"
        verify(label.color !== "red", "Label color should not be red when unchecked")
    }

    function test_color_binding_when_checked() {
        // Test that label color changes to red when checked
        verify(checkBox !== null, "CheckBox should be created")
        
        // Find the label component
        var label = findChild(checkBox, "label")
        verify(label !== null, "Label should exist")
        
        // Set checked to true
        checkBox.checked = true
        wait(10) // Small delay for binding update
        
        // When checked, color should be "red"
        compare(label.color, "red", "Label color should be red when checked")
    }

    function test_color_binding_toggle() {
        // Test that color binding updates correctly when toggling checked state
        verify(checkBox !== null, "CheckBox should be created")
        
        var label = findChild(checkBox, "label")
        verify(label !== null, "Label should exist")
        
        // Start unchecked - should not be red
        verify(checkBox.checked === false, "Should start unchecked")
        verify(label.color !== "red", "Should not be red when unchecked")
        
        // Toggle to checked - should be red
        checkBox.checked = true
        wait(10)
        compare(label.color, "red", "Should be red when checked")
        
        // Toggle back to unchecked - should not be red
        checkBox.checked = false
        wait(10)
        verify(label.color !== "red", "Should not be red when unchecked again")
    }

    function test_textFormat_richText() {
        // Test that Text.RichText format is set (Qt6 compatibility)
        verify(checkBox !== null, "CheckBox should be created")
        
        var label = findChild(checkBox, "label")
        verify(label !== null, "Label should exist")
        
        // Verify RichText format is set for Qt6 compatibility
        compare(label.textFormat, Text.RichText, "Text format should be RichText for Qt6 compatibility")
    }

    // Helper function to find child by objectName or id
    function findChild(parent, name) {
        if (!parent) return null
        if (parent.objectName === name || parent.id === name) return parent
        
        for (var i = 0; i < parent.children.length; i++) {
            var child = findChild(parent.children[i], name)
            if (child) return child
        }
        return null
    }
}

