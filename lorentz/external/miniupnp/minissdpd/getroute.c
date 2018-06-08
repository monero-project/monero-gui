/* $Id: getroute.c,v 1.4 2014/12/01 09:07:17 nanard Exp $ */
/* MiniUPnP project
 * http://miniupnp.free.fr/ or http://miniupnp.tuxfamily.org/
 * (c) 2006-2014 Thomas Bernard
 * This software is subject to the conditions detailed
 * in the LICENCE file provided within the distribution */

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <syslog.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#ifdef __linux__
/*#include <linux/in_route.h>*/
#include <linux/netlink.h>
#include <linux/rtnetlink.h>
#include <libnfnetlink/libnfnetlink.h>
#else /* __linux__ */
#include <net/if.h>
#include <net/route.h>
#include <netinet/in.h>
#ifdef AF_LINK
#include <net/if_dl.h>
#endif /* AF_LINK */
#endif /* __linux__ */

#include "getroute.h"
#include "upnputils.h"
#include "config.h"

/* get_src_for_route_to() function is only called in code
 * enabled with ENABLE_IPV6 */
#ifdef ENABLE_IPV6

int
get_src_for_route_to(const struct sockaddr * dst,
                     void * src, size_t * src_len,
                     int * index)
{
#if __linux__
	int fd = -1;
	struct nlmsghdr *h;
	int status;
	struct {
		struct nlmsghdr n;
		struct rtmsg r;
		char buf[1024];
	} req;
	struct sockaddr_nl nladdr;
	struct iovec iov = {
		.iov_base = (void*) &req.n,
	};
	struct msghdr msg = {
		.msg_name = &nladdr,
		.msg_namelen = sizeof(nladdr),
		.msg_iov = &iov,
		.msg_iovlen = 1,
	};
	const struct sockaddr_in * dst4;
	const struct sockaddr_in6 * dst6;

	memset(&req, 0, sizeof(req));
	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtmsg));
	req.n.nlmsg_flags = NLM_F_REQUEST;
	req.n.nlmsg_type = RTM_GETROUTE;
	req.r.rtm_family = dst->sa_family;
	req.r.rtm_table = 0;
	req.r.rtm_protocol = 0;
	req.r.rtm_scope = 0;
	req.r.rtm_type = 0;
	req.r.rtm_src_len = 0;
	req.r.rtm_dst_len = 0;
	req.r.rtm_tos = 0;

	{
		char dst_str[128];
		sockaddr_to_string(dst, dst_str, sizeof(dst_str));
		syslog(LOG_DEBUG, "get_src_for_route_to (%s)", dst_str);
	}
	/* add address */
	if(dst->sa_family == AF_INET) {
		dst4 = (const struct sockaddr_in *)dst;
		nfnl_addattr_l(&req.n, sizeof(req), RTA_DST, &dst4->sin_addr, 4);
		req.r.rtm_dst_len = 32;
	} else {
		dst6 = (const struct sockaddr_in6 *)dst;
		nfnl_addattr_l(&req.n, sizeof(req), RTA_DST, &dst6->sin6_addr, 16);
		req.r.rtm_dst_len = 128;
	}

	fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
	if (fd < 0) {
		syslog(LOG_ERR, "socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE) : %m");
		return -1;
	}

	memset(&nladdr, 0, sizeof(nladdr));
	nladdr.nl_family = AF_NETLINK;

	req.n.nlmsg_seq = 1;
	iov.iov_len = req.n.nlmsg_len;

	status = sendmsg(fd, &msg, 0);

	if (status < 0) {
		syslog(LOG_ERR, "sendmsg(rtnetlink) : %m");
		goto error;
	}

	memset(&req, 0, sizeof(req));

	for(;;) {
		iov.iov_len = sizeof(req);
		status = recvmsg(fd, &msg, 0);
		if(status < 0) {
			if (errno == EINTR || errno == EAGAIN)
				continue;
			syslog(LOG_ERR, "recvmsg(rtnetlink) %m");
			goto error;
		}
		if(status == 0) {
			syslog(LOG_ERR, "recvmsg(rtnetlink) EOF");
			goto error;
		}
		for (h = (struct nlmsghdr*)&req.n; status >= (int)sizeof(*h); ) {
			int len = h->nlmsg_len;
			int l = len - sizeof(*h);

			if (l<0 || len>status) {
				if (msg.msg_flags & MSG_TRUNC) {
					syslog(LOG_ERR, "Truncated message");
				}
				syslog(LOG_ERR, "malformed message: len=%d", len);
				goto error;
			}

			if(nladdr.nl_pid != 0 || h->nlmsg_seq != 1/*seq*/) {
				syslog(LOG_ERR, "wrong seq = %d\n", h->nlmsg_seq);
				/* Don't forget to skip that message. */
				status -= NLMSG_ALIGN(len);
				h = (struct nlmsghdr*)((char*)h + NLMSG_ALIGN(len));
				continue;
			}

			if(h->nlmsg_type == NLMSG_ERROR) {
				struct nlmsgerr *err = (struct nlmsgerr*)NLMSG_DATA(h);
				syslog(LOG_ERR, "NLMSG_ERROR %d : %s", err->error, strerror(-err->error));
				goto error;
			}
			if(h->nlmsg_type == RTM_NEWROUTE) {
				struct rtattr * rta;
				int len = h->nlmsg_len;
				len -= NLMSG_LENGTH(sizeof(struct rtmsg));
				for(rta = RTM_RTA(NLMSG_DATA((h))); RTA_OK(rta, len); rta = RTA_NEXT(rta,len)) {
					unsigned char * data = RTA_DATA(rta);
					if(rta->rta_type == RTA_PREFSRC) {
						if(src_len && src) {
							if(*src_len < RTA_PAYLOAD(rta)) {
								syslog(LOG_WARNING, "cannot copy src: %u<%lu",
								       (unsigned)*src_len, (unsigned long)RTA_PAYLOAD(rta));
								goto error;
							}
							*src_len = RTA_PAYLOAD(rta);
							memcpy(src, data, RTA_PAYLOAD(rta));
						}
					} else if(rta->rta_type == RTA_OIF) {
						if(index)
							memcpy(index, data, sizeof(int));
					}
				}
				close(fd);
				return 0;
			}
			status -= NLMSG_ALIGN(len);
			h = (struct nlmsghdr*)((char*)h + NLMSG_ALIGN(len));
		}
	}
	syslog(LOG_WARNING, "get_src_for_route_to() : src not found");
