/* $Id: openssdpsocket.h,v 1.7 2015/07/21 15:39:38 nanard Exp $ */
/* MiniUPnP project
 * http://miniupnp.free.fr/ or http://miniupnp.tuxfamily.org/
 * (c) 2006-2015 Thomas Bernard
 * This software is subject to the conditions detailed
 * in the LICENCE file provided within the distribution */
#ifndef OPENSSDPSOCKET_H_INCLUDED
#define OPENSSDPSOCKET_H_INCLUDED

#include "minissdpdtypes.h"

/**
 * Open a socket and configure it for receiving SSDP packets
 *
 * @param ipv6	open INET6 or INET socket
 * @param ttl	multicast TTL
 * @return socket
 */
int
OpenAndConfSSDPReceiveSocket(int ipv6, unsigned char ttl);

/**
 * Add or Drop the multicast membership for SSDP on the interface
 * @param s	the socket
 * @param lan_addr	the LAN address or interface name
 * @param ipv6	IPv6 or IPv4
 * @param drop	0 to add, 1 to drop
 * return -1 on error, 0 on success */
int
AddDropMulticastMembership(int s, struct lan_addr_s * lan_addr, int ipv6, int drop);

#endif

