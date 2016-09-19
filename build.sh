#!/bin/bash

pushd $(pwd)
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MONERO_DIR=monero

if [ ! -d $MONERO_DIR ]; then 
    $SHELL get_libwallet_api.sh
fi
 
if [ ! -d build ]; then mkdir build; fi
cd build

qmake ../monero-core.pro "CONFIG+=release"
make 
make deploy
popd














