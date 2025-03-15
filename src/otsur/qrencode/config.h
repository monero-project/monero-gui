#ifndef __CONFIG_H__
#define __CONFIG_H__

/* Standard includes */
#define HAVE_STDLIB_H
#define HAVE_STRING_H
#define HAVE_STRINGS_H
#define HAVE_STDINT_H
#define HAVE_ERRNO_H

/* Version information */
#define MAJOR_VERSION 4
#define MINOR_VERSION 1
#define MICRO_VERSION 1
#define VERSION "4.1.1"

/* Function availability */
#define HAVE_STRDUP 1

/* Disable features we don't need */
#undef HAVE_LIBPTHREAD
#undef HAVE_PTHREAD_MUTEX_RECURSIVE
#undef HAVE_LIBZ
#undef USE_FAST_COPY
#undef WITH_TESTS

/* Disable Micro QR Code support */
#undef HAVE_MQRSPEC_H

/* Define static functions for release builds */
#define STATIC_IN_RELEASE static

/* Other configurations */
#define QRSPEC_VERSION_MAX 40
#define QRSPEC_WIDTH_MAX 177

/* System-dependent definitions */
#if defined(_WIN32) || defined(_WIN64)
#define HAVE_WINDOWS_H
#define HAVE_STRINGIZE
#endif

#endif /* __CONFIG_H__ */
