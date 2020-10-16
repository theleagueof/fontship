use crate::i18n::LocalText;
use colored::{ColoredString, Colorize};
use git2::Repository;
use std::io::prelude::*;
use std::sync::{Arc, RwLock};
use std::{env, error, fs, result};
use subprocess::{Exec, NullFile, Redirection};

type Result<T> = result::Result<T, Box<dyn error::Error>>;

// FTL: help-subcommand-status
/// Show status information about setup, configuration, and build state
pub fn run() -> Result<()> {
    crate::header("status-header");
    is_setup()?;
    Ok(())
}

#[allow(dead_code)]
#[derive(Debug)]
enum RunAsMode {
    RunAsSubmodule,
    RunAsDirectory,
    RunAsDocker,
    RunAsRunner,
    RunAsSystem,
}

#[allow(dead_code)]
/// Determine the runtime mode
fn run_as() -> RunAsMode {
    RunAsMode::RunAsDocker {}
}

/// Check to see if we're running in GitHub Actions
pub fn is_gha() -> Result<bool> {
    let ret = match env::var("GITHUB_ACTIONS") {
        Ok(_) => true,
        Err(_) => false,
    };
    display_check("status-is-gha", ret);
    Ok(ret)
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
    let msg = LocalText::new(if ret { "status-good" } else { "status-bad" }).fmt();
    eprintln!(
        "{} {}",
        "┗━".cyan(),
        if ret { msg.green() } else { msg.red() }
    );
    Ok(ret)
}

/// Are we in a git repo?
pub fn is_repo() -> Result<bool> {
    let cwd = env::current_dir()?;
    let ret = Repository::discover(cwd).is_ok();
    display_check("status-is-repo", ret);
    Ok(ret)
}

/// Is the git repo we are in writable?
pub fn is_writable() -> Result<bool> {
    let cwd = env::current_dir()?;
    let repo = Repository::discover(cwd)?;
    let workdir = repo.workdir().unwrap();
    let testfile = workdir.join(".fontship-write-test");
    let mut file = fs::File::create(&testfile)?;
    file.write_all(b"test")?;
    fs::remove_file(&testfile)?;
    let ret = true;
    display_check("status-is-writable", ret);
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
    display_check("status-is-make-executable", ret);
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
    display_check("status-is-make-gnu", ret);
    Ok(true)
}

fn display_check(key: &str, val: bool) {
    eprintln!(
        "{} {} {}",
        "┠─".cyan(),
        LocalText::new(key).fmt(),
        fmt_t_f(val)
    );
}

/// Format a localized string just for true / false status prints
fn fmt_t_f(val: bool) -> ColoredString {
    let key = if val { "status-true" } else { "status-false" };
    let text = LocalText::new(key).fmt();
    if val {
        text.green()
    } else {
        text.red()
    }
}
