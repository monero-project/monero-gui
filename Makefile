ANDROID_STANDALONE_TOOLCHAIN_PATH ?= /usr/local/toolchain

dotgit=$(shell ls -d .git/config)
ifneq ($(dotgit), .git/config)
  USE_SINGLE_BUILDDIR=1
endif

subbuilddir:=$(shell echo  `uname | sed -e 's|[:/\\ \(\)]|_|g'`/`git branch | grep '\* ' | cut -f2- -d' '| sed -e 's|[:/\\ \(\)]|_|g'`)
ifeq ($(USE_SINGLE_BUILDDIR),)
  builddir := build/"$(subbuilddir)"
  topdir   := ../../../..
  deldirs  := $(builddir)
else
  builddir := build
  topdir   := ../..
  deldirs  := $(builddir)/debug $(builddir)/release $(builddir)/fuzz
endif


default:
	mkdir -p build && cd build && cmake -D ARCH="x86-64" -D DEV_MODE=$(or ${DEV_MODE},OFF) -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release .. && $(MAKE)
debug:
	mkdir -p build && cd build && cmake -D DEV_MODE=$(or ${DEV_MODE},ON) .. && $(MAKE) VERBOSE=1
devmode:
	mkdir -p build && cd build && cmake -D ARCH="x86-64" -D DEV_MODE=$(or ${DEV_MODE},ON) -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release .. && $(MAKE)
clean:
	mkdir -p build && cd build && rm -rf *
scanner:
	mkdir -p build && cd build && cmake -D ARCH="x86-64" -D DEV_MODE=$(or ${DEV_MODE},ON) -D WITH_SCANNER=ON -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release .. && $(MAKE)

debug-static-win64:
	mkdir -p $(builddir)/debug && cd $(builddir)/debug && cmake -D STATIC=ON -G "MSYS Makefiles" -D DEV_MODE=$(or ${DEV_MODE},ON) -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Debug -D BUILD_TAG="win-x64" -D CMAKE_TOOLCHAIN_FILE=$(topdir)/cmake/64-bit-toolchain.cmake -D MSYS2_FOLDER=$(cd $MINGW_PREFIX/.. && pwd -W) -D MINGW=ON $(topdir) && $(MAKE)

debug-static-mac64:
	mkdir -p $(builddir)/debug
	cd $(builddir)/debug && cmake -D STATIC=ON -D DEV_MODE=$(or ${DEV_MODE},ON) -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=release -D BUILD_TAG="mac-x64" $(topdir) && $(MAKE)

release-static-win64:
	mkdir -p $(builddir)/release && cd $(builddir)/release && cmake -D STATIC=ON -G "MSYS Makefiles" -D DEV_MODE=$(or ${DEV_MODE},OFF) -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="win-x64" -D CMAKE_TOOLCHAIN_FILE=$(topdir)/cmake/64-bit-toolchain.cmake -D MSYS2_FOLDER=$(cd $MINGW_PREFIX/.. && pwd -W) -D MINGW=ON $(topdir) && $(MAKE)

