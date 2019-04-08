/**
 * Formats a date.
 * @param {date} date - toggle decorations
 * @param {params} params - 
 */
function formatDate( date, params ) {
    var options = {
        weekday: "short",
        year: "numeric",
        month: "long",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
        timeZone: "UTC",
        timeZoneName: "short",
    };

    options = [options, params].reduce(function (r, o) {
        Object.keys(o).forEach(function (k) { r[k] = o[k]; });
        return r;
    }, {});

    // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/toLocaleString
    return new Date( date ).toLocaleString( 'en-US', options );
}

function isNumeric(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}

function showSeedPage() {
    // Shows `Settings->Seed & keys`. Prompts a password dialog.
    passwordDialog.onAcceptedCallback = function() {
        if(walletPassword === passwordDialog.password){
            if(currentWallet.seedLanguage == "") {
                console.log("No seed language set. Using English as default");
                currentWallet.setSeedLanguage("English");
            }
            // Load keys page
            appWindow.showPageRequest("Keys");
        } else {
            passwordDialog.showError(qsTr("Wrong password"));
        }
    }
    passwordDialog.onRejectedCallback = function() {
        leftPanel.selectItem(middlePanel.state);
    }
    passwordDialog.open();
    if(isMobile) hideMenu();
    updateBalance();
}

function ago(epoch) {
    // Returns '<delta> [seconds|minutes|hours|days] ago' string given an epoch

    var now = new Date().getTime() / 1000;
    var delta = now - epoch;

    if(delta < 60) {
        if (delta <= 1) {
            return 1 + " " + qsTr("second ago")
        } else {
            return Math.floor(delta) + " " + qsTr("seconds ago")
        }
    } else if (delta >= 60 && delta <= 3600) {
        if(delta >= 60 && delta < 120){
            return 1 + " " + qsTr("minute ago")
        } else {
            return parseInt(Math.floor(delta / 60)) + " " + qsTr("minutes ago")
        }
    } else if (delta >= 3600 && delta <= 86400) {
        if(delta >= 3600 && delta < 7200) {
            return 1 + " " + qsTr("hour ago")
        } else {
            return parseInt(Math.floor(delta / 60 / 60)) + " " + qsTr("hours ago")
        }
    } else if (delta >= 86400){
        if(delta >= 86400 && delta < 172800) {
            return 1 + " " + qsTr("day ago")
        } else {
            var _delta = parseInt(Math.floor(delta / 24 / 60 / 60));
            if(_delta === 1) {
                return 1 + " " + qsTr("day ago")
            } else {
                return _delta + " " + qsTr("days ago")
            }
        }
    }
}

function netTypeToString(){
    // 0: mainnet, 1: testnet, 2: stagenet
    var nettype = appWindow.persistentSettings.nettype;
    return nettype == 1 ? qsTr("Testnet") : nettype == 2 ? qsTr("Stagenet") : qsTr("Mainnet");
}

function randomChoice(arr){
    return arr[Math.floor(Math.random() * arr.length)];
}

function filterNodes(nodes, port) {
    if(typeof data === 'number')
        port = port.toString();
    return nodes.filter(function(_){return _.indexOf(port) !== -1});
}

function epoch(){
    return Math.floor((new Date).getTime()/1000);
}

function isAlpha(letter){ return letter.match(/^[A-Za-z0-9]+$/) !== null; }

function isLowerCaseChar(letter){ return letter === letter.toLowerCase(); }

function isUpperLock(shift, letter){
    if(!isAlpha((letter))) return false;
    if(shift) {
        if(isLowerCaseChar(letter))
            return true;
        else
            return false;
    } else {
        if(isLowerCaseChar(letter))
            return false;
        else
            return true;
    }
}

function qmlEach(item, properties, ignoredObjectNames, arr){
    // Traverse QML object tree and return components that match
    // via property names. Similar to jQuery("myclass").each(...
    // item: root QML object
    // properties: list of strings
    // ignoredObjectNames: list of strings
    if(typeof(arr) == 'undefined') arr = [];
    if(item.hasOwnProperty('data') && item['data'].length > 0){
        for(var i = 0; i < item['data'].length; i += 1){
            arr = qmlEach(item['data'][i], properties, ignoredObjectNames, arr);
        }
    }

    // ignore QML objects on .objectName
    for(var a = 0; a < ignoredObjectNames.length; a += 1){
        if(item.objectName === ignoredObjectNames[a]){
            return arr;
        }
    }

    for(var u = 0; u < properties.length; u += 1){
        if(item.hasOwnProperty(properties[u])) arr.push(item);
        else break;
    }

    return arr;
}
