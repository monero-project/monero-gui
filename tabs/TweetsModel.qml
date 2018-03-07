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

import QtQuick 2.2
import "tweetSearch.js" as Helper

Item {
    id: wrapper

    // Insert valid consumer key and secret tokens below
    // See https://dev.twitter.com/apps
//! [auth tokens]
    property string tweetsMaxCount: "20"
    property string consumerKey : ""
    property string consumerSecret : ""
//! [auth tokens]
    property string bearerToken : ""

    property variant model: tweets
    property string from : ""
    property string phrase : ""

    property int status: XMLHttpRequest.UNSENT
    property bool isLoading: status === XMLHttpRequest.LOADING
    property bool wasLoading: false
    signal isLoaded

    ListModel { id: tweets }

    function encodePhrase(x) { return encodeURIComponent(x); }

    function reload() {
        tweets.clear()
        if (from == "" && phrase == "")
            return;
        //! [requesting]
        var req = new XMLHttpRequest;
        req.open("GET", "https://api.twitter.com/1.1/search/tweets.json?from=" + from +
                 "&count=" + tweetsMaxCount + "&q=" + encodePhrase(phrase));
        req.setRequestHeader("Authorization", "Bearer " + bearerToken);
        req.onreadystatechange = function() {
            status = req.readyState;
            if (status === XMLHttpRequest.DONE) {
                var objectArray = JSON.parse(req.responseText);
                if (objectArray.errors !== undefined)
                    console.log("Error fetching tweets: " + objectArray.errors[0].message)
                else {
                    for (var key in objectArray.statuses) {
                        var jsonObject = objectArray.statuses[key];
                        tweets.append(jsonObject);
                    }
                }
                if (wasLoading == true)
                    wrapper.isLoaded()
            }
            wasLoading = (status === XMLHttpRequest.LOADING);
        }
        req.send();
        //! [requesting]
    }

    Component.onCompleted: {
        if (consumerKey === "" || consumerSecret == "") {
            console.log("setting demo token")
            bearerToken = encodeURIComponent(Helper.demoToken())
            tweetsModel.phrase = ""
            tweetsModel.from = "@monerocurrency"
            // reload()
            return;
        }

        var authReq = new XMLHttpRequest;
        authReq.open("POST", "https://api.twitter.com/oauth2/token");
        authReq.setRequestHeader("Content-Type", "application/x-www-form-urlencoded;charset=UTF-8");
        authReq.setRequestHeader("Authorization", "Basic " + Qt.btoa(consumerKey + ":" + consumerSecret));
        authReq.onreadystatechange = function() {
            if (authReq.readyState === XMLHttpRequest.DONE) {
                var jsonResponse = JSON.parse(authReq.responseText);
                if (jsonResponse.errors !== undefined)
                    console.log("Authentication error: " + jsonResponse.errors[0].message)
                else
                    bearerToken = jsonResponse.access_token;
            }
        }
        authReq.send("grant_type=client_credentials");
    }

}
