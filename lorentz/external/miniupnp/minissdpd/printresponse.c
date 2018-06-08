/* $Id: $ */
/* vim: tabstop=4 shiftwidth=4 noexpandtab
 * Project : miniupnp
 * website : http://miniupnp.free.fr/ or http://miniupnp.tuxfamily.org/
 * Author : Thomas BERNARD
 * copyright (c) 2005-2016 Thomas Bernard
 * This software is subjet to the conditions detailed in the
 * provided LICENCE file. */

#include <stdio.h>
#include "codelength.h"

#define NOTIF_NEW    1
#define NOTIF_UPDATE 2
#define NOTIF_REMOVE 3

void printresponse(const unsigned char * resp, int n)
{
	int i, l;
	int notif_type;
	unsigned int nresp;
	const unsigned char * p;

	if(n == 0)
		return;
	/* first, hexdump the response : */
	for(i = 0; i < n; i += 16) {
		printf("%06x | ", i);
		for(l = i; l < n && l < (i + 16); l++)
			printf("%02x ", resp[l]);
		while(l < (i + 16)) {
			printf("   ");
			l++;
		}
		printf("| ");
		for(l = i; l < n && l < (i + 16); l++)
			putchar((resp[l] >= ' ' && resp[l] < 128) ? resp[l] : '.');
		putchar('\n');
	}
	for(p = resp; p < resp + n; ) {
		/* now parse and display all devices of response */
		nresp = p[0]; /* 1st byte : number of devices in response */
		if(nresp == 0xff) {
			/* notification */
			notif_type = p[1];
			nresp = p[2];
			printf("Notification : ");
			switch(notif_type) {
			case NOTIF_NEW:	printf("new\n"); break;
			case NOTIF_UPDATE:	printf("update\n"); break;
			case NOTIF_REMOVE:	printf("remove\n"); break;
			default:	printf("**UNKNOWN**\n");
			}
			p += 3;
		} else {
			p++;
		}
		for(i = 0; i < (int)nresp; i++) {
			if(p >= resp + n)
				goto error;
			/*l = *(p++);*/
			DECODELENGTH(l, p);
			if(p + l > resp + n)
				goto error;
			printf("%d - %.*s\n", i, l, p); /* URL */
			p += l;
			if(p >= resp + n)
				goto error;
			/*l = *(p++);*/
			DECODELENGTH(l, p);
			if(p + l > resp + n)
				goto error;
			printf("    %.*s\n", l, p);	/* ST */
			p += l;
			if(p >= resp + n)
				goto error;
			/*l = *(p++);*/
			DECODELENGTH(l, p);
			if(p + l > resp + n)
				goto error;
			printf("    %.*s\n", l, p); /* USN */
			p += l;
		}
	}
	return;
error:
	printf("*** WARNING : TRUNCATED RESPONSE ***\n");
}


