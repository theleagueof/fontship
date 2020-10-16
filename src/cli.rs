use clap::{AppSettings, Clap};

/// The command line interface to Fontship,
/// A font development toolkit and collaborative work flow.
#[derive(Clap, Debug)]
#[clap(bin_name = "fontship")]
#[clap(setting = AppSettings::InferSubcommands)]
pub struct Cli {
    /// Enable debug mode flags
    #[clap(short, long)]
    pub debug: bool,

    /// Discard all non-error output messages
    #[clap(short, long)]
    pub quiet: bool,

    /// Enable extra verbose output from tooling
    #[clap(short, long)]
    pub verbose: bool,
}
