#!/bin/bash


MONERO_URL=https://github.com/monero-project/monero.git
MONERO_BRANCH=master
# thanks to SO: http://stackoverflow.com/a/20283965/4118915
CPU_CORE_COUNT=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || sysctl -n hw.ncpu)
pushd $(pwd)
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


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

if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform        
    cmake -D CMAKE_BUILD_TYPE=Release -D STATIC=ON -D BUILD_GUI_DEPS=ON -D INSTALL_VENDORED_LIBUNBOUND=ON -D CMAKE_INSTALL_PREFIX="$MONERO_DIR"  ../..
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Do something under GNU/Linux platform
    PLATFORM="Linux"
    cmake -D CMAKE_BUILD_TYPE=Release -D STATIC=ON -D BUILD_GUI_DEPS=ON -D CMAKE_INSTALL_PREFIX="$MONERO_DIR"  ../..
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    # Do something under Windows NT platform
    cmake -D CMAKE_BUILD_TYPE=Release -D STATIC=ON -D BUILD_GUI_DEPS=ON -D CMAKE_INSTALL_PREFIX="$MONERO_DIR" -G "MSYS Makefiles" ../..
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    # Do something under Windows NT platform
    cmake -D CMAKE_BUILD_TYPE=Release -D STATIC=ON -D BUILD_GUI_DEPS=ON -D CMAKE_INSTALL_PREFIX="$MONERO_DIR" -G "MSYS Makefiles" ../..
fi


pushd $MONERO_DIR/build/release/src/wallet
make -j$CPU_CORE_COUNT
make install -j$CPU_CORE_COUNT
popd

# unbound is one more dependency. can't be merged to the wallet_merged
# since filename conflict (random.c.obj)
# for Linux, we use libunbound from repository, so we don't need to build it
if [ $PLATFORM != "Linux" ]; then
    echo "Building libunbound..."
    pushd $MONERO_DIR/build/release/external/unbound
    make -j$CPU_CORE_COUNT
    make install -j$CPU_CORE_COUNT
    popd
fi

popd











