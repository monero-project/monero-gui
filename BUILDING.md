*Note*: Qt 5.9.7 is the minimum version required to build the GUI.

*Note*: Official GUI releases use monero-wallet-gui from this process alongside the supporting binaries (monerod, etc) from the [CLI deterministic builds](https://github.com/monero-project/monero/blob/master/contrib/gitian/README.md).

  * [Building Reproducible Windows static binaries with Docker (any OS)](#building-reproducible-windows-static-binaries-with-docker-any-os)
  * [Building Reproducible Linux static binaries with Docker (any OS)](#building-reproducible-linux-static-binaries-with-docker-any-os)
  * [Building Android APK with Docker (any OS) *Experimental*](#building-android-apk-with-docker-any-os-experimental)
  * [Building on Linux](#building-on-linux)
  * [Building on OS X](#building-on-os-x)
  * [Building on Windows](#building-on-windows)

### Building Reproducible Windows static binaries with Docker (any OS)

1. Install Docker [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)
2. Clone the repository
   ```
   git clone --branch master --recursive https://github.com/monero-project/monero-gui.git
   ```
   \* `master` - replace with the desired version tag (e.g. `v0.18.3.1`) to build the release binaries.
3. Prepare build environment
   ```
   cd monero-gui
   docker build --tag monero:build-env-windows --build-arg THREADS=4 --file Dockerfile.windows .
   ```
   \* `4` - number of CPU threads to use

4. Build
   ```
   docker run --rm -it -v <MONERO_GUI_DIR_FULL_PATH>:/monero-gui -w /monero-gui monero:build-env-windows sh -c 'make depends root=/depends target=x86_64-w64-mingw32 tag=win-x64 -j4'
   ```
   \* `<MONERO_GUI_DIR_FULL_PATH>` - absolute path to `monero-gui` directory  
   \* `4` - number of CPU threads to use
5. Monero GUI Windows static binaries will be placed in  `monero-gui/build/x86_64-w64-mingw32/release/bin` directory

### Building Reproducible Linux static binaries with Docker (any OS)

1. Install Docker [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)
2. Clone the repository
   ```
   git clone --branch master --recursive https://github.com/monero-project/monero-gui.git
   ```
   \* `master` - replace with the desired version tag (e.g. `v0.18.3.1`) to build the release binaries.
3. Prepare build environment
   ```
   cd monero-gui
   docker build --tag monero:build-env-linux --build-arg THREADS=4 --file Dockerfile.linux .
   ```
   \* `4` - number of CPU threads to use

4. Build
   ```
   docker run --rm -it -v <MONERO_GUI_DIR_FULL_PATH>:/monero-gui -w /monero-gui monero:build-env-linux sh -c 'make release-static -j4'
   ```
   \* `<MONERO_GUI_DIR_FULL_PATH>` - absolute path to `monero-gui` directory  
   \* `4` - number of CPU threads to use
5. Monero GUI Linux static binaries will be placed in  `monero-gui/build/release/bin` directory
6. (*Optional*) Compare `monero-wallet-gui` SHA-256 hash to the one obtained from a trusted source
   ```
   docker run --rm -it -v <MONERO_GUI_DIR_FULL_PATH>:/monero-gui -w /monero-gui monero:build-env-linux sh -c 'shasum -a 256 /monero-gui/build/release/bin/monero-wallet-gui'
   ```
   \* `<MONERO_GUI_DIR_FULL_PATH>` - absolute path to `monero-gui` directory  

### Building Android APK with Docker (any OS) *Experimental*
 - Minimum Android 9 Pie (API 28)
 - ARMv8-A 64-bit CPU
1. Install Docker [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)
2. Clone the repository
   ```
   git clone --recursive https://github.com/monero-project/monero-gui.git
   ```
3. Prepare build environment
   ```
   cd monero-gui
   docker build --tag monero:build-env-android --build-arg THREADS=4 --file Dockerfile.android .
   ```
   \* `4` - number of CPU threads to use

4. Build
   ```
   docker run --rm -it -v <MONERO_GUI_DIR_FULL_PATH>:/monero-gui -e THREADS=4 monero:build-env-android
   ```
   \* `<MONERO_GUI_DIR_FULL_PATH>` - absolute path to `monero-gui` directory  
   \* `4` - number of CPU threads to use
5. Monero GUI APK will be placed in  `monero-gui/build/Android/release/android-build` directory
6. Deploy
   * Using ADB (Android debugger bridge)
     - [Enable adb debugging on your device](https://developer.android.com/studio/command-line/adb.html#Enabling)
      * Connect your device with USB and install Monero GUI APK with adb:
      ```
      adb install build/Android/release/android-build/monero-gui.apk
      ```
      * Troubleshooting:
      ```
      adb devices -l
      adb logcat
      ```
      * If using adb inside docker, make sure you did
      ```
      docker run -v /dev/bus/usb:/dev/bus/usb --privileged
      ```
   * Using a web server
      ```
      mkdir /usr/tmp
      cp build/Android/release/android-build/monero-gui.apk /usr/tmp
      docker run -d -v /usr/tmp:/usr/share/nginx/html:ro -p 8080:80 nginx
      ```
      Now it should be accessible through a web browser at
      ```
      http://<your.local.ip>:8080/QtApp-debug.apk
      ```

### Building on Linux

(Tested on Ubuntu 17.10 x64, Ubuntu 18.04 x64 and Gentoo x64)

1. Install Monero dependencies

  - For Debian distributions (Debian, Ubuntu, Mint, Tails...)

	`sudo apt install build-essential cmake miniupnpc libunbound-dev graphviz doxygen libunwind8-dev pkg-config libssl-dev libzmq3-dev libsodium-dev libhidapi-dev libnorm-dev libusb-1.0-0-dev libpgm-dev libprotobuf-dev protobuf-compiler libgcrypt20-dev libboost-chrono-dev libboost-date-time-dev libboost-filesystem-dev libboost-locale-dev libboost-program-options-dev libboost-regex-dev libboost-serialization-dev libboost-system-dev libboost-thread-dev`

  - For Gentoo

	`sudo emerge app-arch/xz-utils app-doc/doxygen dev-cpp/gtest dev-libs/boost dev-libs/expat dev-libs/openssl dev-util/cmake media-gfx/graphviz net-dns/unbound net-libs/miniupnpc net-libs/zeromq sys-libs/libunwind dev-libs/libsodium dev-libs/hidapi dev-libs/libgcrypt`

  - For Fedora

	`sudo dnf install make automake cmake gcc-c++ boost-devel miniupnpc-devel graphviz doxygen unbound-devel libunwind-devel pkgconfig openssl-devel libcurl-devel hidapi-devel libusb-devel zeromq-devel libgcrypt-devel`

2. Install Qt:

  *Note*: The Qt 5.9.7 or newer requirement makes **some** distributions (mostly based on Debian, like Ubuntu 16.x or Linux Mint 18.x) obsolete due to their repositories containing an older Qt version.

 The recommended way is to install 5.9.7 from the [official Qt installer](https://www.qt.io/download-qt-installer) or [compiling it yourself](https://wiki.qt.io/Install_Qt_5_on_Ubuntu). This ensures you have the correct version. Higher versions *can* work but as it differs from our production build target, slight differences may occur.

The following instructions will fetch Qt from your distribution's repositories instead. Take note of what version it installs. Your mileage may vary.

  - For Debian distributions (Debian, Ubuntu, Mint, Tails...)

    `sudo apt install qtbase5-dev qtdeclarative5-dev qml-module-qtqml-models2 qml-module-qtquick-controls qml-module-qtquick-controls2 qml-module-qtquick-dialogs qml-module-qtquick-xmllistmodel qml-module-qt-labs-settings qml-module-qt-labs-platform qml-module-qt-labs-folderlistmodel qttools5-dev-tools qml-module-qtquick-templates2 libqt5svg5-dev`

  - For Gentoo
  
   
    The *qml* USE flag must be enabled.

    `sudo emerge dev-qt/qtcore:5 dev-qt/qtdeclarative:5 dev-qt/qtquickcontrols:5 dev-qt/qtquickcontrols2:5 dev-qt/qtgraphicaleffects:5`

  - Optional : To build the flag `WITH_SCANNER`

    - For Debian distributions (Debian, Ubuntu, Mint, Tails...)

      `sudo apt install qtmultimedia5-dev qml-module-qtmultimedia`

    - For Gentoo      

      `emerge dev-qt/qtmultimedia:5`


3. Clone repository

    ```
    git clone --recursive https://github.com/monero-project/monero-gui.git
    cd monero-gui
    ```

4. Build

    ```
    make release -j4
    ```

    \* `4` - number of CPU threads to use  
    \* Add `CMAKE_PREFIX_PATH` environment variable to set a custom Qt install directory, e.g. `CMAKE_PREFIX_PATH=$HOME/Qt/5.9.7/gcc_64 make release -j4`

The executable can be found in the build/release/bin folder.

### Building on OS X

1. Install Xcode from AppStore

2. Install [homebrew](http://brew.sh/)

3. Install [monero](https://github.com/monero-project/monero) dependencies:

  `brew install cmake pkg-config openssl boost unbound hidapi zmq libpgm libsodium miniupnpc expat libunwind-headers protobuf libgcrypt`

4. Install Qt:

  `brew install qt5`  (or download QT 5.9.7+ from [qt.io](https://www.qt.io/download-open-source/))

5. Grab an up-to-date copy of the monero-gui repository

   ```
   git clone --recursive https://github.com/monero-project/monero-gui.git
   cd monero-gui
   ```

6. Start the build

    ```
    make release -j4
    ```
    \* `4` - number of CPU threads to use  
    \* Add `CMAKE_PREFIX_PATH` environment variable to set a custom Qt install directory, e.g. `CMAKE_PREFIX_PATH=$HOME/Qt/5.9.7/clang_64 make release -j4`

The executable can be found in the `build/release/bin` folder.

For building an application bundle see `DEPLOY.md`.

### Building on Windows

The Monero GUI on Windows is 64 bits only; 32-bit Windows GUI builds are not officially supported anymore.

1. Install [MSYS2](https://www.msys2.org/), follow the instructions on that page on how to update system and packages to the latest versions

2. Open an 64-bit MSYS2 shell: Use the *MSYS2 MinGW 64-bit* shortcut, or use the `msys2_shell.cmd` batch file with a `-mingw64` parameter

3. Install MSYS2 packages for Monero dependencies; the needed 64-bit packages have `x86_64` in their names

    ```
    pacman -S mingw-w64-x86_64-toolchain make mingw-w64-x86_64-cmake mingw-w64-x86_64-boost mingw-w64-x86_64-openssl mingw-w64-x86_64-zeromq mingw-w64-x86_64-libsodium mingw-w64-x86_64-hidapi mingw-w64-x86_64-protobuf-c mingw-w64-x86_64-libusb mingw-w64-x86_64-libgcrypt mingw-w64-x86_64-unbound mingw-w64-x86_64-pcre
    ```

    You find more details about those dependencies in the [Monero documentation](https://github.com/monero-project/monero). Note that that there is no more need to compile Boost from source; like everything else, you can install it now with a MSYS2 package.

4. Install Qt5

    ```
    pacman -S mingw-w64-x86_64-qt5
    ```

    There is no more need to download some special installer from the Qt website, the standard MSYS2 package for Qt will do in almost all circumstances.

5. Install git

    ```
    pacman -S git
    ```

6. Clone repository

    ```
    git clone --recursive https://github.com/monero-project/monero-gui.git
    cd monero-gui
    ```

7. Build

    ```
    make release-win64 -j4
    cd build/release
    make deploy
    ```
    \* `4` - number of CPU threads to use

The executable can be found in the `.\bin` directory.
