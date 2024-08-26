use clap::{Args, Subcommand};
use std::path;

// FTL: help-description
/// The command line interface to Fontship,
/// a font development toolkit and collaborative work flow.
#[derive(Args, Debug)]
#[clap(author)]
pub struct Cli {
    // FTL: help-flags-debug
    /// Enable extra debug output from tooling
    #[clap(short, long)]
    pub debug: bool,

    // FTL: help-flags-language
    /// Set language
    #[clap(short, long)]
    pub language: Option<String>,

    // FTL: help-flag-passthrough
    /// Eschew all UI output and just pass the subprocess output through
    #[clap(short, long)]
    pub passthrough: bool,

    // FTL: help-flags-path
    /// Set project root path
    #[clap(short = 'P', long, default_value = "./", value_hint = clap::ValueHint::DirPath)]
    pub project: path::PathBuf,

    // FTL: help-flags-quiet
    /// Discard all non-error output messages
    #[clap(short, long)]
    pub quiet: bool,

    // FTL: help-flags-verbose
    /// Enable extra verbose output from tooling
    #[clap(short, long)]
    pub verbose: bool,

    #[clap(subcommand)]
    pub subcommand: Commands,
}

#[derive(Subcommand, Debug)]
pub enum Commands {
    // FTL: help-subcommand-make
    /// Build specified target(s) with ‘make’
    Make {
        // FTL: help-subcommand-make-target
        /// Target as defined in Fontship or project rules
        #[clap(value_hint = clap::ValueHint::AnyPath)]
        target: Vec<String>,
    },

    // FTL: help-subcommand-setup
    /// Configure a font project repository
    Setup {},

    // FTL: help-subcommand-status
    /// Show status information about setup, configuration, and build state
    Status {},
}
