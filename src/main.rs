use clap::{FromArgMatches, IntoApp};
use fontship::cli::{Cli, Subcommand};
use fontship::setup;
use fontship::VERSION;
use std::error;

fn main() -> Result<(), Box<dyn error::Error>> {
    let app = Cli::into_app().version(VERSION);
    let matches = app.get_matches();
    let args = Cli::from_arg_matches(&matches);
    match args.subcommand {
        Subcommand::Setup {} => setup::run(),
    }
}
