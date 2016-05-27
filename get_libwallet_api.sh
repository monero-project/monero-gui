#!/bin/bash


BITMONERO_URL=https://github.com/mbg033/bitmonero
CPU_CORE_COUNT=$(grep -c ^processor /proc/cpuinfo)
pushd $(pwd)
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


INSTALL_DIR=$ROOT_DIR/wallet
BITMONERO_DIR=$ROOT_DIR/bitmonero


if [ ! -d $BITMONERO_DIR ]; then
    git clone --depth=1 $BITMONERO_URL $BITMONERO_DIR
fi

rm -fr $BITMONERO_DIR/build
mkdir -p $BITMONERO_DIR/build/release
pushd $BITMONERO_DIR/build/release

cmake -D CMAKE_BUILD_TYPE=Release -D STATIC=ON -D CMAKE_INSTALL_PREFIX="$BITMONERO_DIR"  ../..

pushd $BITMONERO_DIR/build/release/src/wallet
make -j$CPU_CORE_COUNT
make install -j$CPU_CORE_COUNT
popd
popd











