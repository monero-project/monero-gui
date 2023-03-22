function destinationsToAmount(destinations){
    // Gets amount from destinations line
    // input: "20.000000000000: 9tLGyK277MnYrDc7Vzi6TB1pJvstFoviziFwsqQNFbwA9rvg5RxYVYjEezFKDjvDHgAzTELJhJHVx6JAaWZKeVqSUZkXeKk"
    // returns: 20.000000000000
    return destinations.split(" ")[0].split(":")[0];
}

function destinationsToAddress(destinations){
    var address = destinations.split(" ")[1];
    if(address === undefined) return ""
    return address;
}

function addressTruncate(address, range){
    if(typeof(address) === "undefined") return "";
    if(typeof(range) === "undefined") range = 8;
    return address.substring(0, range) + "..." + address.substring(address.length-range);
}

function addressTruncatePretty(address, blocks){
    if(typeof(address) === "undefined") return "";
    if(typeof(blocks) === "undefined") blocks = 2;
    blocks = blocks <= 1 ? 1 : blocks >= 23 ? 23 : blocks;
    var ret = "";
    return address.substring(0, 4 * blocks).match(/.{1,4}/g).join(' ') + " .. " + address.substring(address.length - 4 * blocks).match(/.{1,4}/g).join(' ');
}

function check256(str, length) {
    if (str.length != length)
        return false;
    for (var i = 0; i < length; ++i) {
        if (str[i] >= '0' && str[i] <= '9')
            continue;
        if (str[i] >= 'a' && str[i] <= 'z')
            continue;
        if (str[i] >= 'A' && str[i] <= 'Z')
            continue;
        return false;
    }
    return true;
}

function checkAddress(address, testnet) {
  return walletManager.addressValid(address, testnet)
}

function checkTxID(txid) {
    return check256(txid, 64)
}

function checkSignature(signature) {
    if (signature.indexOf("OutProofV") === 0) {
        if ((signature.length - 10) % 132 != 0)
            return false;
        return check256(signature, signature.length);
    } else if (signature.indexOf("InProofV") === 0) {
        if ((signature.length - 9) % 132 != 0)
            return false;
        return check256(signature, signature.length);
    } else if (signature.indexOf("SpendProofV") === 0) {
        if ((signature.length - 12) % 88 != 0)
            return false;
        return check256(signature, signature.length);
    } else if (signature.indexOf("ReserveProofV") === 0) {
        if ((signature.length - 14) % 447 != 0)
            return false;
        return check256(signature, signature.length);
    }
    return false;
}

function isValidOpenAliasAddress(address) {
    address = address.trim()
    // we can get an awful lot of valid domains, including non ASCII chars... accept anything
    // there should be something after the .
    // make sure it is not some kind of floating number
    return address.length > 2 && isNaN(parseFloat(address)) && address.indexOf('.') >= 0
}
