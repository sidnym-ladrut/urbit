#[no_mangle]
pub extern "C" fn hello_world() {
    println!("hello world");
}

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        let result = 2 + 2;
        assert_eq!(result, 4);
    }
}
