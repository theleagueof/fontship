use clap::{AppSettings, Clap};
use std::path;

/// The command line interface to Fontship,
/// A font development toolkit and collaborative work flow.
#[derive(Clap, Debug)]
#[clap(bin_name = "fontship")]
#[clap(setting = AppSettings::InferSubcommands)]
pub struct Cli {
    /// Enable extra debug output from tooling
    #[clap(short, long)]
    pub debug: bool,

    /// Set language
    #[clap(short, long, env = "LANG")]
    pub language: Option<String>,

    /// Discard all non-error output messages
    #[clap(short, long)]
    pub quiet: bool,

    /// Enable extra verbose output from tooling
    #[clap(short, long)]
    pub verbose: bool,

    #[clap(subcommand)]
    pub subcommand: Subcommand,
}

#[derive(Clap, Debug)]
pub enum Subcommand {
    /// Build specified target(s) with `make`
    Make {
        /// Target as defined in Fontship or project rules
        target: Vec<String>,
    },

    /// Configure a font project repository
    Setup {
        /// Path to project repository
        #[clap(default_value = "./")]
        path: path::PathBuf,
    },

    /// Show information about setup and build status
    Status {},
}
