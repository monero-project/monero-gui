# Monero Core

Copyright (c) 2014-2015, The Monero Project

## Development Resources

Web: [getmonero.org](https://getmonero.org)  
Forum: [forum.getmonero.org](https://forum.getmonero.org)  
Mail: [dev@getmonero.org](mailto:dev@getmonero.org)  
Github (staging): [https://github.com/monero-project/bitmonero](https://github.com/monero-project/bitmonero)  
Github (development): [http://github.com/monero-project/bitmonero/tree/development](http://github.com/monero-project/bitmonero/tree/development)  
IRC: [#monero-dev on Freenode](irc://chat.freenode.net/#monero-dev)

## Introduction

Monero is a private, secure, untraceable currency. You are your bank, you control your funds, and nobody can trace your transfers.

**Privacy:** Monero uses a cryptographically sound system to allow you to send and receive funds without your transactions being easily revealed on the blockchain (the ledger of transactions that everyone has). This ensures that your purchases, receipts, and all transfers remain absolutely private by default.

**Security:** Using the power of a distributed peer-to-peer consensus network, every transaction on the network is cryptographically secured. Individual wallets have a 24 word mnemonic that is only displayed once, and can be written down to backup the wallet. Wallet files are encrypted with a passphrase to ensure they are useless if stolen.

**Untraceability:** By taking advantage of ring signatures, a special property of certain types of cryptography, Monero is able to ensure that transactions are not only untraceable, but have an optional measure of ambiguity that ensures that transactions cannot easily be tied back to an individual user or computer.

## About this Project

This is the core GUI implementation of Monero. It is open source and completely free to use without restrictions, except for those specified in the license agreement below. There are no restrictions on anyone creating an alternative implementation of Monero that uses the protocol and network in a compatible manner.

As with many development projects, the repository on Github is considered to be the "staging" area for the latest changes. Before changes are merged into that branch on the main repository, they are tested by individual developers, merged to the staging repo, and then subsequently tested by contributors who focus on thorough testing and code reviews. That having been said, the repository should be carefully considered before using it in a production environment, unless there is a patch in the repository for a particular show-stopping issue you are experiencing. It is generally a better idea to use a tagged release for stability.

Anyone is able to contribute to Monero. If you have a fix or code change, feel free to submit is as a pull request directly to the "development" branch. In cases where the change is relatively small or does not affect other parts of the codebase it may be merged in immediately by any one of the collaborators. On the other hand, if the change is particularly large or complex, it is expected that it will be discussed at length either well in advance of the pull request being submitted, or even directly on the pull request.

## Supporting the Project

Monero development can be supported directly through donations.

Both Monero and Bitcoin donations can be made to donate.getmonero.org if using a client that supports the [OpenAlias](https://openalias.org) standard

The Monero donation address is: 46BeWrHpwXmHDpDEUmZBWZfoQpdc6HaERCNmx1pEYL2rAcuwufPN9rXHHtyUA4QVy66qeFQkn6sfK8aHYjA3jk3o1Bv16em (viewkey: e422831985c9205238ef84daf6805526c14d96fd7b059fe68c7ab98e495e5703)

The Bitcoin donation address is: 1FhnVJi2V1k4MqXm2nHoEbY5LV7FPai7bb

Core development funding and/or some supporting services are also graciously provided by sponsors:

[<img width="80" src="https://static.getmonero.org/images/sponsors/mymonero.png"/>](https://mymonero.com)
[<img width="150" src="https://static.getmonero.org/images/sponsors/kitware.png?1"/>](http://kitware.com)
[<img width="100" src="https://static.getmonero.org/images/sponsors/dome9.png"/>](http://dome9.com)
[<img width="150" src="https://static.getmonero.org/images/sponsors/araxis.png"/>](http://araxis.com)
[<img width="150" src="https://static.getmonero.org/images/sponsors/jetbrains.png"/>](http://www.jetbrains.com/)

There are also several mining pools that kindly donate a portion of their fees, [a list of them can be found on our Bitcointalk post](https://bitcointalk.org/index.php?topic=583449.0).

## License

See [LICENSE](LICENSE).

## Installing Monero-core from a Package

Packages are available for

* Arch Linux via AUR: [monero-core-git](https://aur.archlinux.org/packages/monero-core-git/)

Packaging for your favorite distribution would be a welcome contribution!

## Compiling Monero-core from Source

### Dependencies

TODO

### On Linux:

(Tested on Ubuntu 16.04 i386 and Linux Mint 18 "Sarah" - Cinnamon (64-bit))

1. Install Bitmonero dependencies.

`sudo apt install build-essential cmake libboost-all-dev miniupnpc libunbound-dev graphviz doxygen libunwind8-dev pkg-config libssl-dev`

2. Go to the repository where the most recent version is.

`git clone https://github.com/mbg033/monero-core.git`

3. Go into the repository.

`cd monero-core`

4. Use the script to compile the bitmonero libs necessary to run the GUI.

`./get_libwallet_api.sh`

5. Install the GUI dependencies.

  a) For Ubuntu 16.04 i386

`sudo apt-get install qtbase5-dev qt5-default qtdeclarative5-dev qml-module-qtquick-controls qml-module-qtquick-xmllistmodel qttools5-dev-tools qml-module-qtquick-dialogs`

  b) For Ubuntu 16.04 x64
  
`sudo apt-get install qtbase5-dev qt5-default qtdeclarative5-dev qml-module-qtquick-controls qml-module-qtquick-xmllistmodel qttools5-dev-tools qml-module-qtquick-dialogs qml-module-qt-labs-settings libqt5qml-graphicaleffects`

  c) For Linux Mint 18 "Sarah" - Cinnamon (64-bit)

`sudo apt install qml-module-qt-labs-settings qml-module-qtgraphicaleffects`

6. Build the GUI.

`qmake`

`make`

7. Before running the GUI, it's recommended you have a copy of bitmonero running in the background.

`./bitmonerod --rpc-bind-port 38081`

8. Run the GUI client.

`./release/bin/monero-core`

### On OS X:
1. install Xcode from AppStore
2. install [homebrew] (http://brew.sh/)
3. install [bitmonero] (https://github.com/monero-project/bitmonero) dependencies: 
    ```brew install boost --c++11```

    ```brew install pkgconfig```
    
    ```brew install cmake```
    
4. install latest Qt using official installer from [qt.io] (https://www.qt.io/download-open-source/), homebrew version might be outdated
5. Add Qt bin dir to your path:
    
     ```export PATH=$PATH:$HOME/Qt5/5.7clang_64/bin``` 
    
    where ```Qt5``` is the folder you selected to install Qt
6. Clone repository and build:
  
  ```
  git clone https://github.com/monero-project/monero-core.git
  
  cd monero-core
  
  build.sh
  
  ```
  
### On Windows:
TODO
