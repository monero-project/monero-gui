/* $Id: openssdpsocket.c,v 1.17 2015/08/06 14:05:37 nanard Exp $ */
/* MiniUPnP project
 * http://miniupnp.free.fr/ or http://miniupnp.tuxfamily.org/
 * (c) 2006-2018 Thomas Bernard
 * This software is subject to the conditions detailed
 * in the LICENCE file provided within the distribution */

#include "config.h"

#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <syslog.h>

#include "openssdpsocket.h"
#include "upnputils.h"
#include "minissdpdtypes.h"

extern struct lan_addr_list lan_addrs;

/* SSDP ip/port */
#define SSDP_PORT (1900)
#define SSDP_MCAST_ADDR ("239.255.255.250")
/* Link Local and Site Local SSDP IPv6 multicast addresses */
#define LL_SSDP_MCAST_ADDR ("FF02::C")
#define SL_SSDP_MCAST_ADDR ("FF05::C")

/**
 * Add the multicast membership for SSDP on the interface
 * @param s	the socket
 * @param ifaddr	the IPv4 address or interface name
 * @param ipv6	IPv6 or IPv4
 * return -1 on error, 0 on success */
int
AddDropMulticastMembership(int s, struct lan_addr_s * lan_addr, int ipv6, int drop)
{
	struct ip_mreq imr;	/* Ip multicast membership */
#ifdef ENABLE_IPV6
	struct ipv6_mreq mr;
#else	/* ENABLE_IPV6 */
	(void)ipv6;
#endif	/* ENABLE_IPV6 */

	if(s <= 0)
		return -1;	/* nothing to do */
#ifdef ENABLE_IPV6
	if(ipv6)
	{
		memset(&mr, 0, sizeof(mr));
		inet_pton(AF_INET6, LL_SSDP_MCAST_ADDR, &mr.ipv6mr_multiaddr);
		mr.ipv6mr_interface = lan_addr->index;
		if(setsockopt(s, IPPROTO_IPV6, drop ? IPV6_LEAVE_GROUP : IPV6_JOIN_GROUP,
		   &mr, sizeof(struct ipv6_mreq)) < 0)
		{
			syslog(LOG_ERR, "setsockopt(udp, %s)(%s, %s): %m",
			       drop ? "IPV6_LEAVE_GROUP" : "IPV6_JOIN_GROUP",
			       LL_SSDP_MCAST_ADDR,
			       lan_addr->ifname);
			return -1;
		}
		inet_pton(AF_INET6, SL_SSDP_MCAST_ADDR, &mr.ipv6mr_multiaddr);
		if(setsockopt(s, IPPROTO_IPV6, drop ? IPV6_LEAVE_GROUP : IPV6_JOIN_GROUP,
		   &mr, sizeof(struct ipv6_mreq)) < 0)
		{
			syslog(LOG_ERR, "setsockopt(udp, %s)(%s, %s): %m",
			       drop ? "IPV6_LEAVE_GROUP" : "IPV6_JOIN_GROUP",
			       SL_SSDP_MCAST_ADDR,
			       lan_addr->ifname);
			return -1;
		}
	}
	else
	{
#endif /* ENABLE_IPV6 */
		/* setting up imr structure */
		imr.imr_multiaddr.s_addr = inet_addr(SSDP_MCAST_ADDR);
		imr.imr_interface.s_addr = lan_addr->addr.s_addr;
		if(imr.imr_interface.s_addr == INADDR_NONE)
		{
			syslog(LOG_ERR, "no IPv4 address for interface %s",
			       lan_addr->ifname);
			return -1;
		}

		if (setsockopt(s, IPPROTO_IP, drop ? IP_DROP_MEMBERSHIP : IP_ADD_MEMBERSHIP,
		    (void *)&imr, sizeof(struct ip_mreq)) < 0)
		{
			syslog(LOG_ERR, "setsockopt(udp, %s)(%s): %m",
			       drop ? "IP_DROP_MEMBERSHIP" : "IP_ADD_MEMBERSHIP",
			       lan_addr->ifname);
			return -1;
		}
#ifdef ENABLE_IPV6
	}
#endif /* ENABLE_IPV6 */

	return 0;
}

