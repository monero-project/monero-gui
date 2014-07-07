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
            reload()
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
