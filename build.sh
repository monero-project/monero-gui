#!/bin/bash

BUILD_TYPE=$1
BUILD_TREZOR=${BUILD_TREZOR-true}
source ./utils.sh
platform=$(get_platform)
# default build type
if [ -z $BUILD_TYPE ]; then
    BUILD_TYPE=release
fi

# Return 0 if the command exists, 1 if it does not.
exists() {
    command -v "$1" &>/dev/null
}

# Return the first value in $@ that's a runnable command.
find_command() {
    for arg in "$@"; do
        if exists "$arg"; then
           echo "$arg"
           return 0
        fi
    done
    return 1
}

if [ "$BUILD_TYPE" == "release" ]; then
    echo "Building release"
    CONFIG="CONFIG+=release";
    BIN_PATH=release/bin
elif [ "$BUILD_TYPE" == "release-static" ]; then
    echo "Building release-static"
    if [ "$platform" != "darwin" ]; then
	    CONFIG="CONFIG+=release static";
    else
        # OS X: build static libwallet but dynamic Qt. 
        echo "OS X: Building Qt project without static flag"
        CONFIG="CONFIG+=release";
    fi    
    BIN_PATH=release/bin
elif [ "$BUILD_TYPE" == "release-android" ]; then
    echo "Building release for ANDROID"
    CONFIG="CONFIG+=release static WITH_SCANNER DISABLE_PASS_STRENGTH_METER";
    ANDROID=true
    BIN_PATH=release/bin
    DISABLE_PASS_STRENGTH_METER=true
elif [ "$BUILD_TYPE" == "debug-android" ]; then
    echo "Building debug for ANDROID : ultra INSECURE !!"
    CONFIG="CONFIG+=debug qml_debug WITH_SCANNER DISABLE_PASS_STRENGTH_METER";
    ANDROID=true
    BIN_PATH=debug/bin
    DISABLE_PASS_STRENGTH_METER=true
elif [ "$BUILD_TYPE" == "debug" ]; then
    echo "Building debug"
	CONFIG="CONFIG+=debug"
    BIN_PATH=debug/bin
else
    echo "Valid build types are release, release-static, release-android, debug-android and debug"
    exit 1;
fi


source ./utils.sh
pushd $(pwd)
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MONERO_DIR=swap
MONEROD_EXEC=swapd

MAKE='make'
if [[ $platform == *bsd* ]]; then
    MAKE='gmake'
fi

# build libwallet
export BUILD_TREZOR
./get_libwallet_api.sh $BUILD_TYPE
 
# build zxcvbn
if [ "$DISABLE_PASS_STRENGTH_METER" != true ]; then
    $MAKE -C src/zxcvbn-c || exit
fi

if [ ! -d build ]; then mkdir build; fi


# Platform indepenent settings
if [ "$ANDROID" != true ] && ([ "$platform" == "linux32" ] || [ "$platform" == "linux64" ]); then
    exists lsb_release && distro="$(lsb_release -is)"
    if [ "$distro" = "Ubuntu" ] || [ "$distro" = "Fedora" ] || test -f /etc/fedora-release; then
        CONFIG="$CONFIG libunwind_off"
    fi
fi

if [ "$platform" == "darwin" ]; then
    BIN_PATH=$BIN_PATH/swap-wallet-gui.app/Contents/MacOS/
elif [ "$platform" == "mingw64" ] || [ "$platform" == "mingw32" ]; then
    MONEROD_EXEC=swapd.exe
fi

# force version update
get_tag
echo "var GUI_VERSION = \"$TAGNAME\"" > version.js
pushd "$MONERO_DIR"
get_tag
popd
echo "var GUI_MONERO_VERSION = \"$TAGNAME\"" >> version.js

cd build
if ! QMAKE=$(find_command qmake qmake-qt5); then
    echo "Failed to find suitable qmake command."
    exit 1
fi
$QMAKE ../swap-wallet-gui.pro "$CONFIG" || exit
$MAKE || exit 

# Copy swapd to bin folder
if [ "$platform" != "mingw32" ] && [ "$ANDROID" != true ]; then
cp ../$MONERO_DIR/bin/$MONEROD_EXEC $BIN_PATH
fi

# make deploy
popd

