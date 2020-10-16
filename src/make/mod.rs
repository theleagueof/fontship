use std::{error, result};
use subprocess::Exec;

type Result<T> = result::Result<T, Box<dyn error::Error>>;

/// Build specified target(s)
pub fn run(target: Vec<String>) -> Result<()> {
    let process = Exec::cmd("make").args(&target);
    process.join()?;
    Ok(())
}
