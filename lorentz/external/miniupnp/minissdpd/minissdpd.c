/* $Id: minissdpd.c,v 1.53 2016/03/01 18:06:46 nanard Exp $ */
/* vim: tabstop=4 shiftwidth=4 noexpandtab
 * MiniUPnP project
 * (c) 2007-2018 Thomas Bernard
 * website : http://miniupnp.free.fr/ or https://miniupnp.tuxfamily.org/
 * This software is subject to the conditions detailed
 * in the LICENCE file provided within the distribution */

#include "config.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <errno.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <syslog.h>
#include <ctype.h>
#include <time.h>
#include <sys/queue.h>
/* for chmod : */
#include <sys/stat.h>
/* unix sockets */
#include <sys/un.h>
/* for getpwnam() and getgrnam() */
#if 0
#include <pwd.h>
#include <grp.h>
#endif

/* LOG_PERROR does not exist on Solaris */
#ifndef LOG_PERROR
#define LOG_PERROR 0
#endif /* LOG_PERROR */

#include "getifaddr.h"
#include "upnputils.h"
#include "openssdpsocket.h"
#include "daemonize.h"
#include "codelength.h"
#include "ifacewatch.h"
#include "minissdpdtypes.h"
#include "asyncsendto.h"

#define SET_MAX(max, x)	if((x) > (max)) (max) = (x)
#ifndef MIN
#define MIN(x,y) (((x)<(y))?(x):(y))
#endif

/* current request management structure */
struct reqelem {
	int socket;
	int is_notify;	/* has subscribed to notifications */
	LIST_ENTRY(reqelem) entries;
	unsigned char * output_buffer;
	int output_buffer_offset;
	int output_buffer_len;
};

/* device data structures */
struct header {
	const char * p; /* string pointer */
	int l;          /* string length */
};

#define HEADER_NT	0
#define HEADER_USN	1
#define HEADER_LOCATION	2

struct device {
	struct device * next;
	time_t t;                 /* validity time */
	struct header headers[3]; /* NT, USN and LOCATION headers */
	char data[];
};

/* Services stored for answering to M-SEARCH */
struct service {
	char * st;	/* Service type */
	char * usn;	/* Unique identifier */
	char * server;	/* Server string */
	char * location;	/* URL */
	LIST_ENTRY(service) entries;
};
LIST_HEAD(servicehead, service) servicelisthead;

#define NTS_SSDP_ALIVE	1
#define NTS_SSDP_BYEBYE	2
#define NTS_SSDP_UPDATE	3

/* request types */
enum request_type {
	MINISSDPD_GET_VERSION = 0,
	MINISSDPD_SEARCH_TYPE = 1,
	MINISSDPD_SEARCH_USN = 2,
	MINISSDPD_SEARCH_ALL = 3,
	MINISSDPD_SUBMIT = 4,
	MINISSDPD_NOTIF = 5
};

/* discovered device list kept in memory */
struct device * devlist = 0;

/* bootid and configid */
unsigned int upnp_bootid = 1;
unsigned int upnp_configid = 1337;

/* LAN interfaces/addresses */
struct lan_addr_list lan_addrs;

/* connected clients */
LIST_HEAD(reqstructhead, reqelem) reqlisthead;

/* functions prototypes */

#define NOTIF_NEW    1
#define NOTIF_UPDATE 2
#define NOTIF_REMOVE 3
static void
sendNotifications(int notif_type, const struct device * dev, const struct service * serv);

/* functions */

/* parselanaddr()
 * parse address with mask
 * ex: 192.168.1.1/24 or 192.168.1.1/255.255.255.0
 *
 * Can also use the interface name (ie eth0)
 *
 * return value :
 *    0 : ok
 *   -1 : error */
static int
parselanaddr(struct lan_addr_s * lan_addr, const char * str)
{
	const char * p;
	int n;
	char tmp[16];

	memset(lan_addr, 0, sizeof(struct lan_addr_s));
	p = str;
	while(*p && *p != '/' && !isspace(*p))
		p++;
	n = p - str;
	if(!isdigit(str[0]) && n < (int)sizeof(lan_addr->ifname)) {
		/* not starting with a digit : suppose it is an interface name */
		memcpy(lan_addr->ifname, str, n);
		lan_addr->ifname[n] = '\0';
		if(getifaddr(lan_addr->ifname, lan_addr->str, sizeof(lan_addr->str),
		             &lan_addr->addr, &lan_addr->mask) < 0)
			goto parselan_error;
		/*printf("%s => %s\n", lan_addr->ifname, lan_addr->str);*/
	} else {
		if(n>15)
			goto parselan_error;
		memcpy(lan_addr->str, str, n);
		lan_addr->str[n] = '\0';
		if(!inet_aton(lan_addr->str, &lan_addr->addr))
			goto parselan_error;
	}
	if(*p == '/') {
		const char * q = ++p;
		while(*p && isdigit(*p))
			p++;
		if(*p=='.') {
			/* parse mask in /255.255.255.0 format */
			while(*p && (*p=='.' || isdigit(*p)))
				p++;
			n = p - q;
			if(n>15)
				goto parselan_error;
			memcpy(tmp, q, n);
			tmp[n] = '\0';
			if(!inet_aton(tmp, &lan_addr->mask))
				goto parselan_error;
		} else {
			/* it is a /24 format */
			int nbits = atoi(q);
			if(nbits > 32 || nbits < 0)
				goto parselan_error;
			lan_addr->mask.s_addr = htonl(nbits ? (0xffffffffu << (32 - nbits)) : 0);
		}
	} else if(lan_addr->mask.s_addr == 0) {
		/* by default, networks are /24 */
		lan_addr->mask.s_addr = htonl(0xffffff00u);
	}
#ifdef ENABLE_IPV6
	if(lan_addr->ifname[0] != '\0') {
		lan_addr->index = if_nametoindex(lan_addr->ifname);
		if(lan_addr->index == 0)
			fprintf(stderr, "Cannot get index for network interface %s",
			        lan_addr->ifname);
	} else {
		fprintf(stderr,
		        "Error: please specify LAN network interface by name instead of IPv4 address : %s\n",
		        str);
		return -1;
	}
#endif /* ENABLE_IPV6 */
	return 0;
parselan_error:
	fprintf(stderr, "Error parsing address/mask (or interface name) : %s\n",
	        str);
	return -1;
}

static int
write_buffer(struct reqelem * req)
{
	if(req->output_buffer && req->output_buffer_len > 0) {
		int n = write(req->socket,
		              req->output_buffer + req->output_buffer_offset,
		              req->output_buffer_len);
		if(n >= 0) {
			req->output_buffer_offset += n;
			req->output_buffer_len -= n;
		} else if(errno == EINTR || errno == EWOULDBLOCK || errno == EAGAIN) {
			return 0;
		}
		return n;
	} else {
		return 0;
	}
}

static int
add_to_buffer(struct reqelem * req, const unsigned char * data, int len)
{
	unsigned char * tmp;
	if(req->output_buffer_offset > 0) {
		memmove(req->output_buffer, req->output_buffer + req->output_buffer_offset, req->output_buffer_len);
		req->output_buffer_offset = 0;
	}
	tmp = realloc(req->output_buffer, req->output_buffer_len + len);
	if(tmp == NULL) {
		syslog(LOG_ERR, "%s: failed to allocate %d bytes",
		       __func__, req->output_buffer_len + len);
		return -1;
	}
	req->output_buffer = tmp;
	memcpy(req->output_buffer + req->output_buffer_len, data, len);
	req->output_buffer_len += len;
	return len;
}

