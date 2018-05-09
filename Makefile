default:
	mkdir -p build && cd build && cmake -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release .. && $(MAKE)
debug:
	mkdir -p build && cd build && ccmake .. && $(MAKE) VERBOSE=1
devmode:
	mkdir -p build && cd build && cmake -D STATIC=ON -D ARCH="x86-64" -D DEV_MODE=ON -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release .. && $(MAKE)
clean:
	mkdir -p build && cd build && rm -rf *
scanner:
	mkdir -p build && cd build && cmake -D STATIC=ON -D ARCH="x86-64" -D DEV_MODE=ON -D WITH_SCANNER=ON -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release .. && $(MAKE)

