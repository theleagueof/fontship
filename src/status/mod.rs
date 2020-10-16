use crate::i18n::LocalText;
use git2::Repository;
use std::{error, fs, io, path, result};

type Result<T> = result::Result<T, Box<dyn error::Error>>;

/// Show information about setup and build status
pub fn run(path: path::PathBuf) -> Result<()> {
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
