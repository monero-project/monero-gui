#!/bin/bash

BUILD_TYPE=$1
# default build type
if [ -z $BUILD_TYPE ]; then
    BUILD_TYPE=release
fi

if [ "$BUILD_TYPE" == "release" ]; then
    echo "Building release"
    CONFIG="CONFIG+=release";
    BIN_PATH=release/bin
elif [ "$BUILD_TYPE" == "release-static" ]; then
    echo "Building release-static"
	CONFIG="CONFIG+=release static";
    BIN_PATH=release/bin
elif [ "$BUILD_TYPE" == "release-android" ]; then
    echo "Building release for ANDROID"
    CONFIG="CONFIG+=release static";
    ANDROID=true
    BIN_PATH=release/bin
elif [ "$BUILD_TYPE" == "debug-android" ]; then
    echo "Building debug for ANDROID : ultra INSECURE !!"
    CONFIG="CONFIG+=debug qml_debug";
    ANDROID=true
    BIN_PATH=debug/bin
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
MONERO_DIR=monero
MONEROD_EXEC=monerod

# Build libwallet if it doesnt exist
if [ ! -f $MONERO_DIR/lib/libwallet_merged.a ]; then 
    echo "libwallet_merged.a not found - Building libwallet"
    $SHELL get_libwallet_api.sh $BUILD_TYPE
elif [ ! -f $MONERO_DIR/version.sh ]; then 
    echo "monero/version.h not found - Building libwallet"
    $SHELL get_libwallet_api.sh $BUILD_TYPE 
else 
    source ./$MONERO_DIR/version.sh
    # update monero submodule
    git submodule update
    # compare submodule version with latest build
    pushd "$MONERO_DIR"
    get_tag
    popd
    echo "latest libwallet version: $GUI_MONERO_VERSION"
    echo "Installed libwallet version: $VERSIONTAG"
    # check if recent
    if [ "$VERSIONTAG" != "$GUI_MONERO_VERSION" ]; then
        echo "Building new libwallet version $GUI_MONERO_VERSION"
        $SHELL get_libwallet_api.sh $BUILD_TYPE 
    else
        echo "latest libwallet ($GUI_MONERO_VERSION) is already built. Run ./get_libwallet_api.sh to force rebuild"
    fi
fi
 
# build zxcvbn
make -C src/zxcvbn-c

if [ ! -d build ]; then mkdir build; fi


# Platform indepenent settings
platform=$(get_platform)
if [ "$ANDROID" != true ] && ([ "$platform" == "linux32" ] || [ "$platform" == "linux64" ]); then
    distro=$(lsb_release -is)
    if [ "$distro" == "Ubuntu" ]; then
        CONFIG="$CONFIG libunwind_off"
    fi
fi

if [ "$platform" == "darwin" ]; then
    BIN_PATH=$BIN_PATH/monero-wallet-gui.app/Contents/MacOS/
elif [ "$platform" == "mingw64" ] || [ "$platform" == "mingw32" ]; then
    MONEROD_EXEC=monerod.exe
fi

# force version update
get_tag
echo "var GUI_VERSION = \"$VERSIONTAG\"" > version.js
pushd "$MONERO_DIR"
get_tag
popd
echo "var GUI_MONERO_VERSION = \"$VERSIONTAG\"" >> version.js
echo "GUI_MONERO_VERSION=\"$VERSIONTAG\"" >> $MONERO_DIR/version.sh

cd build
qmake ../monero-wallet-gui.pro "$CONFIG"
make 

# Copy monerod to bin folder
if [ "$platform" != "mingw32" ] && [ "$ANDROID" != true ]; then
cp ../$MONERO_DIR/bin/$MONEROD_EXEC $BIN_PATH
fi

# make deploy
popd

