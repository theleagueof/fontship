use std::{error, result};

type Result<T> = result::Result<T, Box<dyn error::Error>>;

/// Setup Fontship for use on a new Font project
pub fn run() -> Result<()> {
    crate::header("setup-header");
    Ok(())
}
