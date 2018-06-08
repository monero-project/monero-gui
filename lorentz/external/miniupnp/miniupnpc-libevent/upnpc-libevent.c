/* $Id: upnpc-libevent.c,v 1.11 2014/12/02 13:33:42 nanard Exp $ */
/* miniupnpc-libevent
 * Copyright (c) 2008-2014, Thomas BERNARD <miniupnp@free.fr>
 * http://miniupnp.free.fr/ or http://miniupnp.tuxfamily.org/
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

#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "miniupnpc-libevent.h"

static struct event_base *base = NULL;
static char local_address[32];

static void sighandler(int signal)
{
	(void)signal;
	/*printf("signal %d\n", signal);*/
	if(base != NULL)
		event_base_loopbreak(base);
}

/* ready callback */
static void ready(int code, upnpc_t * p, upnpc_device_t * d, void * data)
{
	(void)data; (void)p;

	if(code == 200) {
		printf("READY ! %d\n", code);
		printf("  root_desc_location='%s'\n", d->root_desc_location);
		/* 1st request */
#ifdef ENABLE_UPNP_EVENTS
		upnpc_event_subscribe(d);
#else
		upnpc_get_status_info(d);
#endif /* ENABLE_UPNP_EVENTS */
	} else {
		printf("DISCOVER ERROR : %d\n", code);
		switch(code) {
		case UPNPC_ERR_NO_DEVICE_FOUND:
			printf("UPNPC_ERR_NO_DEVICE_FOUND\n");
			break;
		case UPNPC_ERR_ROOT_DESC_ERROR:
			printf("UPNPC_ERR_ROOT_DESC_ERROR\n");
			break;
		case 404:
			printf("Root desc not found (404)\n");
			break;
		default:
			printf("unknown error\n");
		}
	}
}

static enum {
	EGetStatusInfo = 0,
	EGetExtIp,
	EGetMaxRate,
	EAddPortMapping,
	EDeletePortMapping,
	EFinished
	} state = EGetStatusInfo;

/* soap callback */
static void soap(int code, upnpc_t * p, upnpc_device_t * d, void * data)
{
	(void)data; (void)p;

	printf("SOAP ! %d\n", code);
	if(code == 200) {
		switch(state) {
		case EGetStatusInfo:
			printf("ConnectionStatus=%s\n", GetValueFromNameValueList(&d->soap_response_data, "NewConnectionStatus"));
			printf("LastConnectionError=%s\n", GetValueFromNameValueList(&d->soap_response_data, "NewLastConnectionError"));
			printf("Uptime=%s\n", GetValueFromNameValueList(&d->soap_response_data, "NewUptime"));
			upnpc_get_external_ip_address(d);
			state = EGetExtIp;
			break;
		case EGetExtIp:
			printf("ExternalIpAddress=%s\n", GetValueFromNameValueList(&d->soap_response_data, "NewExternalIPAddress"));
			upnpc_get_link_layer_max_rate(d);
			state = EGetMaxRate;
			break;
		case EGetMaxRate:
			printf("DownStream MaxBitRate = %s\t", GetValueFromNameValueList(&d->soap_response_data, "NewLayer1DownstreamMaxBitRate"));
			upnpc_add_port_mapping(d, NULL, 60001, 60002, local_address, "TCP", "test port mapping", 0);
			printf("UpStream MaxBitRate = %s\n", GetValueFromNameValueList(&d->soap_response_data, "NewLayer1UpstreamMaxBitRate"));
			state = EAddPortMapping;
			break;
		case EAddPortMapping:
			printf("AddPortMapping OK!\n");
			upnpc_delete_port_mapping(d, NULL, 60001, "TCP");
			state = EDeletePortMapping;
			break;
		case EDeletePortMapping:
			printf("DeletePortMapping OK!\n");
			state = EFinished;
			break;
		default:
			printf("EFinished : breaking\n");
			event_base_loopbreak(base);
		}
	} else {
		printf("SOAP error :\n");
		printf("  faultcode='%s'\n", GetValueFromNameValueList(&d->soap_response_data, "faultcode"));
		printf("  faultstring='%s'\n", GetValueFromNameValueList(&d->soap_response_data, "faultstring"));
		printf("  errorCode=%s\n", GetValueFromNameValueList(&d->soap_response_data, "errorCode"));
		printf("  errorDescription='%s'\n", GetValueFromNameValueList(&d->soap_response_data, "errorDescription"));
		event_base_loopbreak(base);
	}
}