int
OpenAndConfSSDPReceiveSocket(int ipv6, unsigned char ttl)
{
	int s;
	int opt = 1;
	unsigned char loopchar = 0;
#ifdef ENABLE_IPV6
	struct sockaddr_storage sockname;
#else /* ENABLE_IPV6 */
	struct sockaddr_in sockname;
#endif /* ENABLE_IPV6 */
	socklen_t sockname_len;
	struct lan_addr_s * lan_addr;

#ifndef ENABLE_IPV6
	if(ipv6) {
		syslog(LOG_ERR, "%s: please compile with ENABLE_IPV6 to allow ipv6=1", __func__);
		return -1;
	}
#endif /* ENABLE_IPV6 */

#ifdef ENABLE_IPV6
	if( (s = socket(ipv6 ? PF_INET6 : PF_INET, SOCK_DGRAM, 0)) < 0)
#else /* ENABLE_IPV6 */
	if( (s = socket(PF_INET, SOCK_DGRAM, 0)) < 0)
#endif /* ENABLE_IPV6 */
	{
		syslog(LOG_ERR, "socket(udp): %m");
		return -1;
	}

	if(!set_non_blocking(s)) {
		syslog(LOG_WARNING, "Failed to set SSDP socket non blocking : %m");
	}

#ifdef ENABLE_IPV6
	memset(&sockname, 0, sizeof(struct sockaddr_storage));
	if(ipv6)
	{
#ifdef IPV6_V6ONLY
		if(setsockopt(s, IPPROTO_IPV6, IPV6_V6ONLY,
		              (char *)&opt, sizeof(opt)) < 0)
		{
			syslog(LOG_WARNING, "setsockopt(IPV6_V6ONLY): %m");
		}
#endif /* IPV6_V6ONLY */
		struct sockaddr_in6 * sa = (struct sockaddr_in6 *)&sockname;
		sa->sin6_family = AF_INET6;
		sa->sin6_port = htons(SSDP_PORT);
		sa->sin6_addr = in6addr_any;
		sockname_len = sizeof(struct sockaddr_in6);
	}
	else
	{
		struct sockaddr_in * sa = (struct sockaddr_in *)&sockname;
		sa->sin_family = AF_INET;
		sa->sin_port = htons(SSDP_PORT);
#ifdef SSDP_LISTEN_ON_SPECIFIC_ADDR
		if(lan_addrs.lh_first != NULL && lan_addrs.lh_first->list.le_next == NULL)
		{
			sa->sin_addr.s_addr = lan_addrs.lh_first->addr.s_addr;
			if(sa->sin_addr.s_addr == INADDR_NONE)
			{
				syslog(LOG_ERR, "no IPv4 address for interface %s",
				       lan_addrs.lh_first->ifname);
				close(s);
				return -1;
			}
		}
		else
#endif /* SSDP_LISTEN_ON_SPECIFIC_ADDR */
			sa->sin_addr.s_addr = htonl(INADDR_ANY);
		sockname_len = sizeof(struct sockaddr_in);
	}
#else /* ENABLE_IPV6 */
	memset(&sockname, 0, sizeof(struct sockaddr_in));
    sockname.sin_family = AF_INET;
    sockname.sin_port = htons(SSDP_PORT);
#ifdef SSDP_LISTEN_ON_SPECIFIC_ADDR
	if(lan_addrs.lh_first != NULL && lan_addrs.lh_first->list.le_next == NULL)
	{
		sockname.sin_addr.s_addr = lan_addrs.lh_first->addr.s_addr;
		if(sockname.sin_addr.s_addr == INADDR_NONE)
		{
			syslog(LOG_ERR, "no IPv4 address for interface %s",
			       lan_addrs.lh_first->ifname);
			close(s);
			return -1;
		}
	}
	else
#endif /* SSDP_LISTEN_ON_SPECIFIC_ADDR */
	sockname.sin_addr.s_addr = htonl(INADDR_ANY);
	sockname_len = sizeof(struct sockaddr_in);
#endif /* ENABLE_IPV6 */

	if(setsockopt(s, IPPROTO_IP, IP_MULTICAST_LOOP, (char *)&loopchar, sizeof(loopchar)) < 0)
	{
		syslog(LOG_WARNING, "setsockopt(IP_MULTICAST_LOOP): %m");
	}

	if(setsockopt(s, IPPROTO_IP, IP_MULTICAST_TTL, &ttl, sizeof(ttl)) < 0)
	{
		syslog(LOG_WARNING, "setsockopt(IP_MULTICAST_TTL): %m");
	}

	if(setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) < 0)
	{
		syslog(LOG_WARNING, "setsockopt(SO_REUSEADDR): %m");
	}

    if(bind(s, (struct sockaddr *)&sockname, sockname_len) < 0)
	{
		syslog(LOG_ERR, "bind(udp%s): %m", ipv6 ? "6" : "");
		close(s);
		return -1;
    }

	for(lan_addr = lan_addrs.lh_first; lan_addr != NULL; lan_addr = lan_addr->list.le_next)
	{
		if(AddDropMulticastMembership(s, lan_addr, ipv6, 0) < 0)
		{
			syslog(LOG_WARNING, "Failed to add IPv%d multicast membership for interface %s.",
			       ipv6 ? 6 : 4,
			       lan_addr->ifname);
		}
	}

	return s;
}
