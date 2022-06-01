//! @file client.c
//! HTTP client.

#include "c/portable.h"
#include "c/types.h"
#include "io/lib.h"
#include "vere/vere.h"

//==============================================================================
// Types
//==============================================================================

typedef struct {
  c3_l     req_num_l;
  c3_t     use_tls_t;
  c3_c*    domain_c;      // free if not NULL
  c3_w     ip_w;
  c3_s     port_s;
  c3_c*    method_c;      // free if not NULL
  c3_c*    url_c;         // free if not NULL
  StrPair* headers_u;     // free if not NULL
  c3_w     headers_len_w;
  c3_c*    body_c;        // free if not NULL
} _request;

//==============================================================================
// Static functions
//==============================================================================

//! TODO
static c3_w
_mcut_url(c3_c* const buf_c, c3_w len_w, u3_noun pul)
{
  u3_noun q_pul = u3h(u3t(pul));
  u3_noun r_pul = u3t(u3t(pul));

  len_w = u3_mcut_char(buf_c, len_w, '/');
  // Measure/cut path/extension.
  {
    u3_noun pok = u3k(q_pul);
    u3_noun h_pok = u3h(pok);
    u3_noun t_pok = u3t(pok);

    len_w = u3_mcut_path(buf_c, len_w, '/', u3k(t_pok));
    if ( u3_nul != h_pok ) {
      len_w = u3_mcut_char(buf_c, len_w, '.');
      len_w = u3_mcut_cord(buf_c, len_w, u3k(u3t(h_pok)));
    }
    u3z(pok);
  }

  // Measure/cut query.
  if ( u3_nul != r_pul ) {
    u3_noun quy = u3k(r_pul);
    u3_noun yuq = quy;
    c3_o  fir_o = c3y;

    while ( u3_nul != quy ) {
      if ( c3y == fir_o ) {
        len_w = u3_mcut_char(buf_c, len_w, '?');
        fir_o = c3n;
      }
      else {
        len_w = u3_mcut_char(buf_c, len_w, '&');
      }

      u3_noun i_quy, t_quy;
      u3_noun pi_quy, qi_quy;
      u3x_cell(quy, &i_quy, &t_quy);
      u3x_cell(i_quy, &pi_quy, &qi_quy);

      len_w = u3_mcut_cord(buf_c, len_w, u3k(pi_quy));
      len_w = u3_mcut_char(buf_c, len_w, '=');
      len_w = u3_mcut_cord(buf_c, len_w, u3k(qi_quy));

      quy = t_quy;
    }

    u3z(yuq);
  }

  u3z(pul);
  return len_w;
}

//! Transform an outgoing %http-request from a noun into a byte array.
//!
//! @param[in]  data       HTTP request as a noun.
//! @param[out] req_u      Pointer to request.
//!
//! @return NULL
//! @return serialized request.
static c3_t
_parse_request(u3_noun data, _request* req_u)
{
  c3_t suc_t = 0;

  if ( !req_u ) {
    goto end;
  }

  u3_noun req;
  {
    u3_noun num;
    if ( c3n == u3r_cell(data, &num, &req)
         || c3n == u3r_safe_word(num, &req_u->req_num_l) )
    {
      u3l_log("http-client: unable to parse request\n");
      goto end;
    }
  }

  u3_noun method, url, headers, body;
  if ( c3n == u3r_qual(req, &method, &url, &headers, &body) ) {
    u3l_log("http-client: unable parse request\n");
    goto end;
  }

  u3_noun pul, port, host;
  {
    // Parse the URL out of the new style URL passed to us.
    u3_noun unit_pul = u3do("de-purl:html", u3k(url));
    if ( c3n == u3a_is_cell(unit_pul) ) {
      c3_c* url_c = u3r_string(url);
      u3l_log("http-client: unable to parse url:\n    %s\n", url_c);
      c3_free(url_c);
      goto end;
    }

    pul              = u3t(unit_pul);
    u3_noun hart     = u3h(pul);
    req_u->use_tls_t = u3h(hart) == c3y ? 1 : 0;
    port             = u3h(u3t(hart));
    host             = u3t(u3t(hart));
  }

  // Extract host (either name or IP).
  if ( c3y == u3h(host) ) {
    // Parse u3t(host) into domain name.
    c3_w len_w      = u3_mcut_host(NULL, 0, u3k(u3t(host)));
    req_u->domain_c = c3_calloc(len_w + 1);
    u3_mcut_host(req_u->domain_c, 0, u3t(host));
    req_u->ip_w = 0;
  }
  else {
    // Parse u3t(host) into IP address.
    req_u->ip_w     = u3r_word(0, u3t(host));
    req_u->domain_c = NULL;
  }

  // Extract port number.
  req_u->port_s = u3_nul != port ? u3t(port) : 0;

  // Extract method.
  c3_assert(c3y == u3a_is_atom(method));
  req_u->method_c = u3r_string(method);

  // Extract URL from pul.
  {
    c3_w len_w   = _mcut_url(NULL, 0, u3k(pul));
    req_u->url_c = c3_calloc(len_w + 1);
    _mcut_url(req_u->url_c, 0, u3k(pul));
  }

  // Extract headers.
  {
    c3_w     cap_w     = 4; // starting allocation size
    c3_w     len_w     = 0;
    StrPair* headers_u = c3_malloc(cap_w * sizeof(*headers_u));
    StrPair* header_u  = headers_u;
    while ( u3_nul != headers ) {
      if ( len_w == cap_w ) {
        cap_w    *= 2;
        headers_u = c3_realloc(headers_u, cap_w * sizeof(*headers_u));
        header_u  = headers_u + len_w;
      }
      u3_noun header = u3h(headers);
      u3_noun key = u3h(header);
      u3_noun val = u3t(header);

      c3_w key_len_w = u3r_met(3, key);
      c3_w val_len_w = u3r_met(3, val);

      *header_u = (StrPair){
        .zero_c = c3_calloc(key_len_w + 1),
        .one_c  = c3_calloc(val_len_w + 1),
      };
      u3r_bytes(0, key_len_w, (c3_y*)header_u->zero_c, key);
      u3r_bytes(0, val_len_w, (c3_y*)header_u->one_c, val);

      headers = u3t(headers);
      header_u++;
      len_w++;
    }
    if ( 0 == len_w ) {
      c3_free(headers_u);
      headers_u = NULL;
    }
    req_u->headers_u     = headers_u;
    req_u->headers_len_w = len_w;
  }

  // Extract body.
  if ( u3_nul != body ) {
    u3_noun octet_stream = u3t(body);
    if ( c3n == u3a_is_cat(u3h(octet_stream)) ) { // 2GB max
      u3m_bail(c3__fail);
      goto end;
    }
    c3_w len_w    = u3h(octet_stream);
    req_u->body_c = c3_calloc(len_w + 1);
    u3r_bytes(0, len_w, (c3_y*)req_u->body_c, u3t(octet_stream));
  }

  suc_t = 1;

end:
  return suc_t;
}

