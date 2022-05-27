use crate::{runtime, Bool};
use std::{collections::HashMap, ffi::CStr, os::raw::c_char, rc::Rc, slice};
use tokio::runtime::Runtime;

#[repr(C)]
pub struct HttpClient {
    /// Reserved space for the u3_auto handle on the C side.
    driver: [u8; 88],
    runtime: *const Runtime,
    instance_num: u32,
}

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

#[repr(C)]
pub struct HttpHeader {
    key: *const c_char,
    val: *const c_char,
}

#[repr(C)]
pub struct HttpBody(*const c_char);

async fn send_request(/*req: &HttpRequest*/) {
    /*
    let domain = if let Some(domain) = req.domain {
        let domain = unsafe { CStr::from_ptr(domain).to_str().unwrap() };
    } else {
        unimplemented!();
    };

    let url = if let Some(url) = req.url {
        let url = unsafe { CStr::from_ptr(url).to_str().unwrap() };
    } else {
        unimplemented!();
    };

    let method = if let Some(method) = req.method {
        let method = unsafe { CStr::from_ptr(method).to_str().unwrap() };
    } else {
        unimplemented!();
    };

    let headers = if let Some(headers) = req.headers {
        let headers = unsafe { slice::from_raw_parts(headers, req.headers_len as usize) };
        let mut map = HashMap::new();
        for header in headers {
            let key = unsafe { CStr::from_ptr(header.key).to_str().unwrap() };
            let val = unsafe { CStr::from_ptr(header.val).to_str().unwrap() };
            assert_eq!(map.insert(key, val), None);
        }
        map
    } else {
        unimplemented!();
    };

    let body = if let Some(body) = req.body {
        let body = unsafe { CStr::from_ptr((*body).0).to_str().unwrap() };
    } else {
        unimplemented!();
    };
    */
}

#[no_mangle]
pub extern "C" fn http_client_init(instance_num: u32) -> *mut HttpClient {
    let client = Box::new(HttpClient {
        driver: [0; 88],
        runtime: Rc::into_raw(runtime()),
        instance_num,
    });
    Box::into_raw(client)
}

#[no_mangle]
pub extern "C" fn http_schedule_request(client: *mut HttpClient, req: *const HttpRequest) -> Bool {
    let client = unsafe { Box::from_raw(client) };
    let runtime = unsafe { Rc::from_raw(client.runtime) };
    let req = unsafe { &*req };

    runtime.spawn(send_request(/*req*/));

    Box::into_raw(client);
    Bool::False
}

#[no_mangle]
pub extern "C" fn http_client_deinit(client: *mut HttpClient) {
    unsafe {
        Box::from_raw(client);
    }
}
