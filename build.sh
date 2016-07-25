#!/bin/bash

pushd $(pwd)
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#$SHELL get_libwallet_api.sh
 
if [ ! -d build ]; then mkdir build; fi
cd build
echo $(pwd)
qmake ../monero-core.pro "CONFIG += release"
make release
make deploy
popd














