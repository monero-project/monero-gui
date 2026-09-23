pragma Singleton

import QtQuick

QtObject {
    //Font Awesome version 5.15.3
    readonly property FontLoader regular: FontLoader {
        source: "./fa-regular-400.otf"
    }
    readonly property FontLoader brands: FontLoader {
        source: "./fa-brands-400.otf"
    }
    readonly property FontLoader solid: FontLoader {
        source: "./fa-solid-900.otf"
    }

    readonly property string fontFamily: regular.name
    readonly property string fontFamilyBrands: brands.name
    readonly property string fontFamilySolid: solid.name

    // Icons used in Monero GUI (Font Awesome version 5.15.3)
    // To add new icons, check unicodes in Font Awesome Free's Cheatsheet:
    // https://fontawesome.com/v5/cheatsheet/free/solid
    // https://fontawesome.com/v5/cheatsheet/free/regular
    // https://fontawesome.com/v5/cheatsheet/free/brands
    readonly property string addressBook: "\uf2b9"
    readonly property string arrowCircleRight: "\uf0a9"
    readonly property string arrowDown: "\uf063"
    readonly property string arrowLeft: "\uf060"
    readonly property string arrowRight: "\uf061"
    readonly property string cashRegister: "\uf788"
    readonly property string checkCircle: "\uf058"
    readonly property string clipboard: "\uf0ea"
    readonly property string clockO: "\uf017"
    readonly property string cloud: "\uf0c2"
    readonly property string desktop: "\uf108"
    readonly property string edit: "\uf044"
    readonly property string ellipsisH: "\uf141"
    readonly property string exclamationCircle: "\uf06a"
    readonly property string eye: "\uf06e"
    readonly property string eyeSlash: "\uf070"
    readonly property string folderOpen: "\uf07c"
    readonly property string globe: "\uf0ac"
    readonly property string home: "\uf015"
    readonly property string houseUser: "\ue065"
    readonly property string infinity: "\uf534"
    readonly property string info: "\uf129"
    readonly property string key: "\uf084"
    readonly property string language: "\uf1ab"
    readonly property string lock: "\uf023"
    readonly property string magnifyingGlass: "\uf002"
    readonly property string minus: "\uf068"
    readonly property string minusCircle: "\uf056"
    readonly property string moonO: "\uf186"
    readonly property string monero: "\uf3d0"
    readonly property string paste: "\uf0ea"
    readonly property string pencilSquare: "\uf14b"
    readonly property string plus: "\uf067"
    readonly property string plusCircle: "\uf055"
    readonly property string productHunt: "\uf288"
    readonly property string qrcode: "\uf029"
    readonly property string questionCircle: "\uf059"
    readonly property string random: "\uf074"
    readonly property string repeat: "\uf01e"
    readonly property string searchPlus: "\uf00e"
    readonly property string server: "\uf233"
    readonly property string shieldAlt: "\uf3ed"
    readonly property string signOutAlt: "\uf2f5"
    readonly property string times: "\uf00d"
}
