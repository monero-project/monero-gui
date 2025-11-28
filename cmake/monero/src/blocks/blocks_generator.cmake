file(READ "${INPUT_DAT_FILE}" DATA HEX)
string(REGEX REPLACE "[0-9a-fA-F][0-9a-fA-F]" "0x\\0," DATA "${DATA}")
file(WRITE "${OUTPUT_C_SOURCE}" "
#include <stddef.h>
const unsigned char ${BLOB_NAME}[]={
  ${DATA}
};
const size_t ${BLOB_NAME}_len = sizeof(${BLOB_NAME});
"
)
