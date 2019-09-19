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
	ICU_FILES=(libicudt64.dll libicuin64.dll libicuio64.dll libicutu64.dll libicuuc64.dll)
else
	echo "Debug build"
	ICU_FILES=(libicudtd64.dll libicuind64.dll libicuiod64.dll libicutud64.dll libicuucd64.dll)
fi

FILES=(libprotobuf.dll libusb-1.0.dll zlib1.dll libwinpthread-1.dll libtiff-5.dll libstdc++-6.dll libpng16-16.dll libpcre16-0.dll libpcre-1.dll libmng-2.dll liblzma-5.dll liblcms2-2.dll libjpeg-8.dll libintl-8.dll libiconv-2.dll libharfbuzz-0.dll libgraphite2.dll libglib-2.0-0.dll libfreetype-6.dll libbz2-1.dll libssp-0.dll libpcre2-16-0.dll libhidapi-0.dll libdouble-conversion.dll)

OPENSSL_FILES=(libssl-1_1 libcrypto-1_1)

platform=$(get_platform)

if [[ "$platform" == "mingw64" ]]; then
	PLATFORM_FILES="libgcc_s_seh-1.dll" 
	OPENSSL_SUFFIX="-x64"
elif [[ "$platform" == "mingw32" ]]; then 
	PLATFORM_FILES="libgcc_s_dw2-1.dll" 
	OPENSSL_SUFFIX = ""
fi

for f in "${FILES[@]}"; do cp $MSYSTEM_PREFIX/bin/$f $TARGET || exit 1; done

for f in "${ICU_FILES[@]}"; do cp $MSYSTEM_PREFIX/bin/$f $TARGET || exit 1; done

for f in "${PLATFORM_FILES[@]}"; do cp $MSYSTEM_PREFIX/bin/$f $TARGET || exit 1; done

for f in "${OPENSSL_FILES[@]}"; do cp $MSYSTEM_PREFIX/bin/$f$OPENSSL_SUFFIX.dll $TARGET || exit 1; done

cp $ROOT_DIR/start-low-graphics-mode.bat $TARGET
