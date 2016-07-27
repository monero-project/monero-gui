#!/bin/bash

pushd $(pwd)
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BITMOMERO_DIR=bitmonero

if [ ! -d $BITMOMERO_DIR ]; then 
    $SHELL get_libwallet_api.sh
fi
 
if [ ! -d build ]; then mkdir build; fi
cd build
echo $(pwd)
qmake ../monero-core.pro "CONFIG+=release"
make 
make deploy
popd














