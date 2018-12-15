.pragma library

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

function usefulName(path) {
    // arbitrary "short enough" limit
    if (path.length < 32)
        return path
    return path.replace(/.*[\/\\]/, '').replace(/\.keys$/, '')
}

//usage: getApproximateBlockchainHeight("March 18 2016") or getApproximateBlockchainHeight("2016-11-11")
//returns estimated block height with 1 month buffer prior to requested date.
function getApproximateBlockchainHeight(_date){
    // time of monero birth 2014-04-18 10:49:53 (1397818193)
    var moneroBirthTime = 1397818193;
    // avg seconds per block in v1
    var secondsPerBlockV1 = 60;
    // time of v2 fork 2016-03-23 15:57:38 (1458748658)
    var forkTime = 1458748658;
    // v2 fork block
    var forkBlock = 1009827;
    // avg seconds per block in V2
    var secondsPerBlockV2 = 120;
    // time in UTC
    var requestedTime = Math.floor(new Date(_date) / 1000);
    var approxBlockchainHeight;
    var secondsPerBlock;
    // before monero's birth
    if (requestedTime < moneroBirthTime){
        console.log("Calculated blockchain height: 0, requestedTime < moneroBirthTime " );
        return 0;
    }
    // time between during v1
    if (requestedTime > moneroBirthTime && requestedTime < forkTime){
        approxBlockchainHeight = Math.floor((requestedTime - moneroBirthTime)/secondsPerBlockV1);
        console.log("Calculated blockchain height: " + approxBlockchainHeight );
        secondsPerBlock = secondsPerBlockV1;
    }
    // time is during V2
    else{
        approxBlockchainHeight =  Math.floor(forkBlock + (requestedTime - forkTime)/secondsPerBlockV2);
        console.log("Calculated blockchain height: " + approxBlockchainHeight );
        secondsPerBlock = secondsPerBlockV2;
    }
    var blocksPerMonth = 60*60*24*30/secondsPerBlock;
    if(approxBlockchainHeight - blocksPerMonth > 0){
        return approxBlockchainHeight - blocksPerMonth;
    }
    else{
        return 0;
    }
}