static int
write_or_buffer(struct reqelem * req, const unsigned char * data, int len)
{
	if(write_buffer(req) < 0)
		return -1;
	if(req->output_buffer && req->output_buffer_len > 0) {
		return add_to_buffer(req, data, len);
	} else {
		int n = write(req->socket, data, len);
		if(n == len)
			return len;
		if(n < 0) {
			if(errno == EINTR || errno == EWOULDBLOCK || errno == EAGAIN) {
				n = add_to_buffer(req, data, len);
				if(n < 0) return n;
			} else {
				return n;
			}
		} else {
			n = add_to_buffer(req, data + n, len - n);
			if(n < 0) return n;
		}
	}
	return len;
}

static const char *
nts_to_str(int nts)
{
	switch(nts)
	{
	case NTS_SSDP_ALIVE:
		return "ssdp:alive";
	case NTS_SSDP_BYEBYE:
		return "ssdp:byebye";
	case NTS_SSDP_UPDATE:
		return "ssdp:update";
	}
	return "unknown";
}

/* updateDevice() :
 * adds or updates the device to the list.
 * return value :
 *   0 : the device was updated (or nothing done)
 *   1 : the device was new    */
static int
updateDevice(const struct header * headers, time_t t)
{
	struct device ** pp = &devlist;
	struct device * p = *pp;	/* = devlist; */
	while(p)
	{
		if(  p->headers[HEADER_NT].l == headers[HEADER_NT].l
		  && (0==memcmp(p->headers[HEADER_NT].p, headers[HEADER_NT].p, headers[HEADER_NT].l))
		  && p->headers[HEADER_USN].l == headers[HEADER_USN].l
		  && (0==memcmp(p->headers[HEADER_USN].p, headers[HEADER_USN].p, headers[HEADER_USN].l)) )
		{
			/*printf("found! %d\n", (int)(t - p->t));*/
			syslog(LOG_DEBUG, "device updated : %.*s", headers[HEADER_USN].l, headers[HEADER_USN].p);
			p->t = t;
			/* update Location ! */
			if(headers[HEADER_LOCATION].l > p->headers[HEADER_LOCATION].l)
			{
				struct device * tmp;
				tmp = realloc(p, sizeof(struct device)
				    + headers[0].l+headers[1].l+headers[2].l);
				if(!tmp)	/* allocation error */
				{
					syslog(LOG_ERR, "updateDevice() : memory allocation error");
					free(p);
					return 0;
				}
				p = tmp;
				*pp = p;
			}
			memcpy(p->data + p->headers[0].l + p->headers[1].l,
			       headers[2].p, headers[2].l);
			/* TODO : check p->headers[HEADER_LOCATION].l */
			return 0;
		}
		pp = &p->next;
		p = *pp;	/* p = p->next; */
	}
	syslog(LOG_INFO, "new device discovered : %.*s",
	       headers[HEADER_USN].l, headers[HEADER_USN].p);
	/* add */
	{
		char * pc;
		int i;
		p = malloc(  sizeof(struct device)
		           + headers[0].l+headers[1].l+headers[2].l );
		if(!p) {
			syslog(LOG_ERR, "updateDevice(): cannot allocate memory");
			return -1;
		}
		p->next = devlist;
		p->t = t;
		pc = p->data;
		for(i = 0; i < 3; i++)
		{
			p->headers[i].p = pc;
			p->headers[i].l = headers[i].l;
			memcpy(pc, headers[i].p, headers[i].l);
			pc += headers[i].l;
		}
		devlist = p;
		sendNotifications(NOTIF_NEW, p, NULL);
	}
	return 1;
}

/* removeDevice() :
 * remove a device from the list
 * return value :
 *    0 : no device removed
 *   -1 : device removed */
static int
removeDevice(const struct header * headers)
{
	struct device ** pp = &devlist;
	struct device * p = *pp;	/* = devlist */
	while(p)
	{
		if(  p->headers[HEADER_NT].l == headers[HEADER_NT].l
		  && (0==memcmp(p->headers[HEADER_NT].p, headers[HEADER_NT].p, headers[HEADER_NT].l))
		  && p->headers[HEADER_USN].l == headers[HEADER_USN].l
		  && (0==memcmp(p->headers[HEADER_USN].p, headers[HEADER_USN].p, headers[HEADER_USN].l)) )
		{
			syslog(LOG_INFO, "remove device : %.*s", headers[HEADER_USN].l, headers[HEADER_USN].p);
			sendNotifications(NOTIF_REMOVE, p, NULL);
			*pp = p->next;
			free(p);
			return -1;
		}
		pp = &p->next;
		p = *pp;	/* p = p->next; */
	}
	syslog(LOG_WARNING, "device not found for removing : %.*s", headers[HEADER_USN].l, headers[HEADER_USN].p);
	return 0;
}

/* sent notifications to client having subscribed */
static void
sendNotifications(int notif_type, const struct device * dev, const struct service * serv)
{
	struct reqelem * req;
	unsigned int m;
	unsigned char rbuf[RESPONSE_BUFFER_SIZE];
	unsigned char * rp;

	for(req = reqlisthead.lh_first; req; req = req->entries.le_next) {
		if(!req->is_notify) continue;
		rbuf[0] = '\xff'; /* special code for notifications */
		rbuf[1] = (unsigned char)notif_type;
		rbuf[2] = 0;
		rp = rbuf + 3;
		if(dev) {
			/* response :
			 * 1 - Location
			 * 2 - NT (device/service type)
			 * 3 - usn */
			m = dev->headers[HEADER_LOCATION].l;
			CODELENGTH(m, rp);
			memcpy(rp, dev->headers[HEADER_LOCATION].p, dev->headers[HEADER_LOCATION].l);
			rp += dev->headers[HEADER_LOCATION].l;
			m = dev->headers[HEADER_NT].l;
			CODELENGTH(m, rp);
			memcpy(rp, dev->headers[HEADER_NT].p, dev->headers[HEADER_NT].l);
			rp += dev->headers[HEADER_NT].l;
			m = dev->headers[HEADER_USN].l;
			CODELENGTH(m, rp);
			memcpy(rp, dev->headers[HEADER_USN].p, dev->headers[HEADER_USN].l);
			rp += dev->headers[HEADER_USN].l;
			rbuf[2]++;
		}
		if(serv) {
			/* response :
			 * 1 - Location
			 * 2 - NT (device/service type)
			 * 3 - usn */
			m = strlen(serv->location);
			CODELENGTH(m, rp);
			memcpy(rp, serv->location, m);
			rp += m;
			m = strlen(serv->st);
			CODELENGTH(m, rp);
			memcpy(rp, serv->st, m);
			rp += m;
			m = strlen(serv->usn);
			CODELENGTH(m, rp);
			memcpy(rp, serv->usn, m);
			rp += m;
			rbuf[2]++;
		}
		if(rbuf[2] > 0) {
			if(write_or_buffer(req, rbuf, rp - rbuf) < 0) {
				syslog(LOG_ERR, "(s=%d) write: %m", req->socket);
				/*goto error;*/
			}
		}
	}
}

/* SendSSDPMSEARCHResponse() :
 * build and send response to M-SEARCH SSDP packets. */
