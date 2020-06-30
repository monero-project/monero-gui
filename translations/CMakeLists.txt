file(GLOB TS_FILES *.ts)

set(QRC "<RCC><qresource prefix=\"/\">")
foreach(TS_FILE ${TS_FILES})
  get_filename_component(QM_FILE ${TS_FILE} NAME_WE)
  set(QM_FILE ${CMAKE_CURRENT_BINARY_DIR}/${QM_FILE}.qm)

  execute_process(COMMAND lrelease -compress -nounfinished -removeidentical ${TS_FILE} -qm ${QM_FILE}
    RESULT_VARIABLE RET
    OUTPUT_VARIABLE OUT
    ERROR_VARIABLE ERR
  )
  if(RET)
    message(FATAL_ERROR "${TS_FILE}: lrelease returned non-zero exit code: ${RET} ${OUT} ${ERR}")
  endif()

  get_filename_component(QM_FILE_NAME ${QM_FILE} NAME)
  string(APPEND QRC "<file>${QM_FILE_NAME}</file>")
endforeach()
string(APPEND QRC "</qresource></RCC>")

set(TRANSLATIONS_QRC ${CMAKE_CURRENT_BINARY_DIR}/translations.qrc)
file(WRITE ${TRANSLATIONS_QRC} ${QRC})
