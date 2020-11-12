use crate::i18n::LocalText;
use crate::make;
use crate::CONFIG;
use colored::Colorize;
use git2::{Repository, Status};
use std::io::prelude::*;
use std::sync::{Arc, RwLock};
use std::{error, fs, io, path, result};
use subprocess::{Exec, NullFile, Redirection};

type Result<T> = result::Result<T, Box<dyn error::Error>>;

// FTL: help-subcommand-setup
/// Setup Fontship for use on a new Font project
pub fn run() -> Result<()> {
    crate::header("setup-header");
    let path = &CONFIG.get_string("path")?;
    let metadata = fs::metadata(&path)?;
    match metadata.is_dir() {
        true => match Repository::open(path) {
            Ok(repo) => {
                regen_gitignore(repo)?;
                configure_short_shas(Repository::open(path)?)?;
                Ok(())
            }
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

/// Evaluate whether this project is properly configured
pub fn is_setup() -> Result<bool> {
    let results = Arc::new(RwLock::new(Vec::new()));

    // First round of tests, entirely independent
    rayon::scope(|s| {
        s.spawn(|_| {
            let ret = is_repo().unwrap();
            results.write().unwrap().push(ret);
        });
        s.spawn(|_| {
            let ret = is_make_exectuable().unwrap();
            results.write().unwrap().push(ret);
        });
    });

    // Second round of tests, dependent on first set
    if results.read().unwrap().iter().all(|&v| v) {
        rayon::scope(|s| {
            s.spawn(|_| {
                let ret = is_writable().unwrap();
                results.write().unwrap().push(ret);
            });
            s.spawn(|_| {
                let ret = is_make_gnu().unwrap();
                results.write().unwrap().push(ret);
            });
        });
    }

    let ret = results.read().unwrap().iter().all(|&v| v);
    let msg = LocalText::new(if ret { "setup-good" } else { "setup-bad" }).fmt();
    eprintln!(
        "{} {}",
        "┠─".cyan(),
        if ret { msg.green() } else { msg.red() }
    );
    Ok(ret)
}

/// Are we in a git repo?
pub fn is_repo() -> Result<bool> {
    let ret = crate::get_repo().is_ok();
    crate::display_check("setup-is-repo", ret);
    Ok(ret)
}

/// Is the git repo we are in writable?
pub fn is_writable() -> Result<bool> {
    let repo = crate::get_repo()?;
    let workdir = repo.workdir().unwrap();
    let testfile = workdir.join(".fontship-write-test");
    let mut file = fs::File::create(&testfile)?;
    file.write_all(b"test")?;
    fs::remove_file(&testfile)?;
    let ret = true;
    crate::display_check("setup-is-writable", ret);
    Ok(true)
}

/// Check if we can execute the system's `make` utility
pub fn is_make_exectuable() -> Result<bool> {
    let ret = Exec::cmd("make")
        .arg("-v")
        .stdout(NullFile)
        .stderr(NullFile)
        .join()
        .is_ok();
    crate::display_check("setup-is-make-executable", ret);
    Ok(true)
}

/// Check that the system's `make` utility is GNU Make
pub fn is_make_gnu() -> Result<bool> {
    let out = Exec::cmd("make")
        .arg("-v")
        .stdout(Redirection::Pipe)
        .stderr(NullFile)
        .capture()?
        .stdout_str();
    let ret = out.starts_with("GNU Make 4.");
    crate::display_check("setup-is-make-gnu", ret);
    Ok(true)
}

fn regen_gitignore(repo: Repository) -> Result<()> {
    let target = vec![String::from(".gitignore")];
    make::run(target)?;
    let path = path::Path::new(".gitignore");
    let mut index = repo.index()?;
    index.add_path(path)?;
    let oid = index.write_tree()?;
    match repo.status_file(path) {
        Ok(Status::CURRENT) => {
            let text = LocalText::new("setup-gitignore-fresh").fmt();
            eprintln!("{} {}", "┠┄".cyan(), text);
            Ok(())
        }
        _ => {
            let text = LocalText::new("setup-gitignore-committing").fmt();
            eprintln!("{} {}", "┠┄".cyan(), text);
            match crate::commit(repo, oid, "Update .gitignore") {
                Ok(_) => {
                    index.write()?;
                    Ok(())
                }
                Err(foo) => Err(Box::new(foo)),
            }
        }
    }
}

fn configure_short_shas(repo: Repository) -> Result<()> {
    let text = LocalText::new("setup-short-shas").fmt();
    eprintln!("{} {}", "┠┄".cyan(), text);
    let mut conf = repo.config()?;
    Ok(conf.set_i32("core.abbrev", 7)?)
}
