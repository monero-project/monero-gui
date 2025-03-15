#include "memzero.h"

#ifndef __STDC_WANT_LIB_EXT1__
#define __STDC_WANT_LIB_EXT1__ 1  // C11's bounds-checking interface.
#endif
#include <string.h>

#ifdef _WIN32
#include <windows.h>
#endif

#ifdef __unix__
#include <strings.h>
#include <sys/param.h>
#endif

// C11's bounds-checking interface.
#if defined(__STDC_LIB_EXT1__)
#define HAVE_MEMSET_S 1
#endif

// GNU C Library version 2.25 or later.
#if defined(__GLIBC__) && \
    (__GLIBC__ > 2 || (__GLIBC__ == 2 && __GLIBC_MINOR__ >= 25))
#define HAVE_EXPLICIT_BZERO 1
#endif

// Newlib
#if defined(__NEWLIB__)
#define HAVE_EXPLICIT_BZERO 1
#endif

// FreeBSD version 11.0 or later.
#if defined(__FreeBSD__) && __FreeBSD_version >= 1100037
#define HAVE_EXPLICIT_BZERO 1
#endif

// OpenBSD version 5.5 or later.
#if defined(__OpenBSD__) && OpenBSD >= 201405
#define HAVE_EXPLICIT_BZERO 1
#endif

// NetBSD version 7.2 or later.
#if defined(__NetBSD__) && __NetBSD_Version__ >= 702000000
#define HAVE_EXPLICIT_MEMSET 1
#endif

// Adapted from
// https://github.com/jedisct1/libsodium/blob/1647f0d53ae0e370378a9195477e3df0a792408f/src/libsodium/sodium/utils.c#L102-L130

void memzero(void *const pnt, const size_t len) {
#ifdef _WIN32
  SecureZeroMemory(pnt, len);
#elif defined(HAVE_MEMSET_S)
  memset_s(pnt, (rsize_t)len, 0, (rsize_t)len);
#elif defined(HAVE_EXPLICIT_BZERO)
  bzero(pnt, len);
#elif defined(HAVE_EXPLICIT_MEMSET)
  explicit_memset(pnt, 0, len);
#else
  volatile unsigned char *volatile pnt_ = (volatile unsigned char *volatile)pnt;
  size_t i = (size_t)0U;

  while (i < len) {
    pnt_[i++] = 0U;
  }

  /* Memory barrier that scares the compiler away from optimizing out
   * the above loop.
   *
   * Quoting Adam Langley <agl@google.com> in commit
   * ad1907fe73334d6c696c8539646c21b11178f20f of BoringSSL (ISC License):
   *
   *    As best as we can tell, this is sufficient to break any optimisations
   *    that might try to eliminate "superfluous" memsets.  This method is used
   *    in memzero_explicit() the Linux kernel, too.  Its advantage is that it
   *    is pretty efficient because the compiler can still implement the
   *    memset() efficiently, just not remove it entirely.  See "Dead Store
   *    Elimination (Still) Considered Harmful" by Yang et al. (USENIX Security
   *    2017) for more background.
   */
  __asm__ __volatile__("" : : "r"(pnt_) : "memory");
#endif
}
