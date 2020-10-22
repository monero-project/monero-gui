FROM monero-android

#INSTALL JAVA
RUN echo "deb http://ftp.fr.debian.org/debian/ jessie-backports main contrib non-free" >> /etc/apt/sources.list
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 libz1:i386 \
    && apt-get install -y -t jessie-backports ca-certificates-java openjdk-8-jdk-headless openjdk-8-jre-headless ant
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $JAVA_HOME/bin:$PATH

#Get Qt
ENV QT_VERSION 5.8

RUN git clone git://code.qt.io/qt/qt5.git -b ${QT_VERSION} \
    && cd qt5 \
    && perl init-repository 

## Note: Need to use libc++ but Qt does not provide mkspec for libc++.
## Their support of it is quite recent and they claim they don't use it by default
## [only because it produces bigger binary objects](https://bugreports.qt.io/browse/QTBUG-50724).

#Create new mkspec for clang + libc++
RUN cp -r qt5/qtbase/mkspecs/android-clang qt5/qtbase/mkspecs/android-clang-libc \
    && cd qt5/qtbase/mkspecs/android-clang-libc \
    && sed -i '16i ANDROID_SOURCES_CXX_STL_LIBDIR = $$NDK_ROOT/sources/cxx-stl/llvm-libc++/libs/$$ANDROID_TARGET_ARCH' qmake.conf \
    && sed -i '17i ANDROID_SOURCES_CXX_STL_INCDIR = $$NDK_ROOT/sources/cxx-stl/llvm-libc++/include' qmake.conf \
    && echo "QMAKE_LIBS_PRIVATE      = -lc++_shared -llog -lz -lm -ldl -lc -lgcc " >> qmake.conf \
    && echo "QMAKE_CFLAGS -= -mfpu=vfp " >> qmake.conf \
    && echo "QMAKE_CXXFLAGS -= -mfpu=vfp " >> qmake.conf \ 
    && echo "QMAKE_CFLAGS += -mfpu=vfp4 " >> qmake.conf \
    && echo "QMAKE_CXXFLAGS += -mfpu=vfp4 " >> qmake.conf 

ENV ANDROID_API android-21
    
#ANDROID SDK TOOLS
RUN echo y | $ANDROID_SDK_ROOT/tools/android update sdk --no-ui --all --filter platform-tools 
RUN echo y | $ANDROID_SDK_ROOT/tools/android update sdk --no-ui --all --filter ${ANDROID_API}
RUN echo y | $ANDROID_SDK_ROOT/tools/android update sdk --no-ui --all --filter build-tools-25.0.1 

ENV CLEAN_PATH $JAVA_HOME/bin:/usr/cmake-3.6.3-Linux-x86_64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#build Qt
RUN cd qt5 && PATH=${CLEAN_PATH} ./configure -developer-build -release \
    -xplatform android-clang-libc \
    -android-ndk-platform ${ANDROID_API} \
    -android-ndk $ANDROID_NDK_ROOT \
    -android-sdk $ANDROID_SDK_ROOT \
    -opensource -confirm-license \
    -prefix ${WORKDIR}/Qt-${QT_VERSION} \
    -nomake tests -nomake examples \
    -skip qtserialport \
    -skip qtconnectivity \
    -skip qttranslations \
    -skip qtgamepad -skip qtscript -skip qtdoc

# build Qt tools : gnustl_shared.so is hard-coded in androiddeployqt
# replace it with libc++_shared.so
COPY androiddeployqt.patch qt5/qttools/androiddeployqt.patch
RUN cd qt5/qttools \
    && git apply androiddeployqt.patch \
    && cd .. \
    && PATH=${CLEAN_PATH} make -j4 \
    && PATH=${CLEAN_PATH} make install

# Get iconv and ZBar
ENV ICONV_VERSION 1.14
RUN git clone https://github.com/ZBar/ZBar.git \
    && curl -s -O http://ftp.gnu.org/pub/gnu/libiconv/libiconv-${ICONV_VERSION}.tar.gz \
    && tar -xzf libiconv-${ICONV_VERSION}.tar.gz \
    && cd libiconv-${ICONV_VERSION} \
    && CC=arm-linux-androideabi-clang CXX=arm-linux-androideabi-clang++ ./configure --build=x86_64-linux-gnu --host=arm-eabi --prefix=${WORKDIR}/libiconv --disable-rpath

ENV PATH $ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/platform-tools:${WORKDIR}/Qt-${QT_VERSION}/bin:$PATH

#Build libiconv.a and libzbarjni.a
COPY android.mk.patch ZBar/android.mk.patch
RUN cd ZBar \
    && git apply android.mk.patch \
    && echo \
"APP_ABI := armeabi-v7a \n\
APP_STL := c++_shared \n\
TARGET_PLATFORM := ${ANDROID_API} \n\
TARGET_ARCH_ABI := armeabi-v7a \n\
APP_CFLAGS +=  -target armv7-none-linux-androideabi -fexceptions -fstack-protector-strong -fno-limit-debug-info -mfloat-abi=softfp -mfpu=vfp -fno-builtin-memmove -fno-omit-frame-pointer -fno-stack-protector\n"\
        >> android/jni/Application.mk \
    && cd android \
    && android update project --path . -t "${ANDROID_API}" \
    && CC=arm-linux-androideabi-clang CXX=arm-linux-androideabi-clang++ ant -Dndk.dir=${ANDROID_NDK_ROOT} -Diconv.src=${WORKDIR}/libiconv-${ICONV_VERSION} zbar-clean zbar-ndk-build

RUN cp openssl/lib* ${ANDROID_NDK_ROOT}/platforms/${ANDROID_API}/arch-arm/usr/lib
RUN cp boost_${BOOST_VERSION}/android32/lib/lib* ${ANDROID_NDK_ROOT}/platforms/${ANDROID_API}/arch-arm/usr/lib
RUN cp ZBar/android/obj/local/armeabi-v7a/lib* ${ANDROID_NDK_ROOT}/platforms/${ANDROID_API}/arch-arm/usr/lib

RUN git clone https://github.com/monero-project/monero-gui.git \
    && cd monero-gui \
    && git submodule update \
    && CC=arm-linux-androideabi-clang CXX=arm-linux-androideabi-clang++ BOOST_ROOT=/opt/android/boost_1_62_0 \
         BOOST_LIBRARYDIR=${WORKDIR}/boost_${BOOST_VERSION}/android32/lib/ \
         OPENSSL_ROOT_DIR=${WORKDIR}/openssl/ \
         CMAKE_INCLUDE_PATH=${WORKDIR}/cppzmq/ \
         CMAKE_LIBRARY_PATH=${WORKDIR}/zeromq4-1/.libs \
         CXXFLAGS="-I ${WORKDIR}/zeromq4-1/include/" \
         ./build.sh release-android \
    && cd build \
    && make deploy

