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

function finishSettingsLoad(settings) {
    // Qt may save defaults over existing settings when a new setting is added.
    // Refresh the pending save after all settings have loaded.
    settings.wallet_pathChanged();
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
    var delta = Math.max(now - epoch, 0);

    if(delta < 60)
        return qsTr("%n second(s) ago", "0", Math.floor(delta))
    else if (delta < 3600)
        return qsTr("%n minute(s) ago", "0", Math.floor(delta / 60))
    else if (delta < 86400)
        return qsTr("%n hour(s) ago", "0", Math.floor(delta / 3600))
    else
        return qsTr("%n day(s) ago", "0", Math.floor(delta / 86400))
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

var denominationShift = {
    "xmr": 0,
    "mxmr": 3,
    "atomic": 12,
};

var denominationUnitLabel = {
    "xmr": "XMR",
    "mxmr": "mXMR",
    "atomic": "atomic units",
};

function shiftDecimalPlaces(numberString, places) {
    var negative = numberString.charAt(0) === '-';
    if (negative) numberString = numberString.substring(1);

    var dotIndex = numberString.indexOf('.');
    var intPart = dotIndex === -1 ? numberString : numberString.substring(0, dotIndex);
    var fracPart = dotIndex === -1 ? '' : numberString.substring(dotIndex + 1);

    while (fracPart.length < places) fracPart += '0';
    intPart += fracPart.substring(0, places);
    fracPart = fracPart.substring(places);

    intPart = intPart.replace(/^0+(?=\d)/, '');
    var result = fracPart.length > 0 ? (intPart + '.' + fracPart) : intPart;
    return (negative ? '-' : '') + result;
}

function currentDenomination() {
    var denomination = appWindow.persistentSettings.displayDenomination;
    return denominationShift.hasOwnProperty(denomination) ? denomination : "xmr";
}

function addThousandsSeparators(numberString) {
    var negative = numberString.charAt(0) === '-';
    if (negative) numberString = numberString.substring(1);

    var dotIndex = numberString.indexOf('.');
    var intPart = dotIndex === -1 ? numberString : numberString.substring(0, dotIndex);
    var fracPart = dotIndex === -1 ? '' : numberString.substring(dotIndex);

    var grouped = '';
    for (var i = 0; i < intPart.length; ++i) {
        var digitsFromEnd = intPart.length - i;
        if (i > 0 && digitsFromEnd % 3 === 0) {
            grouped += ',';
        }
        grouped += intPart.charAt(i);
    }

    return (negative ? '-' : '') + grouped + fracPart;
}

function denominate(xmrAmountString) {
    var shifted = shiftDecimalPlaces(xmrAmountString, denominationShift[currentDenomination()]);
    return addThousandsSeparators(shifted);
}

function hiddenBalancePlaceholder() {
    return currentDenomination() === "atomic" ? "?" : "?.??";
}

function denominationUnit() {
    return denominationUnitLabel[currentDenomination()];
}

function parseDateStringOrRestoreHeightAsInteger(value) {
    // Parse date string or restore height as integer
    var restoreHeight = 0;
    if (value.indexOf('-') === 4 && value.length === 10) {
        restoreHeight = Wizard.getApproximateBlockchainHeight(value, Utils.netTypeToString());
    } else if (parseInt(value.substring(0, 4)) >= 2014 && parseInt(value.substring(0, 4)) <= new Date().getFullYear() && value.length === 8) {
        // Correct date typed in a wrong format (20201225 instead of 2020-12-25)
        var restoreHeightHyphenated = value.substring(0, 4) + "-" + value.substring(4, 6) + "-" + value.substring(6, 8);
        restoreHeight = Wizard.getApproximateBlockchainHeight(restoreHeightHyphenated, Utils.netTypeToString());
    } else {
        restoreHeight = parseInt(value);
    }
    return restoreHeight;
}

function htmlEscape(s) {
    if (s === null || s === undefined)
        return "";
    return String(s)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;");
}
