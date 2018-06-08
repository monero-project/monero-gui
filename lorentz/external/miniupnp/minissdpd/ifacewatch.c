/* $Id: ifacewatch.c,v 1.16 2015/09/03 18:31:25 nanard Exp $ */
/* MiniUPnP project
 * (c) 2011-2018 Thomas Bernard
 * website : http://miniupnp.free.fr/ or https://miniupnp.tuxfamily.org/
 * This software is subject to the conditions detailed
 * in the LICENCE file provided within the distribution */
#include "config.h"

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if.h>
#ifdef __linux__
#include <linux/netlink.h>
#include <linux/rtnetlink.h>
#else	/* __linux__ */
#include <net/route.h>
#ifdef AF_LINK
#include <net/if_dl.h>
#endif
#endif	/* __linux__ */
#include <syslog.h>
#include <inttypes.h>

#include "config.h"
#include "openssdpsocket.h"
#include "upnputils.h"
#include "minissdpdtypes.h"

extern struct lan_addr_list lan_addrs;

#ifndef __linux__
#if defined(__OpenBSD__) || defined(__FreeBSD__)
#define SALIGN (sizeof(long) - 1)
#else
#define SALIGN (sizeof(int32_t) - 1)
#endif
#define SA_RLEN(sa) (SA_LEN(sa) ? ((SA_LEN(sa) + SALIGN) & ~SALIGN) : (SALIGN + 1))
#endif

int
OpenAndConfInterfaceWatchSocket(void)
{
	int s;
#ifdef __linux__
	struct sockaddr_nl addr;

	s = socket(PF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
#else	/* __linux__*/
	/*s = socket(PF_ROUTE, SOCK_RAW, AF_INET);*/
	s = socket(PF_ROUTE, SOCK_RAW, AF_UNSPEC);
/* The family parameter may be AF_UNSPEC which will provide routing informa-
 * tion for all address families, or can be restricted to a specific address
 * family by specifying which one is desired.  There can be more than one
 * routing socket open per system. */
#endif
	if(s < 0) {
		syslog(LOG_ERR, "%s socket: %m",
		       "OpenAndConfInterfaceWatchSocket");
		return -1;
	}
	if(!set_non_blocking(s)) {
		syslog(LOG_WARNING, "%s failed to set socket non blocking : %m",
		       "OpenAndConfInterfaceWatchSocket");
	}
#ifdef __linux__
	memset(&addr, 0, sizeof(addr));
	addr.nl_family = AF_NETLINK;
	addr.nl_groups = RTMGRP_LINK | RTMGRP_IPV4_IFADDR | RTMGRP_IPV6_IFADDR;

	if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
		syslog(LOG_ERR, "bind(netlink): %m");
		close(s);
		return -1;
	}
#endif
	return s;
}

/**
 * Process the message and add/drop multicast membership if needed
 */
