add_library(qrdecoder STATIC
    Decoder.cpp
)
target_link_libraries(qrdecoder
    PUBLIC
        Qt5::Gui
    PRIVATE
        quirc
)

if(WITH_SCANNER)
    add_library(qrscanner
        QrCodeScanner.cpp
        QrScanThread.cpp
    )
    target_link_libraries(qrscanner
        PUBLIC
            Qt5::Multimedia
            qrdecoder
    )
endif()
