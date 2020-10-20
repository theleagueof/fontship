use crate::i18n::LocalText;
use crate::CONFIG;
use git2::Repository;
use std::{error, fs, io, result};

type Result<T> = result::Result<T, Box<dyn error::Error>>;

// FTL: help-subcommand-setup
/// Setup Fontship for use on a new Font project
pub fn run() -> Result<()> {
    crate::header("setup-header");
    let path = CONFIG.get_string("path")?;
    let metadata = fs::metadata(&path)?;
    match metadata.is_dir() {
        true => match Repository::open(path) {
            // TODO: check that repo root is input path
            Ok(_repo) => Ok(()),
            Err(_error) => Err(Box::new(io::Error::new(
                io::ErrorKind::InvalidInput,
                LocalText::new("setup-error-not-git").fmt(),
            ))),
        },
        false => Err(Box::new(io::Error::new(
            io::ErrorKind::InvalidInput,
            LocalText::new("setup-error-not-dir").fmt(),
        ))),
    }
}
