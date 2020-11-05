use crate::i18n::LocalText;
use crate::make;
use crate::CONFIG;
use git2::Repository;
use std::{error, fs, io, path::Path, result};

type Result<T> = result::Result<T, Box<dyn error::Error>>;

// FTL: help-subcommand-setup
/// Setup Fontship for use on a new Font project
pub fn run() -> Result<()> {
    crate::header("setup-header");
    let path = CONFIG.get_string("path")?;
    let metadata = fs::metadata(&path)?;
    match metadata.is_dir() {
        true => match Repository::open(path) {
            Ok(repo) => regen_gitignore(repo),
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

fn regen_gitignore(repo: Repository) -> Result<()> {
    let target = vec![String::from(".gitignore")];
    make::run(target)?;
    let path = Path::new(".gitignore");
    let mut index = repo.index()?;
    index.add_path(path)?;
    let oid = index.write_tree()?;
    match crate::commit(repo, oid, "Update .gitignore") {
        Ok(_) => {
            index.write()?;
            Ok(())
        }
        Err(foo) => Err(Box::new(foo)),
    }
}
