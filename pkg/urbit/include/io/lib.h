#ifndef IO_LIB_H
#define IO_LIB_H

#include "vere/vere.h"


//==============================================================================
// client.rs
//==============================================================================

typedef struct {
  u3_auto driver_u;
  void*   runtime_v;
  c3_w    instance_num_w;
} HttpClient;

typedef struct {
  c3_c* key_c; //!< header key
  c3_c* val_c; //!< header value
} HttpHeader;

typedef struct {
  c3_c* body_c; //!< body
} HttpBody;

typedef struct {
  c3_l        req_num_l;     //!< Request number.
  c3_c*       domain_c;      //!< Destination domain name. If NULL, `ip_w`
                             //!< should be used. If not NULL, `ip_w` is 0.
  c3_w        ip_w;          //!< Destination IP address. Zero if `domain_c`
                             //!< is not NULL.
  c3_s        port_s;        //!< Destination port number.
  c3_t        use_tls_t;     //!< Whether to use TLS.
  c3_c*       url_c;         //!< Destination URL.
  c3_c*       method_c;      //!< HTTP request method.
  HttpHeader* headers_u;     //!< HTTP request headers.
  c3_w        headers_len_w; //!< Number of HTTP request headers.
  HttpBody    body_u;        //!< HTTP request body.
} HttpRequest;

HttpClient*
http_client_init(c3_w instance_num_w);

//! Schedule an HTTP request to be sent asynchronously, invoking the callback
//! provided to http_client_init() when the response is received.
//!
//! @param[in] client_u   HTTP client handle. Must NOT be NULL.
//! @param[in] req_u      HTTP request to schedule. Must NOT be NULL.
//!
//! @return 0  Request could not be scheduled.
//! @return 1  Request was successfully scheduled.
c3_t
http_schedule_request(HttpClient* const        client_u,
                      const HttpRequest* const req_u);

void
http_client_deinit(HttpClient* client_u);

#endif /* ifndef IO_LIB_H */
