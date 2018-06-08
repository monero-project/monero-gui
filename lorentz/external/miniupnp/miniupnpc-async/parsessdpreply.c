/* $Id: parsessdpreply.c,v 1.2 2009/11/14 10:37:55 nanard Exp $ */
/* Project : miniupnp
 * website : http://miniupnp.free.fr/ or http://miniupnp.tuxfamily.org/
 * Author : Thomas Bernard
 * copyright (c) 2005-2009 Thomas Bernard
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE. */
#include <strings.h>
#include "parsessdpreply.h"

/* parseMSEARCHReply()
 * the last 4 arguments are filled during the parsing :
 *    - location/locationsize : "location:" field of the SSDP reply packet
 *    - st/stsize : "st:" field of the SSDP reply packet.
 * The strings are NOT null terminated */
void
parseMSEARCHReply(const char * reply, int size,
                  const char * * location, int * locationsize,
			      const char * * st, int * stsize)
{
	int a, b, i;
	i = 0;
	a = i;	/* start of the line */
	b = 0;
	while(i<size)
	{
		switch(reply[i])
		{
		case ':':
				if(b==0)
				{
					b = i; /* end of the "header" */
					/*for(j=a; j<b; j++)
					{
						putchar(reply[j]);
					}
					*/
				}
				break;
		case '\x0a':
		case '\x0d':
				if(b!=0)
				{
					/*for(j=b+1; j<i; j++)
					{
						putchar(reply[j]);
					}
					putchar('\n');*/
					do { b++; } while(reply[b]==' ');
					if(0==strncasecmp(reply+a, "location", 8))
					{
						*location = reply+b;
						*locationsize = i-b;
					}
					else if(0==strncasecmp(reply+a, "st", 2))
					{
						*st = reply+b;
						*stsize = i-b;
					}
					b = 0;
				}
				a = i+1;
				break;
		default:
				break;
		}
		i++;
	}
}

