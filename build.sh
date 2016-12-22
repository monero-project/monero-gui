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
elif [ "$BUILD_TYPE" == "debug" ]; then
    echo "Building debug"
	CONFIG="CONFIG+=debug"
    BIN_PATH=debug/bin
else
    echo "Valid build types are release, release-static and debug"
    exit 1;
fi


source ./utils.sh
pushd $(pwd)
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MONERO_DIR=monero
MONEROD_EXEC=monerod

# Build libwallet if monero folder doesnt exist
if [ ! -d $MONERO_DIR ]; then 
    $SHELL get_libwallet_api.sh $BUILD_TYPE
fi
 
# build zxcvbn
make -C src/zxcvbn-c

if [ ! -d build ]; then mkdir build; fi


# Platform indepenent settings
platform=$(get_platform)
if [ "$platform" == "linux32" ] || [ "$platform" == "linux64" ]; then
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

cd build
qmake ../monero-wallet-gui.pro "$CONFIG"
make 

# Copy monerod to bin folder
if [ "$platform" != "mingw32" ]; then
cp ../$MONERO_DIR/bin/$MONEROD_EXEC $BIN_PATH
fi

# make deploy
popd

