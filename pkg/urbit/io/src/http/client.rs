use crate::{
    cstr_to_str,
    Bool, StrPair, RUNTIME,
};
use hyper;
use std::slice;

const U3_AUTO_SIZE: usize = 88;

/// Callback to handle response to HTTP request.
type Receiver = extern "C" fn(
    status: u32,
    headers: *const StrPair,
    headers_len: u32,
    body: *const u8,
    body_len: u32,
);

#[repr(C)]
pub struct Client {
    /// Reserved space for the u3_auto handle on the C side. Must be the first field of the struct.
    driver: [u8; U3_AUTO_SIZE],
    hyper: hyper::Client<hyper::client::HttpConnector>,
    instance_num: u32,
}

#[no_mangle]
pub extern "C" fn http_client_init(instance_num: u32) -> *mut Client {
    let client = Box::new(Client {
        driver: [0; U3_AUTO_SIZE],
        hyper: hyper::Client::new(),
        instance_num,
    });
    Box::into_raw(client)
}

#[no_mangle]
pub extern "C" fn http_client_instance_num(client: *const Client) -> u32 {
    if client.is_null() {
        0
    } else {
        unsafe { (*client).instance_num }
    }
}

#[no_mangle]
pub extern "C" fn http_schedule_request(
    client: *mut Client,
    req_num: u32,
    domain: *const u8,
    ip: u32,
    port: u16,
    use_tls: Bool,
    url: *const u8,
    method: *const u8,
    headers: *const StrPair,
    headers_len: u32,
    body: *const u8,
    receiver: Receiver,
) -> Bool {
    if client.is_null() {
        return Bool::False;
    }
    let client = unsafe { Box::from_raw(client) };

    let req = {
        let use_tls: bool = use_tls.into();
        let uri = {
            let prefix = "http://";
            let url = cstr_to_str(url).unwrap_or("/");
            if let Some(domain) = cstr_to_str(domain) {
                format!("{}{}:{}{}", prefix, domain, port, url)
            } else {
                format!("{}{}:{}{}", prefix, ip, port, url)
            }
        };
        let method = cstr_to_str(method).expect("method could not be converted");

        let mut req = hyper::Request::builder().uri(uri).method(method);

        if headers_len > 0 {
            let headers = unsafe { slice::from_raw_parts(headers, headers_len as usize) };
            for header in headers {
                let key = cstr_to_str(header.0).expect("header key could not be converted");
                let val = cstr_to_str(header.1).expect("header val could not be converted");
                req = req.header(key, val);
            }
        }

        let body = hyper::Body::from(cstr_to_str(body).unwrap_or(""));
        req.body(body).expect("request could not be compiled")
    };

    let req_fut = client.hyper.request(req);
    RUNTIME.spawn(send_request(req_fut, receiver));

    Bool::False
}

#[no_mangle]
pub extern "C" fn http_client_deinit(client: *mut Client) {
    if !client.is_null() {
        unsafe { Box::from_raw(client) };
    }
}

async fn send_request(req_fut: hyper::client::ResponseFuture, receiver: Receiver) {
    let resp = req_fut.await;
    if let Err(err) = resp {
        panic!("response error");
    }
    let resp = resp.unwrap();

    // receiver needs:
    // - status code as u32
    // - headers as StrPair array
    // - number of headers
    // - body as byte array
    // - length of body in bytes
}
