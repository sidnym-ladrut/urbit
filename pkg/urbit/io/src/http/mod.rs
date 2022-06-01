use std::collections::HashMap;

mod client;

// Public
//==================================================================================================
// Private

/// HTTP request.
struct Request {
    domain: Option<String>,
    ip: Option<u32>,
    port: u16,
    use_tls: bool,
    url: String,
    method: String,
    headers: Option<HashMap<String, String>>,
    body: Option<String>,
}

/// Callback to handle response to HTTP request.
type Receiver = extern "C" fn();
