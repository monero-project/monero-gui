FROM ubuntu:16.04

ARG THREADS=1

RUN apt update

RUN apt install -y automake git pkg-config python xutils-dev && \
    git clone -b xorgproto-2020.1 --depth 1 https://gitlab.freedesktop.org/xorg/proto/xorgproto && \
    cd xorgproto && \
    git reset --hard c62e8203402cafafa5ba0357b6d1c019156c9f36 && \
    CFLAGS='-fPIC' CXXFLAGS='-fPIC' ./autogen.sh --disable-shared --enable-static && \
    make -j$THREADS && \
    make -j$THREADS install

RUN git clone -b 1.12 --depth 1 https://gitlab.freedesktop.org/xorg/proto/xcbproto && \
    cd xcbproto && \
    git reset --hard 6398e42131eedddde0d98759067dde933191f049 && \
    CFLAGS='-fPIC' CXXFLAGS='-fPIC' ./autogen.sh --disable-shared --enable-static && \
    make -j$THREADS && \
    make -j$THREADS install

RUN apt install -y libtool-bin && \
    git clone -b libXau-1.0.9 --depth 1 https://gitlab.freedesktop.org/xorg/lib/libxau && \
    cd libxau && \
    git reset --hard d9443b2c57b512cfb250b35707378654d86c7dea && \
    CFLAGS='-fPIC' CXXFLAGS='-fPIC' ./autogen.sh --disable-shared --enable-static && \
    make -j$THREADS && \
    make -j$THREADS install

RUN apt install -y libpthread-stubs0-dev && \
    git clone -b 1.12 --depth 1 https://gitlab.freedesktop.org/xorg/lib/libxcb && \
    cd libxcb && \
    git reset --hard d34785a34f28fa6a00f8ce00d87e3132ff0f6467 && \
    CFLAGS='-fPIC' CXXFLAGS='-fPIC' ./autogen.sh --disable-shared --enable-static && \
    make -j$THREADS && \
    make -j$THREADS install

RUN git clone -b v1.2.11 --depth 1 https://github.com/madler/zlib && \
    cd zlib && \
    git reset --hard cacf7f1d4e3d44d871b605da3b647f07d718623f && \
    CFLAGS='-fPIC' CXXFLAGS='-fPIC' ./configure --static && \
    make -j$THREADS && \
    make -j$THREADS install

RUN git clone -b VER-2-10-2 --depth 1 https://git.sv.nongnu.org/r/freetype/freetype2.git && \
    cd freetype2 && \
    git reset --hard 132f19b779828b194b3fede187cee719785db4d8 && \
    ./autogen.sh && \
    CFLAGS='-fPIC' CXXFLAGS='-fPIC' ./configure --disable-shared --enable-static --with-zlib=no && \
    make -j$THREADS && \
    make -j$THREADS install

RUN git clone -b R_2_2_9 --depth 1 https://github.com/libexpat/libexpat && \
    cd libexpat/expat && \
    git reset --hard a7bc26b69768f7fb24f0c7976fae24b157b85b13 && \
    ./buildconf.sh && \
    CFLAGS='-fPIC' CXXFLAGS='-fPIC' ./configure --disable-shared --enable-static && \
    make -j$THREADS && \
    make -j$THREADS install

RUN apt install -y autopoint gettext gperf libpng12-dev && \
    git clone -b 2.13.92 --depth 1 https://gitlab.freedesktop.org/fontconfig/fontconfig && \
    cd fontconfig && \
    git reset --hard b1df1101a643ae16cdfa1d83b939de2497b1bf27 && \
    CFLAGS='-fPIC' CXXFLAGS='-fPIC' ./autogen.sh --disable-shared --enable-static --sysconfdir=/etc --localstatedir=/var && \
    make -j$THREADS && \
    make -j$THREADS install

