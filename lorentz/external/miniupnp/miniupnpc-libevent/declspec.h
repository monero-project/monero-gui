#ifndef DECLSPEC_H_DEFINED
#define DECLSPEC_H_DEFINED

#if defined(_WIN32) && !defined(STATICLIB)
	#ifdef MINIUPNP_EXPORTS
		#define LIBSPEC __declspec(dllexport)
	#else
		#define LIBSPEC __declspec(dllimport)
	#endif
#else
	#define LIBSPEC
#endif

#endif /* DECLSPEC_H_DEFINED */

