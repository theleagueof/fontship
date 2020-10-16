use crate::CONFIG;
use std::{error, result};
use subprocess::Exec;

type Result<T> = result::Result<T, Box<dyn error::Error>>;

/// Build specified target(s)
pub fn run(target: Vec<String>) -> Result<()> {
    crate::header("make-header");
    let mut process = Exec::cmd("make").args(&target);
    if CONFIG.get_bool("debug")? {
        process = process.env("DEBUG", "true");
    };
    if CONFIG.get_bool("quiet")? {
        process = process.env("QUIET", "true");
    };
    if CONFIG.get_bool("verbose")? {
        process = process.env("VERBOSE", "true");
    };
    process.join()?;
    Ok(())
}
