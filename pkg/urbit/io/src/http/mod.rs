use crate::Bool;
use std::os::raw::c_char;

mod client;

//==================================================================================================
// Public
//==================================================================================================

#[repr(C)]
pub struct HttpHeader {
    key: *const c_char,
    val: *const c_char,
}

#[repr(C)]
pub struct HttpBody(*const c_char);

#[repr(C)]
pub struct HttpRequest {
    req_num: u32,
    domain: Option<*const c_char>,
    ip: u32,
    port: u16,
    use_tls: Bool,
    url: Option<*const c_char>,
    method: Option<*const c_char>,
    headers: Option<*const HttpHeader>,
    headers_len: u32,
    body: Option<*const HttpBody>,
}

// TODO: verify, but it should be fine for HttpRequest to be Sync (i.e. references shared between
// threads) because we'll never mutate the request.
unsafe impl Sync for HttpRequest {}
