ANDROID_STANDALONE_TOOLCHAIN_PATH ?= /usr/local/toolchain
MANUAL_SUBMODULES ?= OFF

dotgit=$(shell ls -d .git/config)
ifeq ($(dotgit), .git/config)
  ifeq ($(shell git --version > /dev/null 2>&1 ; echo $$?), 0)
	git = yes
  else
    $(warning git command not found)
  endif
endif

builddir := build
topdir := ../..
ifeq ($(USE_SINGLE_BUILDDIR), OFF)
  os := $(shell echo  `uname | sed -e 's|[:/\\ \(\)]|_|g'`)
  builddir := $(builddir)/$(os)
  topdir := $(topdir)/..

  ifdef git
    branch := $(shell git branch | grep '\* ' | cut -f2- -d' '| sed -e 's|[:/\\ \(\)]|_|g')
    builddir := $(builddir)/$(branch)
    topdir := $(topdir)/..
  endif

  deldirs := $(builddir)
else
  deldirs := $(builddir)/debug $(builddir)/release $(builddir)/fuzz
endif

default:
	mkdir -p build && cd build && cmake -D DEBUG_HWDEVICE=ON -D DEV_MODE=$(or ${DEV_MODE},OFF) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release .. && $(MAKE)
debug:
	mkdir -p build && cd build && cmake -D DEV_MODE=$(or ${DEV_MODE},ON) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D CMAKE_BUILD_TYPE=Debug .. && $(MAKE) VERBOSE=1

depends:
	mkdir -p build/$(target)/release
	cd build/$(target)/release && cmake -D STATIC=ON -D DEV_MODE=$(or ${DEV_MODE},OFF) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D BUILD_TAG=$(tag) -D CMAKE_BUILD_TYPE=Release -D CMAKE_TOOLCHAIN_FILE=$(root)/$(target)/share/toolchain.cmake ../../.. && $(MAKE)

devmode:
	mkdir -p build && cd build && cmake -D DEV_MODE=$(or ${DEV_MODE},ON) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release .. && $(MAKE)
clean:
	mkdir -p build && cd build && rm -rf *
scanner:
	mkdir -p build && cd build && cmake -D DEV_MODE=$(or ${DEV_MODE},ON) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D WITH_SCANNER=ON -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release .. && $(MAKE)

release:
	mkdir -p $(builddir)/release && cd $(builddir)/release && cmake -D DEV_MODE=$(or ${DEV_MODE},OFF) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D CMAKE_BUILD_TYPE=Release $(topdir) && $(MAKE)

release-linux-armv8:
	mkdir -p $(builddir)/release && cd $(builddir)/release && cmake -D DEV_MODE=$(or ${DEV_MODE},OFF) -D ARCH="armv8-a" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="linux-armv8" $(topdir) && $(MAKE)

release-linux-ppc64le:
	mkdir -p $(builddir)/release && cd $(builddir)/release && cmake -D DEV_MODE=$(or ${DEV_MODE},OFF) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D ARCH="ppc64le" -D CMAKE_BUILD_TYPE=Release $(topdir) && $(MAKE)

release-static:
	mkdir -p $(builddir)/release && cd $(builddir)/release && cmake -D STATIC=ON -D DEV_MODE=$(or ${DEV_MODE},OFF) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release $(topdir) && $(MAKE)

debug-static-win64:
	mkdir -p $(builddir)/debug && cd $(builddir)/debug && cmake -D STATIC=ON -G "MSYS Makefiles" -D DEV_MODE=$(or ${DEV_MODE},ON) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Debug -D BUILD_TAG="win-x64" -D CMAKE_TOOLCHAIN_FILE=$(topdir)/cmake/64-bit-toolchain.cmake -D MSYS2_FOLDER=$(shell cd ${MINGW_PREFIX}/.. && pwd -W) -D MINGW=ON $(topdir) && $(MAKE)

debug-static-mac64:
	mkdir -p $(builddir)/debug
	cd $(builddir)/debug && cmake -D STATIC=ON -D DEV_MODE=$(or ${DEV_MODE},ON) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Debug -D BUILD_TAG="mac-x64" $(topdir) && $(MAKE)

release-static-win64:
	mkdir -p $(builddir)/release && cd $(builddir)/release && cmake -D DEBUG_HWDEVICE=ON -D STATIC=ON -G "MSYS Makefiles" -D DEV_MODE=$(or ${DEV_MODE},OFF) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="win-x64" -D CMAKE_TOOLCHAIN_FILE=$(topdir)/cmake/64-bit-toolchain.cmake -D MSYS2_FOLDER=$(shell cd ${MINGW_PREFIX}/.. && pwd -W) -D MINGW=ON $(topdir) && $(MAKE)

release-win64:
	mkdir -p $(builddir)/release && cd $(builddir)/release && cmake -D DEBUG_HWDEVICE=ON -D STATIC=OFF -G "MSYS Makefiles" -D DEV_MODE=$(or ${DEV_MODE},OFF) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="win-x64" -D CMAKE_TOOLCHAIN_FILE=$(topdir)/cmake/64-bit-toolchain.cmake -D MSYS2_FOLDER=$(shell cd ${MINGW_PREFIX}/.. && pwd -W) -D MINGW=ON $(topdir) && $(MAKE)
