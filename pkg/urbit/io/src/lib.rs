use std::rc::Rc;
use tokio::runtime::{Builder, Runtime};

mod http;

//==================================================================================================
// Public
//==================================================================================================

/// FFI-safe boolean type.
#[derive(Debug)]
#[repr(u8)]
pub enum Bool {
    False = 0,
    True = 1,
}

//==================================================================================================
// Private
//==================================================================================================

/// Tokio runtime shared by all IO drivers. That this requires a global variable is an unfortunate
/// side effect of the entry point to the Urbit runtime remaining in C, which prevents us from
/// using a `#[tokio::main]` decorated main function.
static mut RT: Option<Rc<Runtime>> = None;

/// Get the Tokio runtime shared by all IO drivers.
fn runtime() -> Rc<Runtime> {
    if unsafe { RT.is_none() } {
        match Builder::new_multi_thread()
            .worker_threads(1)
            .enable_all()
            .build()
        {
            Ok(runtime) => {
                let runtime = Some(Rc::new(runtime));
                unsafe { RT = runtime };
            }
            // TODO: log error if attempt to build runtime fails.
            Err(_) => panic!(),
        }
    }
    let runtime = unsafe { RT.as_ref().unwrap() };
    Rc::clone(runtime)
}
