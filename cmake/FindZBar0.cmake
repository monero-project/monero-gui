# from http://code.google.com/p/low-cost-vision-2012/source/browse/CMakeModules/FindZBar0.cmake?name=2-helium-1&r=d61f248bd5565b3c086bf4769a04bfd98f7079df
# - Try to find ZBar
# This will define
#
#  ZBAR_FOUND - 
#  ZBAR_LIBRARY_DIR - 
#  ZBAR_INCLUDE_DIR - 
#  ZBAR_LIBRARIES - 
#

find_package(PkgConfig)
pkg_check_modules(PC_ZBAR QUIET zbar)
set(ZBAR_DEFINITIONS ${PC_ZBAR_CFLAGS_OTHER})
find_library(ZBAR_LIBRARIES NAMES zbar 
             HINTS ${PC_ZBAR_LIBDIR} ${PC_ZBAR_LIBRARY_DIRS} )
find_path(ZBAR_INCLUDE_DIR Decoder.h
          HINTS ${PC_ZBAR_INCLUDEDIR} ${PC_ZBAR_INCLUDE_DIRS}
          PATH_SUFFIXES zbar )
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ZBAR  DEFAULT_MSG  ZBAR_LIBRARIES ZBAR_INCLUDE_DIR)
message(STATUS "Found zbar libraries ${ZBAR_LIBRARIES}")

