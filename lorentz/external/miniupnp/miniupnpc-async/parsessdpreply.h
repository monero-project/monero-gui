/* $Id: parsessdpreply.h,v 1.1 2009/11/14 10:37:55 nanard Exp $ */
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
#ifndef __PARSESSDPREPLY_H__
#define __PARSESSDPREPLY_H__

/* parseMSEARCHReply()
 * the last 4 arguments are filled during the parsing :
 *    - location/locationsize : "location:" field of the SSDP reply packet
 *    - st/stsize : "st:" field of the SSDP reply packet.
 * The strings are NOT null terminated */
void
parseMSEARCHReply(const char * reply, int size,
                  const char * * location, int * locationsize,
			      const char * * st, int * stsize);

#endif

