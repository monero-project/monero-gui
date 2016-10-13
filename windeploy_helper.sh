#!/bin/bash

TARGET=$1

FILES="zlib1.dll libwinpthread-1.dll libtiff-5.dll libstdc++-6.dll libpng16-16.dll libpcre16-0.dll libpcre-1.dll libmng-2.dll liblzma-5.dll liblcms2-2.dll libjpeg-8.dll libjasper-1.dll libintl-8.dll libicuuc57.dll libicuin57.dll libicudt57.dll libiconv-2.dll libharfbuzz-0.dll libgraphite2.dll libglib-2.0-0.dll libgcc_s_seh-1.dll libgcc_s_dw2-1.dll libfreetype-6.dll libbz2-1.dll"

for f in $FILES; do cp $MSYSTEM_PREFIX/bin/$f $TARGET; done