RUN git clone -b release-64-2 --depth 1 https://github.com/unicode-org/icu && \
    cd icu/icu4c/source && \
    git reset --hard e2d85306162d3a0691b070b4f0a73e4012433444 && \
    CFLAGS='-fPIC' CXXFLAGS='-fPIC' ./configure --disable-shared --enable-static --disable-tests --disable-samples && \
    make -j$THREADS && \
    make -j$THREADS install

RUN apt install -y wget && \
    wget https://dl.bintray.com/boostorg/release/1.73.0/source/boost_1_73_0.tar.gz && \
    echo "9995e192e68528793755692917f9eb6422f3052a53c5e13ba278a228af6c7acf boost_1_73_0.tar.gz" > hashsum.txt && \
    sha256sum -c hashsum.txt && \
    tar -xvzf boost_1_73_0.tar.gz && \
    cd boost_1_73_0 && \
    ./bootstrap.sh && \
    ./b2 --with-atomic --with-system --with-filesystem --with-thread --with-date_time --with-chrono --with-regex --with-serialization --with-program_options --with-locale variant=release link=static runtime-link=static cflags='-fPIC' cxxflags='-fPIC' install -a --prefix=/usr

RUN wget https://www.openssl.org/source/openssl-1.1.1g.tar.gz && \
    echo "ddb04774f1e32f0c49751e21b67216ac87852ceb056b75209af2443400636d46 openssl-1.1.1g.tar.gz" > hashsum.txt && \
    sha256sum -c hashsum.txt && \
    tar -xzf openssl-1.1.1g.tar.gz && \
    cd openssl-1.1.1g && \
    CFLAGS='-fPIC' CXXFLAGS='-fPIC' ./config no-asm no-shared no-zlib-dynamic --openssldir=/usr && \
    make -j$THREADS && \
    make -j$THREADS install

RUN wget https://download.qt.io/archive/qt/5.9/5.9.7/single/qt-everywhere-opensource-src-5.9.7.tar.xz && \
    echo "1c3852aa48b5a1310108382fb8f6185560cefc3802e81ecc099f4e62ee38516c qt-everywhere-opensource-src-5.9.7.tar.xz"  > hashsum.txt && \
    sha256sum -c hashsum.txt && \
    tar -xf qt-everywhere-opensource-src-5.9.7.tar.xz

RUN apt install -y libgl1-mesa-dev libglib2.0-dev libxkbcommon-dev && \
    cd qt-everywhere-opensource-src-5.9.7 && \
    sed -ri s/\(Libs:.*\)/\\1\ -lexpat/ /usr/local/lib/pkgconfig/fontconfig.pc && \
    sed -ri s/\(Libs:.*\)/\\1\ -lz/ /usr/local/lib/pkgconfig/freetype2.pc && \
    sed -ri s/\(Libs:.*\)/\\1\ -lXau/ /usr/local/lib/pkgconfig/xcb.pc && \
    ./configure --prefix=/usr -platform linux-g++-64 -opensource -confirm-license -release -static -no-avx \
    -opengl desktop -qpa xcb -system-freetype -fontconfig -glib \
    -no-dbus -no-openssl -no-sql-sqlite -no-use-gold-linker \
    -qt-harfbuzz -qt-libjpeg -qt-libpng -qt-pcre -qt-zlib \
    -skip qt3d -skip qtandroidextras -skip qtcanvas3d -skip qtcharts -skip qtconnectivity -skip qtdatavis3d \
    -skip qtdoc -skip qtgamepad -skip qtlocation -skip qtmacextras -skip qtnetworkauth -skip qtpurchasing \
    -skip qtscript -skip qtscxml -skip qtsensors -skip qtserialbus -skip qtserialport -skip qtspeech -skip qttools \
    -skip qtvirtualkeyboard -skip qtwayland -skip qtwebchannel -skip qtwebengine -skip qtwebsockets -skip qtwebview \
    -skip qtwinextras -skip qtx11extras -skip gamepad -skip serialbus -skip location -skip webengine \
    -nomake examples -nomake tests -nomake tools && \
    make -j$THREADS && \
    make -j$THREADS install

