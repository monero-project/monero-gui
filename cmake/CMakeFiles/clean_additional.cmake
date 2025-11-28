# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "src/CMakeFiles/monero-wallet-gui_autogen.dir/AutogenUsed.txt"
  "src/CMakeFiles/monero-wallet-gui_autogen.dir/ParseCache.txt"
  "src/QR-Code-scanner/CMakeFiles/qrdecoder_autogen.dir/AutogenUsed.txt"
  "src/QR-Code-scanner/CMakeFiles/qrdecoder_autogen.dir/ParseCache.txt"
  "src/QR-Code-scanner/qrdecoder_autogen"
  "src/monero-wallet-gui_autogen"
  "src/openpgp/CMakeFiles/openpgp_autogen.dir/AutogenUsed.txt"
  "src/openpgp/CMakeFiles/openpgp_autogen.dir/ParseCache.txt"
  "src/openpgp/openpgp_autogen"
  "src/zxcvbn-c/CMakeFiles/zxcvbn_autogen.dir/AutogenUsed.txt"
  "src/zxcvbn-c/CMakeFiles/zxcvbn_autogen.dir/ParseCache.txt"
  "src/zxcvbn-c/zxcvbn_autogen"
  "translations/CMakeFiles/translations_autogen.dir/AutogenUsed.txt"
  "translations/CMakeFiles/translations_autogen.dir/ParseCache.txt"
  "translations/translations_autogen"
  )
endif()