static void
_receive_request(void)
{
  // TODO: transform response into nouns, create wire and card, invoke
  // u3_auto_plan()
}

//! Notify that we're live.
static void
_io_talk(u3_auto* driver_u)
{
  Client* client_u = (Client*)driver_u;
  u3_noun     wire = u3nt(u3i_string("http-client"),
                          u3dc("scot", c3__uv, http_client_instance_num(client_u)),
                          u3_nul);
  u3_noun     card = u3nc(c3__born, u3_nul);

  u3_auto_plan(driver_u, u3_ovum_init(0, c3__i, wire, card));
}

//! Apply effects.
static c3_o
_io_kick(u3_auto* driver_u, u3_noun wire, u3_noun card)
{
  c3_o suc_o = c3n;

  u3_noun tag, data, wire_head;
  if ( c3n == u3r_cell(wire, &wire_head, NULL)
       || c3n == u3r_cell(card, &tag, &data)
       || c3n == u3r_sing_c("http-client", wire_head) )
  {
    goto end;
  }

  Client* client_u = (Client*)driver_u;
  if ( c3y == u3r_sing_c("request", tag) ) {
    _request req_u;
    if ( !_parse_request(data, &req_u) ) {
      goto end;
    }
    suc_o = http_schedule_request(client_u,
                                  req_u.req_num_l,
                                  req_u.domain_c,
                                  req_u.ip_w,
                                  req_u.port_s,
                                  req_u.use_tls_t,
                                  req_u.url_c,
                                  req_u.method_c,
                                  req_u.headers_u,
                                  req_u.headers_len_w,
                                  req_u.body_c,
                                  _receive_request)
            ? c3y
            : c3n;
    // TODO: ensure req_u's fields doesn't leak.
  }
  else if ( c3y == u3r_sing_c("cancel-request", tag) ) {
    // TODO: cancel request
    c3_assert(0);
  }
  else {
    u3l_log("cttp: strange effect (unknown type)\n");
  }
  // TODO: verify tag and data aren't leaked.

end:
  u3z(wire);
  u3z(card);
  return suc_o;
}

//! Dispose of the driver.
static void
_io_exit(u3_auto* driver_u)
{
  Client* client_u = (Client*)driver_u;
  http_client_deinit(client_u);
}

//==============================================================================
// Functions
//==============================================================================

u3_auto*
u3_cttp_io_init(u3_pier* pier_u)
{
  c3_w now_mug_w;
  {
    u3_noun now;
    struct timeval time_u;
    gettimeofday(&time_u, 0);

    now = u3_time_in_tv(&time_u);
    now_mug_w = u3r_mug(now);
    u3z(now);
  }
  Client* client_u = http_client_init(now_mug_w);

  u3_auto* driver_u = (u3_auto*)client_u;
  *driver_u = (u3_auto){
    .nam_m = c3__cttp,
    .liv_o = c3y,
    .io.talk_f = _io_talk,
    .io.kick_f = _io_kick,
    .io.exit_f = _io_exit,
  };

  return driver_u;
}
