#[macro_use]
extern crate lazy_static;

use std::{error, fmt};

pub mod cli;
pub mod config;

// Subcommands
pub mod make;
pub mod setup;
pub mod status;

// Import stuff set by autoconf/automake at build time
pub static CONFIGURE_PREFIX: &'static str = env!["CONFIGURE_PREFIX"];
pub static CONFIGURE_BINDIR: &'static str = env!["CONFIGURE_BINDIR"];
pub static CONFIGURE_DATADIR: &'static str = env!["CONFIGURE_DATADIR"];

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
            details: key.to_string(),
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
