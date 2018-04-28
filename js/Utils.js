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