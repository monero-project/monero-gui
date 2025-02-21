add_library(qrdecoder STATIC
    Decoder.cpp
)
target_link_libraries(qrdecoder
    PUBLIC
        Qt6::Gui
    PRIVATE
        quirc
)

if(WITH_SCANNER)
    add_library(qrscanner
        QrCodeScanner.cpp
        QrScanThread.cpp
    )
    find_package(Qt6 REQUIRED COMPONENTS Multimedia)
    target_link_libraries(qrscanner
        PUBLIC
            Qt6::Multimedia
            qrdecoder
    )
endif()
