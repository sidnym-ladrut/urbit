#[macro_use]
extern crate lazy_static;

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
pub struct StrPair(*const u8, *const u8);

lazy_static! {
    /// IMPORTANT: we can't use a multi-thread runtime here because of the callback model used by
    /// the HTTP client.
    static ref RUNTIME: tokio::runtime::Runtime = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .unwrap();
}

/// `string` must be NULL-terminated.
fn cstr_to_str(string: *const u8) -> Option<&'static str> {
    use std::ffi::CStr;
    if string.is_null() {
        None
    } else {
        unsafe { CStr::from_ptr(string as *const i8).to_str().ok() }
    }
}
