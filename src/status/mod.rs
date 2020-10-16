use std::{error, result};

type Result<T> = result::Result<T, Box<dyn error::Error>>;

// FTL: help-subcommand-status
/// Show status information about setup, configuration, and build state
pub fn run() -> Result<()> {
    crate::header("status-header");
    Ok(())
}
