#[macro_use]
extern crate lazy_static;
extern crate num_cpus;

use crate::config::CONFIG;
use colored::Colorize;
use git2::{Oid, Repository, Signature};
use i18n::LocalText;
use inflector::Inflector;
use regex::Regex;
use std::ffi::OsStr;
use std::{error, fmt, path, result, str};

pub mod cli;
pub mod config;
pub mod i18n;

// Subcommands
pub mod make;
pub mod setup;
pub mod status;

// Import stuff set by autoconf/automake at build time
pub static CONFIGURE_PREFIX: &'static str = env!["CONFIGURE_PREFIX"];
pub static CONFIGURE_BINDIR: &'static str = env!["CONFIGURE_BINDIR"];
pub static CONFIGURE_DATADIR: &'static str = env!["CONFIGURE_DATADIR"];

/// If all else fails, use this BCP-47 locale
pub static DEFAULT_LOCALE: &'static str = "en-US";

/// Fontship version number as detected by `git describe --tags` at build time
pub static VERSION: &'static str = env!("VERGEN_SEMVER_LIGHTWEIGHT");

/// A type for our internal whoops
#[derive(Debug)]
pub struct Error {
    details: String,
}

impl Error {
    pub fn new(key: &str) -> Error {
        Error {
            details: LocalText::new(key).fmt(),
        }
    }
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self.details)
    }
}

impl error::Error for Error {
    fn description(&self) -> &str {
        &self.details
    }
}

pub fn pname(input: &str) -> String {
    let seps = Regex::new(r"[-_]").unwrap();
    let spaces = Regex::new(r" ").unwrap();
    let title = seps.replace(input, " ").to_title_case();
    spaces.replace(&title, "").to_string()
}

pub fn commit(repo: Repository, oid: Oid, msg: &str) -> result::Result<Oid, git2::Error> {
    let prefix = "[fontship]";
    let commiter = repo.signature()?;
    let author = Signature::now("Fontship", commiter.email().unwrap())?;
    let parent = repo.head()?.peel_to_commit()?;
    let tree = repo.find_tree(oid)?;
    let parents = [&parent];
    repo.commit(
        Some("HEAD"),
        &author,
        &commiter,
        &[prefix, msg].join(" "),
        &tree,
        &parents,
    )
}

pub fn format_font_version(version: String) -> String {
    let re = Regex::new(r"-r.*$").unwrap();
    String::from(re.replace(version.as_str(), ""))
}

pub fn format_meta_version(version: String) -> String {
    let re = Regex::new(r"-\d+-g").unwrap();
    let a = re.replace(version.as_str(), ";[");
    String::from(a + "]")
}

/// Output welcome header at start of run before moving on to actual commands
pub fn show_welcome() {
    let welcome = LocalText::new("welcome").arg("version", VERSION);
    eprintln!("{} {}", "┏━".cyan(), welcome.fmt().cyan());
}

/// Output welcome header at start of run before moving on to actual commands
pub fn show_outro() {
    let outro = LocalText::new("outro");
    eprintln!("{} {}", "┗━".cyan(), outro.fmt().cyan());
}

/// Output header before starting work on a subcommand
pub fn header(key: &str) {
    let text = LocalText::new(key);
    eprintln!("{} {}", "┣━".cyan(), text.fmt().yellow());
}

#[cfg(unix)]
pub fn bytes2path(b: &[u8]) -> &path::Path {
    use std::os::unix::prelude::*;
    path::Path::new(OsStr::from_bytes(b))
}
#[cfg(windows)]
pub fn bytes2path(b: &[u8]) -> &path::Path {
    use std::str;
    path::Path::new(str::from_utf8(b).unwrap())
}