int
ProcessInterfaceWatch(int s, int s_ssdp, int s_ssdp6)
{
	struct lan_addr_s * lan_addr;
	ssize_t len;
	char buffer[4096];
#ifdef __linux__
	struct iovec iov;
	struct msghdr hdr;
	struct nlmsghdr *nlhdr;
	struct ifaddrmsg *ifa;
	struct rtattr *rta;
	int ifa_len;

#ifndef ENABLE_IPV6
	(void)s_ssdp6;
#endif
	iov.iov_base = buffer;
	iov.iov_len = sizeof(buffer);

	memset(&hdr, 0, sizeof(hdr));
	hdr.msg_iov = &iov;
	hdr.msg_iovlen = 1;

	len = recvmsg(s, &hdr, 0);
	if(len < 0) {
		syslog(LOG_ERR, "recvmsg(s, &hdr, 0): %m");
		return -1;
	}

	for(nlhdr = (struct nlmsghdr *)buffer;
		NLMSG_OK(nlhdr, len);
		nlhdr = NLMSG_NEXT(nlhdr, len)) {
		int is_del = 0;
		char address[48];
		char ifname[IFNAMSIZ];
		address[0] = '\0';
		ifname[0] = '\0';
		if(nlhdr->nlmsg_type == NLMSG_DONE)
			break;
		switch(nlhdr->nlmsg_type) {
		/* case RTM_NEWLINK: */
		/* case RTM_DELLINK: */
		case RTM_DELADDR:
			is_del = 1;
		case RTM_NEWADDR:
			/* http://linux-hacks.blogspot.fr/2009/01/sample-code-to-learn-netlink.html */
			ifa = (struct ifaddrmsg *)NLMSG_DATA(nlhdr);
			rta = (struct rtattr *)IFA_RTA(ifa);
			ifa_len = IFA_PAYLOAD(nlhdr);
			syslog(LOG_DEBUG, "%s %s index=%d fam=%d prefixlen=%d flags=%d scope=%d",
			       "ProcessInterfaceWatchNotify", is_del ? "RTM_DELADDR" : "RTM_NEWADDR",
			       ifa->ifa_index, ifa->ifa_family, ifa->ifa_prefixlen,
			       ifa->ifa_flags, ifa->ifa_scope);
			for(;RTA_OK(rta, ifa_len); rta = RTA_NEXT(rta, ifa_len)) {
				/*RTA_DATA(rta)*/
				/*rta_type : IFA_ADDRESS, IFA_LOCAL, etc. */
				char tmp[128];
				memset(tmp, 0, sizeof(tmp));
				switch(rta->rta_type) {
				case IFA_ADDRESS:
				case IFA_LOCAL:
				case IFA_BROADCAST:
				case IFA_ANYCAST:
					inet_ntop(ifa->ifa_family, RTA_DATA(rta), tmp, sizeof(tmp));
					if(rta->rta_type == IFA_ADDRESS)
						strncpy(address, tmp, sizeof(address));
					break;
				case IFA_LABEL:
					strncpy(tmp, RTA_DATA(rta), sizeof(tmp));
					strncpy(ifname, tmp, sizeof(ifname));
					break;
				case IFA_CACHEINFO:
					{
						struct ifa_cacheinfo *cache_info;
						cache_info = RTA_DATA(rta);
						snprintf(tmp, sizeof(tmp), "valid=%u preferred=%u",
						         cache_info->ifa_valid, cache_info->ifa_prefered);
					}
					break;
				default:
					strncpy(tmp, "*unknown*", sizeof(tmp));
				}
				syslog(LOG_DEBUG, " rta_len=%d rta_type=%d '%s'", rta->rta_len, rta->rta_type, tmp);
			}
			syslog(LOG_INFO, "%s: %s/%d %s",
			       is_del ? "RTM_DELADDR" : "RTM_NEWADDR",
			       address, ifa->ifa_prefixlen, ifname);
			for(lan_addr = lan_addrs.lh_first; lan_addr != NULL; lan_addr = lan_addr->list.le_next) {
#ifdef ENABLE_IPV6
				if((0 == strcmp(address, lan_addr->str)) ||
				   (0 == strcmp(ifname, lan_addr->ifname)) ||
				   (ifa->ifa_index == lan_addr->index)) {
#else
				if((0 == strcmp(address, lan_addr->str)) ||
				   (0 == strcmp(ifname, lan_addr->ifname))) {
#endif
					if(ifa->ifa_family == AF_INET)
						AddDropMulticastMembership(s_ssdp, lan_addr, 0, is_del);
#ifdef ENABLE_IPV6
					else if(ifa->ifa_family == AF_INET6)
						AddDropMulticastMembership(s_ssdp6, lan_addr, 1, is_del);
#endif
					break;
				}
			}
			break;
		default:
			syslog(LOG_DEBUG, "unknown nlmsg_type=%d", nlhdr->nlmsg_type);
		}
	}
#else /* __linux__ */
	struct rt_msghdr * rtm;
	struct ifa_msghdr * ifam;
	int is_del = 0;
	char tmp[64];
	char * p;
	struct sockaddr * sa;
	int addr;
	char address[48];
	char ifname[IFNAMSIZ];
	int family = AF_UNSPEC;
	int prefixlen = 0;

#ifndef ENABLE_IPV6
	(void)s_ssdp6;
#endif
	address[0] = '\0';
	ifname[0] = '\0';

	len = recv(s, buffer, sizeof(buffer), 0);
	if(len < 0) {
		syslog(LOG_ERR, "%s recv: %m", "ProcessInterfaceWatchNotify");
		return -1;
	}
	rtm = (struct rt_msghdr *)buffer;
	switch(rtm->rtm_type) {
	case RTM_DELADDR:
		is_del = 1;
	case RTM_NEWADDR:
		ifam = (struct ifa_msghdr *)buffer;
		syslog(LOG_DEBUG, "%s %s len=%d/%hu index=%hu addrs=%x flags=%x",
		       "ProcessInterfaceWatchNotify", is_del?"RTM_DELADDR":"RTM_NEWADDR",
		       (int)len, ifam->ifam_msglen,
		       ifam->ifam_index, ifam->ifam_addrs, ifam->ifam_flags);
		p = buffer + sizeof(struct ifa_msghdr);
		addr = 1;
		while(p < buffer + len) {
			sa = (struct sockaddr *)p;
			while(!(addr & ifam->ifam_addrs) && (addr <= ifam->ifam_addrs))
				addr = addr << 1;
			sockaddr_to_string(sa, tmp, sizeof(tmp));
			syslog(LOG_DEBUG, " %s", tmp);
			switch(addr) {
			case RTA_DST:
			case RTA_GATEWAY:
				break;
			case RTA_NETMASK:
				if(sa->sa_family == AF_INET
#if defined(__OpenBSD__)
				   || (sa->sa_family == 0 &&
				       sa->sa_len <= sizeof(struct sockaddr_in))
#endif
				   ) {
					uint32_t sin_addr = ntohl(((struct sockaddr_in *)sa)->sin_addr.s_addr);
					while((prefixlen < 32) &&
					      ((sin_addr & (1 << (31 - prefixlen))) != 0))
						prefixlen++;
				} else if(sa->sa_family == AF_INET6
#if defined(__OpenBSD__)
				          || (sa->sa_family == 0 &&
				              sa->sa_len == sizeof(struct sockaddr_in6))
#endif
				          ) {
					int i = 0;
					uint8_t * q =  ((struct sockaddr_in6 *)sa)->sin6_addr.s6_addr;
					while((*q == 0xff) && (i < 16)) {
						prefixlen += 8;
						q++; i++;
					}
					if(i < 16) {
						i = 0;
						while((i < 8) &&
						      ((*q & (1 << (7 - i))) != 0))
							i++;
						prefixlen += i;
					}
				}
				break;
			case RTA_GENMASK:
				break;
			case RTA_IFP:
#ifdef AF_LINK
				if(sa->sa_family == AF_LINK) {
					struct sockaddr_dl * sdl = (struct sockaddr_dl *)sa;
					memset(ifname, 0, sizeof(ifname));
					memcpy(ifname, sdl->sdl_data, sdl->sdl_nlen);
				}
#endif
				break;
			case RTA_IFA:
				family = sa->sa_family;
				if(sa->sa_family == AF_INET) {
					inet_ntop(sa->sa_family,
					          &((struct sockaddr_in *)sa)->sin_addr,
					          address, sizeof(address));
				} else if(sa->sa_family == AF_INET6) {
					inet_ntop(sa->sa_family,
					          &((struct sockaddr_in6 *)sa)->sin6_addr,
					          address, sizeof(address));
				}
				break;
			case RTA_AUTHOR:
				break;
			case RTA_BRD:
				break;
			}
#if 0
			syslog(LOG_DEBUG, " %d.%d.%d.%d %02x%02x%02x%02x",
			       (uint8_t)p[0], (uint8_t)p[1], (uint8_t)p[2], (uint8_t)p[3],
			       (uint8_t)p[0], (uint8_t)p[1], (uint8_t)p[2], (uint8_t)p[3]); 
			syslog(LOG_DEBUG, " %d.%d.%d.%d %02x%02x%02x%02x",
			       (uint8_t)p[4], (uint8_t)p[5], (uint8_t)p[6], (uint8_t)p[7],
			       (uint8_t)p[4], (uint8_t)p[5], (uint8_t)p[6], (uint8_t)p[7]); 
#endif
			p += SA_RLEN(sa);
			addr = addr << 1;
		}
		syslog(LOG_INFO, "%s: %s/%d %s",
		       is_del ? "RTM_DELADDR" : "RTM_NEWADDR",
		       address, prefixlen, ifname);
		for(lan_addr = lan_addrs.lh_first; lan_addr != NULL; lan_addr = lan_addr->list.le_next) {
#ifdef ENABLE_IPV6
			if((0 == strcmp(address, lan_addr->str)) ||
			   (0 == strcmp(ifname, lan_addr->ifname)) ||
			   (ifam->ifam_index == lan_addr->index)) {
#else
			if((0 == strcmp(address, lan_addr->str)) ||
			   (0 == strcmp(ifname, lan_addr->ifname))) {
#endif
				if(family == AF_INET)
					AddDropMulticastMembership(s_ssdp, lan_addr, 0, is_del);
#ifdef ENABLE_IPV6
				else if(family == AF_INET6)
					AddDropMulticastMembership(s_ssdp6, lan_addr, 1, is_del);
#endif
				break;
			}
		}
		break;
	default:
		syslog(LOG_DEBUG, "Unknown RTM message : rtm->rtm_type=%d len=%d",
		       rtm->rtm_type, (int)len);
	}
#endif
	return 0;
}

