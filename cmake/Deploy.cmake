if(APPLE OR (WIN32 AND NOT STATIC))
    add_custom_target(deploy)
    get_target_property(_qmake_executable Qt5::qmake IMPORTED_LOCATION)
    get_filename_component(_qt_bin_dir "${_qmake_executable}" DIRECTORY)

    if(APPLE AND NOT IOS)
        find_program(MACDEPLOYQT_EXECUTABLE macdeployqt HINTS "${_qt_bin_dir}")
        add_custom_command(TARGET deploy
                           POST_BUILD
                           COMMAND "${MACDEPLOYQT_EXECUTABLE}" "$<TARGET_FILE_DIR:monero-wallet-gui>/../.." -always-overwrite -qmldir="${CMAKE_SOURCE_DIR}"
                           COMMENT "Running macdeployqt..."
        )

        # workaround for a Qt bug that requires manually adding libqsvg.dylib to bundle
        find_file(_qt_svg_dylib "libqsvg.dylib" PATHS "${CMAKE_PREFIX_PATH}/plugins/imageformats" NO_DEFAULT_PATH)
        if(_qt_svg_dylib)
            add_custom_command(TARGET deploy
                               POST_BUILD
                               COMMAND ${CMAKE_COMMAND} -E copy ${_qt_svg_dylib} $<TARGET_FILE_DIR:monero-wallet-gui>/../PlugIns/imageformats/
                               COMMAND ${CMAKE_INSTALL_NAME_TOOL} -change "${CMAKE_PREFIX_PATH}/lib/QtGui.framework/Versions/5/QtGui" "@executable_path/../Frameworks/QtGui.framework/Versions/5/QtGui" $<TARGET_FILE_DIR:monero-wallet-gui>/../PlugIns/imageformats/libqsvg.dylib
                               COMMAND ${CMAKE_INSTALL_NAME_TOOL} -change "${CMAKE_PREFIX_PATH}/lib/QtWidgets.framework/Versions/5/QtWidgets" "@executable_path/../Frameworks/QtWidgets.framework/Versions/5/QtWidgets" $<TARGET_FILE_DIR:monero-wallet-gui>/../PlugIns/imageformats/libqsvg.dylib
                               COMMAND ${CMAKE_INSTALL_NAME_TOOL} -change "${CMAKE_PREFIX_PATH}/lib/QtSvg.framework/Versions/5/QtSvg" "@executable_path/../Frameworks/QtSvg.framework/Versions/5/QtSvg" $<TARGET_FILE_DIR:monero-wallet-gui>/../PlugIns/imageformats/libqsvg.dylib
                               COMMAND ${CMAKE_INSTALL_NAME_TOOL} -change "${CMAKE_PREFIX_PATH}/lib/QtCore.framework/Versions/5/QtCore" "@executable_path/../Frameworks/QtCore.framework/Versions/5/QtCore" $<TARGET_FILE_DIR:monero-wallet-gui>/../PlugIns/imageformats/libqsvg.dylib
                               COMMENT "Copying libqsvg.dylib, running install_name_tool"

            )
        endif()

        # libbost_filesyste-mt.dylib has a dependency on libboost_atomic-mt.dylib, maydeployqt does not copy it by itself
        find_package(Boost COMPONENTS atomic)
        get_target_property(BOOST_ATOMIC_LIB_PATH Boost::atomic LOCATION)
        if(EXISTS ${BOOST_ATOMIC_LIB_PATH})
            add_custom_command(TARGET deploy
                               POST_BUILD
                               COMMAND ${CMAKE_COMMAND} -E copy "${BOOST_ATOMIC_LIB_PATH}" "$<TARGET_FILE_DIR:monero-wallet-gui>/../Frameworks/"
                               COMMENT "Copying libboost_atomic-mt.dylib"
            )
        endif()

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
        find_program(WINDEPLOYQT_EXECUTABLE windeployqt HINTS "${_qt_bin_dir}")
        add_custom_command(TARGET monero-wallet-gui POST_BUILD
                           COMMAND "${CMAKE_COMMAND}" -E env PATH="${_qt_bin_dir}" "${WINDEPLOYQT_EXECUTABLE}" "$<TARGET_FILE:monero-wallet-gui>" -no-translations -qmldir="${CMAKE_SOURCE_DIR}"
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
            libtiff-6.dll
            libstdc++-6.dll
            libpng16-16.dll
            libpcre16-0.dll
            libpcre-1.dll
            libmng-2.dll
            liblzma-5.dll
            liblcms2-2.dll
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
            libicudt77.dll
            libicuin77.dll
            libicuio77.dll
            libicutu77.dll
            libicuuc77.dll
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
