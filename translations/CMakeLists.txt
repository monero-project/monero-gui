find_package(Qt6 ${QT_MIN_VERSION} REQUIRED COMPONENTS Core LinguistTools)

set(LRELEASE_EXECUTABLE $<TARGET_FILE:Qt6::lrelease>)

file(GLOB TS_FILES *.ts)

set(QM_FILES)
set(QRC_CONTENTS "<RCC><qresource prefix=\"/\">")
foreach(TS_FILE ${TS_FILES})
  get_filename_component(QM_FILE ${TS_FILE} NAME_WE)
  set(QM_FILE ${CMAKE_CURRENT_BINARY_DIR}/${QM_FILE}.qm)
  list(APPEND QM_FILES ${QM_FILE})

  add_custom_command(
    OUTPUT ${QM_FILE}
    COMMAND ${LRELEASE_EXECUTABLE} -compress -nounfinished -removeidentical ${TS_FILE} -qm ${QM_FILE}
    DEPENDS ${TS_FILE}
  )

  get_filename_component(QM_FILE_NAME ${QM_FILE} NAME)
  string(APPEND QRC_CONTENTS "<file>${QM_FILE_NAME}</file>")
endforeach()
string(APPEND QRC_CONTENTS "</qresource></RCC>")

set(TRANSLATIONS_QRC ${CMAKE_CURRENT_BINARY_DIR}/translations.qrc)
file(WRITE "${TRANSLATIONS_QRC}" "${QRC_CONTENTS}")
set_source_files_properties(${TRANSLATIONS_QRC} PROPERTIES SKIP_AUTORCC ON)

set(TRANSLATIONS_CPP ${CMAKE_CURRENT_BINARY_DIR}/qrc_translations.cpp)
add_custom_command(
  OUTPUT ${TRANSLATIONS_CPP}
  COMMAND $<TARGET_FILE:Qt6::rcc>
  ARGS --compress-algo zlib --name translations --output ${TRANSLATIONS_CPP} ${TRANSLATIONS_QRC}
  MAIN_DEPENDENCY ${TRANSLATIONS_QRC}
  DEPENDS ${QM_FILES}
  VERBATIM
)
set_source_files_properties(${TRANSLATIONS_CPP} PROPERTIES SKIP_AUTOMOC ON)
set_source_files_properties(${TRANSLATIONS_CPP} PROPERTIES SKIP_AUTOUIC ON)

add_library(translations ${TRANSLATIONS_CPP})
target_link_libraries(translations PUBLIC Qt6::Core)
