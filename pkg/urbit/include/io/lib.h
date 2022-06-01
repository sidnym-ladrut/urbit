#ifndef IO_LIB_H
#define IO_LIB_H

#include "vere/vere.h"

// See io/src/lib.rs.
typedef struct {
  c3_c* zero_c;
  c3_c* one_c;
} StrPair;

//! Opaque HTTP client type defined in io/src/http/client.rs. It's guaranteed
//! that there is enough space for an instance of u3_auto at the very beginning
//! of this type. No other guarantees about this type are made.
struct Client;
typedef struct Client Client;

Client*
http_client_init(const c3_w instance_num_w);

// TODO
c3_w
http_client_instance_num(const Client* const client_u);

//! Schedule an HTTP request to be sent asynchronously, invoking the callback
//! provided to http_client_init() when the response is received.
//!
//! @param[in] client_u       HTTP client handle. Must NOT be NULL.
//! @param[in] req_num_l      Request number.
//! @param[in] domain_c       Destination domain name. If NULL, `ip_w` should be
//!                           used. If not NULL, `ip_w` is 0.
//! @param[in] ip_w           Destination IP address. Zero if `domain_c` is not
//!                           NULL.
//! @param[in] port_s         Destination port number.
//! @param[in] use_tls_t      Whether to use TLS.
//! @param[in] url_c;         Destination URL.
//! @param[in] method_c;      HTTP request method.
//! @param[in] headers_u;     HTTP request headers.
//! @param[in] headers_len_w  Number of HTTP request headers.
//! @param[in] body_u;        HTTP request body.
//!
//! @return 0  Request could not be scheduled.
//! @return 1  Request was successfully scheduled.
c3_t
http_schedule_request(Client* const            client_u,
                      const c3_l               req_num_l,
                      const c3_c* const        domain_c,
                      const c3_w               ip_w,
                      const c3_s               port_s,
                      const c3_t               use_tls_t,
                      const c3_c* const        url_c,
                      const c3_c* const        method_c,
                      const StrPair* const     headers_u,
                      const c3_w               headers_len_w,
                      const c3_c* const        body_c,
                      void                   (*receiver_f)(void));

void
http_client_deinit(Client* client_u);

#endif /* ifndef IO_LIB_H */
