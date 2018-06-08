/* $Id: listifaces.c,v 1.7 2015/02/08 08:51:54 nanard Exp $ */
/* (c) 2006-2015 Thomas BERNARD
 * http://miniupnp.free.fr/ http://miniupnp.tuxfamily.org/
 */
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include "upnputils.h"

/* hexdump */
void printhex(const unsigned char * p, int n)
{
	int i;
	while(n>0)
	{
		for(i=0; i<16; i++)
			printf("%02x ", p[i]);
		printf("| ");
		for(i=0; i<16; i++)
		{
			putchar((p[i]>=32 && p[i]<127)?p[i]:'.');
		}
		printf("\n");
		p+=16;
		n -= 16;
	}
}

/* List network interfaces */
void listifaces(void)
{
	struct ifconf ifc;
	char * buf = NULL;
	int buflen;
	int s, i;
	int j;
	char saddr[256/*INET_ADDRSTRLEN*/];
#ifdef __linux__
	buflen = sizeof(struct ifreq)*10;
#else
	buflen = 0;
#endif
	/*s = socket(PF_INET, SOCK_DGRAM, 0);*/
	s = socket(AF_INET, SOCK_DGRAM, 0);
	do {
		char * tmp;
#ifdef __linux__
		buflen += buflen;
#endif
		if(buflen > 0) {
			tmp = realloc(buf, buflen);
			if(!tmp) {
				fprintf(stderr, "error allocating %d bytes.\n", buflen);
				close(f);
				free(buf);
				return;
			}
			buf = tmp;
		}
		ifc.ifc_len = buflen;
		ifc.ifc_buf = (caddr_t)buf;
		if(ioctl(s, SIOCGIFCONF, &ifc) < 0)
		{
			perror("ioctl");
			close(s);
			free(buf);
			return;
		}
		printf("buffer length=%d - buffer used=%d - sizeof(struct ifreq)=%d\n",
		       buflen, ifc.ifc_len, (int)sizeof(struct ifreq));
		printf("IFNAMSIZ=%d  ", IFNAMSIZ);
		printf("sizeof(struct sockaddr)=%d   sizeof(struct sockaddr_in)=%d\n",
		       (int)sizeof(struct sockaddr), (int)sizeof(struct sockaddr_in) );
#ifndef __linux__
		if(buflen == 0)
			buflen = ifc.ifc_len;
		else
			break;
	} while(1);
#else
	} while(buflen <= ifc.ifc_len);
#endif
	printhex((const unsigned char *)ifc.ifc_buf, ifc.ifc_len);
	printf("off index fam name             address\n");
	for(i = 0, j = 0; i<ifc.ifc_len; j++)
	{
		/*const struct ifreq * ifrp = &(ifc.ifc_req[j]);*/
		const struct ifreq * ifrp = (const struct ifreq *)(buf + i);
		/*inet_ntop(AF_INET, &(((struct sockaddr_in *)&(ifrp->ifr_addr))->sin_addr), saddr, sizeof(saddr));*/
		saddr[0] = '\0';
		/* inet_ntop(ifrp->ifr_addr.sa_family, &(ifrp->ifr_addr.sa_data[2]), saddr, sizeof(saddr)); */
		sockaddr_to_string(&ifrp->ifr_addr, saddr, sizeof(saddr));
		printf("0x%03x %2d   %2d %-16s %s\n", i, j, ifrp->ifr_addr.sa_family, ifrp->ifr_name, saddr);
		/*ifrp->ifr_addr.sa_len is only available on BSD */
#ifdef __linux__
		i += sizeof(struct ifreq);
#else
		if(ifrp->ifr_addr.sa_len == 0)
			break;
		i += IFNAMSIZ + ifrp->ifr_addr.sa_len;
#endif
	}
	free(buf);
	close(s);
}

int main(int argc, char * * argv)
{
	(void)argc;
	(void)argv;
	listifaces();
	return 0;
}

