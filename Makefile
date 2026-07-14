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
endif

default:
	mkdir -p build && cd build && cmake -G Ninja -D DEV_MODE=$(or ${DEV_MODE},OFF) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release .. && cmake --build .
debug:
	mkdir -p build && cd build && cmake -G Ninja -D DEV_MODE=$(or ${DEV_MODE},ON) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D CMAKE_BUILD_TYPE=Debug .. && cmake --build . --verbose

depends:
	mkdir -p build/$(target)/release
	cd build/$(target)/release && cmake -G Ninja -D STATIC=ON -D DEV_MODE=$(or ${DEV_MODE},OFF) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D BUILD_TAG=$(tag) -D CMAKE_BUILD_TYPE=Release -D CMAKE_TOOLCHAIN_FILE=$(root)/$(target)/share/toolchain.cmake ../../.. && cmake --build .

devmode:
	mkdir -p build && cd build && cmake -G Ninja -D DEV_MODE=$(or ${DEV_MODE},ON) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release .. && cmake --build .
clean:
	mkdir -p build && cd build && rm -rf *
scanner:
	mkdir -p build && cd build && cmake -G Ninja -D DEV_MODE=$(or ${DEV_MODE},ON) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D WITH_SCANNER=ON -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release .. && cmake --build .

release:
	mkdir -p $(builddir)/release && cd $(builddir)/release && cmake -G Ninja -D DEV_MODE=$(or ${DEV_MODE},OFF) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D CMAKE_BUILD_TYPE=Release $(topdir) && cmake --build .

release-linux-armv8:
	mkdir -p $(builddir)/release && cd $(builddir)/release && cmake -G Ninja -D DEV_MODE=$(or ${DEV_MODE},OFF) -D ARCH="armv8-a" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="linux-armv8" $(topdir) && cmake --build .

release-linux-ppc64le:
	mkdir -p $(builddir)/release && cd $(builddir)/release && cmake -G Ninja -D DEV_MODE=$(or ${DEV_MODE},OFF) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D ARCH="ppc64le" -D CMAKE_BUILD_TYPE=Release $(topdir) && cmake --build .

release-static:
	mkdir -p $(builddir)/release && cd $(builddir)/release && cmake -G Ninja -D STATIC=ON -D DEV_MODE=$(or ${DEV_MODE},OFF) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release $(topdir) && cmake --build .

debug-static-win64:
	mkdir -p $(builddir)/debug && cd $(builddir)/debug && cmake -D STATIC=ON -G Ninja -D DEV_MODE=$(or ${DEV_MODE},ON) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Debug -D BUILD_TAG="win-x64" -D CMAKE_TOOLCHAIN_FILE=$(topdir)/cmake/64-bit-toolchain.cmake -D MSYS2_FOLDER=$(shell cd ${MINGW_PREFIX}/.. && pwd -W) -D MINGW=ON $(topdir) && cmake --build .

debug-static-mac64:
	mkdir -p $(builddir)/debug
	cd $(builddir)/debug && cmake -G Ninja -D STATIC=ON -D DEV_MODE=$(or ${DEV_MODE},ON) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Debug -D BUILD_TAG="mac-x64" $(topdir) && cmake --build .

release-static-win64:
	mkdir -p $(builddir)/release && cd $(builddir)/release && cmake -D STATIC=ON -G Ninja -D DEV_MODE=$(or ${DEV_MODE},OFF) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="win-x64" $(topdir) && cmake --build .

release-win64:
	mkdir -p $(builddir)/release && cd $(builddir)/release && cmake -D STATIC=OFF -G Ninja -D DEV_MODE=$(or ${DEV_MODE},OFF) -DMANUAL_SUBMODULES=${MANUAL_SUBMODULES} -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="win-x64" $(topdir) && cmake --build .
