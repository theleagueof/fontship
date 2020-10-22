#[macro_use]
extern crate lazy_static;

use crate::config::CONFIG;
use colored::Colorize;
use i18n::LocalText;
use std::{error, fmt};

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

/// Relay STDOUT/STDERR streams from internal commands
pub fn show_line(line: String) {
    eprintln!("{} {}", "┃ ".cyan(), line);
}

pub fn show_start(line: &str) {
    eprintln!("{} Start making {}", "┃ ".cyan(), line.yellow());
}

pub fn show_end(line: &str) {
    eprintln!("{} Finish making {}", "┃ ".cyan(), line.blue());
}

pub fn show_err(line: &str) {
    eprintln!(
        "{} Error making {}, dumping output:",
        "┃ ".cyan(),
        line.red()
    );
}
