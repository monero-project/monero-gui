if(APPLE OR (WIN32 AND NOT STATIC))
    add_custom_target(deploy)
    get_target_property(_qmake_executable Qt6::qmake IMPORTED_LOCATION)
    get_filename_component(_qt_bin_dir "${_qmake_executable}" DIRECTORY)

    if(APPLE AND NOT IOS)
        find_program(MACDEPLOYQT_EXECUTABLE macdeployqt HINTS "${_qt_bin_dir}")
        add_custom_command(TARGET deploy
                           POST_BUILD
                           COMMAND "${MACDEPLOYQT_EXECUTABLE}" "$<TARGET_FILE_DIR:monero-wallet-gui>/../.." -always-overwrite -qmldir="${CMAKE_SOURCE_DIR}"
                           COMMENT "Running macdeployqt..."
        )

        # Copy Boost dylibs that macdeployqt doesn't pick up
        find_package(Boost QUIET COMPONENTS atomic container date_time)
        set(_boost_extras Boost::atomic Boost::container Boost::date_time)
        foreach(_tgt IN LISTS _boost_extras)
            if(TARGET ${_tgt})
                add_custom_command(TARGET deploy POST_BUILD
                                   COMMAND ${CMAKE_COMMAND} -E copy
                                   "$<TARGET_FILE:${_tgt}>"
                                   "$<TARGET_FILE_DIR:monero-wallet-gui>/../Frameworks/"
                                   COMMENT "Copying $<TARGET_FILE_NAME:${_tgt}>"
                )
            endif()
        endforeach()

        # Copy Abseil runtime libraries used by Protobuf's utf8_range libraries.
        # Homebrew's libutf8_validity.dylib links against libabsl_*.dylib, and
        # macdeployqt does not deploy these because the utf8_range libraries are copied manually.
        find_package(Protobuf QUIET)

        if(TARGET protobuf::libprotobuf)
            get_target_property(_protobuf_dylib protobuf::libprotobuf IMPORTED_LOCATION)

            if(_protobuf_dylib)
                get_filename_component(_protobuf_lib_dir "${_protobuf_dylib}" DIRECTORY)

                file(GLOB _protobuf_utf8_dylibs
                    "${_protobuf_lib_dir}/libutf8_*.dylib"
                )

                foreach(_dylib IN LISTS _protobuf_utf8_dylibs)
                    add_custom_command(TARGET deploy POST_BUILD
                        COMMAND ${CMAKE_COMMAND} -E copy
                        "${_dylib}"
                        "$<TARGET_FILE_DIR:monero-wallet-gui>/../Frameworks/"
                        COMMENT "Copying ${_dylib}"
                    )
                endforeach()

                find_file(_abseil_strings_dylib
                    NAMES libabsl_strings.dylib
                    PATHS
                    /opt/homebrew/opt/abseil/lib
                    /usr/local/opt/abseil/lib
                    "${_protobuf_lib_dir}"
                    NO_DEFAULT_PATH
                )

                if(_abseil_strings_dylib)
                    get_filename_component(_abseil_lib_dir "${_abseil_strings_dylib}" DIRECTORY)

                    file(GLOB _protobuf_abseil_dylibs
                        "${_abseil_lib_dir}/libabsl_*.dylib"
                    )

                    foreach(_dylib IN LISTS _protobuf_abseil_dylibs)
                        add_custom_command(TARGET deploy POST_BUILD
                            COMMAND ${CMAKE_COMMAND} -E copy
                            "${_dylib}"
                            "$<TARGET_FILE_DIR:monero-wallet-gui>/../Frameworks/"
                            COMMENT "Copying ${_dylib}"
                        )
                    endforeach()
                else()
                    message(WARNING "Abseil dylibs not found; libutf8_validity may still reference Homebrew")
                endif()
            endif()
        endif()

        # Remove Homebrew rpaths from the executable.
        # These can make the app load local Homebrew libraries instead of bundled libraries.
        add_custom_command(TARGET deploy
            POST_BUILD
            COMMAND ${CMAKE_COMMAND}
            -DEXECUTABLE=$<TARGET_FILE:monero-wallet-gui>
            -DINSTALL_NAME_TOOL=${CMAKE_INSTALL_NAME_TOOL}
            -P ${CMAKE_SOURCE_DIR}/cmake/DeleteHomebrewRpaths.cmake
            COMMENT "Removing Homebrew rpaths from app executable"
        )

        # Apple Silicon requires all binaries to be codesigned
        find_program(CODESIGN_EXECUTABLE NAMES codesign)
        if(CODESIGN_EXECUTABLE)
            add_custom_command(TARGET deploy
                            POST_BUILD
                            COMMAND "${CODESIGN_EXECUTABLE}" --force --deep --sign - "$<TARGET_FILE_DIR:monero-wallet-gui>/../.."
                            COMMENT "Running codesign..."
            )
        endif()

    elseif(WIN32)
        find_program(QMAKE_EXECUTABLE qmake HINTS "${_qt_bin_dir}")
        find_program(WINDEPLOYQT_EXECUTABLE windeployqt HINTS "${_qt_bin_dir}")
        set(QMLIMPORTSCANNER_EXECUTABLE "${_qt_bin_dir}/qmlimportscanner${CMAKE_EXECUTABLE_SUFFIX}")
        if(NOT QMAKE_EXECUTABLE OR NOT WINDEPLOYQT_EXECUTABLE OR
                NOT EXISTS "${QMLIMPORTSCANNER_EXECUTABLE}")
            message(WARNING "Deploy requires qmake, windeployqt, and qmlimportscanner in ${_qt_bin_dir}")
         endif()

        execute_process(
            COMMAND "${QMAKE_EXECUTABLE}" -query QT_INSTALL_QML
            OUTPUT_VARIABLE _qt_qml_dir
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        if(NOT IS_DIRECTORY "${_qt_qml_dir}")
            message(WARNING "Qt QML import directory does not exist: ${_qt_qml_dir}")
        endif()
        add_custom_command(TARGET deploy POST_BUILD
                           COMMAND "${CMAKE_COMMAND}" -E env PATH="${_qt_bin_dir}" "${WINDEPLOYQT_EXECUTABLE}" "$<TARGET_FILE:monero-wallet-gui>" -no-translations -qmldir="${CMAKE_SOURCE_DIR}" -qmlimport="${_qt_qml_dir}"
                           COMMENT "Running windeployqt..."
        )
        set(WIN_DEPLOY_DLLS
            libboost_chrono-mt.dll
            libboost_filesystem-mt.dll
            libboost_locale-mt.dll
            libboost_program_options-mt.dll
            libboost_serialization-mt.dll
            libboost_thread-mt.dll
            libprotobuf.dll
            libbrotlicommon.dll
            libbrotlidec.dll
            libusb-1.0.dll
            zlib1.dll
            libzstd.dll
            libwinpthread-1.dll
            libstdc++-6.dll
            libpng16-16.dll
            libpcre16-0.dll
            libpcre-1.dll
            liblzma-5.dll
            libjpeg-8.dll
            libintl-8.dll
            libiconv-2.dll
            libharfbuzz-0.dll
            libgraphite2.dll
            libglib-2.0-0.dll
            libfreetype-6.dll
            libbz2-1.dll
            libpcre2-16-0.dll
            libhidapi-0.dll
            libdouble-conversion.dll
            libgcrypt-20.dll
            libgpg-error-0.dll
            libsodium-26.dll
            libzmq.dll
            #platform files
            libgcc_s_seh-1.dll
            #openssl files
            libssl-3-x64.dll
            libcrypto-3-x64.dll
            #icu
            libicudt78.dll
            libicuin78.dll
            libicuio78.dll
            libicutu78.dll
            libicuuc78.dll
        )

        # Boost Regex is header-only since 1.77
        if (Boost_VERSION_STRING VERSION_LESS 1.77.0)
            list(APPEND WIN_DEPLOY_DLLS libboost_regex-mt.dll)
        endif()

        list(TRANSFORM WIN_DEPLOY_DLLS PREPEND "$ENV{MSYSTEM_PREFIX}/bin/")
        add_custom_command(TARGET deploy
                           POST_BUILD
                           COMMAND ${CMAKE_COMMAND} -E copy ${WIN_DEPLOY_DLLS} "$<TARGET_FILE_DIR:monero-wallet-gui>"
                           COMMENT "Copying DLLs to target folder"
        )
    endif()
endif()
