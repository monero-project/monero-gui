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


import QtQuick 2.9
import QtTest 1.2

import "../../js/Utils.js" as Utils
import "../../js/Wizard.js" as Wizard

Item {
    id: appWindow

    property alias persistentSettings: persistentSettings

    QtObject {
        id: persistentSettings
        // NetworkType.MAINNET, spelled out so this file needs no wallet backend
        property int nettype: 0
    }

    TestCase {
        name: "Utils"

        function test_restore_height_stays_a_height() {
            compare(Utils.parseDateStringOrRestoreHeightAsInteger("0"), 0)
            compare(Utils.parseDateStringOrRestoreHeightAsInteger("1234567"), 1234567)
        }

        function test_hyphenated_date_becomes_a_height() {
            var height = Utils.parseDateStringOrRestoreHeightAsInteger("2020-12-25")
            compare(height, Wizard.getApproximateBlockchainHeight("2020-12-25", "Mainnet"))
            verify(height > 0)
        }

        function test_compact_date_matches_hyphenated_date() {
            // A date typed without hyphens has to keep working as the years go by,
            // otherwise it silently turns into a restore height millions of blocks
            // into the future.
            var year = new Date().getFullYear()
            var compact = Utils.parseDateStringOrRestoreHeightAsInteger(year + "0315")
            compare(compact, Utils.parseDateStringOrRestoreHeightAsInteger(year + "-03-15"))
            verify(compact > 0)
        }

        function test_compact_number_before_monero_stays_a_height() {
            compare(Utils.parseDateStringOrRestoreHeightAsInteger("20130315"), 20130315)
        }
    }
}
