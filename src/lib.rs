extern crate lazy_static;

pub mod cli;

// Subcommands
pub mod make;
pub mod setup;
pub mod status;

/// Fontship version number as detected by `git describe --tags` at build time
pub static VERSION: &'static str = env!("VERGEN_SEMVER_LIGHTWEIGHT");
