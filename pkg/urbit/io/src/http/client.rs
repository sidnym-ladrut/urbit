use crate::{
    cstr_to_str,
    http::{Receiver, Request},
    Bool, StrPair, RUNTIME,
};
use hyper;
use std::{collections::HashMap, os::raw::c_char, slice};
use tokio;

const U3_AUTO_SIZE: usize = 88;

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
    domain: *const c_char,
    ip: u32,
    port: u16,
    use_tls: Bool,
    url: *const c_char,
    method: *const c_char,
    headers: *const StrPair,
    headers_len: u32,
    body: *const c_char,
    receiver: Receiver,
) -> Bool {
    if client.is_null() {
        return Bool::False;
    }
    let mut client = unsafe { Box::from_raw(client) };

    let req = {
        let use_tls: bool = use_tls.into();
        let uri = {
            let prefix = "http://";
            if let Some(domain) = cstr_to_str(domain) {
                format!("{}{}", prefix, domain)
            } else {
                format!("{}{}:{}", prefix, ip, port)
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

        let body = cstr_to_str(body).unwrap_or("");
        req.body(body).expect("request could not be compiled")
    };

    /*
    let domain = cstr_to_string(domain);
    let ip = if domain.is_some() { None } else { Some(ip) };
    let use_tls = use_tls.into();
    let url = cstr_to_string(url).unwrap();
    let method = cstr_to_string(method).unwrap();
    let headers = if headers_len > 0 {
        let headers = unsafe { slice::from_raw_parts(headers, headers_len as usize) };
        let mut map = HashMap::new();
        for header in headers {
        let key = cstr_to_string(header.0).unwrap();
            let val = cstr_to_string(header.1).unwrap();
            map.insert(key, val);
        }
        Some(map)
    } else {
        None
    };
    let body = cstr_to_string(body);
    */
    Bool::False
}

#[no_mangle]
pub extern "C" fn http_client_deinit(client: *mut Client) {
    if !client.is_null() {
        unsafe { Box::from_raw(client) };
    }
}

async fn send_request(client: Box<Client>, req_num: u32) {
    Box::into_raw(client);
}