RUN cd qt-everywhere-opensource-src-5.9.7/qttools/src/linguist/lrelease && \
    qmake && \
    make -j$THREADS && \
    make -j$THREADS install

RUN apt install -y libudev-dev && \
    git clone -b v1.0.23 --depth 1 https://github.com/libusb/libusb && \
    cd libusb && \
    git reset --hard e782eeb2514266f6738e242cdcb18e3ae1ed06fa && \
    CFLAGS='-fPIC' CXXFLAGS='-fPIC' ./autogen.sh --disable-shared --enable-static && \
    make -j$THREADS && \
    make -j$THREADS install

RUN git clone -b hidapi-0.9.0 --depth 1 https://github.com/libusb/hidapi && \
    cd hidapi && \
    git reset --hard 7da5cc91fc0d2dbe4df4f08cd31f6ca1a262418f && \
    ./bootstrap && \
    CFLAGS='-fPIC' CXXFLAGS='-fPIC' ./configure --disable-shared --enable-static && \
    make -j$THREADS && \
    make -j$THREADS install

RUN git clone -b libX11-1.6.9 --depth 1 https://gitlab.freedesktop.org/xorg/lib/libx11 && \
    cd libx11 && \
    git reset --hard db7cca17ad7807e92a928da9d4c68a00f4836da2 && \
    CFLAGS='-fPIC' CXXFLAGS='-fPIC' ./autogen.sh --disable-shared --enable-static && \
    make -j$THREADS && \
    make -j$THREADS install

RUN git clone -b libXext-1.3.4 --depth 1 https://gitlab.freedesktop.org/xorg/lib/libxext && \
    cd libxext && \
    git reset --hard ebb167f34a3514783966775fb12573c4ed209625 && \
    CFLAGS='-fPIC' CXXFLAGS='-fPIC' ./autogen.sh --disable-shared --enable-static && \
    make -j$THREADS && \
    make -j$THREADS install

RUN apt install -y libsodium-dev && \
    git clone -b v4.3.2 --depth 1 https://github.com/zeromq/libzmq && \
    cd libzmq && \
    git reset --hard a84ffa12b2eb3569ced199660bac5ad128bff1f0 && \
    ./autogen.sh && \
    CFLAGS='-fPIC' CXXFLAGS='-fPIC' ./configure --disable-shared --enable-static --disable-libunwind --with-libsodium && \
    make -j$THREADS && \
    make -j$THREADS install

RUN git clone -b libgpg-error-1.38 --depth 1 git://git.gnupg.org/libgpg-error.git && \
    cd libgpg-error && \
    git reset --hard 71d278824c5fe61865f7927a2ed1aa3115f9e439 && \
    ./autogen.sh && \
    CFLAGS='-fPIC' CXXFLAGS='-fPIC' ./configure --disable-shared --enable-static --disable-doc --disable-tests && \
    make -j$THREADS && \
    make -j$THREADS install

RUN git clone -b libgcrypt-1.8.5 --depth 1 git://git.gnupg.org/libgcrypt.git && \
    cd libgcrypt && \
    git reset --hard 56606331bc2a80536db9fc11ad53695126007298 && \
    ./autogen.sh && \
    CFLAGS='-fPIC' CXXFLAGS='-fPIC' ./configure --disable-shared --enable-static --disable-doc && \
    make -j$THREADS && \
    make -j$THREADS install

RUN git clone -b v3.10.0 --depth 1 https://github.com/protocolbuffers/protobuf && \
    cd protobuf && \
    git reset --hard 6d4e7fd7966c989e38024a8ea693db83758944f1 && \
    ./autogen.sh && \
    CFLAGS='-fPIC' CXXFLAGS='-fPIC' ./configure --enable-static --disable-shared && \
    make -j$THREADS && \
    make -j$THREADS install

RUN apt install -y cmake libusb-1.0-0-dev
