#!/bin/bash


BITMONERO_URL=https://github.com/monero-project/bitmonero.git
BITMONERO_BRANCH=master
# thanks to SO: http://stackoverflow.com/a/20283965/4118915
CPU_CORE_COUNT=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || sysctl -n hw.ncpu)
pushd $(pwd)
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


INSTALL_DIR=$ROOT_DIR/wallet
BITMONERO_DIR=$ROOT_DIR/bitmonero


if [ ! -d $BITMONERO_DIR ]; then
    git clone --depth=1 $BITMONERO_URL $BITMONERO_DIR --branch $BITMONERO_BRANCH --single-branch
else
    cd $BITMONERO_DIR;
    git checkout $BITMONERO_BRANCH
    git pull;
fi

echo "cleaning up existing bitmonero build dir, libs and includes"
rm -fr $BITMONERO_DIR/build
rm -fr $BITMONERO_DIR/lib
rm -fr $BITMONERO_DIR/include

mkdir -p $BITMONERO_DIR/build/release
pushd $BITMONERO_DIR/build/release


if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform        
    cmake -D CMAKE_BUILD_TYPE=Release -D STATIC=ON -D CMAKE_INSTALL_PREFIX="$BITMONERO_DIR"  ../..
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Do something under GNU/Linux platform
    cmake -D CMAKE_BUILD_TYPE=Release -D STATIC=ON -D CMAKE_INSTALL_PREFIX="$BITMONERO_DIR"  ../..
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    # Do something under Windows NT platform
    cmake -D CMAKE_BUILD_TYPE=Release -D STATIC=ON -D CMAKE_INSTALL_PREFIX="$BITMONERO_DIR" -G "MSYS Makefiles" ../..
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    # Do something under Windows NT platform
    cmake -D CMAKE_BUILD_TYPE=Release -D STATIC=ON -D CMAKE_INSTALL_PREFIX="$BITMONERO_DIR" -G "MSYS Makefiles" ../..
fi


pushd $BITMONERO_DIR/build/release/src/wallet
make -j$CPU_CORE_COUNT
make install -j$CPU_CORE_COUNT
popd
popd











