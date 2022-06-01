#[macro_use]
extern crate lazy_static;

use std::os::raw::c_char;
use tokio::runtime;

mod http;

/// FFI-safe boolean type.
#[derive(Debug)]
#[repr(u8)]
pub enum Bool {
    False = 0,
    True = 1,
}

impl From<bool> for Bool {
    fn from(b: bool) -> Self {
        if b {
            Self::True
        } else {
            Self::False
        }
    }
}

impl From<Bool> for bool {
    fn from(b: Bool) -> Self {
        match b {
            Bool::True => true,
            Bool::False => false,
        }
    }
}

/// FFI-safe tuple type.
#[repr(C)]
pub struct StrPair(*const c_char, *const c_char);

// Public
//==================================================================================================
// Private

lazy_static! {
    /// IMPORTANT: we can't use a multi-thread runtime here because of the callback model used by
    /// the HTTP client.
    static ref RUNTIME: runtime::Runtime = runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .unwrap();
}

fn cstr_to_string(string: *const c_char) -> Option<String> {
    use std::ffi::CStr;
    if string.is_null() {
        None
    } else {
        let string = unsafe { CStr::from_ptr(string) };
        let string = string.to_str().ok()?;
        Some(String::from(string))
    }
}
