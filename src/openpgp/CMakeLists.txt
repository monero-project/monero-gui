file(GLOB_RECURSE SOURCES *.cpp)
file(GLOB_RECURSE HEADERS *.h)

find_library(GCRYPT_LIBRARY gcrypt REQUIRED)
find_path(GCRYPT_INCLUDE_DIR gcrypt.h REQUIRED)

find_library(GPG_ERROR_LIBRARY gpg-error REQUIRED)

add_library(openpgp
  ${SOURCES}
  ${HEADERS})

target_include_directories(openpgp
  PUBLIC
    ${CMAKE_SOURCE_DIR}/monero/contrib/epee/include
    ${GCRYPT_INCLUDE_DIR})

target_link_libraries(openpgp
  PUBLIC
    ${GCRYPT_LIBRARY}
    ${GPG_ERROR_LIBRARY})
