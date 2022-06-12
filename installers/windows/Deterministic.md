# Building the Installer Deterministically

This file contains info about building the Windows installer deterministically, i.e. how different people on different Windows machines or VMs can build it and arrive at a result that is bit-for-bit identical. This approach is also known as *reproducible builds*, see e.g. [this Wikipedia article](https://en.wikipedia.org/wiki/Reproducible_builds).

The steps to build the Windows installer deterministically by a group of people are the following (for some details about the build process in general see `README.md`):

* Agree on a particular version of Inno Setup, and everybody install that
* Get the zip file for the Windows GUI wallet and unpack it, plus make sure / check that the file timestamps are preserved, i.e. upacked timestamp = timestamp in zip file
* Build using Inno Setup and the `Monero.iss` script file
* Success: All people arrive at a bit-for-bit identical installer .exe file, which they can verify by calculating and exchanging SHA256 hashes

Some background info why this process is relatively simple:

The tool used to build the Windows installer, Inno Setup, avoids many issues that make reproducible builds very challenging with many other compilers and similar tools: It does not store current date and time in the installer .exe file, and it does not seem to depend on the Windows version it runs on (tried with Windows 7 and two different editions of Windows 10), nor on the locale and display language.

So fortunately no complicated things as faked current system time or use of VMs with exactly prescribed versions of Windows are necessary.

The version of Inno Setup **is** important however: People wanting to reproducibly build the installer must agree on a particular version to use. This should not be hard to do however.

Also important are the **timestamps** of the source files because they go into the installer file, to be restored at install time.

You would think timestamp preservation is no problem when unpacking the zip archive with the files for the Windows GUI wallet from getmonero.org, but if you use the zip folder unpack functionality of the Windows 7 GUI, the files get the current date, **not** the file recorded in the zip file. (The Windows 10 GUI seems better here, and also the 7zip app.)

In any case, after unpacking, check the file dates in the `bin` directory where the installer script looks for them with the dates of the files in the zip file: They must be identical.

Note that the the following line in `Monero.iss` is also important regarding file timestamps:

    TimeStampsInUTC=yes

Without this line the **timezone** of the machine used to build the installer would matter, with different timezones leading to different installer files.
