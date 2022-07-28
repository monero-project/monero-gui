pragma Singleton
import QtQuick 2.9

Object {

    //Font Awesome version 5.15.3
    FontLoader {
        id: regular
        source: "./fa-regular-400.otf"
    }

    FontLoader {
        id: brands
        source: "./fa-brands-400.otf"
    }

    FontLoader {
        id: solid
        source: "./fa-solid-900.otf"
    }

    property string fontFamily: regular.name
    property string fontFamilyBrands: brands.name
    property string fontFamilySolid: solid.name

    // Icons used in Monero GUI (Font Awesome version 5.15.3)
    // To add new icons, check unicodes in Font Awesome Free's Cheatsheet:
    // https://fontawesome.com/v5/cheatsheet/free/solid
    // https://fontawesome.com/v5/cheatsheet/free/regular
    // https://fontawesome.com/v5/cheatsheet/free/brands

    property string addressBook : "\uf2b9"
    property string arrowCircleRight : "\uf0a9"
    property string arrowDown : "\uf063"
    property string arrowLeft : "\uf060"
    property string arrowRight : "\uf061"
    property string cashRegister: "\uf788"
    property string checkCircle: "\uf058"
    property string clipboard : "\uf0ea"
    property string clockO : "\uf017"
    property string cloud : "\uf0c2"
    property string desktop : "\uf108"
    property string edit : "\uf044"
    property string ellipsisH : "\uf141"
    property string exclamationCircle : "\uf06a"
    property string eye : "\uf06e"
    property string eyeSlash : "\uf070"
    property string folderOpen : "\uf07c"
    property string globe : "\uf0ac"
    property string home : "\uf015"
    property string houseUser : "\ue065"
    property string infinity : "\uf534"
    property string info : "\uf129"
    property string key : "\uf084"
    property string language : "\uf1ab"
    property string lock : "\uf023"
    property string magnifyingGlass : "\uf002"
    property string minus : "\uf068"
    property string minusCircle : "\uf056"
    property string moonO : "\uf186"
    property string monero : "\uf3d0"
    property string paste : "\uf0ea"
    property string pencilSquare : "\uf14b"
    property string plus : "\uf067"
    property string plusCircle : "\uf055"
    property string productHunt : "\uf288"
    property string qrcode : "\uf029"
    property string questionCircle : "\uf059"
    property string random : "\uf074"
    property string repeat : "\uf01e"
    property string searchPlus : "\uf00e"
    property string server : "\uf233"
    property string shieldAlt : "\uf3ed"
    property string signOutAlt : "\uf2f5"
    property string times : "\uf00d"
}
