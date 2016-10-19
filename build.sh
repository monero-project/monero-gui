#!/bin/bash

BUILD_TYPE=$1
if [ -z $BUILD_TYPE ]; then
    BUILD_TYPE=Release
fi


source ./utils.sh
pushd $(pwd)
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MONERO_DIR=monero

if [ ! -d $MONERO_DIR ]; then 
    $SHELL get_libwallet_api.sh $BUILD_TYPE
fi
 
if [ ! -d build ]; then mkdir build; fi

if [ "$BUILD_TYPE" == "Release" ]; then
	CONFIG="CONFIG+=release";
else
	CONFIG="CONFIG+=debug"
fi


platform=$(get_platform)
if [ "$platform" == "linux" ]; then
    distro=$(lsb_release -is)
    if [ "$distro" == "Ubuntu" ]; then
        CONFIG="$CONFIG libunwind_off"
    fi
fi

cd build
qmake ../monero-core.pro "$CONFIG"
make 
# make deploy
popd

