set(QRENCODE_SOURCES
    qrencode.c
    qrinput.c
    qrspec.c
    rsecc.c
    mask.c
    split.c
    bitstream.c
    mmask.c
    mqrspec.c
)

set(QRENCODE_HEADERS
    qrencode_inner.h
    qrencode.h
    qrinput.h
    qrspec.h
    rsecc.h
    mask.h
    split.h
    bitstream.h
    mmask.h
    mqrspec.h
)

add_library(qrencode STATIC ${QRENCODE_SOURCES} ${QRENCODE_HEADERS})
target_compile_definitions(qrencode PRIVATE HAVE_CONFIG_H STATIC_IN_RELEASE=static)

set_target_properties(qrencode PROPERTIES C_STANDARD 99 C_STANDARD_REQUIRED ON)
