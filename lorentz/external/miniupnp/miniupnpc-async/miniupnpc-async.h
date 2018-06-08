/* $Id: miniupnpc-async.h,v 1.13 2014/11/07 11:25:52 nanard Exp $ */
/* miniupnpc-async
 * Copyright (c) 2008-2017, Thomas BERNARD <miniupnp@free.fr>
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
#ifndef MINIUPNPC_ASYNC_H_INCLUDED
#define MINIUPNPC_ASYNC_H_INCLUDED

/* for struct sockaddr_storage */
#include <netinet/in.h>
/* for fd_set */
#include <sys/select.h>

#include "declspec.h"
#include "upnpreplyparse.h"

#ifdef __cplusplus
extern "C" {
#endif

#define UPNPC_OK 0
#define UPNPC_ERR_INVALID_ARGS (-1)
#define UPNPC_ERR_SOCKET_FAILED (-2)
#define UPNPC_ERR_BIND_FAILED (-3)
#define UPNPC_ERR_UNKNOWN_STATE (-4)

#define UPNPC_SSDP_READABLE  0x0001
#define UPNPC_SSDP_WRITEABLE 0x0100
#define UPNPC_HTTP_READABLE  0x0002
#define UPNPC_HTTP_WRITEABLE 0x0200

typedef struct upnpc_device {
	struct upnpc_device * next;
	enum {
		EDevInit = 1,
		EDevGetDescConnect,
		EDevGetDescRequest,
		EDevGetDescResponse,
		EDevReady,
		EDevSoapConnect,
		EDevSoapRequest,
		EDevSoapResponse,
		EDevFinalized = 99,
		EDevError = 1000
	} state;
	char * root_desc_location;
	char * control_cif_url;
	char * control_conn_url;
	int http_socket;
	int socket_flags;	/* see UPNPC_*_READABLE, etc. */
	char * http_request;
	int http_request_len;
	int http_request_sent;
	char * http_response;
	int http_response_received;
	int http_response_end_of_headers;
	int http_response_content_length;
	int http_response_chunked;
	int http_response_code;
	struct NameValueParserData soap_response_data;
	struct sockaddr_storage selfaddr;
	socklen_t selfaddrlen;
} upnpc_device_t;

typedef struct {
	enum {
		EUPnPInit = 1,
		EUPnPSendSSDP,
		EUPnPReceiveSSDP,
		EUPnPGetDesc,
		EUPnPReady,
		EUPnPProcessing,
		EUPnPFinalized = 99,
		EUPnPError = 1000
	} state;
	int socket_flags;	/* see UPNPC_*_READABLE, etc. */
	int ssdp_socket;
	upnpc_device_t * device_list;
} upnpc_t;

int upnpc_init(upnpc_t * p, const char * multicastif);

int upnpc_finalize(upnpc_t * p);

int upnpc_get_external_ip_address(upnpc_device_t * p);

int upnpc_get_link_layer_max_rate(upnpc_device_t * p);

int upnpc_add_port_mapping(upnpc_device_t * p,
                           const char * remote_host, unsigned short ext_port,
                           unsigned short int_port, const char * int_client,
                           const char * proto, const char * description,
                           unsigned int lease_duration);

#ifdef UPNPC_USE_SELECT
int upnpc_select_fds(upnpc_t * p, int * nfds, fd_set * readfds, fd_set * writefds);
void upnpc_check_select_fds(upnpc_t * p, const fd_set * readfds, const fd_set * writefds);
#endif /* UPNPC_USE_SELECT */

int upnpc_process(upnpc_t * p);

#ifdef __cplusplus
}
#endif

#endif /* MINIUPNPC_ASYNC_H_INCLUDED */

