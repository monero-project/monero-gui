#!/bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $ROOT_DIR/utils.sh


TARGET=$1

BUILD_TYPE=$2




if [[ -z $BUILD_TYPE ]]; then
	BUILD_TYPE=Release
fi

if [[ "$BUILD_TYPE" == "Release" ]]; then
	echo "Release build"
	ICU_FILES=(libicudt61.dll libicuin61.dll libicuio61.dll libicutu61.dll libicuuc61.dll)
else
	echo "Debug build"
	ICU_FILES=(libicudtd61.dll libicuind61.dll libicuiod61.dll libicutud61.dll libicuucd61.dll)
fi

FILES=(zlib1.dll libwinpthread-1.dll libtiff-5.dll libstdc++-6.dll libpng16-16.dll libpcre16-0.dll libpcre-1.dll libmng-2.dll liblzma-5.dll liblcms2-2.dll libjpeg-8.dll libintl-8.dll libiconv-2.dll libharfbuzz-0.dll libgraphite2.dll libglib-2.0-0.dll libfreetype-6.dll libbz2-1.dll libssp-0.dll libpcre2-16-0.dll)

platform=$(get_platform)

if [[ "$platform" == "mingw64" ]]; then
	PLATFORM_FILES="libgcc_s_seh-1.dll" 
elif [[ "$platform" == "mingw32" ]]; then 
	PLATFORM_FILES="libgcc_s_dw2-1.dll" 
fi

for f in "${FILES[@]}"; do cp $MSYSTEM_PREFIX/bin/$f $TARGET || exit 1; done

for f in "${ICU_FILES[@]}"; do cp $MSYSTEM_PREFIX/bin/$f $TARGET || exit 1; done

for f in "${PLATFORM_FILES[@]}"; do cp $MSYSTEM_PREFIX/bin/$f $TARGET || exit 1; done

cp $ROOT_DIR/start-low-graphics-mode.bat $TARGET
