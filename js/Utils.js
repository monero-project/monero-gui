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
    return (value + '').replace(/(\.\d*[1-9])0+$/, '$1');
}

function ipv6Regexes(){
    return {
        common: /^(::)?((?:[0-9a-f]+::?)+)?([0-9a-f]+)?(::)?(%[0-9a-z]{1,})?$/i,
        transitional: /^((?:(0?\d+|0x[a-f0-9]+))|(?:::)(?:(?:[0-9a-f]+::?)+)?)(0?\d+|0x[a-f0-9]+)\.(0?\d+|0x[a-f0-9]+)\.(0?\d+|0x[a-f0-9]+)\.(0?\d+|0x[a-f0-9]+)(%[0-9a-z]{1,})?$/i
    };
}

function isIPv6(value){
    // Matches an IPv6 address, 2001:db8::1 and fe80:200::1%en0 are valid (last
    // one with a zone identifier on a LL address). Also IPv4 transitional
    // mapped addresses are identified (::ffff:192.186.0.1)
    return ipv6Regexes().common.test(value) || ipv6Regexes().transitional.test(value);
}

function getAddressParts(value){
    var start_pos = value.indexOf("[");
    if(start_pos != -1){
        start_pos += 1;
        var end_pos = value.lastIndexOf("]");
        // Unclosed bracket? return value as is, it's invalid.
        if(end_pos == -1){
            return { host: value.trim(), port: "" };
        }

        // User gave us ]craziness[, it's invalid.
        if(start_pos > end_pos){
            return { host: value.trim(), port: "" };
        }

        var slice = value.slice(start_pos, end_pos);
        if(isIPv6(slice)){
            var maybe_port = "";
            if(end_pos + 1 < value.length){
                maybe_port = value.slice(end_pos + 1, value.length).split(":").pop();
            }

            return { host: slice.trim(), port: maybe_port.trim() };
        } else {
            // Not valid IPv6 address ;)
            return { host: value.trim(), port: "" };
        }
    }

    // Previous if didn't match an [ipv6 addr]:port, check if the input is just
    // an IPv6 address.
    if(isIPv6(value)) {
        return { host: value.trim(), port: "" };
    }

    // Okay, not an IPv6 address, this is for sure ;). Start parsing a common
    // DNS or IPv4 <host>:<port> host.
    if (value.search(":") != -1) {
        var split = value.split(":");
        var host = split[0].trim();
        var maybe_port = "";
        if (split.length > 1) {
            maybe_port = split.pop().trim();
        }

        return { host: host, port: maybe_port };
    } else {
        // Value is just the host, doens't have a port.
        return { host: value.trim(), port: "" };
    }
}
