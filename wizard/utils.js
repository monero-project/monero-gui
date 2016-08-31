
.pragma library

// grabbed from SO answer page: http://stackoverflow.com/questions/948172/password-strength-meter

function scorePassword(pass) {
    var score = 0;
    if (!pass)
        return score;

    // award every unique letter until 5 repetitions
    var letters = {};
    for (var i=0; i<pass.length; i++) {
        letters[pass[i]] = (letters[pass[i]] || 0) + 1;
        score += 5.0 / letters[pass[i]];
    }

    // bonus points for mixing it up
    var variations = {
        digits: /\d/.test(pass),
        lower: /[a-z]/.test(pass),
        upper: /[A-Z]/.test(pass),
        nonWords: /\W/.test(pass),
    }

    var variationCount = 0;
    for (var check in variations) {
        variationCount += (variations[check] === true) ? 1 : 0;
    }
    score += (variationCount - 1) * 10;

    return parseInt(score);
}

function mapScope (inputScopeFrom, inputScopeTo, outputScopeFrom, outputScopeTo, value) {
    var x = (value - inputScopeFrom) / (inputScopeTo - inputScopeFrom);
    var result = outputScopeFrom + ((outputScopeTo - outputScopeFrom) * x);
    return result;
}


function tr(text) {
    return qsTr(text) + translationManager.emptyString
}


function lineBreaksToSpaces(text) {
    return text.trim().replace(/(\r\n|\n|\r)/gm, " ");
}