static void
SendSSDPMSEARCHResponse(int s, const struct sockaddr * sockname,
                        const char * st, size_t st_len, const char * usn,
                        const char * server, const char * location)
{
	int l, n;
	char buf[1024];
	socklen_t sockname_len;
	/*
	 * follow guideline from document "UPnP Device Architecture 1.0"
	 * uppercase is recommended.
	 * DATE: is recommended
	 * SERVER: OS/ver UPnP/1.0 miniupnpd/1.0
	 * - check what to put in the 'Cache-Control' header
	 *
	 * have a look at the document "UPnP Device Architecture v1.1 */
	l = snprintf(buf, sizeof(buf), "HTTP/1.1 200 OK\r\n"
		"CACHE-CONTROL: max-age=120\r\n"
		/*"DATE: ...\r\n"*/
		"ST: %.*s\r\n"
		"USN: %s\r\n"
		"EXT:\r\n"
		"SERVER: %s\r\n"
		"LOCATION: %s\r\n"
		"OPT: \"http://schemas.upnp.org/upnp/1/0/\"; ns=01\r\n" /* UDA v1.1 */
		"01-NLS: %u\r\n" /* same as BOOTID. UDA v1.1 */
		"BOOTID.UPNP.ORG: %u\r\n" /* UDA v1.1 */
		"CONFIGID.UPNP.ORG: %u\r\n" /* UDA v1.1 */
		"\r\n",
		(int)st_len, st, usn,
		server, location,
		upnp_bootid, upnp_bootid, upnp_configid);
#ifdef ENABLE_IPV6
	sockname_len = (sockname->sa_family == PF_INET6)
	             ? sizeof(struct sockaddr_in6)
	             : sizeof(struct sockaddr_in);
#else	/* ENABLE_IPV6 */
	sockname_len = sizeof(struct sockaddr_in);
#endif	/* ENABLE_IPV6 */
	n = sendto_or_schedule(s, buf, l, 0, sockname, sockname_len);
	if(n < 0) {
		syslog(LOG_ERR, "%s: sendto(udp): %m", __func__);
	}
}

/* Process M-SEARCH requests */
static void
processMSEARCH(int s, const char * st, size_t st_len,
               const struct sockaddr * addr)
{
	struct service * serv;
#ifdef ENABLE_IPV6
	char buf[64];
#endif /* ENABLE_IPV6 */

	if(!st || st_len==0)
		return;
#ifdef ENABLE_IPV6
	sockaddr_to_string(addr, buf, sizeof(buf));
	syslog(LOG_INFO, "SSDP M-SEARCH from %s ST:%.*s",
	       buf, (int)st_len, st);
#else	/* ENABLE_IPV6 */
	syslog(LOG_INFO, "SSDP M-SEARCH from %s:%d ST: %.*s",
	       inet_ntoa(((const struct sockaddr_in *)addr)->sin_addr),
	       ntohs(((const struct sockaddr_in *)addr)->sin_port),
	       (int)st_len, st);
#endif	/* ENABLE_IPV6 */
	if(st_len==8 && (0==memcmp(st, "ssdp:all", 8))) {
		/* send a response for all services */
		for(serv = servicelisthead.lh_first;
		    serv;
		    serv = serv->entries.le_next) {
			SendSSDPMSEARCHResponse(s, addr,
			                        serv->st, strlen(serv->st), serv->usn,
			                        serv->server, serv->location);
		}
	} else if(st_len > 5 && (0==memcmp(st, "uuid:", 5))) {
		/* find a matching UUID value */
		for(serv = servicelisthead.lh_first;
		    serv;
		    serv = serv->entries.le_next) {
			if(0 == strncmp(serv->usn, st, st_len)) {
				SendSSDPMSEARCHResponse(s, addr,
				                        serv->st, strlen(serv->st), serv->usn,
				                        serv->server, serv->location);
			}
		}
	} else {
		size_t l;
		int st_ver = 0;
		char atoi_buffer[8];

		/* remove version at the end of the ST string */
		for (l = st_len; l > 0; l--) {
			if (st[l-1] == ':') {
				memset(atoi_buffer, 0, sizeof(atoi_buffer));
				memcpy(atoi_buffer, st + l, MIN((sizeof(atoi_buffer) - 1), st_len - l));
				st_ver = atoi(atoi_buffer);
				break;
			}
		}
		if (l == 0)
			l = st_len;
		/* answer for each matching service */
		/* From UPnP Device Architecture v1.1 :
		 * 1.3.2 [...] Updated versions of device and service types
		 * are REQUIRED to be full backward compatible with
		 * previous versions. Devices MUST respond to M-SEARCH
		 * requests for any supported version. For example, if a
		 * device implements “urn:schemas-upnporg:service:xyz:2”,
		 * it MUST respond to search requests for both that type
		 * and “urn:schemas-upnp-org:service:xyz:1”. The response
		 * MUST specify the same version as was contained in the
		 * search request. [...] */
		for(serv = servicelisthead.lh_first;
		    serv;
		    serv = serv->entries.le_next) {
			if(0 == strncmp(serv->st, st, l)) {
				syslog(LOG_DEBUG, "Found matching service : %s %s", serv->st, serv->location);
				SendSSDPMSEARCHResponse(s, addr,
				                        st, st_len, serv->usn,
				                        serv->server, serv->location);
			}
		}
	}
}

/**
 * helper function.
 * reject any non ASCII or non printable character.
 */
static int
containsForbiddenChars(const unsigned char * p, int len)
{
	while(len > 0) {
		if(*p < ' ' || *p >= '\x7f')
			return 1;
		p++;
		len--;
	}
	return 0;
}

#define METHOD_MSEARCH 1
#define METHOD_NOTIFY 2

/* ParseSSDPPacket() :
 * parse a received SSDP Packet and call
 * updateDevice() or removeDevice() as needed
 * return value :
 *    -1 : a device was removed
 *     0 : no device removed nor added
 *     1 : a device was added.  */
