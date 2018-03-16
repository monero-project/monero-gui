# Monero GUI

Copyright (c) 2014-2018, The Monero Project

## Development resources

- Web: [getmonero.org](https://getmonero.org)
- Forum: [forum.getmonero.org](https://forum.getmonero.org)
- Mail: [dev@getmonero.org](mailto:dev@getmonero.org)
- Github: [https://github.com/monero-project/monero-gui](https://github.com/monero-project/monero-gui)
- IRC: [#monero-dev on Freenode](irc://chat.freenode.net/#monero-dev)

## Vulnerability response

- Our [Vulnerability Response Process](https://github.com/monero-project/meta/blob/master/VULNERABILITY_RESPONSE_PROCESS.md) encourages responsible disclosure
- We are also available via [HackerOne](https://hackerone.com/monero)

## Introduction

Monero is a private, secure, untraceable, decentralised digital currency. You are your bank, you control your funds, and nobody can trace your transfers unless you allow them to do so.

**Privacy:** Monero uses a cryptographically sound system to allow you to send and receive funds without your transactions being easily revealed on the blockchain (the ledger of transactions that everyone has). This ensures that your purchases, receipts, and all transfers remain absolutely private by default.

**Security:** Using the power of a distributed peer-to-peer consensus network, every transaction on the network is cryptographically secured. Individual wallets have a 25 word mnemonic seed that is only displayed once, and can be written down to backup the wallet. Wallet files are encrypted with a passphrase to ensure they are useless if stolen.

**Untraceability:** By taking advantage of ring signatures, a special property of a certain type of cryptography, Monero is able to ensure that transactions are not only untraceable, but have an optional measure of ambiguity that ensures that transactions cannot easily be tied back to an individual user or computer.

## About this project

This is the GUI for the [core Monero implementation](https://github.com/monero-project/monero). It is open source and completely free to use without restrictions, except for those specified in the license agreement below. There are no restrictions on anyone creating an alternative implementation of Monero that uses the protocol and network in a compatible manner.

As with many development projects, the repository on Github is considered to be the "staging" area for the latest changes. Before changes are merged into that branch on the main repository, they are tested by individual developers in their own branches, submitted as a pull request, and then subsequently tested by contributors who focus on testing and code reviews. That having been said, the repository should be carefully considered before using it in a production environment, unless there is a patch in the repository for a particular show-stopping issue you are experiencing. It is generally a better idea to use a tagged release for stability.

## Supporting the project

Monero is a 100% community-sponsored endeavor. If you want to join our efforts, the easiest thing you can do is support the project financially. Both Monero and Bitcoin donations can be made to **donate.getmonero.org** if using a client that supports the [OpenAlias](https://openalias.org) standard.

The Monero donation address is: `44AFFq5kSiGBoZ4NMDwYtN18obc8AemS33DBLWs3H7otXft3XjrpDtQGv7SqSsaBYBb98uNbr2VBBEt7f2wfn3RVGQBEP3A` (viewkey: `f359631075708155cc3d92a32b75a7d02a5dcf27756707b47a2b31b21c389501`)

The Bitcoin donation address is: `1KTexdemPdxSBcG55heUuTjDRYqbC5ZL8H`

GUI development funding and/or some supporting services are also graciously provided by sponsors:

[<img width="80" src="https://static.getmonero.org/images/sponsors/mymonero.png"/>](https://mymonero.com)
[<img width="150" src="https://static.getmonero.org/images/sponsors/kitware.png?1"/>](http://kitware.com)
[<img width="100" src="https://static.getmonero.org/images/sponsors/dome9.png"/>](http://dome9.com)
[<img width="150" src="https://static.getmonero.org/images/sponsors/araxis.png"/>](http://araxis.com)
[<img width="150" src="https://static.getmonero.org/images/sponsors/jetbrains.png"/>](http://www.jetbrains.com/)
[<img width="150" src="https://static.getmonero.org/images/sponsors/navicat.png"/>](http://www.navicat.com/)
[<img width="150" src="https://static.getmonero.org/images/sponsors/symas.png"/>](http://www.symas.com/)

There are also several mining pools that kindly donate a portion of their fees, [a list of them can be found on our Bitcointalk post](https://bitcointalk.org/index.php?topic=583449.0).

## License

See [LICENSE](LICENSE).

## Installing the Monero GUI from a package

Packages are available for

* Arch Linux via AUR: [monero-wallet-qt](https://aur.archlinux.org/packages/monero-wallet-qt/)
* Void Linux: xbps-install -S monero-core
* GuixSD: guix package -i monero-core

Packaging for your favorite distribution would be a welcome contribution!

## Compiling the Monero GUI from source

### On Linux:

(Tested on Ubuntu 16.04 x86, 16.10 x64, Gentoo x64 and Linux Mint 18 "Sarah" - Cinnamon x64)

1. Install Monero dependencies

  - For Ubuntu and Mint

	`sudo apt install build-essential cmake libboost-all-dev miniupnpc libunbound-dev graphviz doxygen libunwind8-dev pkg-config libssl-dev libzmq3-dev`

  - For Gentoo

	`sudo emerge app-arch/xz-utils app-doc/doxygen dev-cpp/gtest dev-libs/boost dev-libs/expat dev-libs/openssl dev-util/cmake media-gfx/graphviz net-dns/unbound net-libs/ldns net-libs/miniupnpc net-libs/zeromq sys-libs/libunwind`

2. Grab an up-to-date copy of the monero-gui repository

	`git clone https://github.com/monero-project/monero-gui.git`

3. Go into the repository

	`cd monero-gui`

4. Install the GUI dependencies

  - For Ubuntu 16.04 x86

	`sudo apt install qtbase5-dev qt5-default qtdeclarative5-dev qml-module-qtquick-controls qml-module-qtquick-xmllistmodel qttools5-dev-tools qml-module-qtquick-dialogs`

  - For Ubuntu 16.04+ x64

    `sudo apt install qtbase5-dev qt5-default qtdeclarative5-dev qml-module-qtquick-controls qml-module-qtquick-xmllistmodel qttools5-dev-tools qml-module-qtquick-dialogs qml-module-qt-labs-settings libqt5qml-graphicaleffects`

  - For Linux Mint 18 "Sarah" - Cinnamon x64

    `sudo apt install qml-module-qt-labs-settings qml-module-qtgraphicaleffects`

  - For Gentoo

    `sudo emerge dev-qt/qtcore:5 dev-qt/qtdeclarative:5 dev-qt/qtquickcontrols:5 dev-qt/qtquickcontrols2:5 dev-qt/qtgraphicaleffects:5`

  - Optional : To build the flag `WITH_SCANNER`

    - For Ubuntu and Mint

      `sudo apt install qtmultimedia5-dev qml-module-qtmultimedia libzbar-dev`

    - For Gentoo

      The *qml* USE flag must be enabled.

      `emerge dev-qt/qtmultimedia:5 media-gfx/zbar`

5. Build the GUI

  - For Ubuntu and Mint

	`./build.sh`

  - For Gentoo

    `QT_SELECT=5 ./build.sh`

The executable can be found in the build/release/bin folder.

### On OS X:

1. Install Xcode from AppStore

2. Install [homebrew](http://brew.sh/)

3. Install [monero](https://github.com/monero-project/monero) dependencies:

  `brew install boost --c++11`

  `brew install openssl` - to install openssl headers

  `brew install pkgconfig`

  `brew install cmake`

  `brew install zeromq`

  *Note*: If cmake can not find zmq.hpp file on OS X, installing `zmq.hpp` from https://github.com/zeromq/cppzmq to `/usr/local/include` should fix that error.

4. Install Qt:

  `brew install qt5`  (or download QT 5.8+ from [qt.io](https://www.qt.io/download-open-source/))

  If you have an older version of Qt installed via homebrew, you can force it to use 5.x like so:
  
  `brew link --force --overwrite qt5`

5. Add the Qt bin directory to your path

    Example: `export PATH=$PATH:$HOME/Qt/5.8/clang_64/bin`

    This is the directory where Qt 5.x is installed on **your** system

6. Grab an up-to-date copy of the monero-gui repository

  `git clone https://github.com/monero-project/monero-gui.git`

7. Go into the repository

  `cd monero-gui`

8. Start the build

  `./build.sh`

The executable can be found in the `build/release/bin` folder.

**Note:** Workaround for "ERROR: Xcode not set up properly"

Edit `$HOME/Qt/5.8/clang_64/mkspecs/features/mac/default_pre.prf`

replace
`isEmpty($$list($$system("/usr/bin/xcrun -find xcrun 2>/dev/null")))`

with
`isEmpty($$list($$system("/usr/bin/xcrun -find xcodebuild 2>/dev/null")))`

More info: http://stackoverflow.com/a/35098040/1683164


### On Windows:

1. Install [msys2](http://msys2.github.io/), follow the instructions on that page on how to update packages to the latest versions

2. Install Monero dependencies as described in [monero documentation](https://github.com/monero-project/monero) into msys2 environment
   **As we only build application for x86, install only dependencies for x86 architecture (i686 in package name)**
   ```
   pacman -S mingw-w64-i686-toolchain make mingw-w64-i686-cmake mingw-w64-i686-boost mingw-w64-i686-openssl mingw-w64-i686-zeromq mingw-w64-i686-libsodium

   ```

3. Install git into msys2 environment

    ```
    pacman -S git
    ```

4. Install Qt5 from [official site](https://www.qt.io/download-open-source/)
   - download unified installer, run and select following options:
       - Qt > Qt 5.7 > MinGW 5.3.0 32 bit
       - Tools > MinGW 5.3.0
   - continue with installation

5. Open ```MinGW-w64 Win32 Shell``` shell

   ```%MSYS_ROOT%\msys2_shell.cmd -mingw32```

   Where ```%MSYS_ROOT%``` will be ```c:\msys32``` if your host OS is x86-based or ```c:\msys64``` if your host OS
   is x64-based

6. Install the latest version of boost, specifically the required static libraries
    ```
    cd
    wget http://sourceforge.net/projects/boost/files/boost/1.63.0/boost_1_63_0.tar.bz2
    tar xjf boost_1_63_0.tar.bz2
    cd boost_1_63_0
    ./bootstrap.sh mingw
    ./b2 --prefix=/mingw32/boost --layout=tagged --without-mpi --without-python toolset=gcc address-model=32 variant=debug,release link=static threading=multi runtime-link=static -j$(nproc) install
    ```

7. Clone repository
    ```
    cd
    git clone https://github.com/monero-project/monero-gui.git
    ```

8. Build the GUI
    ```
    cd monero-gui
    export PATH=$(ls -rd /c/Qt/5.[6,7,8]/mingw53_32/bin | head -1):$PATH
    ./build.sh
    cd build
    make deploy
    ```

The executable can be found in the ```.\release\bin``` directory.
