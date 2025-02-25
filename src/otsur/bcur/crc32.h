//
//  crc32.h
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

#ifndef BC_UR_CRC32_H
#define BC_UR_CRC32_H

#include <stdint.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

// Returns the CRC-32 checksum of the input buffer.
uint32_t ur_crc32(const uint8_t* bytes, size_t len);

// Returns the CRC-32 checksum of the input buffer in network byte order (big endian).
uint32_t ur_crc32n(const uint8_t* bytes, size_t len);

#ifdef __cplusplus
}
#endif

#endif // BC_UR_CRC32_H
