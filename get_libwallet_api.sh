#!/bin/bash


MONERO_URL=https://github.com/monero-project/monero.git
MONERO_BRANCH=master
# MONERO_URL=https://github.com/mbg033/monero.git
# MONERO_BRANCH=develop
# Buidling "debug" build optionally
BUILD_TYPE=$1
if [ -z $BUILD_TYPE ]; then
    BUILD_TYPE=Release
fi
# thanks to SO: http://stackoverflow.com/a/20283965/4118915
CPU_CORE_COUNT=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || sysctl -n hw.ncpu)
pushd $(pwd)
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $ROOT_DIR/utils.sh


INSTALL_DIR=$ROOT_DIR/wallet
MONERO_DIR=$ROOT_DIR/monero


if [ ! -d $MONERO_DIR ]; then
    git clone --depth=1 $MONERO_URL $MONERO_DIR --branch $MONERO_BRANCH --single-branch
else
    cd $MONERO_DIR;
    git checkout $MONERO_BRANCH
    git pull;
fi

echo "cleaning up existing monero build dir, libs and includes"
rm -fr $MONERO_DIR/build
rm -fr $MONERO_DIR/lib
rm -fr $MONERO_DIR/include

mkdir -p $MONERO_DIR/build/release
pushd $MONERO_DIR/build/release

# reusing function from "utils.sh"
platform=$(get_platform)

if [ "$platform" == "darwin" ]; then
    # Do something under Mac OS X platform        
    echo "Configuring build for MacOS.."
    cmake -D CMAKE_BUILD_TYPE=$BUILD_TYPE -D STATIC=ON -D BUILD_GUI_DEPS=ON -D INSTALL_VENDORED_LIBUNBOUND=ON -D CMAKE_INSTALL_PREFIX="$MONERO_DIR"  ../..
elif [ "$platform" == "linux" ]; then
    # Do something under GNU/Linux platform
    echo "Configuring build for Linux.."
    cmake -D CMAKE_BUILD_TYPE=$BUILD_TYPE -D STATIC=ON -D BUILD_GUI_DEPS=ON -D CMAKE_INSTALL_PREFIX="$MONERO_DIR"  ../..
elif [ "$platform" == "mingw64" ]; then
    # Do something under Windows NT platform
    echo "Configuring build for MINGW64.."
    cmake -D CMAKE_BUILD_TYPE=$BUILD_TYPE -D STATIC=ON -D BUILD_GUI_DEPS=ON -D INSTALL_VENDORED_LIBUNBOUND=ON -D CMAKE_INSTALL_PREFIX="$MONERO_DIR" -G "MSYS Makefiles" ../..
elif [ "$platform" == "mingw32" ]; then
    # Do something under Windows NT platform
    echo "Configuring build for MINGW32.."
    cmake -D CMAKE_BUILD_TYPE=$BUILD_TYPE -D STATIC=ON -D BUILD_GUI_DEPS=ON -D INSTALL_VENDORED_LIBUNBOUND=ON -D CMAKE_INSTALL_PREFIX="$MONERO_DIR" -G "MSYS Makefiles" ../..
else
    echo "Unsupported platform: $platform"
    popd
    exit 1
fi


pushd $MONERO_DIR/build/release/src/wallet
make -j$CPU_CORE_COUNT
make install -j$CPU_CORE_COUNT
popd

# unbound is one more dependency. can't be merged to the wallet_merged
# since filename conflict (random.c.obj)
# for Linux, we use libunbound shipped with the system, so we don't need to build it

if [ "$platform" != "linux" ]; then
    echo "Building libunbound..."
    pushd $MONERO_DIR/build/release/external/unbound
    # no need to make, it was already built as dependency for libwallet
    # make -j$CPU_CORE_COUNT
    make install -j$CPU_CORE_COUNT
    popd
fi

popd











