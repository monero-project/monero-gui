// Copyright (c) 2026, The Monero Project
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

import QtQuick
import QtCore
import QtTest
import moneroComponents.Settings 1.0

TestCase {
    id: testCase
    name: "Settings"

    property var settingsObjects: []

    property int caseNumber: 0
    property string casePath
    property string normalPath: casePath + "/host-settings.ini"
    property string portablePath: casePath + "/monero-storage/settings.ini"
    property string markerPath: casePath + "/monero-storage/.portable"

    Component {
        id: fixtureComponent
        Item {
            property alias portable: storage
            property alias settings: preferences
            PortableSettings {
                id: storage
                unportableFileName: testCase.normalPath
                settings: preferences
            }
            Settings {
                id: preferences
                location: storage.location
                property string wallet_path: ""
                property string language: "English"
                property int kdfRounds: 1
                property var nettype: 0
                property bool pruneBlockchain: false
                Component.onCompleted: wallet_pathChanged()
            }
        }
    }

    function createFixture() {
        var fixture = fixtureComponent.createObject(testCase)
        verify(fixture !== null)
        settingsObjects.push(fixture)
        return fixture
    }

    function destroySettingsObjects() {
        for (var i = 0; i < settingsObjects.length; ++i)
            settingsObjects[i].destroy()
        settingsObjects = []
        wait(0)
    }

    function init() {
        failOnWarning(/.?/)
        casePath = moneroTestRoot + "/portable-case-" + (++caseNumber)
        verify(settingsTestHelper.makeDirectory(casePath))
        verify(settingsTestHelper.setCurrentDirectory(casePath))
    }

    function cleanup() {
        destroySettingsObjects()
        verify(settingsTestHelper.setCurrentDirectory(moneroTestRoot))
    }

    function createSettingsObject(fileName, newPropertyIndex) {
        var properties = [
            "property string wallet_path: ''",
            "property string blockchainDataDir: ''",
            "property bool blackTheme: true"
        ]
        properties.splice(newPropertyIndex, 0, "property string newSetting: 'new default'")
        var source = "import QtQml\nimport QtCore\n" +
                "import " + JSON.stringify(Qt.resolvedUrl("../../js/Utils.js").toString()) + " as Utils\n" +
                "Settings {\n" +
                "id: settings\n" +
                "location: " + JSON.stringify(settingsTestHelper.fileUrl(fileName).toString()) + "\n" +
                properties.join("\n") + "\n" +
                "Component.onCompleted: Utils.finishSettingsLoad(settings)\n}"
        var settings = Qt.createQmlObject(source, testCase)
        settingsObjects.push(settings)
        return settings
    }

    function compareSavedValues(values, expected) {
        compare(values.wallet_path, expected.wallet_path)
        compare(values.blockchainDataDir, expected.blockchainDataDir)
        // QSettings may read a boolean from an INI file as a string.
        compare(String(values.blackTheme), String(expected.blackTheme))
    }

    function test_adding_setting_preserves_existing_values_data() {
        return [
            { tag: "first", newPropertyIndex: 0 },
            { tag: "middle", newPropertyIndex: 1 },
            { tag: "last", newPropertyIndex: 3 }
        ]
    }

    function test_adding_setting_preserves_existing_values(data) {
        var expected = {
            wallet_path: "/custom/wallet",
            blockchainDataDir: "/custom/blockchain",
            blackTheme: false
        }
        var fileName = moneroTestRoot + "/settings-upgrade-" + data.tag + ".ini"
        for (var key in expected)
            verify(settingsTestHelper.writeSetting(fileName, key, expected[key]))
        verify(!settingsTestHelper.containsSetting(fileName, "newSetting"))
        var settings = createSettingsObject(fileName, data.newPropertyIndex)
        compareSavedValues(settings, expected)

        // Let the delayed write happen without changing any QML properties:
        // a post-load change would refresh the snapshot and hide this regression.
        tryVerify(function() {
            return settingsTestHelper.readSetting(fileName, "newSetting") === "new default"
        })
        for (var savedKey in expected) {
            compare(String(settingsTestHelper.readSetting(fileName, savedKey)),
                    String(expected[savedKey]))
        }

        destroySettingsObjects()
        var reloadedSettings = createSettingsObject(fileName, data.newPropertyIndex)
        compareSavedValues(reloadedSettings, expected)
        compare(reloadedSettings.newSetting, "new default")
    }

    function test_legacy_portable_and_disabled_restart() {
        verify(settingsTestHelper.writeSetting(portablePath, "wallet_path", "/portable/wallet"))
        verify(settingsTestHelper.writeSetting(portablePath, "kdfRounds", 42))
        verify(settingsTestHelper.writeSetting(normalPath, "wallet_path", "/host/wallet"))
        var fixture = createFixture()
        verify(fixture.portable.portable)
        compare(fixture.settings.wallet_path, "/portable/wallet")
        compare(fixture.settings.kdfRounds, 42)

        verify(fixture.portable.setPortable(false))
        compare(settingsTestHelper.readFile(markerPath), "disabled\n")
        verify(settingsTestHelper.fileExists(portablePath))
        destroySettingsObjects()

        fixture = createFixture()
        verify(!fixture.portable.portable)
        compare(fixture.settings.wallet_path, "/portable/wallet")
        compare(fixture.settings.kdfRounds, 42)
        verify(fixture.portable.setPortable(true))
        destroySettingsObjects()

        fixture = createFixture()
        verify(fixture.portable.portable)
        compare(fixture.settings.kdfRounds, 42)
    }

    function test_pending_changes_in_both_directions() {
        verify(settingsTestHelper.writeSetting(normalPath, "language", "English"))
        verify(settingsTestHelper.writeSetting(normalPath, "nettype", 0))
        var fixture = createFixture()
        fixture.settings.language = "German"
        fixture.settings.nettype = 2
        fixture.settings.pruneBlockchain = true
        verify(fixture.portable.setPortable(true))
        compare(fixture.settings.language, "German")
        compare(fixture.settings.nettype, 2)
        verify(fixture.settings.pruneBlockchain)
        compare(settingsTestHelper.readSetting(normalPath, "language"), "German")
        compare(settingsTestHelper.readSetting(portablePath, "language"), "German")

        fixture.settings.language = "French"
        fixture.settings.nettype = 1
        verify(fixture.portable.setPortable(false))
        compare(fixture.settings.language, "French")
        compare(fixture.settings.nettype, 1)
        destroySettingsObjects()
        fixture = createFixture()
        compare(fixture.settings.language, "French")
        compare(fixture.settings.nettype, 1)
    }

    function test_first_run_portable_leaves_no_host_settings() {
        var fixture = createFixture()
        var temporaryPath = settingsTestHelper.localFilePath(fixture.portable.location)
        fixture.settings.language = "German"
        tryVerify(function() { return settingsTestHelper.fileExists(temporaryPath) })
        verify(!settingsTestHelper.fileExists(normalPath))
        verify(fixture.portable.setPortable(true))
        compare(fixture.settings.language, "German")
        verify(!settingsTestHelper.fileExists(normalPath))
        verify(!settingsTestHelper.fileExists(temporaryPath))
        destroySettingsObjects()
        verify(!settingsTestHelper.fileExists(normalPath))
    }

    function test_first_run_nonportable_commits_settings() {
        var fixture = createFixture()
        fixture.settings.language = "German"
        verify(fixture.portable.setPortable(false))
        compare(settingsTestHelper.readSetting(normalPath, "language"), "German")
        verify(!settingsTestHelper.fileExists(markerPath))
        destroySettingsObjects()
        fixture = createFixture()
        compare(fixture.settings.language, "German")
    }

    function test_exit_before_mode_selection_removes_temporary_settings() {
        var fixture = createFixture()
        var temporaryPath = settingsTestHelper.localFilePath(fixture.portable.location)
        fixture.settings.language = "German"
        destroySettingsObjects()
        verify(!settingsTestHelper.fileExists(normalPath))
        verify(!settingsTestHelper.fileExists(temporaryPath))
    }

    function test_marker_failure_preserves_existing_destination() {
        verify(settingsTestHelper.writeSetting(normalPath, "language", "English"))
        verify(settingsTestHelper.writeSetting(portablePath, "legacy", "preserve me"))
        verify(settingsTestHelper.makeDirectory(markerPath))
        var fixture = createFixture()
        fixture.settings.language = "German"
        verify(!fixture.portable.setPortable(true))
        verify(!fixture.portable.portable)
        compare(fixture.settings.language, "German")
        compare(settingsTestHelper.readSetting(portablePath, "legacy"), "preserve me")
        verify(!settingsTestHelper.containsSetting(portablePath, "language"))
    }

    function test_marker_failure_removes_new_portable_file() {
        verify(settingsTestHelper.makeDirectory(markerPath))
        var fixture = createFixture()
        fixture.settings.language = "German"
        verify(!fixture.portable.setPortable(true))
        verify(!fixture.portable.portable)
        verify(!settingsTestHelper.fileExists(portablePath))
        verify(!settingsTestHelper.fileExists(normalPath))
        destroySettingsObjects()
        fixture = createFixture()
        verify(!fixture.portable.portable)
    }
}
