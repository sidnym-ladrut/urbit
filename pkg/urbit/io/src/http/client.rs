use crate::{
    http::{HttpBody, HttpHeader, HttpRequest},
    runtime, Bool,
};
use hyper::{client::HttpConnector, Client};
use std::{collections::HashMap, ffi::CStr, rc::Rc, slice};
use tokio::runtime::Runtime;

//==================================================================================================
// Public
//==================================================================================================

#[repr(C)]
pub struct HttpClient {
    /// Reserved space for the u3_auto handle on the C side.
    driver: [u8; 88],
    runtime: *const Runtime,
    hyper: *const Client<HttpConnector>,
    instance_num: u32,
}

#[no_mangle]
pub extern "C" fn http_client_init(instance_num: u32) -> *mut HttpClient {
    let hyper = Box::new(Client::new());
    let client = Box::new(HttpClient {
        driver: [0; 88],
        runtime: Rc::into_raw(runtime()),
        hyper: Box::into_raw(hyper),
        instance_num,
    });
    Box::into_raw(client)
}

#[no_mangle]
pub extern "C" fn http_schedule_request(client: *mut HttpClient, req: *const HttpRequest) -> Bool {
    let client = unsafe { Box::from_raw(client) };
    let runtime = unsafe { Rc::from_raw(client.runtime) };
    let req = unsafe { &*req };

    runtime.spawn(send_request(req));

    // Prevent these from being dropped.
    Rc::into_raw(runtime);
    Box::into_raw(client);

    Bool::False
}

#[no_mangle]
pub extern "C" fn http_client_deinit(client: *mut HttpClient) {
    // Convert the raw pointers back to smart pointers so that they get dropped.
    let client = unsafe { Box::from_raw(client) };
    let runtime = unsafe { Rc::from_raw(client.runtime) };
    // We could make the `hyper` field of `HttpClient` mutable and avoid this
    // cast, but it doesn't need to be.
    let hyper = unsafe { Box::from_raw(client.hyper as *mut Client<HttpConnector>) };
}

//==================================================================================================
// Private
//==================================================================================================

async fn send_request(req: &HttpRequest) {
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
}
