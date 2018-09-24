ARG IMAGE_FROM=monero:android
FROM ${IMAGE_FROM}

ARG NPROC=1

#INSTALL JAVA
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 libz1:i386 \
    && apt-get install -y ca-certificates-java openjdk-8-jdk-headless openjdk-8-jre-headless ant
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $JAVA_HOME/bin:$PATH

#Get Qt
ENV QT_VERSION 5.11

RUN git clone git://code.qt.io/qt/qt5.git -b ${QT_VERSION} \
    && cd qt5 \
    && perl init-repository 

ENV ANDROID_API android-21
    
#ANDROID SDK TOOLS
RUN cd ${ANDROID_SDK_ROOT} && echo y | ./bin/sdkmanager "platform-tools" "platforms;${ANDROID_API}" "tools"

RUN cp -r ${WORKDIR}/platforms ${WORKDIR}/platform-tools ${ANDROID_SDK_ROOT}

ENV HOST_PATH $JAVA_HOME/bin:/usr/cmake-3.6.3-Linux-x86_64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${ANDROID_SDK_ROOT}/bin

#build Qt
RUN cd qt5 && PATH=${HOST_PATH} ./configure -developer-build -release \
    -xplatform android-clang \
    -android-ndk-platform ${ANDROID_API} \
    -android-ndk $ANDROID_NDK_ROOT \
    -android-sdk $ANDROID_SDK_ROOT \
    -opensource -confirm-license \
    -prefix ${WORKDIR}/Qt-${QT_VERSION} \
    -nomake tests -nomake examples \
    -skip qtserialport \
    -skip qtconnectivity \
    -skip qttranslations \
    -skip qtpurchasing \
    -skip qtgamepad -skip qtscript -skip qtdoc \
    -no-warnings-are-errors \
   && PATH=${HOST_PATH} make -j ${NPROC} \
   && PATH=${HOST_PATH} make install

# Get ZBar
RUN git clone https://github.com/ZBar/ZBar.git

ENV PATH ${ANDROID_SDK_ROOT}/bin:${WORKDIR}/Qt-${QT_VERSION}/bin:${WORKDIR}/tools:$PATH

#Build libzbarjni.a
COPY android/docker/android.mk.patch ZBar/android.mk.patch
RUN cd ZBar \
    && git apply android.mk.patch \
    && echo \
"APP_ABI := armeabi-v7a \n\
APP_STL := c++_shared \n\
TARGET_PLATFORM := ${ANDROID_API} \n\
TARGET_ARCH_ABI := armeabi-v7a \n\
APP_CFLAGS +=  -target armv7-none-linux-androideabi -fexceptions -fstack-protector-strong -fno-limit-debug-info -mfloat-abi=softfp -fno-builtin-memmove -fno-omit-frame-pointer -fno-stack-protector\n"\
        >> android/jni/Application.mk \
    && cd android \
    && CC=arm-linux-androideabi-clang CXX=arm-linux-androideabi-clang++ ${ANDROID_NDK_ROOT}/ndk-build ICONV_SRC=${WORKDIR}/libiconv-${ICONV_VERSION} -B V=1 NDK_APPLICATION_MK=jni/Application.mk

RUN cp ZBar/android/obj/local/armeabi-v7a/lib* ${ANDROID_NDK_ROOT}/platforms/${ANDROID_API}/arch-arm/usr/lib
RUN cp -r ${PREFIX}/lib/* ${ANDROID_NDK_ROOT}/platforms/${ANDROID_API}/arch-arm/usr/lib

ENV HOST_PATH=${WORKDIR}/Qt-${QT_VERSION}/bin:${JAVA_HOME}/bin:/usr/cmake-${CMAKE_VERSION}-Linux-x86_64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Since r26.0.0, old binary `android` has been removed but is stil used by androiddeployqt
# So using older binary `android` as a workaround
RUN cd tools && curl -O http://dl-ssl.google.com/android/repository/tools_r25.2.5-linux.zip \
  && unzip tools_r25.2.5-linux.zip \
  && rm -f tools_r25.2.5-linux.zip \
  && echo y | $ANDROID_SDK_ROOT/tools/android update sdk --no-ui --all --filter build-tools-25.0.3

ADD . ${WORKDIR}/monero-gui
RUN cd ${WORKDIR}/monero-gui \
    && CMAKE_INCLUDE_PATH="${PREFIX}/include" \
       CMAKE_LIBRARY_PATH="${PREFIX}/lib" \
       ANDROID_STANDALONE_TOOLCHAIN_PATH=${TOOLCHAIN_DIR} \
       PATH=${HOST_PATH} \
       GIT_STRATEGY="none" \
           ./build.sh release-android

RUN cd ${WORKDIR}/monero-gui/build && PATH=${HOST_PATH} make deploy