static int
ParseSSDPPacket(int s, const char * p, ssize_t n,
                const struct sockaddr * addr,
                const char * searched_device)
{
	const char * linestart;
	const char * lineend;
	const char * nameend;
	const char * valuestart;
	struct header headers[3];
	int i, r = 0;
	int methodlen;
	int nts = -1;
	int method = -1;
	unsigned int lifetime = 180;	/* 3 minutes by default */
	const char * st = NULL;
	int st_len = 0;

	/* first check from what subnet is the sender */
	if(get_lan_for_peer(addr) == NULL) {
		char addr_str[64];
		sockaddr_to_string(addr, addr_str, sizeof(addr_str));
		syslog(LOG_WARNING, "peer %s is not from a LAN",
		       addr_str);
		return 0;
	}

	/* do the parsing */
	memset(headers, 0, sizeof(headers));
	for(methodlen = 0;
	    methodlen < n && (isalpha(p[methodlen]) || p[methodlen]=='-');
		methodlen++);
	if(methodlen==8 && 0==memcmp(p, "M-SEARCH", 8))
		method = METHOD_MSEARCH;
	else if(methodlen==6 && 0==memcmp(p, "NOTIFY", 6))
		method = METHOD_NOTIFY;
	else if(methodlen==4 && 0==memcmp(p, "HTTP", 4)) {
		/* answer to a M-SEARCH => process it as a NOTIFY
		 * with NTS: ssdp:alive */
		method = METHOD_NOTIFY;
		nts = NTS_SSDP_ALIVE;
	}
	linestart = p;
	while(linestart < p + n - 2) {
		/* start parsing the line : detect line end */
		lineend = linestart;
		while(lineend < p + n && *lineend != '\n' && *lineend != '\r')
			lineend++;
		/*printf("line: '%.*s'\n", lineend - linestart, linestart);*/
		/* detect name end : ':' character */
		nameend = linestart;
		while(nameend < lineend && *nameend != ':')
			nameend++;
		/* detect value */
		if(nameend < lineend)
			valuestart = nameend + 1;
		else
			valuestart = nameend;
		/* trim spaces */
		while(valuestart < lineend && isspace(*valuestart))
			valuestart++;
		/* suppress leading " if needed */
		if(valuestart < lineend && *valuestart=='\"')
			valuestart++;
		if(nameend > linestart && valuestart < lineend) {
			int l = nameend - linestart;	/* header name length */
			int m = lineend - valuestart;	/* header value length */
			/* suppress tailing spaces */
			while(m>0 && isspace(valuestart[m-1]))
				m--;
			/* suppress tailing ' if needed */
			if(m>0 && valuestart[m-1] == '\"')
				m--;
			i = -1;
			/*printf("--%.*s: (%d)%.*s--\n", l, linestart,
			                           m, m, valuestart);*/
			if(l==2 && 0==strncasecmp(linestart, "nt", 2))
				i = HEADER_NT;
			else if(l==3 && 0==strncasecmp(linestart, "usn", 3))
				i = HEADER_USN;
			else if(l==3 && 0==strncasecmp(linestart, "nts", 3)) {
				if(m==10 && 0==strncasecmp(valuestart, "ssdp:alive", 10))
					nts = NTS_SSDP_ALIVE;
				else if(m==11 && 0==strncasecmp(valuestart, "ssdp:byebye", 11))
					nts = NTS_SSDP_BYEBYE;
				else if(m==11 && 0==strncasecmp(valuestart, "ssdp:update", 11))
					nts = NTS_SSDP_UPDATE;
			}
			else if(l==8 && 0==strncasecmp(linestart, "location", 8))
				i = HEADER_LOCATION;
			else if(l==13 && 0==strncasecmp(linestart, "cache-control", 13)) {
				/* parse "name1=value1, name_alone, name2=value2" string */
				const char * name = valuestart;	/* name */
				const char * val;				/* value */
				int rem = m;	/* remaining bytes to process */
				while(rem > 0) {
					val = name;
					while(val < name + rem && *val != '=' && *val != ',')
						val++;
					if(val >= name + rem)
						break;
					if(*val == '=') {
						while(val < name + rem && (*val == '=' || isspace(*val)))
							val++;
						if(val >= name + rem)
							break;
						if(0==strncasecmp(name, "max-age", 7))
							lifetime = (unsigned int)strtoul(val, 0, 0);
						/* move to the next name=value pair */
						while(rem > 0 && *name != ',') {
							rem--;
							name++;
						}
						/* skip spaces */
						while(rem > 0 && (*name == ',' || isspace(*name))) {
							rem--;
							name++;
						}
					} else {
						rem -= (val - name);
						name = val;
						while(rem > 0 && (*name == ',' || isspace(*name))) {
							rem--;
							name++;
						}
					}
				}
				/*syslog(LOG_DEBUG, "**%.*s**%u", m, valuestart, lifetime);*/
			} else if(l==2 && 0==strncasecmp(linestart, "st", 2)) {
				st = valuestart;
				st_len = m;
				if(method == METHOD_NOTIFY)
					i = HEADER_NT;	/* it was a M-SEARCH response */
			}
			if(i>=0) {
				headers[i].p = valuestart;
				headers[i].l = m;
			}
		}
		linestart = lineend;
		while((*linestart == '\n' || *linestart == '\r') && linestart < p + n)
			linestart++;
	}
#if 0
	printf("NTS=%d\n", nts);
	for(i=0; i<3; i++) {
		if(headers[i].p)
			printf("%d-'%.*s'\n", i, headers[i].l, headers[i].p);
	}
#endif
	syslog(LOG_DEBUG,"SSDP request: '%.*s' (%d) %s %s=%.*s",
	       methodlen, p, method, nts_to_str(nts),
	       (method==METHOD_NOTIFY)?"nt":"st",
	       (method==METHOD_NOTIFY)?headers[HEADER_NT].l:st_len,
	       (method==METHOD_NOTIFY)?headers[HEADER_NT].p:st);
	switch(method) {
	case METHOD_NOTIFY:
		if(nts==NTS_SSDP_ALIVE || nts==NTS_SSDP_UPDATE) {
			if(headers[HEADER_NT].p && headers[HEADER_USN].p && headers[HEADER_LOCATION].p) {
				/* filter if needed */
				if(searched_device &&
				   0 != memcmp(headers[HEADER_NT].p, searched_device, headers[HEADER_NT].l))
					break;
				r = updateDevice(headers, time(NULL) + lifetime);
			} else {
				syslog(LOG_WARNING, "missing header nt=%p usn=%p location=%p",
				       headers[HEADER_NT].p, headers[HEADER_USN].p,
				       headers[HEADER_LOCATION].p);
			}
		} else if(nts==NTS_SSDP_BYEBYE) {
			if(headers[HEADER_NT].p && headers[HEADER_USN].p) {
				r = removeDevice(headers);
			} else {
				syslog(LOG_WARNING, "missing header nt=%p usn=%p",
				       headers[HEADER_NT].p, headers[HEADER_USN].p);
			}
		}
		break;
	case METHOD_MSEARCH:
		processMSEARCH(s, st, st_len, addr);
		break;
	default:
		{
			char addr_str[64];
			sockaddr_to_string(addr, addr_str, sizeof(addr_str));
			syslog(LOG_WARNING, "method %.*s, don't know what to do (from %s)",
			       methodlen, p, addr_str);
		}
	}
	return r;
}

/* OpenUnixSocket()
 * open the unix socket and call bind() and listen()
 * return -1 in case of error */
static int
OpenUnixSocket(const char * path)
{
	struct sockaddr_un addr;
	int s;
	int rv;
	s = socket(AF_UNIX, SOCK_STREAM, 0);
	if(s < 0)
	{
		syslog(LOG_ERR, "socket(AF_UNIX): %m");
		return -1;
	}
	/* unlink the socket pseudo file before binding */
	rv = unlink(path);
	if(rv < 0 && errno != ENOENT)
	{
		syslog(LOG_ERR, "unlink(unixsocket, \"%s\"): %m", path);
		close(s);
		return -1;
	}
	addr.sun_family = AF_UNIX;
	strncpy(addr.sun_path, path, sizeof(addr.sun_path));
	if(bind(s, (struct sockaddr *)&addr,
	           sizeof(struct sockaddr_un)) < 0)
	{
		syslog(LOG_ERR, "bind(unixsocket, \"%s\"): %m", path);
		close(s);
		return -1;
	}
	else if(listen(s, 5) < 0)
	{
		syslog(LOG_ERR, "listen(unixsocket): %m");
		close(s);
		return -1;
	}
	/* Change rights so everyone can communicate with us */
	if(chmod(path, 0666) < 0)
	{
		syslog(LOG_WARNING, "chmod(\"%s\"): %m", path);
	}
	return s;
}

static ssize_t processRequestSub(struct reqelem * req, const unsigned char * buf, ssize_t n);

/* processRequest() :
 * process the request coming from a unix socket */
