use clap::{AppSettings, Clap};
use std::path;

// FTL: help-description
/// The command line interface to Fontship,
/// A font development toolkit and collaborative work flow.
#[derive(Clap, Debug)]
#[clap(bin_name = "fontship")]
#[clap(setting = AppSettings::InferSubcommands)]
pub struct Cli {
    // FTL: help-flags-debug
    /// Enable extra debug output from tooling
    #[clap(short, long)]
    pub debug: bool,

    // FTL: help-flags-language
    /// Set language
    #[clap(short, long, env = "LANG")]
    pub language: Option<String>,

    // FTL: help-flags-path
    /// Set project root path
    #[clap(short, long, default_value = "./")]
    pub path: path::PathBuf,

    // FTL: help-flags-quiet
    /// Discard all non-error output messages
    #[clap(short, long)]
    pub quiet: bool,

    // FTL: help-flags-verbose
    /// Enable extra verbose output from tooling
    #[clap(short, long)]
    pub verbose: bool,

    #[clap(subcommand)]
    pub subcommand: Subcommand,
}

#[derive(Clap, Debug)]
pub enum Subcommand {
    // FTL: help-subcommand-make
    /// Build specified target(s) with ‘make’
    Make {
        /// Target as defined in Fontship or project rules
        target: Vec<String>,
    },

    // FTL: help-subcommand-setup
    /// Configure a font project repository
    Setup {},

    // FTL: help-subcommand-status
    /// Show status information about setup, configuration, and build state
    Status {},
}
