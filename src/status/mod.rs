use crate::i18n::LocalText;
use crate::CONFIG;
use colored::{ColoredString, Colorize};
use git2::{DescribeFormatOptions, DescribeOptions, Repository};
use regex::Regex;
use std::io::prelude::*;
use std::sync::{Arc, RwLock};
use std::{env, error, fs, path, result};
use subprocess::{Exec, NullFile, Redirection};

type Result<T> = result::Result<T, Box<dyn error::Error>>;

// FTL: help-subcommand-status
/// Show status information about setup, configuration, and build state
pub fn run() -> Result<()> {
    crate::header("status-header");
    CONFIG.set_bool("verbose", true)?;
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
        "┠─".cyan(),
        if ret { msg.green() } else { msg.red() }
    );
    Ok(ret)
}

/// Are we in a git repo?
pub fn is_repo() -> Result<bool> {
    let ret = get_repo().is_ok();
    display_check("status-is-repo", ret);
    Ok(ret)
}

/// Is the git repo we are in writable?
pub fn is_writable() -> Result<bool> {
    let repo = get_repo()?;
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

/// Figure out if we're running inside Docker or another container
pub fn is_container() -> bool {
    let dockerenv = path::Path::new("/.dockerenv");
    dockerenv.exists()
}

/// Get repository object
pub fn get_repo() -> Result<Repository> {
    let path = CONFIG.get_string("path")?;
    Ok(Repository::discover(path)?)
}

pub fn get_gitname() -> Result<String> {
    fn origin() -> Result<String> {
        let repo = get_repo()?;
        let remote = repo.find_remote("origin")?;
        let url = remote.url().unwrap();
        let re = Regex::new(r"^(.*/)([^/]+)(/?\.git/?)$").unwrap();
        let name = re
            .captures(url)
            .ok_or(crate::Error::new("error-no-remote"))?
            .get(2)
            .ok_or(crate::Error::new("error-no-remote"))?
            .as_str();
        Ok(String::from(name))
    }
    fn path() -> Result<String> {
        let path = &CONFIG.get_string("path")?;
        let file = path::Path::new(path)
            .file_name()
            .ok_or(crate::Error::new("error-no-path"))?
            .to_str();
        Ok(file.unwrap().to_string())
    }
    let default = Ok(String::from("fontship"));
    origin().or(path().or(default))
}

/// Scan for existing makefiles with Fontship rules
pub fn get_rules() -> Result<Vec<path::PathBuf>> {
    let repo = get_repo()?;
    let root = repo.workdir().unwrap();
    let files = vec!["GNUMakefile", "makefile", "Makefile", "rules.mk"];
    let mut rules = Vec::new();
    for file in &files {
        let p = root.join(file);
        if p.exists() {
            rules.push(p);
        }
    }
    Ok(rules)
}

/// Scan for sources
pub fn get_sources() -> Result<Vec<path::PathBuf>> {
    let repo = get_repo()?;
    let index = repo.index()?;
    let mut sources = vec![];
    let sourcedir = CONFIG.get_string("sourcedir")?;
    let sourcedir = path::Path::new(&sourcedir);
    let sourceexts = Regex::new(r"\.(sfd|glyphs|designspace)$").unwrap();
    let ufoexts = Regex::new(r"\.ufo$").unwrap();
    for entry in index.iter() {
        let rawpath = &entry.path;
        let path = crate::bytes2path(rawpath);
        if !path.exists() {
            continue;
        }
        if let Ok(part) = path.strip_prefix(&sourcedir) {
            let mut components = part.components();
            if let Some(path::Component::Normal(name)) = components.next() {
                let n = name.to_str().unwrap().clone();
                if let Some(_) = sourceexts.find(n) {
                    sources.push(path.to_path_buf());
                } else if let Some(_) = ufoexts.find(n) {
                    let mut p = sourcedir.to_path_buf();
                    p.push(name);
                    sources.push(p);
                }
            }
        }
    }
    sources.dedup();
    Ok(sources)
}

/// Figure out version string from repo tags
pub fn get_git_version() -> String {
    let zero_version = String::from("0.000");
    let repo = get_repo().unwrap();
    let mut opts = DescribeOptions::new();
    opts.describe_tags().pattern("*[0-9].[0-9][0-9][0-9]");
    let desc = match repo.describe(&opts) {
        Ok(a) => {
            let mut fmt = DescribeFormatOptions::new();
            fmt.abbreviated_size(7).always_use_long_format(true);
            a.format(Some(&fmt)).unwrap()
        }
        Err(_) => {
            let head = repo.revparse("HEAD").unwrap();
            let mut revwalk = repo.revwalk().unwrap();
            revwalk.push_head().unwrap();
            let ahead = revwalk.count();
            let sha = head.from().unwrap().short_id().unwrap();
            format!("{}-{}-g{}", zero_version, ahead, sha.as_str().unwrap())
        }
    };
    let prefix = Regex::new(r"^v").unwrap();
    let sep = Regex::new(r"-").unwrap();
    String::from(sep.replace(&prefix.replace(desc.as_str(), ""), "-r"))
}

fn display_check(key: &str, val: bool) {
    if CONFIG.get_bool("debug").unwrap() || CONFIG.get_bool("verbose").unwrap() {
        eprintln!(
            "{} {} {}",
            "┠─".cyan(),
            LocalText::new(key).fmt(),
            fmt_t_f(val)
        );
    };
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
