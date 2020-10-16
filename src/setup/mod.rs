use crate::i18n::LocalText;
use git2::Repository;
use std::{error, fs, io, path, result};

type Result<T> = result::Result<T, Box<dyn error::Error>>;

/// Setup Fontship for use on a new Font project
pub fn run(path: path::PathBuf) -> Result<()> {
    crate::header("setup-header");
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