void processRequest(struct reqelem * req)
{
	ssize_t n, r;
	unsigned char buf[2048];
	const unsigned char * p;

	n = read(req->socket, buf, sizeof(buf));
	if(n<0) {
		if(errno == EINTR || errno == EAGAIN || errno == EWOULDBLOCK)
			return;	/* try again later */
		syslog(LOG_ERR, "(s=%d) processRequest(): read(): %m", req->socket);
		goto error;
	}
	if(n==0) {
		syslog(LOG_INFO, "(s=%d) request connection closed", req->socket);
		goto error;
	}
	p = buf;
	while (n > 0)
	{
		r = processRequestSub(req, p, n);
		if (r < 0)
			goto error;
		p += r;
		n -= r;
	}
	return;
error:
	close(req->socket);
	req->socket = -1;
}

static ssize_t processRequestSub(struct reqelem * req, const unsigned char * buf, ssize_t n)
{
	unsigned int l, m;
	unsigned int baselen;	/* without the version */
	const unsigned char * p;
	enum request_type type;
	struct device * d = devlist;
	unsigned char rbuf[RESPONSE_BUFFER_SIZE];
	unsigned char * rp;
	unsigned char nrep = 0;
	time_t t;
	struct service * newserv = NULL;
	struct service * serv;

	t = time(NULL);
	type = buf[0];
	p = buf + 1;
	DECODELENGTH_CHECKLIMIT(l, p, buf + n);
	if(l > (unsigned)(buf+n-p)) {
		syslog(LOG_WARNING, "bad request (length encoding l=%u n=%u)",
		       l, (unsigned)n);
		goto error;
	}
	if(l == 0 && type != MINISSDPD_SEARCH_ALL
	   && type != MINISSDPD_GET_VERSION && type != MINISSDPD_NOTIF) {
		syslog(LOG_WARNING, "bad request (length=0, type=%d)", type);
		goto error;
	}
	syslog(LOG_INFO, "(s=%d) request type=%d str='%.*s'",
	       req->socket, type, l, p);
	switch(type) {
	case MINISSDPD_GET_VERSION:
		rp = rbuf;
		CODELENGTH((sizeof(MINISSDPD_VERSION) - 1), rp);
		memcpy(rp, MINISSDPD_VERSION, sizeof(MINISSDPD_VERSION) - 1);
		rp += (sizeof(MINISSDPD_VERSION) - 1);
		if(write_or_buffer(req, rbuf, rp - rbuf) < 0) {
			syslog(LOG_ERR, "(s=%d) write: %m", req->socket);
			goto error;
		}
		p += l;
		break;
	case MINISSDPD_SEARCH_TYPE:	/* request by type */
	case MINISSDPD_SEARCH_USN:	/* request by USN (unique id) */
	case MINISSDPD_SEARCH_ALL:	/* everything */
		rp = rbuf+1;
		/* From UPnP Device Architecture v1.1 :
		 * 1.3.2 [...] Updated versions of device and service types
		 * are REQUIRED to be full backward compatible with
		 * previous versions. Devices MUST respond to M-SEARCH
		 * requests for any supported version. For example, if a
		 * device implements “urn:schemas-upnporg:service:xyz:2”,
		 * it MUST respond to search requests for both that type
		 * and “urn:schemas-upnp-org:service:xyz:1”. The response
		 * MUST specify the same version as was contained in the
		 * search request. [...] */
		baselen = l;	/* remove the version */
		while(baselen > 0) {
			if(p[baselen-1] == ':')
				break;
			if(!(p[baselen-1] >= '0' && p[baselen-1] <= '9'))
				break;
			baselen--;
		}
		while(d && (nrep < 255)) {
			if(d->t < t) {
				syslog(LOG_INFO, "outdated device");
			} else {
				/* test if we can put more responses in the buffer */
				if(d->headers[HEADER_LOCATION].l + d->headers[HEADER_NT].l
				  + d->headers[HEADER_USN].l + 6
				  + (rp - rbuf) >= (int)sizeof(rbuf))
					break;
				if( (type==MINISSDPD_SEARCH_TYPE && 0==memcmp(d->headers[HEADER_NT].p, p, baselen))
				  ||(type==MINISSDPD_SEARCH_USN && 0==memcmp(d->headers[HEADER_USN].p, p, l))
				  ||(type==MINISSDPD_SEARCH_ALL) ) {
					/* response :
					 * 1 - Location
					 * 2 - NT (device/service type)
					 * 3 - usn */
					m = d->headers[HEADER_LOCATION].l;
					CODELENGTH(m, rp);
					memcpy(rp, d->headers[HEADER_LOCATION].p, d->headers[HEADER_LOCATION].l);
					rp += d->headers[HEADER_LOCATION].l;
					m = d->headers[HEADER_NT].l;
					CODELENGTH(m, rp);
					memcpy(rp, d->headers[HEADER_NT].p, d->headers[HEADER_NT].l);
					rp += d->headers[HEADER_NT].l;
					m = d->headers[HEADER_USN].l;
					CODELENGTH(m, rp);
					memcpy(rp, d->headers[HEADER_USN].p, d->headers[HEADER_USN].l);
					rp += d->headers[HEADER_USN].l;
					nrep++;
				}
			}
			d = d->next;
		}
		/* Also look in service list */
		for(serv = servicelisthead.lh_first;
		    serv && (nrep < 255);
		    serv = serv->entries.le_next) {
			/* test if we can put more responses in the buffer */
			if(strlen(serv->location) + strlen(serv->st)
			  + strlen(serv->usn) + 6 + (rp - rbuf) >= sizeof(rbuf))
			  	break;
			if( (type==MINISSDPD_SEARCH_TYPE && 0==strncmp(serv->st, (const char *)p, l))
			  ||(type==MINISSDPD_SEARCH_USN && 0==strncmp(serv->usn, (const char *)p, l))
			  ||(type==MINISSDPD_SEARCH_ALL) ) {
				/* response :
				 * 1 - Location
				 * 2 - NT (device/service type)
				 * 3 - usn */
				m = strlen(serv->location);
				CODELENGTH(m, rp);
				memcpy(rp, serv->location, m);
				rp += m;
				m = strlen(serv->st);
				CODELENGTH(m, rp);
				memcpy(rp, serv->st, m);
				rp += m;
				m = strlen(serv->usn);
				CODELENGTH(m, rp);
				memcpy(rp, serv->usn, m);
				rp += m;
				nrep++;
			}
		}
		rbuf[0] = nrep;
		syslog(LOG_DEBUG, "(s=%d) response : %d device%s",
		       req->socket, nrep, (nrep > 1) ? "s" : "");
		if(write_or_buffer(req, rbuf, rp - rbuf) < 0) {
			syslog(LOG_ERR, "(s=%d) write: %m", req->socket);
			goto error;
		}
		p += l;
		break;
	case MINISSDPD_SUBMIT:	/* submit service */
		newserv = malloc(sizeof(struct service));
		if(!newserv) {
			syslog(LOG_ERR, "cannot allocate memory");
			goto error;
		}
		memset(newserv, 0, sizeof(struct service));	/* set pointers to NULL */
		if(containsForbiddenChars(p, l)) {
			syslog(LOG_ERR, "bad request (st contains forbidden chars)");
			goto error;
		}
		newserv->st = malloc(l + 1);
		if(!newserv->st) {
			syslog(LOG_ERR, "cannot allocate memory");
			goto error;
		}
		memcpy(newserv->st, p, l);
		newserv->st[l] = '\0';
		p += l;
		if(p >= buf + n) {
			syslog(LOG_WARNING, "bad request (missing usn)");
			goto error;
		}
		DECODELENGTH_CHECKLIMIT(l, p, buf + n);
		if(l > (unsigned)(buf+n-p)) {
			syslog(LOG_WARNING, "bad request (length encoding)");
			goto error;
		}
		if(containsForbiddenChars(p, l)) {
			syslog(LOG_ERR, "bad request (usn contains forbidden chars)");
			goto error;
		}
		syslog(LOG_INFO, "usn='%.*s'", l, p);
		newserv->usn = malloc(l + 1);
		if(!newserv->usn) {
			syslog(LOG_ERR, "cannot allocate memory");
			goto error;
		}
		memcpy(newserv->usn, p, l);
		newserv->usn[l] = '\0';
		p += l;
		DECODELENGTH_CHECKLIMIT(l, p, buf + n);
		if(l > (unsigned)(buf+n-p)) {
			syslog(LOG_WARNING, "bad request (length encoding)");
			goto error;
		}
		if(containsForbiddenChars(p, l)) {
			syslog(LOG_ERR, "bad request (server contains forbidden chars)");
			goto error;
		}
		syslog(LOG_INFO, "server='%.*s'", l, p);
		newserv->server = malloc(l + 1);
		if(!newserv->server) {
			syslog(LOG_ERR, "cannot allocate memory");
			goto error;
		}
		memcpy(newserv->server, p, l);
		newserv->server[l] = '\0';
		p += l;
		DECODELENGTH_CHECKLIMIT(l, p, buf + n);
		if(l > (unsigned)(buf+n-p)) {
			syslog(LOG_WARNING, "bad request (length encoding)");
			goto error;
		}
		if(containsForbiddenChars(p, l)) {
			syslog(LOG_ERR, "bad request (location contains forbidden chars)");
			goto error;
		}
		syslog(LOG_INFO, "location='%.*s'", l, p);
		newserv->location = malloc(l + 1);
		if(!newserv->location) {
			syslog(LOG_ERR, "cannot allocate memory");
			goto error;
		}
		memcpy(newserv->location, p, l);
		newserv->location[l] = '\0';
		p += l;
		/* look in service list for duplicate */
		for(serv = servicelisthead.lh_first;
		    serv;
		    serv = serv->entries.le_next) {
			if(0 == strcmp(newserv->usn, serv->usn)
			  && 0 == strcmp(newserv->st, serv->st)) {
				syslog(LOG_INFO, "Service already in the list. Updating...");
				free(newserv->st);
				free(newserv->usn);
				free(serv->server);
				serv->server = newserv->server;
				free(serv->location);
				serv->location = newserv->location;
				free(newserv);
				newserv = NULL;
				return (p - buf);
			}
		}
		/* Inserting new service */
		LIST_INSERT_HEAD(&servicelisthead, newserv, entries);
		sendNotifications(NOTIF_NEW, NULL, newserv);
		newserv = NULL;
		break;
	case MINISSDPD_NOTIF:	/* switch socket to notify */
		rbuf[0] = '\0';
		if(write_or_buffer(req, rbuf, 1) < 0) {
			syslog(LOG_ERR, "(s=%d) write: %m", req->socket);
			goto error;
		}
		req->is_notify = 1;
		p += l;
		break;
	default:
		syslog(LOG_WARNING, "Unknown request type %d", type);
		rbuf[0] = '\0';
		if(write_or_buffer(req, rbuf, 1) < 0) {
			syslog(LOG_ERR, "(s=%d) write: %m", req->socket);
			goto error;
		}
	}
	return (p - buf);
error:
	if(newserv) {
		free(newserv->st);
		free(newserv->usn);
		free(newserv->server);
		free(newserv->location);
		free(newserv);
		newserv = NULL;
	}
	return -1;
}

