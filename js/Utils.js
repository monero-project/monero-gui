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
    updateBalance();
}

function ago(epoch) {
    // Returns '<delta> [seconds|minutes|hours|days] ago' string given an epoch

    var now = new Date().getTime() / 1000;
    var delta = now - epoch;

    if(delta < 60)
        return qsTr("%n second(s) ago", "0", Math.floor(delta))
    else if (delta >= 60 && delta <= 3600)
        return qsTr("%n minute(s) ago", "0", Math.floor(delta / 60))
    else if (delta >= 3600 && delta <= 86400)
        return qsTr("%n hour(s) ago", "0", Math.floor(delta / 60 / 60))
    else if (delta >= 86400)
        return qsTr("%n day(s) ago", "0", Math.floor(delta / 24 / 60 / 60))
}

function netTypeToString(){
    // 0: mainnet, 1: testnet, 2: stagenet
    var nettype = appWindow.persistentSettings.nettype;
    return nettype == 1 ? qsTr("Testnet") : nettype == 2 ? qsTr("Stagenet") : qsTr("Mainnet");
}

function epoch(){
    return Math.floor((new Date).getTime()/1000);
}

function roundDownToNearestThousand(_num){
    return Math.floor(_num/1000.0)*1000
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

function capitalize(s){
    if (typeof s !== 'string') return ''
    return s.charAt(0).toUpperCase() + s.slice(1)
}

function removeTrailingZeros(value) {
    return (value + '').replace(/(\.\d*?)0+$/, '$1').replace(/\.$/, '');
}
