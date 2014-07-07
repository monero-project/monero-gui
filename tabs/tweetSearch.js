.pragma library

function formatDate(date) {
    var da = new Date(date)
    return da.toDateString()
}

function demoToken() {
    var a = new Array(22).join('A')
    return a + String.fromCharCode(0x44, 0x69, 0x4a, 0x52, 0x51, 0x41, 0x41, 0x41, 0x41,
                                   0x41, 0x41, 0x74, 0x2b, 0x72, 0x6a, 0x6c, 0x2b, 0x71,
                                   0x6d, 0x7a, 0x30, 0x72, 0x63, 0x79, 0x2b, 0x42, 0x62,
                                   0x75, 0x58, 0x42, 0x42, 0x73, 0x72, 0x55, 0x48, 0x47,
                                   0x45, 0x67, 0x3d, 0x71, 0x30, 0x45, 0x4b, 0x32, 0x61,
                                   0x57, 0x71, 0x51, 0x4d, 0x62, 0x31, 0x35, 0x67, 0x43,
                                   0x5a, 0x4e, 0x77, 0x5a, 0x6f, 0x39, 0x79, 0x71, 0x61,
                                   0x65, 0x30, 0x68, 0x70, 0x65, 0x32, 0x46, 0x44, 0x73,
                                   0x53, 0x39, 0x32, 0x57, 0x41, 0x75, 0x30, 0x67)
}

function linkForEntity(entity) {
    return (entity.url ? entity.url :
           (entity.screen_name ? 'https://twitter.com/' + entity.screen_name :
                                 'https://twitter.com/search?q=%23' + entity.text))
}

function textForEntity(entity) {
    return (entity.display_url ? entity.display_url :
           (entity.screen_name ? entity.screen_name : entity.text))
}

function insertLinks(text, entities) {
    if (typeof text !== 'string')
        return "";

    if (!entities)
        return text;

    // Add all links (urls, usernames and hashtags) to an array and sort them in
    // descending order of appearance in text
    var links = []
    if (entities.urls)
        links = entities.urls.concat(entities.hashtags, entities.user_mentions)
    else if (entities.url)
        links = entities.url.urls

    links.sort(function(a, b) { return b.indices[0] - a.indices[0] })

    for (var i = 0; i < links.length; i++) {
        var offset = links[i].url ? 0 : 1
        text = text.substring(0, links[i].indices[0] + offset) +
            '<a href=\"' + linkForEntity(links[i]) + '\">' +
            textForEntity(links[i]) + '</a>' +
            text.substring(links[i].indices[1])
    }
    return text.replace(/\n/g, '<br>');
}

function boldLinks(text, entities) {
    if (typeof text !== 'string')
        return "";

    if (!entities)
        return text;

    // Add all links (urls, usernames and hashtags) to an array and sort them in
    // descending order of appearance in text
    var links = []
    if (entities.urls)
        links = entities.urls.concat(entities.hashtags, entities.user_mentions)
    else if (entities.url)
        links = entities.url.urls

    links.sort(function(a, b) { return b.indices[0] - a.indices[0] })

    for (var i = 0; i < links.length; i++) {
        var offset = links[i].url ? 0 : 1
        text = text.substring(0, links[i].indices[0] + offset) +
            '<b>' + textForEntity(links[i]) + '</b>' +
            text.substring(links[i].indices[1])
    }
    return text.replace(/\n/g, '<br>');
}