static volatile sig_atomic_t quitting = 0;
/* SIGTERM signal handler */
static void
sigterm(int sig)
{
	(void)sig;
	/*int save_errno = errno;*/
	/*signal(sig, SIG_IGN);*/
#if 0
	/* calling syslog() is forbidden in a signal handler according to
	 * signal(3) */
	syslog(LOG_NOTICE, "received signal %d, good-bye", sig);
#endif
	quitting = 1;
	/*errno = save_errno;*/
}

#define PORT 1900
#define XSTR(s) STR(s)
#define STR(s) #s
#define UPNP_MCAST_ADDR "239.255.255.250"
/* for IPv6 */
#define UPNP_MCAST_LL_ADDR "FF02::C" /* link-local */
#define UPNP_MCAST_SL_ADDR "FF05::C" /* site-local */

/* send the M-SEARCH request for devices
 * either all devices (third argument is NULL or "*") or a specific one */
static void ssdpDiscover(int s, int ipv6, const char * search)
{
	static const char MSearchMsgFmt[] =
	"M-SEARCH * HTTP/1.1\r\n"
	"HOST: %s:" XSTR(PORT) "\r\n"
	"ST: %s\r\n"
	"MAN: \"ssdp:discover\"\r\n"
	"MX: %u\r\n"
	"\r\n";
	char bufr[512];
	int n;
	int mx = 3;
	int linklocal = 1;
	struct sockaddr_storage sockudp_w;

	{
		n = snprintf(bufr, sizeof(bufr),
		             MSearchMsgFmt,
		             ipv6 ?
		             (linklocal ? "[" UPNP_MCAST_LL_ADDR "]" :  "[" UPNP_MCAST_SL_ADDR "]")
		             : UPNP_MCAST_ADDR,
		             (search ? search : "ssdp:all"), mx);
		memset(&sockudp_w, 0, sizeof(struct sockaddr_storage));
		if(ipv6) {
			struct sockaddr_in6 * p = (struct sockaddr_in6 *)&sockudp_w;
			p->sin6_family = AF_INET6;
			p->sin6_port = htons(PORT);
			inet_pton(AF_INET6,
			          linklocal ? UPNP_MCAST_LL_ADDR : UPNP_MCAST_SL_ADDR,
			          &(p->sin6_addr));
		} else {
			struct sockaddr_in * p = (struct sockaddr_in *)&sockudp_w;
			p->sin_family = AF_INET;
			p->sin_port = htons(PORT);
			p->sin_addr.s_addr = inet_addr(UPNP_MCAST_ADDR);
		}

		n = sendto_or_schedule(s, bufr, n, 0, (const struct sockaddr *)&sockudp_w,
		                       ipv6 ? sizeof(struct sockaddr_in6) : sizeof(struct sockaddr_in));
		if (n < 0) {
			syslog(LOG_ERR, "%s: sendto: %m", __func__);
		}
	}
}

