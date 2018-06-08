/* $Id: testcodelength.c,v 1.3 2012/05/02 10:30:26 nanard Exp $ */
/* Project : miniupnp
 * Author : Thomas BERNARD
 * copyright (c) 2005-2018 Thomas Bernard
 * This software is subjet to the conditions detailed in the
 * provided LICENCE file. */
#include <stdio.h>
#include "codelength.h"

int main(int argc, char * * argv)
{
	unsigned char buf[256];
	unsigned char * p;
	long i, j;
	(void)argc; (void)argv;

	for(i = 1; i < 1000000000; i *= 2) {
		/* encode i, decode to j */
		printf("%ld ", i);
		p = buf;
		CODELENGTH(i, p);
		p = buf;
		DECODELENGTH(j, p);
		if(i != j) {
			fprintf(stderr, "Error ! encoded %ld, decoded %ld.\n", i, j);
			return 1;
		}
	}
	printf("Test successful\n");
	return 0;
}
