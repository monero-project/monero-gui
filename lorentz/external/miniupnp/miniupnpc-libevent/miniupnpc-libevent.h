/* $Id: miniupnpc-libevent.h,v 1.13 2015/07/22 13:48:37 nanard Exp $ */
/* miniupnpc-libevent
 * Copyright (c) 2008-2015, Thomas BERNARD <miniupnp@free.fr>
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
#ifndef MINIUPNPC_LIBEVENT_H_INCLUDED
#define MINIUPNPC_LIBEVENT_H_INCLUDED

#include <event2/event.h>

#include "declspec.h"
#include "upnpreplyparse.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MINIUPNPC_LIBEVENT_API_VERSION 1

#define UPNPC_OK 0
#define UPNPC_ERR_INVALID_ARGS (-1)
#define UPNPC_ERR_SOCKET_FAILED (-2)
#define UPNPC_ERR_BIND_FAILED (-3)
#define UPNPC_ERR_REQ_IN_PROGRESS (-4)

#define UPNPC_ERR_NO_DEVICE_FOUND (-100)
#define UPNPC_ERR_ROOT_DESC_ERROR (-101)
#define UPNPC_ERR_NOT_IGD         (-102)
#define UPNPC_ERR_NOT_CONNECTED   (-103)

/* device->state masks */
#define UPNPC_DEVICE_SOAP_REQ  (0x0001)
#define UPNPC_DEVICE_GETSTATUS (0x0002)
#define UPNPC_DEVICE_CONNECTED (0x4000)
#define UPNPC_DEVICE_READY     (0x8000)

typedef struct upnpc_device upnpc_device_t;
typedef struct upnpc upnpc_t;

typedef void(* upnpc_callback_fn)(int, upnpc_t *, upnpc_device_t *, void *);
#ifdef ENABLE_UPNP_EVENTS
typedef void(* upnpc_event_callback_fn)(upnpc_t *, upnpc_device_t *, void *, const char *, const char *, const char *);
#endif /* ENABLE_UPNP_EVENTS */

struct upnpc_device {
	upnpc_t * parent;
	upnpc_device_t * next;
	char * root_desc_location;
	struct evhttp_connection * desc_conn;
	char * control_cif_url;
	char * event_cif_url;
	char * cif_service_type;
	char * control_conn_url;
	char * event_conn_url;
	char * conn_service_type;
	struct evhttp_connection * soap_conn;
	struct NameValueParserData soap_response_data;
	unsigned int state;
#ifdef ENABLE_UPNP_EVENTS
	char * event_conn_sid;
#endif /* ENABLE_UPNP_EVENTS */
};

struct upnpc {
	struct event_base * base;
	evutil_socket_t ssdp_socket;
	struct event * ev_ssdp_recv;
	struct event * ev_ssdp_writable;
	int discover_device_index;
	upnpc_device_t * devices;
	upnpc_callback_fn ready_cb;
	upnpc_callback_fn soap_cb;
	void * cb_data;
#ifdef ENABLE_UPNP_EVENTS
	struct evhttp * http_server;
	upnpc_event_callback_fn value_changed_cb;
#endif /* ENABLE_UPNP_EVENTS */
	char * local_address;
	uint16_t local_port;
	unsigned char ttl;
};

int upnpc_init(upnpc_t * p, struct event_base * base, const char * multicastif,
               upnpc_callback_fn ready_cb, upnpc_callback_fn soap_cb, void * cb_data);

int upnpc_set_local_address(upnpc_t * p, const char * address, uint16_t port);

#ifdef ENABLE_UPNP_EVENTS
int upnpc_set_event_callback(upnpc_t * p, upnpc_event_callback_fn cb);
#endif /* ENABLE_UPNP_EVENTS */

int upnpc_start(upnpc_t * p);

int upnpc_finalize(upnpc_t * p);

#ifdef ENABLE_UPNP_EVENTS
int upnpc_event_subscribe(upnpc_device_t * p);
#endif /* ENABLE_UPNP_EVENTS */

int upnpc_get_external_ip_address(upnpc_device_t * p);

int upnpc_get_link_layer_max_rate(upnpc_device_t * p);

int upnpc_add_port_mapping(upnpc_device_t * p,
                           const char * remote_host, unsigned short ext_port,
                           unsigned short int_port, const char * int_client,
                           const char * proto, const char * description,
                           unsigned int lease_duration);

int upnpc_delete_port_mapping(upnpc_device_t * p,
                              const char * remote_host, unsigned short ext_port,
                              const char * proto);

int upnpc_get_status_info(upnpc_device_t * p);

#ifdef __cplusplus
}
#endif

#endif /* MINIUPNPC_LIBEVENT_H_INCLUDED */