/* main(): program entry point */
int main(int argc, char * * argv)
{
	int ret = 0;
	int pid;
	struct sigaction sa;
	char buf[1500];
	ssize_t n;
	int s_ssdp = -1;	/* udp socket receiving ssdp packets */
#ifdef ENABLE_IPV6
	int s_ssdp6 = -1;	/* udp socket receiving ssdp packets IPv6*/
#else	/* ENABLE_IPV6 */
#define s_ssdp6 (-1)
#endif	/* ENABLE_IPV6 */
	int s_unix = -1;	/* unix socket communicating with clients */
	int s_ifacewatch = -1;	/* socket to receive Route / network interface config changes */
	struct reqelem * req;
	struct reqelem * reqnext;
	fd_set readfds;
	fd_set writefds;
	struct timeval now;
	int max_fd;
	struct lan_addr_s * lan_addr;
	int i;
	const char * sockpath = "/var/run/minissdpd.sock";
	const char * pidfilename = "/var/run/minissdpd.pid";
	int debug_flag = 0;
#ifdef ENABLE_IPV6
	int ipv6 = 0;
#endif /* ENABLE_IPV6 */
	int deltadev = 0;
	struct sockaddr_in sendername;
	socklen_t sendername_len;
#ifdef ENABLE_IPV6
	struct sockaddr_in6 sendername6;
	socklen_t sendername6_len;
#endif	/* ENABLE_IPV6 */
	unsigned char ttl = 2;	/* UDA says it should default to 2 */
	const char * searched_device = NULL;	/* if not NULL, search/filter a specific device type */

	LIST_INIT(&reqlisthead);
	LIST_INIT(&servicelisthead);
	LIST_INIT(&lan_addrs);
	/* process command line */
	for(i=1; i<argc; i++)
	{
 		if(0==strcmp(argv[i], "-d"))
			debug_flag = 1;
#ifdef ENABLE_IPV6
		else if(0==strcmp(argv[i], "-6"))
			ipv6 = 1;
#endif	/* ENABLE_IPV6 */
		else {
			if((i + 1) >= argc) {
				fprintf(stderr, "option %s needs an argument.\n", argv[i]);
				break;
			}
			if(0==strcmp(argv[i], "-i")) {
				lan_addr = malloc(sizeof(struct lan_addr_s));
				if(lan_addr == NULL) {
					fprintf(stderr, "malloc(%d) FAILED\n", (int)sizeof(struct lan_addr_s));
					break;
				}
				if(parselanaddr(lan_addr, argv[++i]) != 0) {
					fprintf(stderr, "can't parse \"%s\" as a valid address or interface name\n", argv[i]);
					free(lan_addr);
				} else {
					LIST_INSERT_HEAD(&lan_addrs, lan_addr, list);
				}
			} else if(0==strcmp(argv[i], "-s"))
				sockpath = argv[++i];
			else if(0==strcmp(argv[i], "-p"))
				pidfilename = argv[++i];
			else if(0==strcmp(argv[i], "-t"))
				ttl = (unsigned char)atoi(argv[++i]);
			else if(0==strcmp(argv[i], "-f"))
				searched_device = argv[++i];
			else
				fprintf(stderr, "unknown commandline option %s.\n", argv[i]);
		}
	}
	if(lan_addrs.lh_first == NULL)
	{
		fprintf(stderr,
		        "Usage: %s [-d] "
#ifdef ENABLE_IPV6
		        "[-6] "
#endif /* ENABLE_IPV6 */
		        "[-s socket] [-p pidfile] [-t TTL] "
		        "[-f device] "
		        "-i <interface> [-i <interface2>] ...\n",
		        argv[0]);
		fprintf(stderr,
		        "\n  <interface> is either an IPv4 address with mask such as\n"
		        "  192.168.1.42/255.255.255.0, or an interface name such as eth0.\n");
		fprintf(stderr,
		        "\n  By default, socket will be open as %s\n"
		        "  and pid written to file %s\n",
		        sockpath, pidfilename);
		return 1;
	}

	/* open log */
	openlog("minissdpd",
	        LOG_CONS|LOG_PID|(debug_flag?LOG_PERROR:0),
			LOG_MINISSDPD);
	if(!debug_flag) /* speed things up and ignore LOG_INFO and LOG_DEBUG */
		setlogmask(LOG_UPTO(LOG_NOTICE));

	if(checkforrunning(pidfilename) < 0)
	{
		syslog(LOG_ERR, "MiniSSDPd is already running. EXITING");
		return 1;
	}

	upnp_bootid = (unsigned int)time(NULL);

	/* set signal handlers */
	memset(&sa, 0, sizeof(struct sigaction));
	sa.sa_handler = sigterm;
	if(sigaction(SIGTERM, &sa, NULL))
	{
		syslog(LOG_ERR, "Failed to set SIGTERM handler. EXITING");
		ret = 1;
		goto quit;
	}
	if(sigaction(SIGINT, &sa, NULL))
	{
		syslog(LOG_ERR, "Failed to set SIGINT handler. EXITING");
		ret = 1;
		goto quit;
	}
	/* open route/interface config changes socket */
	s_ifacewatch = OpenAndConfInterfaceWatchSocket();
	/* open UDP socket(s) for receiving SSDP packets */
	s_ssdp = OpenAndConfSSDPReceiveSocket(0, ttl);
	if(s_ssdp < 0)
	{
		syslog(LOG_ERR, "Cannot open socket for receiving SSDP messages, exiting");
		ret = 1;
		goto quit;
	}
#ifdef ENABLE_IPV6
	if(ipv6) {
		s_ssdp6 = OpenAndConfSSDPReceiveSocket(1, ttl);
		if(s_ssdp6 < 0)
		{
			syslog(LOG_ERR, "Cannot open socket for receiving SSDP messages (IPv6), exiting");
			ret = 1;
			goto quit;
		}
	}
#endif	/* ENABLE_IPV6 */
	/* Open Unix socket to communicate with other programs on
	 * the same machine */
	s_unix = OpenUnixSocket(sockpath);
	if(s_unix < 0)
	{
		syslog(LOG_ERR, "Cannot open unix socket for communicating with clients. Exiting");
		ret = 1;
		goto quit;
	}

	/* drop privileges */
#if 0
	/* if we drop privileges, how to unlink(/var/run/minissdpd.sock) ? */
	if(getuid() == 0) {
		struct passwd * user;
		struct group * group;
		user = getpwnam("nobody");
		if(!user) {
			syslog(LOG_ERR, "getpwnam(\"%s\") : %m", "nobody");
			ret = 1;
			goto quit;
		}
		group = getgrnam("nogroup");
		if(!group) {
			syslog(LOG_ERR, "getgrnam(\"%s\") : %m", "nogroup");
			ret = 1;
			goto quit;
		}
		if(setgid(group->gr_gid) < 0) {
			syslog(LOG_ERR, "setgit(%d) : %m", group->gr_gid);
			ret = 1;
			goto quit;
		}
		if(setuid(user->pw_uid) < 0) {
			syslog(LOG_ERR, "setuid(%d) : %m", user->pw_uid);
			ret = 1;
			goto quit;
		}
	}
#endif

	/* daemonize or in any case get pid ! */
	if(debug_flag)
		pid = getpid();
	else {
#ifdef USE_DAEMON
		if(daemon(0, 0) < 0)
			perror("daemon()");
		pid = getpid();
#else  /* USE_DAEMON */
		pid = daemonize();
#endif /* USE_DAEMON */
	}

	writepidfile(pidfilename, pid);

	/* send M-SEARCH ssdp:all Requests */
	if(s_ssdp >= 0)
		ssdpDiscover(s_ssdp, 0, searched_device);
	if(s_ssdp6 >= 0)
		ssdpDiscover(s_ssdp6, 1, searched_device);

	/* Main loop */
	while(!quitting) {
		/* fill readfds fd_set */
		FD_ZERO(&readfds);
		FD_ZERO(&writefds);

		FD_SET(s_unix, &readfds);
		max_fd = s_unix;
		if(s_ssdp >= 0) {
			FD_SET(s_ssdp, &readfds);
			SET_MAX(max_fd, s_ssdp);
		}
#ifdef ENABLE_IPV6
		if(s_ssdp6 >= 0) {
			FD_SET(s_ssdp6, &readfds);
			SET_MAX(max_fd, s_ssdp6);
		}
#endif /* ENABLE_IPV6 */
		if(s_ifacewatch >= 0) {
			FD_SET(s_ifacewatch, &readfds);
			SET_MAX(max_fd, s_ifacewatch);
		}
		for(req = reqlisthead.lh_first; req; req = req->entries.le_next) {
			if(req->socket >= 0) {
				FD_SET(req->socket, &readfds);
				SET_MAX(max_fd, req->socket);
			}
			if(req->output_buffer_len > 0) {
				FD_SET(req->socket, &writefds);
				SET_MAX(max_fd, req->socket);
			}
		}
		gettimeofday(&now, NULL);
		i = get_sendto_fds(&writefds, &max_fd, &now);
		/* select call */
		if(select(max_fd + 1, &readfds, &writefds, 0, 0) < 0) {
			if(errno != EINTR) {
				syslog(LOG_ERR, "select: %m");
				break;	/* quit */
			}
			continue;	/* try again */
		}
		if(try_sendto(&writefds) < 0) {
			syslog(LOG_ERR, "try_sendto: %m");
			break;
		}
#ifdef ENABLE_IPV6
		if((s_ssdp6 >= 0) && FD_ISSET(s_ssdp6, &readfds))
		{
			sendername6_len = sizeof(struct sockaddr_in6);
			n = recvfrom(s_ssdp6, buf, sizeof(buf), 0,
			             (struct sockaddr *)&sendername6, &sendername6_len);
			if(n<0)
			{
				 /* EAGAIN, EWOULDBLOCK, EINTR : silently ignore (try again next time)
				  * other errors : log to LOG_ERR */
				if(errno != EAGAIN && errno != EWOULDBLOCK && errno != EINTR)
					syslog(LOG_ERR, "recvfrom: %m");
			}
			else
			{
				/* Parse and process the packet received */
				/*printf("%.*s", n, buf);*/
				i = ParseSSDPPacket(s_ssdp6, buf, n,
				                    (struct sockaddr *)&sendername6, searched_device);
				syslog(LOG_DEBUG, "** i=%d deltadev=%d **", i, deltadev);
				if(i==0 || (i*deltadev < 0))
				{
					if(deltadev > 0)
						syslog(LOG_NOTICE, "%d new devices added", deltadev);
					else if(deltadev < 0)
						syslog(LOG_NOTICE, "%d devices removed (good-bye!)", -deltadev);
					deltadev = i;
				}
				else if((i*deltadev) >= 0)
				{
					deltadev += i;
				}
			}
		}
#endif	/* ENABLE_IPV6 */
		if((s_ssdp >= 0) && FD_ISSET(s_ssdp, &readfds))
		{
			sendername_len = sizeof(struct sockaddr_in);
			n = recvfrom(s_ssdp, buf, sizeof(buf), 0,
			             (struct sockaddr *)&sendername, &sendername_len);
			if(n<0)
			{
				 /* EAGAIN, EWOULDBLOCK, EINTR : silently ignore (try again next time)
				  * other errors : log to LOG_ERR */
				if(errno != EAGAIN && errno != EWOULDBLOCK && errno != EINTR)
					syslog(LOG_ERR, "recvfrom: %m");
			}
			else
			{
				/* Parse and process the packet received */
				/*printf("%.*s", n, buf);*/
				i = ParseSSDPPacket(s_ssdp, buf, n,
				                    (struct sockaddr *)&sendername, searched_device);
				syslog(LOG_DEBUG, "** i=%d deltadev=%d **", i, deltadev);
				if(i==0 || (i*deltadev < 0))
				{
					if(deltadev > 0)
						syslog(LOG_NOTICE, "%d new devices added", deltadev);
					else if(deltadev < 0)
						syslog(LOG_NOTICE, "%d devices removed (good-bye!)", -deltadev);
					deltadev = i;
				}
				else if((i*deltadev) >= 0)
				{
					deltadev += i;
				}
			}
		}
		/* processing unix socket requests */
		for(req = reqlisthead.lh_first; req;) {
			reqnext = req->entries.le_next;
			if((req->socket >= 0) && FD_ISSET(req->socket, &readfds)) {
				processRequest(req);
			}
			if((req->socket >= 0) && FD_ISSET(req->socket, &writefds)) {
				write_buffer(req);
			}
			if(req->socket < 0) {
				LIST_REMOVE(req, entries);
				free(req->output_buffer);
				free(req);
			}
			req = reqnext;
		}
		/* processing new requests */
		if(FD_ISSET(s_unix, &readfds))
		{
			struct reqelem * tmp;
			int s = accept(s_unix, NULL, NULL);
			if(s < 0) {
				syslog(LOG_ERR, "accept(s_unix): %m");
			} else {
				syslog(LOG_INFO, "(s=%d) new request connection", s);
				if(!set_non_blocking(s))
					syslog(LOG_WARNING, "Failed to set new socket non blocking : %m");
				tmp = malloc(sizeof(struct reqelem));
				if(!tmp) {
					syslog(LOG_ERR, "cannot allocate memory for request");
					close(s);
				} else {
					memset(tmp, 0, sizeof(struct reqelem));
					tmp->socket = s;
					LIST_INSERT_HEAD(&reqlisthead, tmp, entries);
				}
			}
		}
		/* processing route/network interface config changes */
		if((s_ifacewatch >= 0) && FD_ISSET(s_ifacewatch, &readfds)) {
			ProcessInterfaceWatch(s_ifacewatch, s_ssdp, s_ssdp6);
		}
	}
	syslog(LOG_DEBUG, "quitting...");
	finalize_sendto();

	/* closing and cleaning everything */
quit:
	if(s_ssdp >= 0) {
		close(s_ssdp);
		s_ssdp = -1;
	}
#ifdef ENABLE_IPV6
	if(s_ssdp6 >= 0) {
		close(s_ssdp6);
		s_ssdp6 = -1;
	}
#endif	/* ENABLE_IPV6 */
	if(s_unix >= 0) {
		close(s_unix);
		s_unix = -1;
		if(unlink(sockpath) < 0)
			syslog(LOG_ERR, "unlink(%s): %m", sockpath);
	}
	if(s_ifacewatch >= 0) {
		close(s_ifacewatch);
		s_ifacewatch = -1;
	}
	/* empty LAN interface/address list */
	while(lan_addrs.lh_first != NULL) {
		lan_addr = lan_addrs.lh_first;
		LIST_REMOVE(lan_addrs.lh_first, list);
		free(lan_addr);
	}
	/* empty device list */
	while(devlist != NULL) {
		struct device * next = devlist->next;
		free(devlist);
		devlist = next;
	}
	/* empty service list */
	while(servicelisthead.lh_first != NULL) {
		struct service * serv = servicelisthead.lh_first;
		LIST_REMOVE(servicelisthead.lh_first, entries);
		free(serv->st);
		free(serv->usn);
		free(serv->server);
		free(serv->location);
		free(serv);
	}
	if(unlink(pidfilename) < 0)
		syslog(LOG_ERR, "unlink(%s): %m", pidfilename);
	closelog();
	return ret;
}

