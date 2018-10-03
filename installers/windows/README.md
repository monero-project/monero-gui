# Monero GUI Wallet Windows Installer #

Copyright (c) 2014-2018, The Monero Project

## Introduction ##

This is a *Inno Setup* script `Monero.iss` plus some related files
that allows you to build a standalone Windows installer (.exe) for
the GUI wallet that comes with the Lithium Luna release of Monero.

This turns the GUI wallet into a more or less standard Windows program,
by default installed into a subdirectory of `C:\Program Files`, a
program group with some icons in the *Start* menu, and automatic
uninstall support. It helps lowering the "barrier to entry"
somewhat, especially for less technically experienced users of
Monero.

As the setup script in file [Monero.iss](Monero.iss) has to list every
single file of the GUI wallet package to install by name,
this version of the script only works with exactly the GUI wallet
for Monero release *Lithium Luna* that you find on
[the official download page](https://getmonero.org/downloads/).

But of course it will be easy to modify the script for future
versions of the GUI wallet.

## License ##

See [LICENSE](LICENSE).

## Building ##

You can only build on Windows, and the result is always a
Windows .exe file that can act as a standalone installer for the
Lithium Luna GUI wallet.

The build steps in detail:

1. Install *Inno Setup*. You can get it from [here](http://www.jrsoftware.org/isdl.php)
2. Get the Inno Setup script plus related files by cloning the whole [monero-core GitHub repository](https://github.com/monero-project/monero-core); you will only need the files in the installer directory `installers\windows` however
3. The setup script is written to take the GUI wallet files from a subdirectory named `bin`; so create `installers\windows\bin`, get the zip file of the GUI wallet from [here](https://getmonero.org/downloads/), unpack it somewhere, and copy all the files and subdirectories in the `monero-gui-0.12.3.0` directory to this `bin` subdirectory
4. Start Inno Setup, load `Monero.iss` and compile it
5. The result i.e. the finished installer will be the file `mysetup.exe` in the `installers\windows\Output` subdirectory 

