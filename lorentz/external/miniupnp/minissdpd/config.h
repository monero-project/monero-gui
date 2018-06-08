/* $Id: config.h,v 1.10 2018/02/23 13:58:14 nanard Exp $ */
/*  MiniUPnP project
 * http://miniupnp.free.fr/ or http://miniupnp.tuxfamily.org/
 * (c) 2006-2018 Thomas Bernard
 * This software is subject to the conditions detailed
 * in the LICENCE file provided within the distribution */
#ifndef CONFIG_H_INCLUDED
#define CONFIG_H_INCLUDED

#define MINISSDPD_VERSION "1.5"

/* use BSD daemon() ? */
#define USE_DAEMON

/* set the syslog facility to use. See man syslog(3) and syslog.conf(5). */
#define LOG_MINISSDPD	LOG_DAEMON

/* enable IPv6 */
#define ENABLE_IPV6

/* The size of unix socket response buffer */
#define RESPONSE_BUFFER_SIZE (1024 * 4)

/* Uncomment the following line in order to make minissdpd
 * listen on 1.2.3.4:1900 instead of *:1900
 * FOR TESTING PURPOSE ONLY
 * Note : it prevents multicast packets to be received,
 *        at least with linux
 * As miniSSDPd needs to receive SSDP packets both multicasted
 * and unicasted, we cannot bind to 239.255.255.250 neither */
/*#define SSDP_LISTEN_ON_SPECIFIC_ADDR*/

#endif
