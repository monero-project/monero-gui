# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file LICENSE.rst or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION ${CMAKE_VERSION}) # this file comes with cmake

# If CMAKE_DISABLE_SOURCE_CHANGES is set to true and the source directory is an
# existing directory in our source tree, calling file(MAKE_DIRECTORY) on it
# would cause a fatal error, even though it would be a no-op.
if(NOT EXISTS "/Users/gjeane/work/draft_3/monero-gui/monero/translations")
  file(MAKE_DIRECTORY "/Users/gjeane/work/draft_3/monero-gui/monero/translations")
endif()
file(MAKE_DIRECTORY
  "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/translations"
  "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/generate_translations_header-prefix"
  "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/generate_translations_header-prefix/tmp"
  "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/generate_translations_header-prefix/src/generate_translations_header-stamp"
  "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/generate_translations_header-prefix/src"
  "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/generate_translations_header-prefix/src/generate_translations_header-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/generate_translations_header-prefix/src/generate_translations_header-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/generate_translations_header-prefix/src/generate_translations_header-stamp${cfgdir}") # cfgdir has leading slash
endif()