#ifdef ENABLE_UPNP_EVENTS
/* event callback */
static void event_callback(upnpc_t * p, upnpc_device_t * d, void * data,
                           const char * service_id, const char * property_name, const char * property_value)
{
	(void)p; (void)d; (void)data;
	printf("PROPERTY VALUE CHANGE (service=%s): %s=%s\n", service_id, property_name, property_value);
}
#endif /* ENABLE_UPNP_EVENTS */

/* use a UDP "connection" to 8.8.8.8
 * to retrieve local address */
int find_local_address(void)
{
	int s;
	struct sockaddr_in local, remote;
	socklen_t len;

	s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if(s < 0) {
		perror("socket");
		return -1;
	}

	memset(&local, 0, sizeof(local));
	memset(&remote, 0, sizeof(remote));
	/* bind to local port 4567 */
	local.sin_family = AF_INET;
	local.sin_port = htons(4567);
	local.sin_addr.s_addr = htonl(INADDR_ANY);
	if(bind(s, (struct sockaddr *)&local, sizeof(local)) < 0) {
		perror("bind");
		return -1;
	}
	/* "connect" google's DNS server at 8.8.8.8 port 4567 */
	remote.sin_family = AF_INET;
	remote.sin_port = htons(4567);
	remote.sin_addr.s_addr = inet_addr("8.8.8.8");
	if(connect(s, (struct sockaddr *)&remote, sizeof(remote)) < 0) {
		perror("connect");
		return -1;
	}
	len = sizeof(local);
	if(getsockname(s, (struct sockaddr *)&local, &len) < 0) {
		perror("getsockname");
		return -1;
	}
	if(inet_ntop(AF_INET, &(local.sin_addr), local_address, sizeof(local_address)) == NULL) {
		perror("inet_ntop");
		return -1;
	}
	printf("local address : %s\n", local_address);
	close(s);
	return 0;
}

/* program entry point */

int main(int argc, char * * argv)
{
	struct sigaction sa;
	upnpc_t upnp;
	char * multicast_if = NULL;

	if(argc > 1) {
		multicast_if = argv[1];
	}

	memset(&sa, 0, sizeof(struct sigaction));
	sa.sa_handler = sighandler;
	if(sigaction(SIGINT, &sa, NULL) < 0) {
		perror("sigaction");
	}

	if(find_local_address() < 0) {
		fprintf(stderr, "failed to get local address\n");
		return 1;
	}
#ifdef DEBUG
	event_enable_debug_mode();
#if LIBEVENT_VERSION_NUMBER >= 0x02010100
	event_enable_debug_logging(EVENT_DBG_ALL);	/* Libevent 2.1.1 */
#endif /* LIBEVENT_VERSION_NUMBER >= 0x02010100 */
#endif /* DEBUG */
	printf("Using libevent %s\n", event_get_version());
	if(LIBEVENT_VERSION_NUMBER != event_get_version_number()) {
		fprintf(stderr, "WARNING build using libevent %s", LIBEVENT_VERSION);
	}

	base = event_base_new();
	if(base == NULL) {
		fprintf(stderr, "event_base_new() failed\n");
		return 1;
	}
#ifdef DEBUG
	printf("Using Libevent with backend method %s.\n",
        event_base_get_method(base));
#endif /* DEBUG */

	if(upnpc_init(&upnp, base, multicast_if, ready, soap, &upnp) != UPNPC_OK) {
		fprintf(stderr, "upnpc_init() failed\n");
		return 1;
	}
	upnpc_set_local_address(&upnp, local_address, 50000);
#ifdef ENABLE_UPNP_EVENTS
	upnpc_set_event_callback(&upnp, event_callback);
#endif /* ENABLE_UPNP_EVENTS */
	if(upnpc_start(&upnp) != UPNPC_OK) {
		fprintf(stderr, "upnp_start() failed\n");
		return 1;
	}

	event_base_dispatch(base);	/* TODO : check return value */
	printf("finishing...\n");

	upnpc_finalize(&upnp);
	event_base_free(base);

#if LIBEVENT_VERSION_NUMBER >= 0x02010100
	libevent_global_shutdown();	/* Libevent 2.1.1 */
#endif
	return 0;
}