error:
	if(fd >= 0)
		close(fd);
	return -1;
#else /* __linux__ */
	int found = 0;
	int s;
	int l, i;
	char * p;
	struct sockaddr * sa;
	struct {
	  struct rt_msghdr m_rtm;
	  char       m_space[512];
	} m_rtmsg;
#define rtm m_rtmsg.m_rtm

	if(dst == NULL)
		return -1;
#ifdef __APPLE__
	if(dst->sa_family == AF_INET6) {
		syslog(LOG_ERR, "Sorry, get_src_for_route_to() is known to fail with IPV6 on OS X...");
		return -1;
	}
#endif
	s = socket(PF_ROUTE, SOCK_RAW, dst->sa_family);
	if(s < 0) {
		syslog(LOG_ERR, "socket(PF_ROUTE) failed : %m");
		return -1;
	}
	memset(&rtm, 0, sizeof(rtm));
	rtm.rtm_type = RTM_GET;
	rtm.rtm_flags = RTF_UP;
	rtm.rtm_version = RTM_VERSION;
	rtm.rtm_seq = 1;
	rtm.rtm_addrs = RTA_DST;	/* destination address */
	memcpy(m_rtmsg.m_space, dst, sizeof(struct sockaddr));
	rtm.rtm_msglen = sizeof(struct rt_msghdr) + sizeof(struct sockaddr);
	if(write(s, &m_rtmsg, rtm.rtm_msglen) < 0) {
		syslog(LOG_ERR, "write: %m");
		close(s);
		return -1;
	}

	do {
		l = read(s, &m_rtmsg, sizeof(m_rtmsg));
		if(l<0) {
			syslog(LOG_ERR, "read: %m");
			close(s);
			return -1;
		}
		syslog(LOG_DEBUG, "read l=%d seq=%d pid=%d",
		       l, rtm.rtm_seq, rtm.rtm_pid);
	} while(l > 0 && (rtm.rtm_pid != getpid() || rtm.rtm_seq != 1));
	close(s);
	p = m_rtmsg.m_space;
	if(rtm.rtm_addrs) {
		for(i=1; i<0x8000; i <<= 1) {
			if(i & rtm.rtm_addrs) {
				char tmp[256] = { 0 };
				sa = (struct sockaddr *)p;
				sockaddr_to_string(sa, tmp, sizeof(tmp));
				syslog(LOG_DEBUG, "type=%d sa_len=%d sa_family=%d %s",
				       i, SA_LEN(sa), sa->sa_family, tmp);
				if((i == RTA_DST || i == RTA_GATEWAY) &&
				   (src_len && src)) {
					size_t len = 0;
					void * paddr = NULL;
					if(sa->sa_family == AF_INET) {
						paddr = &((struct sockaddr_in *)sa)->sin_addr;
						len = sizeof(struct in_addr);
					} else if(sa->sa_family == AF_INET6) {
						paddr = &((struct sockaddr_in6 *)sa)->sin6_addr;
						len = sizeof(struct in6_addr);
					}
					if(paddr) {
						if(*src_len < len) {
							syslog(LOG_WARNING, "cannot copy src. %u<%u",
							       (unsigned)*src_len, (unsigned)len);
							return -1;
						}
						memcpy(src, paddr, len);
						*src_len = len;
						found = 1;
					}
				}
#ifdef AF_LINK
				if(sa->sa_family == AF_LINK) {
					struct sockaddr_dl * sdl = (struct sockaddr_dl *)sa;
					if(index)
						*index = sdl->sdl_index;
				}
#endif
				p += SA_LEN(sa);
			}
		}
	}
	return found ? 0 : -1;
#endif /* __linux__ */
}

#endif /* ENABLE_IPV6 */
