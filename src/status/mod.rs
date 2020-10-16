use std::{error, result};

type Result<T> = result::Result<T, Box<dyn error::Error>>;

/// Show information about setup and build status
pub fn run() -> Result<()> {
    crate::header("status-header");
    Ok(())
}
